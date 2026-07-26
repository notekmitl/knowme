import 'life_map_plain_thai_renderer.dart';
import 'life_map_verdict_semantics.dart';
import 'thai_mirror_life_timeline_state.dart';

/// V1.3.3 — map structured current claims into ≤4 life domains for UI.
///
/// Domains are derived from [LifeMapClaimDomain], never from rendered keywords.
abstract final class LifeMapCurrentDomainComposer {
  static const titleLife = 'การดำเนินชีวิต';
  static const titleWork = 'การงาน';
  static const titleLove = 'ความรัก';
  static const titleHealth = 'สุขภาพ';

  static const allowedTitles = <String>[
    titleLife,
    titleWork,
    titleLove,
    titleHealth,
  ];

  /// Product life-domain for a structured claim domain.
  static String? productTitleFor(LifeMapClaimDomain domain) {
    return switch (domain) {
      LifeMapClaimDomain.workRole ||
      LifeMapClaimDomain.opportunityExpand ||
      LifeMapClaimDomain.learningPath => titleWork,
      LifeMapClaimDomain.relationshipBond => titleLove,
      LifeMapClaimDomain.healthEnergy => titleHealth,
      LifeMapClaimDomain.moneySecurity ||
      LifeMapClaimDomain.familyHome ||
      LifeMapClaimDomain.identityBelonging ||
      LifeMapClaimDomain.dutyBurden ||
      LifeMapClaimDomain.transitionRebuild => titleLife,
    };
  }

  /// Build domain blocks for Current only. Empty for past/future callers.
  static List<ThaiMirrorLifeDomainBlock> compose({
    required LifeMapVerdictSemantics semantics,
    String comparison = '',
  }) {
    if (semantics.tense != LifeMapVerdictTense.current) {
      return const [];
    }

    final buckets = <String, List<_ClaimLine>>{
      titleLife: [],
      titleWork: [],
      titleLove: [],
      titleHealth: [],
    };

    void add(LifeMapClaimDomain domain, String role, String text) {
      final title = productTitleFor(domain);
      if (title == null) return;
      final cleaned = text.trim();
      if (cleaned.isEmpty) return;
      if (LifeMapPlainThaiRenderer.hasVagueRelationshipForm(cleaned)) return;
      if (LifeMapVerdictCopy.violatesPrimaryBody(cleaned)) return;
      if (_looksLikeUnsupportedHealth(title, cleaned)) return;
      final list = buckets[title]!;
      if (list.any(
        (c) => LifeMapPlainThaiRenderer.sameMeaningPublic(c.text, cleaned),
      )) {
        return;
      }
      // One structured claim → one product domain only (already by title).
      list.add(_ClaimLine(role: role, text: cleaned, domain: domain));
    }

    add(
      semantics.primary.domain,
      'situation',
      _withCurrentLead(semantics.primary.situationTh),
    );
    if (semantics.secondary != null) {
      add(
        semantics.secondary!.domain,
        'secondary',
        semantics.secondary!.situationTh,
      );
    }
    if (semantics.pressure != null) {
      add(
        semantics.pressure!.domain,
        'pressure',
        semantics.pressure!.pressureTh,
      );
    }
    if (semantics.consequence != null) {
      add(
        semantics.consequence!.domain,
        'consequence',
        semantics.consequence!.consequenceTh,
      );
    }

    // Comparison is a life-direction bridge when present.
    final bridge = comparison.trim();
    if (bridge.isNotEmpty &&
        !LifeMapVerdictCopy.violatesPrimaryBody(bridge) &&
        !buckets[titleLife]!.any(
          (c) => LifeMapPlainThaiRenderer.sameMeaningPublic(c.text, bridge),
        )) {
      buckets[titleLife]!.add(
        _ClaimLine(
          role: 'transition',
          text: bridge,
          domain: LifeMapClaimDomain.transitionRebuild,
        ),
      );
    }

    final out = <ThaiMirrorLifeDomainBlock>[];
    for (final title in allowedTitles) {
      final lines = buckets[title]!;
      if (lines.isEmpty) continue;
      final body = _synthesize(lines);
      if (body.isEmpty) continue;
      out.add(
        ThaiMirrorLifeDomainBlock(
          title: title,
          body: body,
          evidenceKeys: [
            for (final line in lines) ...[
              'domain:${line.domain.id}',
              'role:${line.role}',
            ],
          ],
        ),
      );
    }

    // Prefer at least การดำเนินชีวิต when any current evidence exists.
    if (out.isEmpty && semantics.primary.situationTh.trim().isNotEmpty) {
      final fallback = _withCurrentLead(semantics.primary.situationTh);
      if (fallback.isNotEmpty) {
        out.add(
          ThaiMirrorLifeDomainBlock(
            title: titleLife,
            body: fallback,
            evidenceKeys: [
              'domain:${semantics.primary.domainId}',
              'role:situation',
            ],
          ),
        );
      }
    }

    return out.take(4).toList(growable: false);
  }

  static String _withCurrentLead(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return '';
    if (t.startsWith('ตอนนี้') || t.startsWith('ขณะนี้')) return t;
    return 'ตอนนี้$t';
  }

  static String _synthesize(List<_ClaimLine> lines) {
    // Prefer situation + one distinct pressure/consequence (1–2 sentences).
    final situation = lines.where((l) => l.role == 'situation').toList();
    final rest = lines.where((l) => l.role != 'situation').toList();
    final parts = <String>[];
    if (situation.isNotEmpty) {
      parts.add(situation.first.text);
    }
    for (final line in rest) {
      if (parts.any(
        (p) => LifeMapPlainThaiRenderer.sameMeaningPublic(p, line.text),
      )) {
        continue;
      }
      parts.add(line.text);
      if (parts.length >= 2) break;
    }
    if (parts.isEmpty && lines.isNotEmpty) {
      parts.add(lines.first.text);
    }
    return parts.join(' ');
  }

  static bool _looksLikeUnsupportedHealth(String title, String text) {
    if (title != titleHealth) return false;
    const banned = [
      'โรค',
      'มะเร็ง',
      'หัวใจวาย',
      'เบาหวาน',
      'ความดัน',
      'ผ่าตัด',
      'ติดเชื้อ',
      'อวัยวะ',
      'วินิจฉัย',
      'ยาฆ่าเชื้อ',
    ];
    return banned.any(text.contains);
  }
}

class _ClaimLine {
  const _ClaimLine({
    required this.role,
    required this.text,
    required this.domain,
  });

  final String role;
  final String text;
  final LifeMapClaimDomain domain;
}
