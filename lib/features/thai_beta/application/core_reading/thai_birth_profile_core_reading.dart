import 'package:knowme/features/astrology/thai/content/models/thai_content_key.dart';
import 'package:knowme/features/astrology/thai/foundation/constants/thai_lagna_rulership.dart';
import 'package:knowme/features/astrology/thai/foundation/models/thai_astrology_profile.dart';
import 'package:knowme/features/astrology/thai/foundation/v2/engines/house_engine.dart';
import 'package:knowme/features/astrology/thai/foundation/v2/models/thai_lagna.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_section_id.dart';
import 'package:knowme/features/astrology/thai/mirror/models/thai_mirror_theme_ref.dart';
import 'package:knowme/features/astrology/thai/mirror/presentation/models/thai_mirror_consumer_view_state.dart';
import 'package:knowme/features/thai_beta/application/thai_beta_analysis.dart';

/// Centralized reader-facing copy for the Core Reading surface and PDF.
class ThaiBirthProfileCoreReadingCopy {
  const ThaiBirthProfileCoreReadingCopy._();

  static const reportTitle = 'ดวงจากวันเกิดของคุณ';
  static const summaryTitle = 'สรุปตัวคุณจากพื้นดวง';
  static const workTitle = 'การงาน';
  static const moneyTitle = 'การเงิน';
  static const relationshipsTitle = 'ความรักและความสัมพันธ์';
  static const wellbeingTitle = 'สุขภาพและพลังชีวิตตามตำรา';
  static const closingTitle = 'สิ่งที่ดวงนี้อยากบอกคุณ';
  static const methodologyTitle = 'ดวงนี้วิเคราะห์จากอะไร';
  static const timelineTransitionTitle = 'จากพื้นดวงสู่จังหวะชีวิต';
  static const medicalDisclaimer =
      'เนื้อหาส่วนนี้เป็นมุมมองตามความเชื่อทางโหราศาสตร์ '
      'ไม่ใช่การวินิจฉัยโรคหรือคำแนะนำทางการแพทย์';
}

enum ThaiBirthProfileCoreDomain {
  summary,
  work,
  money,
  relationships,
  wellbeing,
  closing,
  methodology,
}

enum ThaiBirthProfileCoreClaimRole {
  fact,
  interpretation,
  synthesis,
  disclosure,
}

enum ThaiBirthProfileCoreAtomKind {
  astrologicalWeekday,
  lagnaSign,
  lagnaLord,
  houseSign,
  houseLord,
  identityTheme,
  strengthTheme,
  riskTheme,
  actionTheme,
}

enum _ThemeAtomSource { topThemes, sectionSupportingThemes }

class _ThemeAtomCandidate {
  const _ThemeAtomCandidate(this.theme, this.source, {this.sectionId});

  final ThaiMirrorThemeRef theme;
  final _ThemeAtomSource source;
  final ThaiMirrorSectionId? sectionId;
}

class ThaiBirthProfileCoreEvidenceRef {
  const ThaiBirthProfileCoreEvidenceRef({
    required this.sourceRef,
    required this.rawValue,
  });

  final String sourceRef;
  final String rawValue;
}

/// A typed computed fact used before any reader-facing sentence is composed.
class ThaiBirthProfileCoreClaimAtom {
  const ThaiBirthProfileCoreClaimAtom({
    required this.kind,
    required this.domain,
    required this.sourceRef,
    required this.rawValue,
    this.houseNumber,
    this.themeId,
    this.score = 0,
    this.additionalEvidenceRefs = const [],
  });

  final ThaiBirthProfileCoreAtomKind kind;
  final ThaiBirthProfileCoreDomain domain;

  /// Exact field or computed result member that supplied [rawValue].
  final String sourceRef;
  final String rawValue;
  final List<ThaiBirthProfileCoreEvidenceRef> additionalEvidenceRefs;
  final int? houseNumber;
  final String? themeId;
  final double score;

  List<ThaiBirthProfileCoreEvidenceRef> get evidenceRefs => [
    ThaiBirthProfileCoreEvidenceRef(sourceRef: sourceRef, rawValue: rawValue),
    ...additionalEvidenceRefs,
  ];
}

/// One reader-facing paragraph with deterministic, internal-only ownership.
class ThaiBirthProfileCoreParagraph {
  const ThaiBirthProfileCoreParagraph({
    required this.text,
    required this.domain,
    required this.role,
    required this.semanticKey,
    required this.evidenceKeys,
    this.sourceAtoms = const [],
  });

  final String text;
  final ThaiBirthProfileCoreDomain domain;
  final ThaiBirthProfileCoreClaimRole role;
  final String semanticKey;

  /// Exact fact/source references used for this paragraph. Never rendered.
  final List<String> evidenceKeys;
  final List<ThaiBirthProfileCoreClaimAtom> sourceAtoms;
}

class ThaiBirthProfileCoreSection {
  const ThaiBirthProfileCoreSection({
    required this.title,
    required this.domain,
    required this.claims,
    this.isMethodology = false,
  });

  final String title;
  final ThaiBirthProfileCoreDomain domain;
  final List<ThaiBirthProfileCoreParagraph> claims;
  final bool isMethodology;

  List<String> get paragraphs =>
      claims.map((claim) => claim.text).toList(growable: false);
  List<String> get publicParagraphs => paragraphs;

  /// Compatibility view for internal diagnostics; ownership lives on claims.
  List<String> get evidenceKeys => {
    for (final claim in claims) ...claim.evidenceKeys,
  }.toList(growable: false);
}

/// Deterministic protection against a fact being restated with light edits.
class ThaiBirthProfileCoreClaimDeduplicator {
  ThaiBirthProfileCoreClaimDeduplicator._();

  static bool isNearDuplicate(
    ThaiBirthProfileCoreParagraph candidate,
    ThaiBirthProfileCoreParagraph existing,
  ) {
    if (candidate.semanticKey == existing.semanticKey) return true;
    final left = _normalize(candidate.text);
    final right = _normalize(existing.text);
    if (left == right) return true;
    if (left.isEmpty || right.isEmpty) return false;
    final leftIsShorter = left.length <= right.length;
    final shorter = leftIsShorter ? left : right;
    final longer = leftIsShorter ? right : left;
    if (longer.contains(shorter) && shorter.length / longer.length >= .9) {
      return true;
    }
    final leftGrams = _grams(left);
    final rightGrams = _grams(right);
    final overlap = leftGrams.intersection(rightGrams).length;
    final union = leftGrams.union(rightGrams).length;
    if (union > 0 && overlap / union >= .82) return true;
    final leftConcepts = _concepts(candidate.text);
    final rightConcepts = _concepts(existing.text);
    final sharedConcepts = leftConcepts.intersection(rightConcepts).length;
    final smallerConceptSet = leftConcepts.length < rightConcepts.length
        ? leftConcepts.length
        : rightConcepts.length;
    return sharedConcepts >= 2 &&
        smallerConceptSet > 0 &&
        sharedConcepts / smallerConceptSet >= .67;
  }

  static Set<String> _grams(String value) {
    if (value.length < 3) return {value};
    return {
      for (var index = 0; index <= value.length - 3; index++)
        value.substring(index, index + 3),
    };
  }

  static String _normalize(String value) => value
      .replaceAll('**', '')
      .replaceAll(RegExp(r'[\s·•:;,.!?()\-–—]+'), '')
      .toLowerCase();

  static Set<String> _concepts(String value) {
    final normalized = _normalize(value);
    const lexicon = <String, List<String>>{
      'take_work': ['รับงาน', 'รับภาระ', 'รับผิดชอบเพิ่ม'],
      'excess': ['มากเกิน', 'เกินไป', 'เกินกำลัง'],
      'lead': ['ผู้นำ', 'ต้องนำ', 'นำทีม'],
      'plan': ['วางแผน', 'จัดลำดับ', 'กำหนดขั้น'],
      'delay': ['ช้าลง', 'เลื่อนออก', 'ยังไม่ลงมือ'],
      'control': ['ควบคุม', 'จัดการทุกอย่าง', 'กำกับทุกด้าน'],
      'rest': ['พัก', 'คืนแรง', 'ความล้า'],
      'money': ['เงิน', 'งบ', 'รายรับ', 'ทรัพยากร'],
      'relationship': ['ความสัมพันธ์', 'ไว้ใจ', 'คนใกล้ตัว'],
    };
    return {
      for (final entry in lexicon.entries)
        if (entry.value.any(normalized.contains)) entry.key,
    };
  }
}

class ThaiBirthProfileCoreDomainPolicy {
  const ThaiBirthProfileCoreDomainPolicy._();

  static bool acceptsAtom(
    ThaiBirthProfileCoreDomain domain,
    ThaiBirthProfileCoreClaimAtom atom,
  ) {
    if (atom.domain != domain) return false;
    return switch (domain) {
      ThaiBirthProfileCoreDomain.summary =>
        atom.kind == ThaiBirthProfileCoreAtomKind.astrologicalWeekday ||
            atom.kind == ThaiBirthProfileCoreAtomKind.lagnaSign ||
            atom.kind == ThaiBirthProfileCoreAtomKind.lagnaLord ||
            atom.kind == ThaiBirthProfileCoreAtomKind.identityTheme,
      ThaiBirthProfileCoreDomain.work => _isHouseAtom(atom, expectedHouse: 10),
      ThaiBirthProfileCoreDomain.money => _isHouseAtom(atom, expectedHouse: 2),
      ThaiBirthProfileCoreDomain.relationships => _isHouseAtom(
        atom,
        expectedHouse: 7,
      ),
      ThaiBirthProfileCoreDomain.wellbeing => _isHouseAtom(
        atom,
        expectedHouse: 6,
      ),
      ThaiBirthProfileCoreDomain.closing =>
        atom.kind == ThaiBirthProfileCoreAtomKind.strengthTheme ||
            atom.kind == ThaiBirthProfileCoreAtomKind.riskTheme ||
            atom.kind == ThaiBirthProfileCoreAtomKind.actionTheme,
      ThaiBirthProfileCoreDomain.methodology => true,
    };
  }

  static bool _isHouseAtom(
    ThaiBirthProfileCoreClaimAtom atom, {
    required int expectedHouse,
  }) {
    return atom.houseNumber == expectedHouse &&
        (atom.kind == ThaiBirthProfileCoreAtomKind.houseSign ||
            atom.kind == ThaiBirthProfileCoreAtomKind.houseLord);
  }
}

class ThaiBirthProfileCoreReading {
  const ThaiBirthProfileCoreReading({
    required this.title,
    required this.subtitle,
    required this.sections,
    required this.hasBirthTime,
  });

  static const reportTitle = ThaiBirthProfileCoreReadingCopy.reportTitle;
  static const medicalDisclaimer =
      ThaiBirthProfileCoreReadingCopy.medicalDisclaimer;

  final String title;
  final String subtitle;
  final List<ThaiBirthProfileCoreSection> sections;
  final bool hasBirthTime;

  factory ThaiBirthProfileCoreReading.fromAnalysis(
    ThaiBetaAnalysis analysis, {
    ThaiMirrorConsumerViewState? consumerView,
  }) {
    final profile = analysis.profile;
    final normalized = analysis.normalizedSnapshot;
    final birthData = analysis.pipelineResult?.birthData;
    final mirror = analysis.pipelineResult?.mirrorResult;
    final acceptedClaims = <ThaiBirthProfileCoreParagraph>[];

    ThaiBirthProfileCoreParagraph? claim({
      required String text,
      required ThaiBirthProfileCoreDomain domain,
      required ThaiBirthProfileCoreClaimRole role,
      required String semanticKey,
      required List<ThaiBirthProfileCoreClaimAtom> atoms,
      bool allowTemporal = false,
    }) {
      final value = allowTemporal ? _plain(text) : _lifelong(text);
      if (value.isEmpty || atoms.isEmpty) return null;
      if (atoms.any(
        (atom) => !ThaiBirthProfileCoreDomainPolicy.acceptsAtom(domain, atom),
      )) {
        return null;
      }
      final candidate = ThaiBirthProfileCoreParagraph(
        text: value,
        domain: domain,
        role: role,
        semanticKey: semanticKey,
        evidenceKeys: List.unmodifiable(
          atoms
              .expand((atom) => atom.evidenceRefs)
              .map((evidence) => evidence.sourceRef)
              .toSet(),
        ),
        sourceAtoms: List.unmodifiable(atoms),
      );
      if (acceptedClaims.any(
        (existing) => ThaiBirthProfileCoreClaimDeduplicator.isNearDuplicate(
          candidate,
          existing,
        ),
      )) {
        return null;
      }
      acceptedClaims.add(candidate);
      return candidate;
    }

    List<ThaiBirthProfileCoreParagraph> compact(
      Iterable<ThaiBirthProfileCoreParagraph?> values,
    ) => values.whereType<ThaiBirthProfileCoreParagraph>().toList();

    final summaryAtoms = <ThaiBirthProfileCoreClaimAtom>[];
    if (birthData?.thaiWeekdayNumber != null) {
      summaryAtoms.add(
        ThaiBirthProfileCoreClaimAtom(
          kind: ThaiBirthProfileCoreAtomKind.astrologicalWeekday,
          domain: ThaiBirthProfileCoreDomain.summary,
          sourceRef: 'ThaiMirrorPipelineResult.birthData.thaiWeekdayNumber',
          rawValue: '${birthData!.thaiWeekdayNumber}',
          score: 80,
        ),
      );
    }
    if (profile?.lagnaKey != null && profile!.lagnaKey!.isNotEmpty) {
      summaryAtoms.addAll([
        ThaiBirthProfileCoreClaimAtom(
          kind: ThaiBirthProfileCoreAtomKind.lagnaSign,
          domain: ThaiBirthProfileCoreDomain.summary,
          sourceRef: 'ThaiAstrologyProfile.lagnaKey',
          rawValue: profile.lagnaKey!,
          score: 90,
        ),
        if (profile.lagnaLordKey != null && profile.lagnaLordKey!.isNotEmpty)
          ThaiBirthProfileCoreClaimAtom(
            kind: ThaiBirthProfileCoreAtomKind.lagnaLord,
            domain: ThaiBirthProfileCoreDomain.summary,
            sourceRef: 'ThaiAstrologyProfile.lagnaLordKey',
            rawValue: profile.lagnaLordKey!,
            score: 90,
          ),
      ]);
    }

    final identityTheme = selectHighestPriorityTheme(
      mirror?.sectionById(ThaiMirrorSectionId.coreSelf)?.supportingThemes ??
          const [],
      supportedThemeIds: _identityPhrases.keys,
    );
    final identityAtom = identityTheme == null
        ? null
        : _themeAtom(
            identityTheme,
            domain: ThaiBirthProfileCoreDomain.summary,
            kind: ThaiBirthProfileCoreAtomKind.identityTheme,
            source: _ThemeAtomSource.sectionSupportingThemes,
            sectionId: ThaiMirrorSectionId.coreSelf,
          );
    final specificSummary = compact([
      if (identityAtom != null &&
          summaryAtoms.any(
            (atom) => atom.kind == ThaiBirthProfileCoreAtomKind.lagnaSign,
          ))
        claim(
          text: _composeLagnaSummary(summaryAtoms, identityAtom),
          domain: ThaiBirthProfileCoreDomain.summary,
          role: ThaiBirthProfileCoreClaimRole.interpretation,
          semanticKey: 'computed:lagna-identity-frame',
          atoms: [
            ...summaryAtoms.where(
              (atom) =>
                  atom.kind == ThaiBirthProfileCoreAtomKind.lagnaSign ||
                  atom.kind == ThaiBirthProfileCoreAtomKind.lagnaLord,
            ),
            identityAtom,
          ],
        ),
    ]);

    final summary = specificSummary;

    final houseAtoms = _houseAtoms(profile);
    ThaiBirthProfileCoreSection? lifeDomain({
      required String title,
      required ThaiBirthProfileCoreDomain domain,
      required int houseNumber,
      bool includeMedicalDisclaimer = false,
    }) {
      final atoms = houseAtoms
          .where(
            (atom) => atom.domain == domain && atom.houseNumber == houseNumber,
          )
          .toList(growable: false);
      if (atoms.length < 2 ||
          !atoms.any(
            (atom) => atom.kind == ThaiBirthProfileCoreAtomKind.houseSign,
          ) ||
          !atoms.any(
            (atom) => atom.kind == ThaiBirthProfileCoreAtomKind.houseLord,
          )) {
        return null;
      }
      final copy = _composeHouseDomain(domain, atoms);
      final analysisParagraph = claim(
        text: copy.analysis,
        domain: domain,
        role: ThaiBirthProfileCoreClaimRole.synthesis,
        semanticKey: 'computed:house:$houseNumber:analysis',
        atoms: atoms,
      );
      final guidanceParagraph = claim(
        text: copy.guidance,
        domain: domain,
        role: ThaiBirthProfileCoreClaimRole.synthesis,
        semanticKey: 'computed:house:$houseNumber:guidance',
        atoms: atoms,
      );
      if (analysisParagraph == null || guidanceParagraph == null) return null;
      return ThaiBirthProfileCoreSection(
        title: title,
        domain: domain,
        claims: [
          analysisParagraph,
          guidanceParagraph,
          if (includeMedicalDisclaimer)
            ThaiBirthProfileCoreParagraph(
              text: medicalDisclaimer,
              domain: domain,
              role: ThaiBirthProfileCoreClaimRole.disclosure,
              semanticKey: 'disclosure:medical',
              evidenceKeys: atoms
                  .expand((atom) => atom.evidenceRefs)
                  .map((evidence) => evidence.sourceRef)
                  .toSet()
                  .toList(growable: false),
              sourceAtoms: atoms,
            ),
        ],
      );
    }

    final closingCandidates = <_ThemeAtomCandidate>[
      for (final theme in mirror?.topThemes ?? const <ThaiMirrorThemeRef>[])
        _ThemeAtomCandidate(theme, _ThemeAtomSource.topThemes),
      for (final sectionId in [
        ThaiMirrorSectionId.strengths,
        ThaiMirrorSectionId.growthAreas,
        ThaiMirrorSectionId.growthPath,
      ])
        for (final theme
            in mirror?.sectionById(sectionId)?.supportingThemes ??
                const <ThaiMirrorThemeRef>[])
          _ThemeAtomCandidate(
            theme,
            _ThemeAtomSource.sectionSupportingThemes,
            sectionId: sectionId,
          ),
    ];
    final closingTheme = selectClosingContextTheme(
      closingCandidates.map((candidate) => candidate.theme),
    );
    final closingSource = closingTheme == null
        ? null
        : closingCandidates.firstWhere(
            (candidate) =>
                candidate.theme.themeId == closingTheme.themeId &&
                candidate.theme.score == closingTheme.score,
          );
    final closingAtoms = <ThaiBirthProfileCoreClaimAtom>[
      if (closingTheme != null && closingSource != null)
        _themeAtom(
          closingTheme,
          domain: ThaiBirthProfileCoreDomain.closing,
          kind: ThaiBirthProfileCoreAtomKind.strengthTheme,
          source: closingSource.source,
          sectionId: closingSource.sectionId,
        ),
      if (closingTheme != null && closingSource != null)
        _themeAtom(
          closingTheme,
          domain: ThaiBirthProfileCoreDomain.closing,
          kind: ThaiBirthProfileCoreAtomKind.riskTheme,
          source: closingSource.source,
          sectionId: closingSource.sectionId,
        ),
      if (closingTheme != null && closingSource != null)
        _themeAtom(
          closingTheme,
          domain: ThaiBirthProfileCoreDomain.closing,
          kind: ThaiBirthProfileCoreAtomKind.actionTheme,
          source: closingSource.source,
          sectionId: closingSource.sectionId,
        ),
    ];
    final closingCopy = _composeClosing(closingAtoms);
    final closingClaims = closingAtoms.length < 3 ||
            closingCopy.strength.isEmpty ||
            closingCopy.risk.isEmpty ||
            closingCopy.action.isEmpty
        ? const <ThaiBirthProfileCoreParagraph>[]
        : compact([
            claim(
              text:
                  '${closingCopy.strength} ${closingCopy.risk} ${closingCopy.action}',
              domain: ThaiBirthProfileCoreDomain.closing,
              role: ThaiBirthProfileCoreClaimRole.synthesis,
              semanticKey: 'computed:ranked-strength-risk-action',
              atoms: closingAtoms,
            ),
          ]);

    final methodologyClaims = <ThaiBirthProfileCoreParagraph>[];
    void addMethodologyClaim({
      required String text,
      required String semanticKey,
      required List<ThaiBirthProfileCoreClaimAtom> atoms,
    }) {
      if (text.trim().isEmpty || atoms.isEmpty) return;
      methodologyClaims.add(
        ThaiBirthProfileCoreParagraph(
          text: text,
          domain: ThaiBirthProfileCoreDomain.methodology,
          role: ThaiBirthProfileCoreClaimRole.disclosure,
          semanticKey: semanticKey,
          evidenceKeys: atoms
              .expand((atom) => atom.evidenceRefs)
              .map((evidence) => evidence.sourceRef)
              .toSet()
              .toList(growable: false),
          sourceAtoms: List.unmodifiable(atoms),
        ),
      );
    }

    if (normalized != null) {
      final thaiDay = _thaiWeekday(
        analysis.pipelineResult?.birthData?.thaiWeekdayNumber,
      );
      addMethodologyClaim(
        text:
            'วันเกิดตามสูติบัตรยังเป็นวันที่ ${normalized.rawBirthDate} ตามเดิม '
            'ส่วนการอ่านตามหลักโหราศาสตร์ไทยใช้วัน$thaiDay '
            '(วันที่ ${normalized.thaiAstrologicalDate}) เป็นวันทางโหราศาสตร์',
        semanticKey: 'methodology:astrological-date',
        atoms: [
          if (birthData?.thaiWeekdayNumber != null)
            ThaiBirthProfileCoreClaimAtom(
              kind: ThaiBirthProfileCoreAtomKind.astrologicalWeekday,
              domain: ThaiBirthProfileCoreDomain.methodology,
              sourceRef: 'ThaiMirrorPipelineResult.birthData.thaiWeekdayNumber',
              rawValue: '${birthData!.thaiWeekdayNumber}',
            ),
          ThaiBirthProfileCoreClaimAtom(
            kind: ThaiBirthProfileCoreAtomKind.astrologicalWeekday,
            domain: ThaiBirthProfileCoreDomain.methodology,
            sourceRef:
                'ThaiBetaAnalysis.normalizedSnapshot.thaiAstrologicalDate',
            rawValue: normalized.thaiAstrologicalDate,
          ),
        ],
      );
      if (normalized.sunriseAvailable) {
        addMethodologyClaim(
          text: normalized.usedPreviousDay
              ? 'เวลาเกิดอยู่ก่อนพระอาทิตย์ขึ้นเวลา ${normalized.sunrise} '
                    'จึงใช้วันก่อนหน้าตามกฎที่นับวันใหม่เมื่อพระอาทิตย์ขึ้น '
                    'โดยไม่เปลี่ยนวันเกิดตามสูติบัตร'
              : 'เวลาเกิดอยู่หลังพระอาทิตย์ขึ้นเวลา ${normalized.sunrise} '
                    'จึงใช้วันเดียวกับวันเกิดตามสูติบัตร',
          semanticKey: 'methodology:sunrise-boundary',
          atoms: [
            ThaiBirthProfileCoreClaimAtom(
              kind: ThaiBirthProfileCoreAtomKind.astrologicalWeekday,
              domain: ThaiBirthProfileCoreDomain.methodology,
              sourceRef: 'ThaiBetaAnalysis.normalizedSnapshot.birthTime',
              rawValue: normalized.birthTime,
            ),
            ThaiBirthProfileCoreClaimAtom(
              kind: ThaiBirthProfileCoreAtomKind.astrologicalWeekday,
              domain: ThaiBirthProfileCoreDomain.methodology,
              sourceRef: 'ThaiBetaAnalysis.normalizedSnapshot.sunrise',
              rawValue: normalized.sunrise,
            ),
            ThaiBirthProfileCoreClaimAtom(
              kind: ThaiBirthProfileCoreAtomKind.astrologicalWeekday,
              domain: ThaiBirthProfileCoreDomain.methodology,
              sourceRef: 'ThaiBetaAnalysis.normalizedSnapshot.usedPreviousDay',
              rawValue: '${normalized.usedPreviousDay}',
            ),
            ThaiBirthProfileCoreClaimAtom(
              kind: ThaiBirthProfileCoreAtomKind.astrologicalWeekday,
              domain: ThaiBirthProfileCoreDomain.methodology,
              sourceRef: 'ThaiBetaAnalysis.normalizedSnapshot.rawBirthDate',
              rawValue: normalized.rawBirthDate,
            ),
          ],
        );
      }
    }
    if (analysis.input.hasBirthTime &&
        profile?.lagnaKey != null &&
        profile!.lagnaKey!.isNotEmpty) {
      addMethodologyClaim(
        text:
            'ลัคนา (ภาพบุคลิกตั้งต้นที่คำนวณจากเวลาและสถานที่เกิด) '
            'อยู่ที่${_lagnaLabel(profile.lagnaKey!)}',
        semanticKey: 'methodology:lagna-inputs',
        atoms: [
          ThaiBirthProfileCoreClaimAtom(
            kind: ThaiBirthProfileCoreAtomKind.lagnaSign,
            domain: ThaiBirthProfileCoreDomain.methodology,
            sourceRef: 'ThaiAstrologyProfile.lagnaKey',
            rawValue: profile.lagnaKey!,
          ),
          if (normalized != null) ...[
            ThaiBirthProfileCoreClaimAtom(
              kind: ThaiBirthProfileCoreAtomKind.lagnaSign,
              domain: ThaiBirthProfileCoreDomain.methodology,
              sourceRef: 'ThaiBetaAnalysis.normalizedSnapshot.birthTime',
              rawValue: normalized.birthTime,
            ),
            ThaiBirthProfileCoreClaimAtom(
              kind: ThaiBirthProfileCoreAtomKind.lagnaSign,
              domain: ThaiBirthProfileCoreDomain.methodology,
              sourceRef: 'ThaiBetaAnalysis.normalizedSnapshot.latitude',
              rawValue: '${normalized.latitude}',
            ),
            ThaiBirthProfileCoreClaimAtom(
              kind: ThaiBirthProfileCoreAtomKind.lagnaSign,
              domain: ThaiBirthProfileCoreDomain.methodology,
              sourceRef: 'ThaiBetaAnalysis.normalizedSnapshot.longitude',
              rawValue: '${normalized.longitude}',
            ),
            ThaiBirthProfileCoreClaimAtom(
              kind: ThaiBirthProfileCoreAtomKind.lagnaSign,
              domain: ThaiBirthProfileCoreDomain.methodology,
              sourceRef: 'ThaiBetaAnalysis.normalizedSnapshot.timeZoneId',
              rawValue: normalized.timeZoneId,
            ),
          ],
        ],
      );
    } else {
      addMethodologyClaim(
        text:
            'รายงานนี้ไม่มีเวลาเกิด จึงไม่กล่าวถึงลัคนา ภพ '
            'หรือข้อสรุปที่ต้องพึ่งตำแหน่งตามเวลาเกิด',
        semanticKey: 'methodology:no-birth-time',
        atoms: [
          ThaiBirthProfileCoreClaimAtom(
            kind: ThaiBirthProfileCoreAtomKind.astrologicalWeekday,
            domain: ThaiBirthProfileCoreDomain.methodology,
            sourceRef: 'ThaiBetaInput.birthTimeUnknown',
            rawValue: '${analysis.input.birthTimeUnknown}',
          ),
          if (normalized != null)
            ThaiBirthProfileCoreClaimAtom(
              kind: ThaiBirthProfileCoreAtomKind.astrologicalWeekday,
              domain: ThaiBirthProfileCoreDomain.methodology,
              sourceRef: 'ThaiBetaAnalysis.normalizedSnapshot.birthTime',
              rawValue: normalized.birthTime,
            ),
        ],
      );
    }
    if (mirror != null && mirror.topThemes.isNotEmpty) {
      addMethodologyClaim(
        text:
            'คำอ่านข้างต้นจัดลำดับจากแนวโน้มที่มีน้ำหนักเด่นในผลวิเคราะห์ '
            'โดยไม่นำชื่อหมวดภายในมาแสดงแทนคำอธิบายสำหรับผู้อ่าน',
        semanticKey: 'methodology:top-themes',
        atoms: [
          for (final theme in mirror.topThemes.take(3))
            _themeAtom(
              theme,
              domain: ThaiBirthProfileCoreDomain.methodology,
              kind: ThaiBirthProfileCoreAtomKind.identityTheme,
              source: _ThemeAtomSource.topThemes,
            ),
        ],
      );
    }

    final domainSections = <ThaiBirthProfileCoreSection?>[
      lifeDomain(
        title: ThaiBirthProfileCoreReadingCopy.workTitle,
        domain: ThaiBirthProfileCoreDomain.work,
        houseNumber: 10,
      ),
      lifeDomain(
        title: ThaiBirthProfileCoreReadingCopy.moneyTitle,
        domain: ThaiBirthProfileCoreDomain.money,
        houseNumber: 2,
      ),
      lifeDomain(
        title: ThaiBirthProfileCoreReadingCopy.relationshipsTitle,
        domain: ThaiBirthProfileCoreDomain.relationships,
        houseNumber: 7,
      ),
      lifeDomain(
        title: ThaiBirthProfileCoreReadingCopy.wellbeingTitle,
        domain: ThaiBirthProfileCoreDomain.wellbeing,
        houseNumber: 6,
        includeMedicalDisclaimer: true,
      ),
    ];
    final sections = <ThaiBirthProfileCoreSection>[
      ThaiBirthProfileCoreSection(
        title: ThaiBirthProfileCoreReadingCopy.summaryTitle,
        domain: ThaiBirthProfileCoreDomain.summary,
        claims: summary,
      ),
      ...domainSections.whereType<ThaiBirthProfileCoreSection>(),
      ThaiBirthProfileCoreSection(
        title: ThaiBirthProfileCoreReadingCopy.closingTitle,
        domain: ThaiBirthProfileCoreDomain.closing,
        claims: closingClaims,
      ),
      ThaiBirthProfileCoreSection(
        title: ThaiBirthProfileCoreReadingCopy.methodologyTitle,
        domain: ThaiBirthProfileCoreDomain.methodology,
        claims: methodologyClaims,
        isMethodology: true,
      ),
    ];

    return ThaiBirthProfileCoreReading(
      title: reportTitle,
      subtitle: analysis.input.hasBirthTime
          ? 'คำอ่านพื้นดวงตลอดชีวิตจากวัน เวลา และสถานที่เกิด'
          : 'คำอ่านพื้นดวงจากวันและสถานที่เกิด พร้อมระบุข้อจำกัดเมื่อไม่มีเวลาเกิด',
      sections: sections,
      hasBirthTime: analysis.input.hasBirthTime,
    );
  }

  static ThaiMirrorThemeRef? selectHighestPriorityTheme(
    Iterable<ThaiMirrorThemeRef> themes, {
    required Iterable<String> supportedThemeIds,
    Iterable<String> excludedThemeIds = const [],
  }) {
    final supported = supportedThemeIds.toSet();
    final excluded = excludedThemeIds.toSet();
    final ranked =
        themes
            .where(
              (theme) =>
                  supported.contains(theme.themeId) &&
                  !excluded.contains(theme.themeId),
            )
            .toList(growable: false)
          ..sort((a, b) {
            final score = b.score.compareTo(a.score);
            return score != 0 ? score : a.themeId.compareTo(b.themeId);
          });
    return ranked.isEmpty ? null : ranked.first;
  }

  static ThaiMirrorThemeRef? selectClosingContextTheme(
    Iterable<ThaiMirrorThemeRef> themes,
  ) {
    final fullySupported = _strengthPhrases.keys
        .toSet()
        .intersection(_riskPhrases.keys.toSet())
        .intersection(_actionPhrases.keys.toSet());
    return selectHighestPriorityTheme(
      themes,
      supportedThemeIds: fullySupported,
    );
  }

  static ThaiBirthProfileCoreClaimAtom _themeAtom(
    ThaiMirrorThemeRef theme, {
    required ThaiBirthProfileCoreDomain domain,
    required ThaiBirthProfileCoreAtomKind kind,
    required _ThemeAtomSource source,
    ThaiMirrorSectionId? sectionId,
  }) {
    if (source == _ThemeAtomSource.sectionSupportingThemes &&
        sectionId == null) {
      throw ArgumentError('sectionId is required for a section theme atom');
    }
    final collectionPath = switch (source) {
      _ThemeAtomSource.topThemes => 'ThaiMirrorResult.topThemes',
      _ThemeAtomSource.sectionSupportingThemes =>
        'ThaiMirrorResult.sections[${sectionId!.id}].supportingThemes',
    };
    final itemPath = '$collectionPath[themeId=${theme.themeId}]';
    return ThaiBirthProfileCoreClaimAtom(
      kind: kind,
      domain: domain,
      sourceRef: '$itemPath.themeId',
      rawValue: theme.themeId,
      additionalEvidenceRefs: [
        ThaiBirthProfileCoreEvidenceRef(
          sourceRef: '$itemPath.score',
          rawValue: '${theme.score}',
        ),
        ThaiBirthProfileCoreEvidenceRef(
          sourceRef: '$itemPath.themeName',
          rawValue: theme.themeName,
        ),
      ],
      themeId: theme.themeId,
      score: theme.score,
    );
  }

  static List<ThaiBirthProfileCoreClaimAtom> _houseAtoms(
    ThaiAstrologyProfile? profile,
  ) {
    if (profile == null ||
        !profile.hasBirthTime ||
        profile.lagnaKey == null ||
        profile.lagnaKey!.isEmpty ||
        profile.siderealAscendantDeg == null) {
      return const [];
    }
    final signIndex = ThaiContentKeys.allLagna.indexOf(profile.lagnaKey!);
    if (signIndex < 0) return const [];
    final lagna = ThaiLagna(
      signKey: profile.lagnaKey!,
      lordKey:
          profile.lagnaLordKey ??
          ThaiLagnaRulership.lordForLagna(profile.lagnaKey!) ??
          '',
      siderealDeg: profile.siderealAscendantDeg!,
      signIndex: signIndex,
    );
    final domains = <int, ThaiBirthProfileCoreDomain>{
      10: ThaiBirthProfileCoreDomain.work,
      2: ThaiBirthProfileCoreDomain.money,
      7: ThaiBirthProfileCoreDomain.relationships,
      6: ThaiBirthProfileCoreDomain.wellbeing,
    };
    return [
      for (final house in HouseEngine.calculate(lagna: lagna))
        if (domains[house.houseNumber] case final domain?) ...[
          ThaiBirthProfileCoreClaimAtom(
            kind: ThaiBirthProfileCoreAtomKind.houseSign,
            domain: domain,
            sourceRef:
                'HouseEngine.calculate.house[${house.houseNumber}].signKey',
            rawValue: house.signKey,
            houseNumber: house.houseNumber,
            score: 70,
          ),
          ThaiBirthProfileCoreClaimAtom(
            kind: ThaiBirthProfileCoreAtomKind.houseLord,
            domain: domain,
            sourceRef:
                'HouseEngine.calculate.house[${house.houseNumber}].lordKey',
            rawValue: house.lordKey,
            houseNumber: house.houseNumber,
            score: 70,
          ),
        ],
    ];
  }

  static String _composeLagnaSummary(
    List<ThaiBirthProfileCoreClaimAtom> atoms,
    ThaiBirthProfileCoreClaimAtom identityAtom,
  ) {
    ThaiBirthProfileCoreClaimAtom? sign;
    ThaiBirthProfileCoreClaimAtom? lord;
    for (final atom in atoms) {
      if (atom.kind == ThaiBirthProfileCoreAtomKind.lagnaSign) sign = atom;
      if (atom.kind == ThaiBirthProfileCoreAtomKind.lagnaLord) lord = atom;
    }
    if (sign == null || lord == null) return '';
    final identityPhrase = _identityPhrases[identityAtom.themeId] ?? '';
    if (identityPhrase.isEmpty) return '';
    return 'เมื่อพิจารณาวัน เวลา และสถานที่เกิด '
        'ภาพบุคลิกตั้งต้นเชื่อมกับ${_lagnaLabel(sign.rawValue)}และ'
        '${_lordLabel(lord.rawValue)} โดยภาพรวมนี้ชี้ว่า$identityPhrase';
  }

  static ({String analysis, String guidance}) _composeHouseDomain(
    ThaiBirthProfileCoreDomain domain,
    List<ThaiBirthProfileCoreClaimAtom> atoms,
  ) {
    final sign = atoms.firstWhere(
      (atom) => atom.kind == ThaiBirthProfileCoreAtomKind.houseSign,
    );
    final lord = atoms.firstWhere(
      (atom) => atom.kind == ThaiBirthProfileCoreAtomKind.houseLord,
    );
    final signLabel = _lagnaLabel(sign.rawValue);
    final lordLabel = _lordLabel(lord.rawValue);
    final mode = _planetMode(lord.rawValue);
    return switch (domain) {
      ThaiBirthProfileCoreDomain.work => (
        analysis:
            'แนวโน้มหลัก: ในเรื่องงาน ตำแหน่ง$signLabelและ$lordLabelสะท้อนว่า'
            'คุณมักให้ความสำคัญกับ${mode.$1}',
        guidance:
            'สิ่งที่ควรระวัง: เมื่อแนวโน้มนี้ทำงานมากเกินไป อาจเกิด${mode.$2} '
            'สิ่งที่นำไปใช้ได้: ลอง${mode.$3}เพื่อให้งานเดินต่อได้โดยไม่ฝืนตัวเอง',
      ),
      ThaiBirthProfileCoreDomain.money => (
        analysis:
            'แนวโน้มหลัก: ในเรื่องเงิน ตำแหน่ง$signLabelและ$lordLabelสะท้อนว่า'
            'คุณมักจัดการทรัพยากรโดยให้ความสำคัญกับ${mode.$1}',
        guidance:
            'สิ่งที่ควรระวัง: ก่อนตัดสินใจเรื่องเงิน ควรเผื่อใจต่อ${mode.$2} '
            'สิ่งที่นำไปใช้ได้: ใช้${mode.$3}เป็นเกณฑ์ประกอบ',
      ),
      ThaiBirthProfileCoreDomain.relationships => (
        analysis:
            'แนวโน้มหลัก: ในความสัมพันธ์ ตำแหน่ง$signLabelและ$lordLabelสะท้อนว่า'
            'คุณมักสร้างความไว้ใจผ่าน${mode.$1}',
        guidance:
            'สิ่งที่ควรระวัง: เมื่ออยู่กับคนใกล้ตัว ควรระวัง${mode.$2} '
            'สิ่งที่นำไปใช้ได้: ลอง${mode.$3}เพื่อรักษาพื้นที่ของทั้งสองฝ่าย',
      ),
      ThaiBirthProfileCoreDomain.wellbeing => (
        analysis:
            'แนวโน้มหลัก: ในมุมสุขภาวะตามตำรา ตำแหน่ง$signLabelและ$lordLabel'
            'ชวนให้ดูแลพลังของตัวเองผ่าน${mode.$1}',
        guidance:
            'สิ่งที่ควรระวัง: หากเริ่มรู้สึกว่า${mode.$2} '
            'สิ่งที่นำไปใช้ได้: ลอง${mode.$3}และจัดเวลาพักให้สม่ำเสมอ',
      ),
      _ => (analysis: '', guidance: ''),
    };
  }

  static ({String strength, String risk, String action}) _composeClosing(
    List<ThaiBirthProfileCoreClaimAtom> atoms,
  ) {
    String phrase(
      ThaiBirthProfileCoreAtomKind kind,
      Map<String, String> registry,
    ) {
      for (final atom in atoms) {
        if (atom.kind == kind && atom.themeId != null) {
          return registry[atom.themeId] ?? '';
        }
      }
      return '';
    }

    final strength = phrase(
      ThaiBirthProfileCoreAtomKind.strengthTheme,
      _strengthPhrases,
    );
    final risk = phrase(ThaiBirthProfileCoreAtomKind.riskTheme, _riskPhrases);
    final action = phrase(
      ThaiBirthProfileCoreAtomKind.actionTheme,
      _actionPhrases,
    );
    return (
      strength: strength.isEmpty ? '' : 'จุดแข็งที่คุณพึ่งพาได้คือ$strength',
      risk: risk.isEmpty ? '' : 'เมื่อใช้จุดแข็งนี้มากเกินไป ควรระวัง$risk',
      action: action.isEmpty ? '' : 'เพื่อใช้จุดแข็งนี้ได้อย่างพอดี ลอง$action',
    );
  }

  static (String, String, String) _planetMode(String lordKey) =>
      switch (lordKey) {
        ThaiContentKeys.lagnaLordSun => (
          'ความชัดเจนและการตัดสินใจด้วยตัวเอง',
          'การยึดทิศทางเดียวจนไม่รับข้อมูลใหม่',
          'การกำหนดเป้าหมายและทบทวนผลอย่างตรงไปตรงมา',
        ),
        ThaiContentKeys.lagnaLordMoon => (
          'การรับรู้ความเปลี่ยนแปลงและความต้องการรอบตัว',
          'การตัดสินใจตามความผันผวนชั่วคราว',
          'การเว้นจังหวะก่อนตอบสนองและกลับมาดูความจำเป็นจริง',
        ),
        ThaiContentKeys.lagnaLordMars => (
          'ความกล้าลงมือและการจัดการสิ่งเร่งด่วน',
          'การเร่งเกินกำลังหรือปะทะก่อนเห็นภาพครบ',
          'การแบ่งแรงเป็นขั้นและกำหนดขอบเขตที่ชัด',
        ),
        ThaiContentKeys.lagnaLordMercury => (
          'ข้อมูล การเปรียบเทียบ และการสื่อสารให้เข้าใจตรงกัน',
          'การคิดหลายทางจนเปลี่ยนแผนบ่อย',
          'การเขียนเกณฑ์ตัดสินใจและตรวจรายละเอียดทีละส่วน',
        ),
        ThaiContentKeys.lagnaLordJupiter => (
          'ภาพระยะยาว ความรู้ และการขยายอย่างมีหลัก',
          'การคาดหวังผลมากกว่าทรัพยากรที่มี',
          'การตั้งเกณฑ์เติบโตที่วัดได้และเผื่อพื้นที่สำหรับการเรียนรู้',
        ),
        ThaiContentKeys.lagnaLordVenus => (
          'คุณค่า ความพอดี และความร่วมมือที่ทั้งสองฝ่ายรับได้',
          'การเลือกความสบายระยะสั้นแทนความจำเป็นระยะยาว',
          'การชั่งน้ำหนักคุณค่ากับต้นทุนก่อนตกลง',
        ),
        ThaiContentKeys.lagnaLordSaturn => (
          'วินัย ความต่อเนื่อง และการสร้างฐานทีละขั้น',
          'การแบกภาระนานเกินไปโดยไม่ปรับวิธี',
          'การวางระบบที่ทำซ้ำได้และกำหนดเวลาพักไว้ล่วงหน้า',
        ),
        _ => ('', '', ''),
      };

  static String _lordLabel(String key) => switch (key) {
    ThaiContentKeys.lagnaLordSun => 'ดาวอาทิตย์',
    ThaiContentKeys.lagnaLordMoon => 'ดาวจันทร์',
    ThaiContentKeys.lagnaLordMars => 'ดาวอังคาร',
    ThaiContentKeys.lagnaLordMercury => 'ดาวพุธ',
    ThaiContentKeys.lagnaLordJupiter => 'ดาวพฤหัสบดี',
    ThaiContentKeys.lagnaLordVenus => 'ดาวศุกร์',
    ThaiContentKeys.lagnaLordSaturn => 'ดาวเสาร์',
    _ => 'ดาวที่ระบบคำนวณได้',
  };

  static const _identityPhrases = <String, String>{
    'independent': 'พื้นดวงให้น้ำหนักกับการกำหนดทิศทางด้วยตัวเอง',
    'disciplined': 'พื้นดวงให้น้ำหนักกับความสม่ำเสมอและการรักษาระบบ',
    'curious': 'พื้นดวงให้น้ำหนักกับการเรียนรู้จากสิ่งใหม่',
    'practical': 'พื้นดวงให้น้ำหนักกับสิ่งที่นำไปใช้ได้จริง',
    'grounded': 'พื้นดวงให้น้ำหนักกับความมั่นคงและฐานที่ไว้ใจได้',
    'visionary': 'พื้นดวงให้น้ำหนักกับภาพระยะยาวและความหมายของสิ่งที่ทำ',
    'protective': 'พื้นดวงให้น้ำหนักกับการดูแลสิ่งที่เห็นว่าสำคัญ',
    'adaptable': 'พื้นดวงให้น้ำหนักกับการปรับวิธีเมื่อเงื่อนไขเปลี่ยน',
    'creative': 'พื้นดวงให้น้ำหนักกับการสร้างทางเลือกใหม่ด้วยตัวเอง',
    'ambitious': 'พื้นดวงให้น้ำหนักกับการพัฒนาและขยับเป้าหมายไปข้างหน้า',
  };

  static const _strengthPhrases = <String, String>{
    'independent': 'การกำหนดทิศทางและตัดสินใจด้วยตัวเอง',
    'disciplined': 'ความสม่ำเสมอและการรักษาระบบที่วางไว้',
    'curious': 'การเรียนรู้และตั้งคำถามกับข้อมูลใหม่',
    'practical': 'การแปลงแนวคิดให้เป็นขั้นตอนที่ใช้ได้จริง',
    'grounded': 'การรักษาฐานที่มั่นคงเมื่อเงื่อนไขเปลี่ยน',
    'visionary': 'การมองภาพระยะยาวก่อนเลือกทิศทาง',
    'protective': 'การดูแลสิ่งและคนที่เห็นว่าสำคัญ',
    'adaptable': 'การปรับวิธีโดยยังรักษาเป้าหมายหลัก',
    'creative': 'การสร้างทางเลือกเมื่อวิธีเดิมไม่ตอบโจทย์',
    'ambitious': 'แรงผลักดันให้พัฒนาเป้าหมายอย่างต่อเนื่อง',
    'persistence': 'ความสามารถในการเดินหน้าต่อเมื่อผลยังมาไม่ทันที',
    'communication': 'การทำให้ความคิดและความต้องการเข้าใจตรงกัน',
    'adaptability': 'การเปลี่ยนวิธีโดยไม่ทิ้งเป้าหมายหลัก',
    'leadership': 'การจัดทิศทางและประสานแรงของคนหลายฝ่าย',
    'creativity': 'การมองเห็นทางเลือกที่ยังไม่มีใครลอง',
    'empathy': 'การเข้าใจมุมมองและความต้องการของคนรอบตัว',
    'reliability': 'การรักษาคำมั่นและทำสิ่งสำคัญอย่างต่อเนื่อง',
  };

  static const _riskPhrases = <String, String>{
    'independent': 'การตัดสินใจลำพังจนพลาดข้อมูลจากคนอื่น',
    'disciplined': 'การยึดระบบเดิมแม้เงื่อนไขเปลี่ยนไปแล้ว',
    'curious': 'การเปิดเรื่องใหม่หลายทางจนสิ่งสำคัญไม่จบ',
    'practical': 'การเลือกเฉพาะผลระยะสั้นจนพลาดภาพกว้าง',
    'grounded': 'การรักษาความมั่นคงจนชะลอการเปลี่ยนที่จำเป็น',
    'visionary': 'การมองไกลกว่าทรัพยากรและขั้นตอนที่มี',
    'protective': 'การรับภาระแทนคนอื่นมากเกินขอบเขต',
    'adaptable': 'การปรับบ่อยจนทิศทางหลักไม่ชัด',
    'creative': 'การสร้างทางเลือกเพิ่มจนตัดสินใจไม่ลง',
    'ambitious': 'การเพิ่มเป้าหมายเร็วกว่ากำลังที่รองรับได้',
    'perfectionism': 'มาตรฐานที่สูงจนทำให้เริ่มหรือจบงานช้าลง',
    'impulsiveness': 'การลงมือก่อนตรวจผลกระทบให้ครบ',
    'overthinking': 'การวนอยู่กับการคิดจนเสียจังหวะลงมือ',
    'avoidance': 'การเลื่อนเรื่องที่ไม่สบายใจออกไปนานเกินจำเป็น',
    'self_criticism': 'การตัดสินตัวเองรุนแรงกว่าข้อเท็จจริง',
    'control': 'การพยายามควบคุมทุกเงื่อนไขเมื่อยังมีความไม่แน่นอน',
    'people_pleasing': 'การให้ความเห็นชอบของคนอื่นมาก่อนความจำเป็นของตัวเอง',
  };

  static const _actionPhrases = <String, String>{
    'independent': 'กำหนดเกณฑ์ตัดสินใจและขอข้อมูลค้านหนึ่งมุมก่อนสรุป',
    'disciplined': 'นัดทบทวนว่าระบบเดิมยังตอบเงื่อนไขจริงหรือไม่',
    'curious': 'เลือกคำถามหลักหนึ่งข้อและปิดการทดลองทีละเรื่อง',
    'practical': 'เพิ่มเกณฑ์ผลระยะยาวก่อนเลือกทางที่ทำได้เร็วที่สุด',
    'grounded': 'กำหนดจุดที่ความมั่นคงต้องเปิดทางให้การเปลี่ยนแปลง',
    'visionary': 'แตกภาพระยะยาวเป็นขั้นที่วัดผลและจัดทรัพยากรได้',
    'protective': 'แยกสิ่งที่ต้องดูแลออกจากภาระที่ควรคืนเจ้าของ',
    'adaptable': 'ล็อกเป้าหมายหลักไว้แล้วจำกัดสิ่งที่จะปรับในแต่ละรอบ',
    'creative': 'ตั้งเส้นตายเลือกหนึ่งทางแล้วทดสอบกับข้อเท็จจริง',
    'ambitious': 'จัดลำดับเป้าหมายและเพิ่มงานเมื่อฐานเดิมรองรับแล้ว',
    'trust_yourself_more': 'ตั้งเกณฑ์ตัดสินใจให้ชัดแล้วเชื่อผลที่ตรวจสอบได้',
    'open_to_collaboration': 'แบ่งปันข้อมูลและขออีกมุมมองก่อนสรุป',
    'develop_patience': 'ให้แต่ละขั้นมีเวลาพอโดยไม่เร่งผลเกินกระบวนการ',
    'embrace_change': 'ปรับแผนเมื่อข้อมูลใหม่เปลี่ยนเงื่อนไขสำคัญ',
    'express_emotions_more_freely':
        'บอกความรู้สึกและขอบเขตด้วยภาษาที่ตรงแต่สุภาพ',
    'balance_structure_with_flexibility':
        'รักษาโครงหลักไว้พร้อมเปิดพื้นที่ให้ปรับรายละเอียด',
  };

  static String _plain(String value) =>
      value.replaceAll('**', '').replaceAll(RegExp(r'\s+'), ' ').trim();

  static String _lifelong(String value) {
    final plain = _plain(value);
    const metaValidationMarkers = [
      'อย่าใช้ข้อความนี้แทน',
      'แทนการสังเกตพฤติกรรมจริง',
      'ข้อความนี้เป็นเพียง',
      'ผลนี้เป็นเพียง',
    ];
    if (metaValidationMarkers.any(plain.contains)) return '';
    const temporalMarkers = [
      'อายุ ',
      'ช่วงนี้',
      'ตอนนี้',
      'ช่วงปัจจุบัน',
      'ช่วงถัดไป',
      'ช่วงก่อนหน้า',
      'อนาคต',
      'ปีข้างหน้า',
      'กำลังอยู่',
      'จังหวะปัจจุบัน',
      'เส้นทางชีวิตเดินเป็นช่วง',
    ];
    if (temporalMarkers.any(plain.contains)) return '';
    return plain;
  }

  static String _thaiWeekday(int? number) => switch (number) {
    1 => 'อาทิตย์',
    2 => 'จันทร์',
    3 => 'อังคาร',
    4 => 'พุธ',
    5 => 'พฤหัสบดี',
    6 => 'ศุกร์',
    7 => 'เสาร์',
    _ => 'ที่ระบบคำนวณได้',
  };

  static String _lagnaLabel(String key) => switch (key) {
    'lagna_aries' => 'ราศีเมษ',
    'lagna_taurus' => 'ราศีพฤษภ',
    'lagna_gemini' => 'ราศีเมถุน',
    'lagna_cancer' => 'ราศีกรกฎ',
    'lagna_leo' => 'ราศีสิงห์',
    'lagna_virgo' => 'ราศีกันย์',
    'lagna_libra' => 'ราศีตุล',
    'lagna_scorpio' => 'ราศีพิจิก',
    'lagna_sagittarius' => 'ราศีธนู',
    'lagna_capricorn' => 'ราศีมังกร',
    'lagna_aquarius' => 'ราศีกุมภ์',
    'lagna_pisces' => 'ราศีมีน',
    _ => 'ราศีที่ระบบคำนวณได้',
  };
}
