const TARGET_CONTEXT = 'mahabhut2537.rem0.saturday';

const within = (age, period) => {
  const match = String(period).match(/^(\d+)-(\d+)$/u);
  return Boolean(match && age >= Number(match[1]) && age <= Number(match[2]));
};

export function selectSemanticSignals(input, ledger) {
  if (input.birthTimeMode !== 'known' || input.contextId !== TARGET_CONTEXT) return [];
  return ledger.sourceSignals.filter((signal) => signal.semanticRecord && (
    within(input.age, signal.period) ||
    (signal.period === '42-43|61-62' && (within(input.age, '42-43') || within(input.age, '61-62')))
  ));
}

const readerTextBySignal = {
  'T0003-SRC-0-10-FAMILY-CONSTRAINT': 'ช่วงอายุ 0–10 ปี พ่อแม่มีปัญหาสุขภาพ การงานไม่ราบรื่น และการเงินติดขัดในเวลาเดียวกัน',
  'T0003-SRC-11-62-RISING-BLOCK': 'ช่วงอายุ 11–62 ปี ชีวิตอยู่ในช่วงที่ดีขึ้นโดยรวม',
  'T0003-SRC-42-62-SUPPORT': 'ช่วงอายุ 42–62 ปี คุณได้รับความช่วยเหลือจากครู ผู้มีประสบการณ์ เพื่อน และคนรอบตัว',
  'T0003-SRC-42-62-WORK': 'ช่วงอายุ 42–62 ปี คุณมีงานให้ทำ',
  'T0003-SRC-42-62-FINANCE': 'ช่วงอายุ 42–62 ปี คุณมีเงินใช้และมีโชคลาภ',
  'T0003-SRC-42-62-FLOW': 'ช่วงอายุ 42–62 ปี การลงมือ พูดคุย และคิดตัดสินใจราบรื่นขึ้น',
  'T0003-SRC-42-43-61-62-EXCEPTION': 'ช่วงอายุ 42–43 และ 61–62 ปี สิ่งที่ได้มาอาจอยู่ไม่นาน และต้องระวังคำพูด',
};

const domainBySignal = {
  'T0003-SRC-0-10-FAMILY-CONSTRAINT': 'family',
  'T0003-SRC-11-62-RISING-BLOCK': 'life_direction',
  'T0003-SRC-42-62-SUPPORT': 'support',
  'T0003-SRC-42-62-WORK': 'work',
  'T0003-SRC-42-62-FINANCE': 'finance',
  'T0003-SRC-42-62-FLOW': 'communication',
  'T0003-SRC-42-43-61-62-EXCEPTION': 'finance',
};

export function decideClaims(input, selectedSignals) {
  if (input.birthTimeMode !== 'known') return { tierOutcome: 'D', claims: [], conflictResult: 'INSUFFICIENT_BIRTH_TIME_FAIL_CLOSED' };
  const predictive = selectedSignals.filter((signal) => ['SOURCE_DIRECT_EVENT', 'SOURCE_DIRECT_TREND'].includes(signal.signalType));
  const hasException = predictive.some((signal) => signal.signalId === 'T0003-SRC-42-43-61-62-EXCEPTION');
  const claims = predictive
    .filter((signal) => !(hasException && signal.signalId === 'T0003-SRC-42-62-FINANCE'))
    .map((signal) => ({
      generatedFromSignalId: signal.signalId,
      ruleId: signal.signalType === 'SOURCE_DIRECT_EVENT' ? 'OR4-A-DIRECT-EVENT' : 'OR4-B-DIRECT-TREND',
      authorityTier: signal.signalType === 'SOURCE_DIRECT_EVENT' ? 'A' : 'B',
      fullReaderText: readerTextBySignal[signal.signalId],
      domain: domainBySignal[signal.signalId],
      period: signal.period.includes('|') ? (input.age <= 43 ? '42-43' : '61-62') : signal.period,
      polarity: signal.polarity,
      timingGranularity: 'LIFE_PERIOD',
      signalRefs: [signal.signalId],
      evidenceOwnerIds: [signal.evidenceOwnerId],
      independentSignalCount: 1,
      conflictResult: hasException ? 'NARROWED' : 'NONE',
      containsCausalWording: false,
      readerStrength: signal.signalType === 'SOURCE_DIRECT_EVENT' ? 'DIRECT_EVENT' : 'DIRECTION',
      classification: 'PREDICTION',
      semanticMotifs: [signal.evidenceOwnerId],
    }));
  const tierOutcome = claims.some((claim) => claim.authorityTier === 'A') ? 'A' : claims.some((claim) => claim.authorityTier === 'B') ? 'B' : 'D';
  return { tierOutcome, claims, conflictResult: hasException ? 'NARROWED_EXCEPTION_OVERRIDES_FINANCE' : claims.length ? 'NONE' : 'INSUFFICIENT_SEMANTIC_SOURCE_AUTHORITY' };
}

export function evaluateFixture(input, ledger) {
  const selectedSignals = selectSemanticSignals(input, ledger);
  return { input, selectedSignalIds: selectedSignals.map((row) => row.signalId), ...decideClaims(input, selectedSignals) };
}
