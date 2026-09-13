import 'package:knowme/data/models/bazi_chart_model.dart';
import 'package:knowme/features/bazi_compatibility/application/bazi_symbolic_reading_engine.dart';
import 'package:knowme/features/bazi_compatibility/domain/bazi_compatibility_report.dart';

abstract final class BaziCompatibilityReportBuilder {
  static BaziCompatibilityReport build(
    BaziChartModel chart, {
    String languageCode = 'th',
  }) {
    final th = languageCode != 'en';
    final reading = BaziSymbolicReadingEngine.build(
      chart,
      languageCode: languageCode,
    );
    return BaziCompatibilityReport(
      title: th
          ? 'KnowMe โหราศาสตร์จีน · BaZi V1'
          : 'KnowMe Chinese Astrology · BaZi V1',
      subtitle: th
          ? 'คำอ่านพื้นดวงเชิงสัญลักษณ์จาก Day Master และความสัมพันธ์ของธาตุที่มองเห็น พร้อมแสดงกติกาและที่มาให้ตรวจสอบได้'
          : 'A symbolic natal reading from the Day Master and visible element relationships, with reproducible rules and sources.',
      sections: [
        _inputSection(chart, th),
        _readingOverviewSection(reading, th),
        _dayMasterSection(reading, th),
        if (reading.hasChartEmphasis) _relationshipSection(chart, reading, th),
        _pillarsSection(chart, th),
        _elementSection(chart, th),
        _methodSection(chart, th),
        _sourcesSection(th),
        _limitationsSection(chart, th),
      ],
    );
  }

  static BaziCompatibilityReportSection _readingOverviewSection(
    BaziSymbolicReading reading,
    bool th,
  ) {
    return BaziCompatibilityReportSection(
      title: th ? 'ภาพรวมคำอ่านพื้นดวง' : 'Natal reading overview',
      intro: th
          ? 'ส่วนนี้เป็นการตีความตามกรอบ BaZi แบบกำหนดกติกาตายตัว ไม่ได้ใช้ AI สร้างคำทำนายเฉพาะหน้า'
          : 'This is a deterministic BaZi interpretation. No AI generates a prediction at request time.',
      paragraphs: [reading.overview],
      notes: [reading.coverageNote],
    );
  }

  static BaziCompatibilityReportSection _dayMasterSection(
    BaziSymbolicReading reading,
    bool th,
  ) {
    final profile = reading.dayMaster;
    return BaziCompatibilityReportSection(
      title: th ? 'แกนตัวตนตาม Day Master' : 'Day Master symbolic lens',
      intro: th
          ? 'Day Master คือก้านฟ้าของเสาวัน ใช้เป็นจุดอ้างอิงหลักของคำอ่าน แต่ไม่ใช่ข้อสรุปบุคลิกทั้งหมดของคนคนหนึ่ง'
          : 'The Day Master is the Heavenly Stem of the Day pillar. It anchors this reading but is not a complete personality verdict.',
      rows: [
        BaziCompatibilityReportRow(label: 'Day Master', value: profile.name),
        BaziCompatibilityReportRow(
          label: th ? 'ภาพเปรียบเทียบดั้งเดิม' : 'Traditional metaphor',
          value: profile.symbol,
        ),
        BaziCompatibilityReportRow(
          label: th ? 'แนวโน้มเชิงสัญลักษณ์' : 'Symbolic tendency',
          value: profile.overview,
        ),
        BaziCompatibilityReportRow(
          label: th ? 'พลังที่นำไปใช้ได้' : 'Constructive expression',
          value: profile.strengths.join(' · '),
        ),
        BaziCompatibilityReportRow(
          label: th ? 'จุดที่ควรรักษาสมดุล' : 'Balance to watch',
          value: profile.cautions.join(' · '),
        ),
        BaziCompatibilityReportRow(
          label: th ? 'แนวทางทดลองใช้' : 'Practical reflection',
          value: profile.practices.join(' · '),
        ),
      ],
      notes: [
        th
            ? 'คำอ่านนี้เป็นภาษาสะท้อนตนเองจากสัญลักษณ์ ไม่ได้ยืนยันว่าคุณต้องมีลักษณะดังกล่าวทุกข้อ'
            : 'This is reflective language derived from a symbol; it does not assert that every trait must describe you.',
      ],
    );
  }

  static BaziCompatibilityReportSection _relationshipSection(
    BaziChartModel chart,
    BaziSymbolicReading reading,
    bool th,
  ) {
    final rows = [
      for (final family in reading.relationships)
        BaziCompatibilityReportRow(
          label: th
              ? '${family.label} · ${family.traditionalLabel.split(' · ').first}'
              : '${family.label} · ${family.traditionalLabel}',
          value: th
              ? '${family.traditionalLabel.split(' · ').last} · '
                    '${_element(family.element, true)} ${family.count} ช่อง — '
                    '${family.meaning}'
              : '${_element(family.element, false)} ${family.count} slots — ${family.meaning}',
        ),
    ];
    return BaziCompatibilityReportSection(
      title: th
          ? 'ความสัมพันธ์ของธาตุที่มองเห็น'
          : 'Visible element relationships',
      intro: th
          ? 'จัดธาตุที่ปรากฏในเสาซึ่งยืนยันได้เป็น 5 กลุ่มเมื่อเทียบกับ Day Master เพื่อช่วยอ่านว่าโครงสร้างส่วนใดมองเห็นมากหรือน้อย'
          : 'Groups visible elements from confirmed pillars into five families relative to the Day Master.',
      rows: rows,
      notes: [
        th
            ? 'จำนวน 0 ในตารางนี้ไม่ได้แปลว่า “ไม่มีพลังนั้น” เพราะ V1 ยังไม่รวมก้านซ่อน ฤดูกาล ราก และน้ำหนักความแข็งแรง'
            : 'A zero here does not mean the role is absent; V1 excludes hidden stems, seasonality, rooting, and strength weighting.',
        if (!chart.timeKnown)
          th
              ? 'ไม่รวมส่วนที่มาจากเสาชั่วโมง เพราะไม่ทราบเวลาเกิด'
              : 'Hour-pillar contributions are excluded because the birth time is unknown.',
      ],
    );
  }

  static BaziCompatibilityReportSection _inputSection(
    BaziChartModel chart,
    bool th,
  ) {
    final birthTime = _text(chart.input['birth_time']);
    return BaziCompatibilityReportSection(
      title: th ? 'ข้อมูลที่ใช้คำนวณ' : 'Calculation input',
      rows: [
        BaziCompatibilityReportRow(
          label: th ? 'วันเกิดตามปฏิทินเกรกอเรียน' : 'Gregorian birth date',
          value: _text(chart.input['birth_date'], fallback: '—'),
        ),
        BaziCompatibilityReportRow(
          label: th ? 'เวลาเกิด' : 'Birth time',
          value: chart.timeKnown ? birthTime : (th ? 'ไม่ทราบเวลา' : 'Unknown'),
        ),
        BaziCompatibilityReportRow(
          label: th ? 'เขตเวลา IANA' : 'IANA timezone',
          value: _text(chart.input['timezone'], fallback: '—'),
        ),
      ],
      notes: chart.timeKnown
          ? const []
          : [
              th
                  ? 'เมื่อไม่ทราบเวลา ระบบจะไม่แสดงเสาชั่วโมงหรือข้อมูลที่ขึ้นกับเวลา และจะตัดเสาปี/เดือนที่เปลี่ยนภายในวันนั้นออก'
                  : 'With Unknown time, the Hour pillar and time-dependent outputs are omitted; a Year or Month pillar that changes during that date is also omitted.',
            ],
    );
  }

  static BaziCompatibilityReportSection _pillarsSection(
    BaziChartModel chart,
    bool th,
  ) {
    final rows = <BaziCompatibilityReportRow>[];
    void add(String roleTh, String roleEn, BaziPillar pillar) {
      if (!pillar.isAvailable) return;
      rows.add(
        BaziCompatibilityReportRow(
          label: th ? roleTh : roleEn,
          value:
              '${pillar.pillarLabel} '
              '(${pillar.stemRoman}/${pillar.branchRoman}) — '
              '${_element(pillar.stemElement, th)} + '
              '${_element(pillar.branchElement, th)}',
        ),
      );
    }

    add('เสาปี', 'Year pillar', chart.pillars.year);
    add('เสาเดือน', 'Month pillar', chart.pillars.month);
    add('เสาวัน', 'Day pillar', chart.pillars.day);
    add('เสาชั่วโมง', 'Hour pillar', chart.pillars.hour);

    final notes = <String>[];
    if (!chart.pillars.year.isAvailable) {
      notes.add(
        th
            ? 'ไม่แสดงเสาปี: วันดังกล่าวคร่อมจุดเปลี่ยน Li Chun (ลี่ชุน) และไม่มีเวลาเกิดมายืนยันด้านของเส้นแบ่ง'
            : 'Year pillar omitted: the date crosses Li Chun and no birth time fixes the side of the boundary.',
      );
    }
    if (!chart.pillars.month.isAvailable) {
      notes.add(
        th
            ? 'ไม่แสดงเสาเดือน: วันดังกล่าวคร่อมจุดเปลี่ยน Jie (เจี๋ย) และไม่มีเวลาเกิดมายืนยันด้านของเส้นแบ่ง'
            : 'Month pillar omitted: the date crosses a Jie boundary and no birth time fixes the side of the boundary.',
      );
    }
    if (!chart.pillars.hour.isAvailable) {
      notes.add(
        th
            ? 'ไม่แสดงเสาชั่วโมง เพราะไม่มีเวลาเกิดที่ทราบแน่ชัด'
            : 'Hour pillar omitted because the birth time is unknown.',
      );
    }
    if (chart.yearAnimal.isAvailable) {
      rows.add(
        BaziCompatibilityReportRow(
          label: th ? 'สัตว์ประจำเสาปี' : 'Year-pillar animal',
          value: _yearAnimal(chart.yearAnimal, th),
        ),
      );
    }

    return BaziCompatibilityReportSection(
      title: th ? 'ผลเสาหลักที่ยืนยันได้' : 'Available pillar results',
      intro: th
          ? 'เสาหลักคือรหัสก้านฟ้าและกิ่งดินที่ระบบคำนวณได้ ส่วน Day Master ในข้อมูลดิบคือก้านฟ้าของเสาวัน ไม่ใช่คำอธิบายบุคลิก'
          : 'Each pillar is an engine-calculated heavenly-stem/earthly-branch code. Day Master is the Day pillar stem, not a personality description.',
      rows: rows,
      notes: notes,
    );
  }

  static BaziCompatibilityReportSection _elementSection(
    BaziChartModel chart,
    bool th,
  ) {
    final balance = chart.elementBalance;
    return BaziCompatibilityReportSection(
      title: th ? 'จำนวนธาตุที่ปรากฏ' : 'Visible element counts',
      intro: th
          ? 'นับธาตุบนก้านฟ้าและกิ่งดินของเสาที่แสดงเท่านั้น ไม่รวมก้านซ่อน ราก ฤดูกาล หรือน้ำหนักความแข็งแรง'
          : 'Counts visible stem and branch elements from displayed pillars only; hidden stems, rooting, seasonality, and strength weighting are excluded.',
      rows: [
        BaziCompatibilityReportRow(
          label: _element('wood', th),
          value: '${balance.wood}',
        ),
        BaziCompatibilityReportRow(
          label: _element('fire', th),
          value: '${balance.fire}',
        ),
        BaziCompatibilityReportRow(
          label: _element('earth', th),
          value: '${balance.earth}',
        ),
        BaziCompatibilityReportRow(
          label: _element('metal', th),
          value: '${balance.metal}',
        ),
        BaziCompatibilityReportRow(
          label: _element('water', th),
          value: '${balance.water}',
        ),
        BaziCompatibilityReportRow(
          label: th ? 'ช่องข้อมูลที่นับ' : 'Counted slots',
          value: '${balance.totalSlots}',
        ),
      ],
    );
  }

  static BaziCompatibilityReportSection _methodSection(
    BaziChartModel chart,
    bool th,
  ) {
    return BaziCompatibilityReportSection(
      title: th
          ? 'กติกาและข้อมูลสำหรับตรวจซ้ำ'
          : 'Rules and reproducibility data',
      rows: [
        BaziCompatibilityReportRow(
          label: th ? 'สัญญากติกา' : 'Rule contract',
          value: chart.contractId,
        ),
        BaziCompatibilityReportRow(
          label: th ? 'ระบบคำนวณ' : 'Engine',
          value: chart.engineVersion,
        ),
        BaziCompatibilityReportRow(
          label: th ? 'ฐานเวลา' : 'Time basis',
          value: th
              ? 'เวลาท้องถิ่นตาม IANA zone ที่ระบุ โดยไม่แปลงเป็น UTC'
              : 'Local civil time in the supplied IANA zone, without UTC conversion',
        ),
        BaziCompatibilityReportRow(
          label: th ? 'เส้นแบ่งปี' : 'Year boundary',
          value: 'Li Chun (立春)',
        ),
        BaziCompatibilityReportRow(
          label: th ? 'เส้นแบ่งเดือน' : 'Month boundary',
          value: 'Jie (節)',
        ),
        BaziCompatibilityReportRow(
          label: th ? 'เส้นแบ่งวัน' : 'Day boundary',
          value: th
              ? '00:00 ตามเวลาท้องถิ่น (sect=2)'
              : '00:00 local civil time (sect=2)',
        ),
        BaziCompatibilityReportRow(
          label: th ? 'การปรับเวลาสุริยะจริง' : 'True-solar correction',
          value: th ? 'ไม่ปรับ' : 'None',
        ),
        BaziCompatibilityReportRow(
          label: th ? 'สถานที่และพิกัด' : 'Location and coordinates',
          value: th
              ? 'บันทึกเป็นบริบท แต่ไม่ใช้เปลี่ยนผลคำนวณใน V1'
              : 'Recorded as context but do not alter the V1 calculation',
        ),
        BaziCompatibilityReportRow(
          label: th ? 'รหัสตรวจ input' : 'Input fingerprint',
          value: chart.inputHash,
        ),
        BaziCompatibilityReportRow(
          label: th ? 'สัญญาคำอ่าน' : 'Reading contract',
          value: BaziSymbolicReadingEngine.interpretationContractId,
        ),
      ],
    );
  }

  static BaziCompatibilityReportSection _sourcesSection(bool th) {
    return BaziCompatibilityReportSection(
      title: th
          ? 'ที่มาของผลคำนวณและคำอ่าน'
          : 'Calculation and reading sources',
      intro: th
          ? 'แยกแหล่งคำนวณออกจากแหล่งตีความ เพื่อให้ตรวจได้ว่าข้อความแต่ละส่วนมาจากกรอบใด'
          : 'Calculation sources are separated from interpretation sources so each layer can be audited.',
      rows: [
        BaziCompatibilityReportRow(
          label: th
              ? '[C1] โครงสร้างก้านฟ้า–กิ่งดิน'
              : '[C1] Stem–Branch structure',
          value:
              'Hong Kong Observatory · Heavenly Stems and Earthly Branches · https://www.hko.gov.hk/en/gts/time/stemsandbranches.htm',
        ),
        BaziCompatibilityReportRow(
          label: th ? '[C2] 24 ฤดูกาลจีน' : '[C2] 24 Solar Terms',
          value:
              'Hong Kong Observatory · The 24 Solar Terms · https://www.hko.gov.hk/en/gts/time/24solarterms.htm',
        ),
        BaziCompatibilityReportRow(
          label: th
              ? '[C3] โค้ดระบบคำนวณที่ตรึงเวอร์ชัน'
              : '[C3] Pinned calculation implementation',
          value:
              '6tail · lunar-python v1.4.8 · https://github.com/6tail/lunar-python/tree/v1.4.8',
        ),
        BaziCompatibilityReportRow(
          label: th
              ? '[I1] กรอบ Ten Day Masters'
              : '[I1] Ten Day Masters framework',
          value:
              'Joey Yap · BaZi Essentials — The Ten Day Masters · JY Books, 2009 · ISBN 9789675395321',
        ),
        BaziCompatibilityReportRow(
          label: th
              ? '[I2] กลุ่มความสัมพันธ์ของธาตุ'
              : '[I2] Element relationship families',
          value:
              'Joey Yap · The Power of X: Enter the 10 Gods · JY Books, 2011 · ISBN 9789675395918',
        ),
      ],
      notes: [
        th
            ? 'KnowMe เรียบเรียงถ้อยคำใหม่ให้เป็นภาษาสะท้อนตนเอง ไม่ได้คัดลอกคำทำนายจากแหล่งอ้างอิง และไม่ใช้แหล่งเหล่านี้เป็นหลักฐานทางวิทยาศาสตร์'
            : 'KnowMe paraphrases the framework into reflective language. These references are not presented as scientific validation.',
      ],
    );
  }

  static BaziCompatibilityReportSection _limitationsSection(
    BaziChartModel chart,
    bool th,
  ) {
    return BaziCompatibilityReportSection(
      title: th ? 'ข้อจำกัดและคำเตือน' : 'Limitations and cautions',
      notes: [
        th
            ? 'รายงานนี้ใช้กติกา KnowMe BaZi Compatibility V1 และคำอ่านเชิงสัญลักษณ์ที่ระบุที่มา ไม่ได้อ้างว่าเป็นมาตรฐานสากลของทุกสำนักหรือข้อพิสูจน์บุคลิก'
            : 'This report uses the KnowMe BaZi Compatibility V1 rules and sourced symbolic interpretation; it is neither a universal school standard nor proof of personality.',
        if (!chart.timeKnown)
          th
              ? 'ผล Unknown time เป็นแบบ fail-closed: ข้อมูลที่ต้องใช้เวลาและค่าปี/เดือนที่กำกวมจะไม่ถูกแสดง'
              : 'Unknown-time results fail closed: time-dependent and ambiguous Year/Month values are not shown.',
        th
            ? 'V1 ยังไม่คำนวณก้านซ่อน ความแข็งแรงตามฤดูกาล Useful God การผสม/ปะทะ ดวงจรสิบปี หรือจังหวะรายปี จึงไม่ทำนายเหตุการณ์ อาชีพเฉพาะ ความรัก สุขภาพ หรือผลการเงิน'
            : 'V1 does not calculate hidden stems, seasonal strength, Useful God, combinations/clashes, ten-year luck pillars, or annual timing, so it does not predict events, specific careers, relationships, health, or financial outcomes.',
        th
            ? 'ห้ามใช้รายงานนี้แทนคำแนะนำจากผู้เชี่ยวชาญด้านสุขภาพ การแพทย์ การเงิน การลงทุน หรือกฎหมาย และไม่ควรใช้เพื่อรับประกันเหตุการณ์ในอนาคต'
            : 'Do not use this report as health, medical, financial, investment, or legal advice, or as a guarantee of future events.',
      ],
    );
  }

  static String _element(String value, bool th) {
    const thai = {
      'wood': 'ไม้',
      'fire': 'ไฟ',
      'earth': 'ดิน',
      'metal': 'ทอง',
      'water': 'น้ำ',
    };
    return th ? (thai[value] ?? value) : value;
  }

  static String _yearAnimal(BaziYearAnimal animal, bool th) {
    if (!th) return '${animal.zh} (${animal.en})';
    const thai = {
      'rat': 'หนู',
      'ox': 'วัว',
      'tiger': 'เสือ',
      'rabbit': 'กระต่าย',
      'dragon': 'มังกร',
      'snake': 'งู',
      'horse': 'ม้า',
      'goat': 'แพะ',
      'monkey': 'ลิง',
      'rooster': 'ไก่',
      'dog': 'สุนัข',
      'pig': 'หมู',
    };
    final translated = thai[animal.roman.trim().toLowerCase()];
    if (translated == null) return '${animal.zh} (${animal.en})';
    return '$translated (${animal.zh} / ${animal.en})';
  }

  static String _text(dynamic value, {String fallback = ''}) {
    final result = value is String ? value.trim() : '';
    return result.isEmpty ? fallback : result;
  }
}
