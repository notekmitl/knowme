import 'thai_mirror_consumer_copy.dart';
import 'thai_mirror_theme_phrases.dart';

/// V7 — Evidence-driven narrative composition layer.
///
/// The earlier versions wrote copy *from themes*: one theme → one paragraph.
/// Two people sharing the same top themes therefore read almost identically.
///
/// This layer writes copy *from evidence combinations*. Every theme maps to an
/// archetypal [ReportFacet]; the ordered list of themes (already weighted by the
/// engine) becomes an [EvidenceProfile] in which the strongest facet dominates
/// the wording, the secondary facet shifts the tone, and weaker facets appear
/// only as nuance. Paragraphs, the hero, contradictions, micro-stories and the
/// signature insight are all assembled from facet *pairs* plus a seeded
/// narrative-style rotation — so the same theme almost never produces the same
/// sentence twice.
///
/// IMPORTANT: this reads only existing engine output (the ordered theme ids).
/// It does not touch the engine, scoring, evidence calculation or selection.

enum ReportFacet {
  thinking,
  action,
  structure,
  people,
  independent,
  leadership,
  novelty,
  emotion,
  drive,
  caution,
}

/// Overall reading pacing, derived from the dominant facets.
enum ReportTone { reflective, energetic, calm, warm }

class ReportFacetData {
  const ReportFacetData({
    required this.shortTrait,
    required this.identity,
    required this.essence,
    required this.want,
    required this.gift,
    required this.trigger,
    required this.flip,
    required this.meetingScene,
    required this.decisionScene,
    required this.relationalScene,
    required this.quietScene,
    required this.signals,
    required this.growthEdge,
    required this.signature,
    required this.discovery,
  });

  /// A short verb phrase usable mid-sentence ("คิดละเอียด").
  final String shortTrait;

  /// Identity noun phrase ("คนที่คิดก่อนทำ").
  final String identity;

  /// Core clause describing the facet ("มักมองหลาย ๆ ด้านก่อนลงมือ").
  final String essence;

  /// What this facet quietly wants.
  final String want;

  /// What others gain from it.
  final String gift;

  /// A context that *flips* the person when this facet is the secondary pull.
  final String trigger;

  /// The flipped reaction once triggered.
  final String flip;

  final String meetingScene;
  final String decisionScene;
  final String relationalScene;
  final String quietScene;

  /// Plain-language observable signals (for the "why this feels true" block).
  final List<String> signals;

  /// The growth edge for this facet (used by advice + signature insight).
  final String growthEdge;

  /// A memorable, screenshot-worthy signature line.
  final String signature;

  /// A "you may never have noticed" discovery line.
  final String discovery;
}

/// A weighted reading of the profile's evidence.
class EvidenceProfile {
  EvidenceProfile._({
    required this.orderedFacets,
    required this.weights,
    required this.tone,
  });

  final List<ReportFacet> orderedFacets;
  final Map<ReportFacet, int> weights;
  final ReportTone tone;

  ReportFacet get primary =>
      orderedFacets.isNotEmpty ? orderedFacets.first : ReportFacet.thinking;
  ReportFacet get secondary =>
      orderedFacets.length > 1 ? orderedFacets[1] : primary;
  ReportFacet get tertiary =>
      orderedFacets.length > 2 ? orderedFacets[2] : secondary;
  ReportFacet get quaternary =>
      orderedFacets.length > 3 ? orderedFacets[3] : tertiary;

  /// The strongest facet that genuinely *contrasts* with [facet] — used to
  /// generate believable internal contradictions from real evidence.
  ReportFacet contrastFor(ReportFacet facet) {
    final opposites = _opposites[facet] ?? const <ReportFacet>[];
    for (final f in orderedFacets) {
      if (opposites.contains(f)) return f;
    }
    // No natural opposite present: fall back to the strongest *other* facet.
    for (final f in orderedFacets) {
      if (f != facet) return f;
    }
    return ReportFacet.emotion;
  }

  static EvidenceProfile fromThemeIds(List<String> orderedThemeIds) {
    final weights = <ReportFacet, int>{};
    final order = <ReportFacet>[];
    final n = orderedThemeIds.length;
    for (var i = 0; i < n; i++) {
      final facet = _facetForTheme(orderedThemeIds[i]);
      final w = n - i; // earliest (strongest) evidence weighs most.
      weights[facet] = (weights[facet] ?? 0) + w;
      if (!order.contains(facet)) order.add(facet);
    }
    if (order.isEmpty) {
      order.add(ReportFacet.thinking);
      weights[ReportFacet.thinking] = 1;
    }
    order.sort((a, b) {
      final cmp = (weights[b] ?? 0).compareTo(weights[a] ?? 0);
      if (cmp != 0) return cmp;
      return order.indexOf(a).compareTo(order.indexOf(b));
    });
    return EvidenceProfile._(
      orderedFacets: order,
      weights: weights,
      tone: _toneFrom(weights),
    );
  }

  static ReportTone _toneFrom(Map<ReportFacet, int> w) {
    int g(ReportFacet f) => w[f] ?? 0;
    final reflective =
        g(ReportFacet.thinking) + g(ReportFacet.caution) + g(ReportFacet.emotion);
    final energetic = g(ReportFacet.action) + g(ReportFacet.drive) + g(ReportFacet.novelty);
    final calm = g(ReportFacet.structure) + g(ReportFacet.independent);
    final warm = g(ReportFacet.people) + g(ReportFacet.leadership);
    final scores = {
      ReportTone.reflective: reflective,
      ReportTone.energetic: energetic,
      ReportTone.calm: calm,
      ReportTone.warm: warm,
    };
    var best = ReportTone.reflective;
    var bestScore = -1;
    scores.forEach((tone, score) {
      if (score > bestScore) {
        bestScore = score;
        best = tone;
      }
    });
    return best;
  }
}

/// Stateless generators that compose copy from an [EvidenceProfile].
abstract final class ThaiMirrorEvidenceComposer {
  static EvidenceProfile profileFor(List<String> orderedThemeIds) =>
      EvidenceProfile.fromThemeIds(orderedThemeIds);

  static ReportFacet facetForThemeId(String themeId) => _facetForTheme(themeId);

  // --- hero ---------------------------------------------------------------

  /// A headline built from the strongest *combination* (primary × secondary),
  /// so it almost never repeats across profiles.
  static String headline(EvidenceProfile p, int seed, List<String> themeIds) {
    // Vocabulary comes from the *specific* top themes (granular — ~50 distinct
    // phrasings), while the facet order gives the combination structure. So
    // "analytical + relationship_oriented" reads differently from
    // "analytical + independent" even though both are thinking-led.
    final parts = _topTraitWords(p, themeIds, 4);
    final s0 = parts[0];
    final s1 = parts[1];
    final s2 = parts[2];
    final s3 = parts[3];
    // Rotate *which* trait fills *which* slot — drawing on up to four facets —
    // so two profiles sharing their dominant facets still read differently.
    final mode = (seed.abs() ~/ 8) % 6;
    final (a, b, c) = switch (mode) {
      0 => (s0, s1, s2),
      1 => (s0, s2, s1),
      2 => (s1, s0, s2),
      3 => (s0, s1, s3),
      4 => (s0, s3, s2),
      _ => (s1, s2, s3),
    };
    final templates = <String>[
      'คุณเป็นคนที่$a\nแต่ในเวลาเดียวกัน\nก็$b',
      'หลายคนเห็นคุณเป็นคนที่$a\nแต่จริง ๆ แล้ว\nคุณ$bมากกว่าที่คิด',
      'คุณ$a\nและนั่นแหละ ทำให้คุณ$b\nในแบบที่เป็นคุณ',
      'ข้างนอกคุณดูเป็นคนที่$a\nแต่ลึก ๆ\nคุณคือคนที่$b',
      'คุณคือส่วนผสมของคนที่$a\nกับคนที่$b\nในคนคนเดียว',
      'คุณ$a $b\nและยัง$c\nในแบบที่ไม่เหมือนใคร',
      'ถ้าให้บอกสั้น ๆ\nคุณคือคนที่$a\nแต่ก็$cไปพร้อมกัน',
      'คุณไม่ได้เป็นแค่คนที่$a\nคุณยังเป็นคนที่$b\nและ$c',
      'เบื้องหลังความเป็นคนที่$a\nคือคนที่$b\nมากกว่าที่ใครเห็น',
      'คุณ$a เป็นธรรมชาติ\nและพอถึงเวลา ก็$b\nได้แบบไม่ต้องฝืน',
      'จุดที่ทำให้คุณเป็นคุณ\nคือการที่$a\nไปพร้อมกับ$b',
      'คนที่$a อย่างคุณ\nมักมีอีกด้านที่$c\nซ่อนอยู่',
    ];
    final idx = seed.abs() % templates.length;
    return _multi(templates[idx]);
  }

  /// Hero summary: 3 evidence signals woven into interpretation, not a list.
  static String heroSummary(EvidenceProfile p, int seed, List<String> themeIds) {
    final a = _facetData[p.primary]!;
    final contrast = p.contrastFor(p.primary);
    final cData = _facetData[contrast]!;

    // Granular, theme-specific opening (heroDetail is a distinct sentence per
    // theme) so two profiles do not share a single facet-level frame. The seed
    // also rotates *which* of the top themes supplies the lead sentence, so two
    // profiles that happen to share their single strongest theme still diverge
    // as soon as their secondary evidence differs.
    final details = _themeDetails(themeIds, 2);
    final detail = details[(seed.abs() ~/ 11) % details.length];
    final trait = _secondTraitWord(p, themeIds);
    final p1frames = <String>[
      '$detail และในเวลาเดียวกัน คุณก็เป็นคนที่$trait',
      '$detail ขณะที่อีกด้านหนึ่งของคุณก็$trait ไปพร้อมกัน',
      'คนรอบตัวมักสัมผัสได้ว่า $detail และคุณยัง$trait ในแบบของคุณ',
      '$detail — และพอมารวมกับการที่คุณ$trait ก็ยิ่งทำให้คุณเป็นคุณ',
    ];
    // Middle line carries a real contrast drawn from the evidence interaction.
    final p2frames = <String>[
      'ลึก ๆ คุณ**${_clip(a.want)}** '
          'แต่พอ${cData.trigger} คุณก็${cData.flip}ได้เหมือนกัน',
      'เบื้องหลังเกือบทุกอย่างคือการที่คุณ**${_clip(a.want)}** '
          'ถึงบางครั้งพอ${cData.trigger} อีกด้านของคุณก็โผล่ออกมา',
      'คุณ**${_clip(a.want)}** มากกว่าที่ปากบอก '
          'และพอ${cData.trigger} คุณกลับ${cData.flip}จนตัวเองก็แปลกใจ',
    ];
    final p1 = p1frames[(seed.abs() ~/ 3) % p1frames.length];
    final p2 = contrast == p.primary
        ? 'ลึก ๆ คุณ**${_clip(a.want)}** และยิ่งได้อยู่กับสิ่งที่ใช่ '
            'คุณก็ยิ่งเป็นตัวเอง'
        : p2frames[(seed.abs() ~/ 5) % p2frames.length];
    final p3opts = const [
      'ลองอ่านช้า ๆ แล้วถามตัวเองว่า “ใช่เราหรือเปล่า”',
      'อ่านแบบไม่ต้องรีบ เก็บเฉพาะส่วนที่รู้สึกว่าใช่',
      'บางอย่างอาจใช่ บางอย่างอาจไม่ ใช้เท่าที่ตรงกับคุณก็พอ',
      'สังเกตดูว่าตรงไหนสะกิดใจคุณที่สุด',
      'นี่ไม่ใช่คำฟันธง แต่เป็นมุมให้คุณลองคิดตาม',
      'ลองดูว่าอันไหนคือคุณ อันไหนไม่ใช่',
    ];
    final p3 = p3opts[(seed.abs() ~/ 7) % p3opts.length];
    return [_s(p1), _bold(p2), _s(p3)].join('\n\n');
  }

  static List<String> heroTags(EvidenceProfile p) =>
      p.orderedFacets.take(5).map((f) => _facetData[f]!.shortTrait).toList();

  /// Shareable summary points, ordered by evidence weight.
  static List<String> summaryPoints(EvidenceProfile p) {
    final pts = <String>[];
    final seen = <String>{};
    for (final f in p.orderedFacets.take(5)) {
      final line = _s('คนที่${_facetData[f]!.essence}');
      if (seen.add(line)) pts.add(line);
    }
    return pts;
  }

  // --- signature insight (the heart of the report) ------------------------

  /// One paragraph that only this profile receives. Combines identity,
  /// a generated contradiction, the growth edge and a forward-looking
  /// identity line into a single memorable insight.
  static ({String eyebrow, String body, String signature}) signatureInsight(
    EvidenceProfile p,
    int seed,
  ) {
    final a = _facetData[p.primary]!;
    final b = _facetData[p.secondary]!;
    final contrast = p.contrastFor(p.primary);
    final cData = _facetData[contrast]!;
    final growthFacet = p.orderedFacets.length > 2
        ? p.orderedFacets.last
        : p.secondary;
    final g = _facetData[growthFacet]!;

    final p1opts = <String>[
      'ถ้าตัดทุกอย่างออกไป แล้วเหลือไว้แค่สิ่งเดียวที่เป็นคุณจริง ๆ '
          'มันคือการที่คุณ${a.essence}',
      'ถ้าจะมีประโยคเดียวที่อธิบายคุณได้ มันคงเป็นว่า '
          'คุณเป็นคนที่${a.essence} และ${b.shortTrait}ไปพร้อมกัน',
      'สิ่งที่อยู่ใจกลางตัวคุณ — ที่ไม่ค่อยเปลี่ยนไม่ว่าจะเจออะไร — '
          'คือการที่คุณ${a.essence}',
    ];
    final para1 = p1opts[(seed.abs() ~/ 2) % p1opts.length];

    final p2opts = <String>[
      'แต่สิ่งที่ทำให้คุณน่าสนใจ คือคุณไม่ได้มีด้านเดียว — '
          'เพราะพอ${cData.trigger} คุณกลับ${cData.flip} '
          'จนบางทีคุณเองก็แปลกใจในตัวเอง',
      'และมีอีกด้านที่คนไม่ค่อยเห็น — พอ${cData.trigger} '
          'คุณกลับ${cData.flip} ทั้งที่ปกติไม่ใช่คนแบบนั้นเลย',
      'ความขัดกันเล็ก ๆ ในตัวคุณคือ ปกติคุณ${a.shortTrait} '
          'แต่พอ${cData.trigger} ด้านที่${cData.shortTrait}ก็ขึ้นมานำแทน',
    ];
    final para2 = contrast == p.primary
        ? 'และยิ่งคุณได้อยู่กับสิ่งที่ใช่ คุณก็ยิ่งเป็นตัวเองได้เต็มที่ '
            'โดยไม่ต้องฝืนเป็นใคร'
        : p2opts[(seed.abs() ~/ 3) % p2opts.length];

    final p3opts = <String>[
      'สิ่งที่คุณกำลังค่อย ๆ เรียนรู้คือ ${_lower(g.growthEdge)} '
          'และถ้าคุณให้เวลากับมันอีกหน่อย คุณจะไปได้ไกลกว่าที่เคยคิดไว้',
      'และสิ่งที่รออยู่ข้างหน้าคือการได้${_lower(g.growthEdge)} — '
          'ไม่ใช่เพื่อเป็นคนใหม่ แต่เพื่อเป็นตัวเองในเวอร์ชันที่สบายใจกว่าเดิม',
    ];
    final para3 = p3opts[(seed.abs() ~/ 5) % p3opts.length];

    final sig = (seed.abs() ~/ 7).isEven ? a.signature : b.signature;

    return (
      eyebrow: 'ถ้าจะเข้าใจคุณ แค่เรื่องเดียว',
      body: [_s(para1), _s(para2), _s(para3)].join('\n\n'),
      signature: _s(sig),
    );
  }

  // --- per-section building blocks ---------------------------------------

  static String sectionOverview({
    required String area,
    required ReportFacet primary,
    required ReportFacet secondary,
    required EvidenceProfile profile,
    required int seed,
  }) {
    final a = _facetData[primary]!;
    final b = _facetData[secondary]!;
    final lead = _areaLead[area] ?? 'ในเรื่องนี้';
    final effect = _areaEffect[area] ?? 'หลายเรื่องในชีวิตคุณเป็นแบบที่เป็น';
    final styles = <String>[
      // observation — facet-gift tail (less shared scaffolding)
      '$lead คุณมักเป็นคนที่${_dropMak(a.essence)} '
          'จึงไม่แปลกที่คุณ${_lower(a.gift)}',
      // reflection
      '$lead ถ้าลองสังเกตดี ๆ คุณ${a.shortTrait} '
          'และนั่นก็มักไปด้วยกันกับการที่คุณ${b.shortTrait} โดยไม่รู้ตัว',
      // contrast — facet-want tail
      '$lead คนอื่นอาจเห็นแค่ว่าคุณ${a.shortTrait} '
          'แต่จริง ๆ เบื้องหลังนั้นคือการที่คุณ${_lower(a.want)}',
      // cause→effect (uses the explicit area effect)
      '$lead การที่คุณ${a.essence} '
          'นี่อาจเป็นเหตุผลที่$effect',
      // memory / second-person reflection — facet-want tail
      '$lead น่าจะมีหลายครั้งที่คุณ${a.shortTrait} '
          'จนมันกลายเป็นส่วนหนึ่งของคุณไปแล้ว เพราะลึก ๆ คุณ${_lower(a.want)}',
      // two-sides framing
      '$lead คุณมีทั้งด้านที่${a.shortTrait} และด้านที่${b.shortTrait} '
          'และพอสองด้านนี้ทำงานด้วยกัน คุณก็${_lower(a.gift)}',
    ];
    // Pacing: the dominant tone shifts which narrative styles surface, so a
    // reflective profile reads differently from an energetic one.
    final idx = (seed.abs() ~/ 3 + _paceOffset(profile.tone)) % styles.length;
    return _s(styles[idx]);
  }

  /// A contradiction generated from the interaction of two facets.
  static String contradiction(ReportFacet a, ReportFacet b, int seed) {
    if (a == b) {
      final d = _facetData[a]!;
      return _s('ในตัวคุณมีทั้งคนที่${d.want} '
          'และคนที่บางครั้งก็เหนื่อยกับการพยายามขนาดนั้น');
    }
    final da = _facetData[a]!;
    final db = _facetData[b]!;
    final templates = <String>[
      '${_youOften(da.essence)} แต่พอ${db.trigger} คุณกลับ${db.flip}',
      'ปกติคุณเป็นคนที่${da.shortTrait} '
          'แต่พอ${db.trigger} ด้านที่${db.shortTrait}ในตัวคุณก็จะขึ้นมานำแทน',
      'มีสองเสียงในตัวคุณที่ไม่ค่อยตรงกัน — '
          'เสียงหนึ่ง${_wantTail(da.want)} อีกเสียงกลับ${db.flip}เมื่อ${db.trigger}',
    ];
    final idx = (seed.abs() ~/ 5) % templates.length;
    return _s(templates[idx]);
  }

  /// A micro-story that depends on the facet *and* the life area.
  static String microStory({
    required String area,
    required ReportFacet facet,
    required int seed,
  }) {
    final d = _facetData[facet]!;
    final group = _areaSceneGroup[area] ?? 'cognitive';
    final String scene;
    switch (group) {
      case 'relational':
        scene = d.relationalScene;
        break;
      case 'quiet':
        scene = d.quietScene;
        break;
      case 'decision':
        scene = d.decisionScene;
        break;
      default: // cognitive — alternate meeting / decision by seed
        scene = (seed.abs() ~/ 2).isEven ? d.meetingScene : d.decisionScene;
    }
    return _s(scene);
  }

  /// A short, emphasised callout. Seeded so that when the same facet lens
  /// recurs across sections the pull-quote still alternates between the facet's
  /// signature line and its "discovery" line, avoiding a repeated banner.
  static String pullQuote(ReportFacet facet, [int seed = 0]) {
    final d = _facetData[facet]!;
    final options = <String>[d.signature, d.discovery];
    return _s(options[seed.abs() % options.length]);
  }

  /// The facet's signature line only — used as the pull-quote for sections that
  /// also render a separate "discovery" line, so the two never collide into the
  /// same sentence appearing twice in one card.
  static String signatureQuote(ReportFacet facet) =>
      _s(_facetData[facet]!.signature);

  static String discovery(ReportFacet facet, int seed) =>
      _s(_facetData[facet]!.discovery);

  static ({String title, List<String> signals}) reasoning(
    ReportFacet facet,
    int seed,
  ) {
    final d = _facetData[facet]!;
    final titles = <String>[
      'ถ้าลองสังเกตดี ๆ มันมาจากสิ่งเดิม ๆ ที่คุณทำจนเป็นนิสัย',
      'นี่อาจเป็นเหตุผล — ลองดูจากสิ่งที่คุณทำซ้ำ ๆ',
      'มันไม่ได้มาจากไหนไกล แต่มาจากวิธีที่คุณใช้ชีวิตมาตลอด',
    ];
    final idx = (seed.abs() ~/ 11) % titles.length;
    return (title: titles[idx], signals: d.signals.map(_s).toList());
  }

  static String effect({
    required String area,
    required ReportFacet facet,
    required int seed,
  }) {
    final d = _facetData[facet]!;
    final templates = <String>[
      'สิ่งที่มักตามมาก็คือ คุณ${_lower(d.gift)} '
          'แต่บางครั้งก็แบกมันไว้คนเดียวนานเกินไป',
      'พอเป็นแบบนี้ คุณเลย${_lower(d.gift)} '
          'ถึงบางทีคนอื่นจะไม่ทันสังเกตก็ตาม',
      'ผลก็คือ คุณ${_lower(d.gift)} '
          'และนั่นคือสิ่งที่ทำให้คนรอบตัวรู้สึกว่ามีคุณอยู่แล้วอุ่นใจ',
    ];
    final idx = (seed.abs() ~/ 13) % templates.length;
    return _s(templates[idx]);
  }

  static String advice({
    required String area,
    required ReportFacet facet,
    required int seed,
  }) {
    final d = _facetData[facet]!;
    final areaAdvice = _areaAdvice[area];
    if (areaAdvice != null && (seed.abs() ~/ 2).isEven) {
      return _s(areaAdvice);
    }
    // Personalised fallback. Rotate the closing reassurance so the same
    // "ไม่ต้องรีบ…" tail doesn't end half the report's sections.
    const tails = <String>[
      'ไม่ต้องรีบ ค่อย ๆ ขยับทีละนิดก็พอ',
      'เริ่มจากครั้งเล็ก ๆ ที่ทำได้จริงก่อนก็ได้',
      'ให้เวลาตัวเองหน่อย ไม่มีอะไรต้องรีบพิสูจน์',
      'ลองทีละก้าว แล้วสังเกตว่าใจรู้สึกอย่างไร',
    ];
    final tail = tails[(seed.abs() ~/ 17) % tails.length];
    return _s('ลอง${_lower(d.growthEdge)} $tail');
  }

  static String reflectionQuestion({
    required String area,
    required ReportFacet facet,
    required int seed,
  }) {
    final byArea = _areaQuestions[area];
    if (byArea != null) return _s(byArea);
    final d = _facetData[facet]!;
    return _s('ครั้งล่าสุดที่คุณได้${_lower(d.want)}อย่างเต็มที่ คือเมื่อไหร่?');
  }

  /// Quiet-wisdom closing, flavoured by the primary facet + tone.
  static ({String eyebrow, String message, String signature}) closing(
    EvidenceProfile p,
    int seed,
  ) {
    final a = _facetData[p.primary]!;
    final b = _facetData[p.secondary]!;
    final essence = _lower(a.essence);
    final bt = b.shortTrait;
    final messages = <String>[
      'ดวงไทยไม่ได้มาบอกว่าอนาคตคุณจะเป็นอย่างไร\n'
          'และไม่ได้มาตัดสินว่าคุณควรเป็นใคร\n\n'
          'เรามักรอให้ตัวเอง “ดีกว่านี้” ก่อน\n'
          'ค่อยอนุญาตให้ตัวเองภูมิใจ\n'
          'แต่ถ้าดูจากทุกอย่างที่คุณเพิ่งอ่านมา —\n'
          'การที่คุณ$essence และ$btไปพร้อมกัน\n'
          'ก็ทำให้คุณดีพอในแบบของคุณมานานแล้ว\n\n'
          'วันนี้คุณไม่ต้องเปลี่ยนอะไรเลยก็ได้\n'
          'แค่กลับมาใจดีกับตัวเองอีกสักนิด\n'
          'เท่านั้นเอง',
      'ตลอดทั้งหน้านี้ เราพูดถึงหลายด้านของคุณ\n'
          'ทั้งด้านที่$essence และด้านที่$bt\n'
          'แต่ถ้าให้เหลือไว้แค่ความรู้สึกเดียว\n'
          'ขอให้เป็นว่า — สิ่งเหล่านี้ไม่ใช่เรื่องที่ต้องแก้\n'
          'มันคือสิ่งที่ทำให้คุณเป็นคุณ\n\n'
          'ไม่ต้องรีบเป็นใครให้ทันใคร\n'
          'แค่ค่อย ๆ เป็นตัวเองให้ชัดขึ้นในแต่ละวัน\n'
          'เท่านั้นก็ไกลพอแล้ว',
      'บางวันคุณอาจรู้สึกว่าตัวเองยังไม่ดีพอ\n'
          'ทั้งที่จริง ๆ คุณก็$btและ$essence\n'
          'มาตลอดโดยไม่เคยให้เครดิตตัวเองเลย\n\n'
          'ลองใจดีกับคนคนนั้นบ้าง\n'
          'คนที่พยายามมาตลอด — ก็คือตัวคุณเอง',
      'เราใช้เวลาเกือบทั้งชีวิต พยายามเป็นใครสักคนให้ได้\n'
          'ทั้งที่บางครั้ง สิ่งที่ยากที่สุด\n'
          'คือการอนุญาตให้ตัวเองเป็นอย่างที่เป็น\n\n'
          'คุณที่$essence และยัง$bt\n'
          'ไม่ได้มาถึงตรงนี้เพราะโชค\n'
          'แต่เพราะคุณเป็นแบบนี้มาตลอด',
    ];
    final sigs = <String>[a.signature, b.signature];
    final idx = (seed.abs() ~/ 11) % messages.length;
    return (
      eyebrow: 'ก่อนจะปิดหน้านี้',
      message: _multi(messages[idx]),
      signature: _s(sigs[(seed.abs() ~/ 13) % sigs.length]),
    );
  }

  // --- helpers ------------------------------------------------------------

  /// Distinct trait words drawn from the top themes' `headlinePart` (granular),
  /// padded with facet short-traits. Guarantees [n] entries.
  static List<String> _topTraitWords(
    EvidenceProfile p,
    List<String> themeIds,
    int n,
  ) {
    final words = <String>[];
    final seen = <String>{};
    for (final id in themeIds) {
      if (words.length >= n) break;
      final hp = ThaiMirrorThemePhrases.phrase(id).headlinePart.trim();
      if (hp.isEmpty || !seen.add(hp)) continue;
      words.add(hp);
    }
    for (final f in p.orderedFacets) {
      if (words.length >= n) break;
      final w = _facetData[f]!.shortTrait;
      if (seen.add(w)) words.add(w);
    }
    while (words.length < n) {
      words.add(_facetData[p.primary]!.shortTrait);
    }
    return words;
  }

  /// The first [n] distinct `heroDetail` sentences, strongest theme first, so a
  /// seed can rotate which strong theme leads the hero paragraph.
  static List<String> _themeDetails(List<String> themeIds, int n) {
    final out = <String>[];
    final seen = <String>{};
    for (final id in themeIds) {
      if (out.length >= n) break;
      final d = ThaiMirrorThemePhrases.phrase(id).heroDetail.trim();
      if (d.isEmpty || !seen.add(d)) continue;
      out.add(d);
    }
    if (out.isEmpty) out.add('คุณมีวิธีคิดและใช้ชีวิตที่เป็นแบบของตัวเอง');
    return out;
  }

  /// The second distinct theme's `headlinePart`, for "X but also Y" framing.
  static String _secondTraitWord(EvidenceProfile p, List<String> themeIds) {
    final firstHp = themeIds.isNotEmpty
        ? ThaiMirrorThemePhrases.phrase(themeIds.first).headlinePart.trim()
        : '';
    for (final id in themeIds.skip(1)) {
      final hp = ThaiMirrorThemePhrases.phrase(id).headlinePart.trim();
      if (hp.isNotEmpty && hp != firstHp) return hp;
    }
    return _facetData[p.secondary]!.shortTrait;
  }

  static int _paceOffset(ReportTone tone) => switch (tone) {
        ReportTone.reflective => 0,
        ReportTone.warm => 1,
        ReportTone.calm => 2,
        ReportTone.energetic => 3,
      };

  static String _s(String text) =>
      ThaiMirrorConsumerCopy.sanitizeDisplayText(text);

  static String _bold(String text) =>
      ThaiMirrorConsumerCopy.sanitizeDisplayText(text);

  static String _multi(String text) =>
      text.split('\n').map(_s).join('\n');

  static String _clip(String text) {
    final t = text.trim();
    return t.startsWith('อยาก') ? t.substring(4) : t;
  }

  static String _lower(String text) {
    final t = text.trim();
    if (t.startsWith('คุณ')) return t.substring(3);
    return t;
  }

  /// Drops a leading "มัก" from an essence clause so it can follow phrasing that
  /// already implies frequency (e.g. "คุณมักเป็นคนที่…"), avoiding "…ที่มัก…".
  static String _dropMak(String essence) {
    final t = essence.trim();
    return t.startsWith('มัก') ? t.substring(3).trimLeft() : t;
  }

  /// "คุณมัก…" prefixing that won't produce a doubled "มักมัก" (when the essence
  /// already starts with "มัก") nor an awkward "มักพอ…" (connective-led essence).
  static String _youOften(String essence) {
    final t = essence.trim();
    if (t.startsWith('มัก') || t.startsWith('พอ')) return 'คุณ$t';
    return 'คุณมัก$t';
  }

  /// A `want` phrase ready to follow "เสียงหนึ่ง" — exactly one leading "อยาก".
  /// (All facet `want` values already begin with "อยาก"; this guards against a
  /// doubled "อยากอยาก" and tolerates any future phrasing without one.)
  static String _wantTail(String want) {
    final t = want.trim();
    return t.startsWith('อยาก') ? t : 'อยาก$t';
  }
}

// --- area metadata ----------------------------------------------------------

const Map<String, String> _areaLead = {
  'work': 'ในเรื่องการงาน',
  'money': 'ในเรื่องเงิน',
  'love': 'ในความรัก',
  'family': 'กับครอบครัว',
  'social': 'ในกลุ่มเพื่อนและผู้คน',
  'health': 'ในเรื่องสุขภาพและพลังใจ',
  'rhythm': 'ในจังหวะชีวิตของคุณ',
  'pressure': 'เวลาเจอแรงกดดัน',
  'compatibility': 'ในเรื่องคนที่เข้ากับคุณ',
  'growth': 'ในเส้นทางการเติบโต',
};

const Map<String, String> _areaEffect = {
  'work': 'งานหลายชิ้นของคุณมีลายเซ็นของคุณติดอยู่',
  'money': 'การตัดสินใจเรื่องเงินของคุณไม่ค่อยเหมือนคนอื่น',
  'love': 'ความรักของคุณมักลึกกว่าที่คุณแสดงออก',
  'family': 'คนที่บ้านมักนึกถึงคุณก่อนเวลาต้องการที่พึ่ง',
  'social': 'คนรอบตัวรู้สึกสบายใจเวลาได้อยู่กับคุณ',
  'health': 'คุณมักไปต่อได้นาน จนบางทีลืมว่าตัวเองก็เหนื่อยเป็น',
  'rhythm': 'สิ่งดี ๆ มักมาในจังหวะที่คุณพร้อม',
  'pressure': 'คนรอบตัวมักรู้สึกอุ่นใจเวลามีคุณอยู่',
  'compatibility': 'ความสัมพันธ์ที่อยู่นานของคุณไม่ต้องฝืน',
  'growth': 'คุณเติบโตขึ้นเงียบ ๆ แต่สะสมอยู่ตลอด',
};

const Map<String, String> _areaSceneGroup = {
  'work': 'cognitive',
  'money': 'decision',
  'love': 'relational',
  'family': 'relational',
  'social': 'cognitive',
  'health': 'quiet',
  'rhythm': 'quiet',
  'pressure': 'cognitive',
  'compatibility': 'relational',
  'growth': 'quiet',
};

const Map<String, String> _areaAdvice = {
  'work': 'อนุญาตให้บางงานออกมาแค่ “ดีพอ” บ้าง '
      'พลังที่เก็บไว้จะได้เหลือไปทำสิ่งที่สำคัญกว่า',
  'money': 'ตั้งกติกาเงินที่เข้ากับใจตัวเอง ไม่ต้องเทียบกับใคร '
      'แล้วกลับมาดูเป็นระยะว่ามันยังพาคุณไปในทางที่อยากไปอยู่ไหม',
  'love': 'เป็นฝ่ายเอ่ยความรู้สึกก่อนสักครั้ง '
      'คนที่รักคุณอยากรู้ว่าคุณคิดอะไรอยู่ มากกว่าที่คุณคิด',
  'family': 'นอกจากดูแลเขา ลองเปิดให้เขาได้ดูแลคุณบ้าง '
      'การยอมให้คนอื่นช่วยก็เป็นของขวัญอย่างหนึ่ง',
  'social': 'ใช้พลังกับคนที่ใช่ และไม่ต้องรู้สึกผิดที่จะปฏิเสธบางอย่าง '
      'เวลาของคุณมีค่าพอที่จะเลือก',
  'health': 'ฟังร่างกายตั้งแต่มันเริ่มกระซิบ ไม่ต้องรอให้มันตะโกน '
      'การพักไม่ใช่การยอมแพ้ แต่คือการดูแลคนที่ต้องอยู่กับคุณไปอีกนาน',
  'rhythm': 'ไม่ต้องเร่งให้ทุกอย่างเกิดพร้อมกัน '
      'บางครั้งการรออย่างมีความหวัง ก็คือการลงมือทำอย่างหนึ่ง',
  'pressure': 'แยกสิ่งที่คุมได้ออกจากสิ่งที่คุมไม่ได้ แล้วโฟกัสทีละเรื่อง '
      'และถ้าเหนื่อย การขอความช่วยเหลือไม่ได้ทำให้คุณเล็กลงเลย',
  'compatibility': 'มองหาคนที่อยู่ด้วยแล้วคุณหายใจได้เต็มปอด '
      'ไม่ใช่คนที่ทำให้คุณต้องคอยระวังตัว',
  'growth': 'เลือกพัฒนาทีละเรื่องที่ใกล้ตัว แล้วให้เวลามันทำงาน '
      'คุณไม่ได้แข่งกับใคร นอกจากตัวเองเมื่อวาน',
};

const Map<String, String> _areaQuestions = {
  'work': 'ลองนึกดู — งานชิ้นไหนที่คุณภูมิใจที่สุด และวันนั้นคุณได้เป็นตัวเองแบบไหน?',
  'money': 'ครั้งล่าสุดที่ใช้เงินแล้วรู้สึกว่า “คุ้มจริง ๆ” มันคือเรื่องอะไร?',
  'love': 'คุณแสดงความรักด้วยวิธีไหนบ่อยที่สุด โดยที่อีกฝ่ายอาจยังไม่เคยรู้?',
  'family': 'มีครั้งไหนที่คุณเป็นที่พึ่งให้คนที่บ้าน โดยที่เขาอาจไม่เคยเอ่ยขอบคุณ?',
  'social': 'ใครคือคนที่อยู่ด้วยแล้วคุณได้เป็นตัวเองที่สุด — แล้วคุณให้เวลากับเขาพอหรือยัง?',
  'health': 'ครั้งสุดท้ายที่คุณได้พักจริง ๆ โดยไม่รู้สึกผิด คือเมื่อไหร่?',
  'rhythm': 'มีโอกาสไหนที่ตอนนั้นดูช้าไป แต่พอมองย้อนกลับ กลับมาถูกเวลาพอดี?',
  'pressure': 'เรื่องที่หนักที่สุดที่คุณผ่านมาได้ อะไรคือสิ่งที่พยุงคุณไว้ตอนนั้น?',
  'compatibility': 'คนที่ทำให้คุณรู้สึกปลอดภัยที่จะเป็นตัวเอง เขามีอะไรเหมือนกันบ้าง?',
  'growth': 'ถ้าปีหน้าคุณได้เก่งขึ้นเรื่องเดียว คุณอยากให้มันเป็นเรื่องอะไร?',
};

// --- facet opposites (for believable contradictions) ------------------------

const Map<ReportFacet, List<ReportFacet>> _opposites = {
  ReportFacet.thinking: [ReportFacet.action, ReportFacet.emotion, ReportFacet.novelty],
  ReportFacet.action: [ReportFacet.thinking, ReportFacet.caution],
  ReportFacet.structure: [ReportFacet.novelty, ReportFacet.emotion],
  ReportFacet.people: [ReportFacet.independent, ReportFacet.drive],
  ReportFacet.independent: [ReportFacet.people, ReportFacet.emotion],
  ReportFacet.leadership: [ReportFacet.emotion, ReportFacet.caution],
  ReportFacet.novelty: [ReportFacet.structure, ReportFacet.caution],
  ReportFacet.emotion: [ReportFacet.thinking, ReportFacet.structure, ReportFacet.independent],
  ReportFacet.drive: [ReportFacet.people, ReportFacet.emotion],
  ReportFacet.caution: [ReportFacet.action, ReportFacet.novelty],
};

// --- theme → facet map ------------------------------------------------------

ReportFacet _facetForTheme(String themeId) =>
    _themeFacet[themeId] ?? ReportFacet.thinking;

const Map<String, ReportFacet> _themeFacet = {
  'independent': ReportFacet.independent,
  'disciplined': ReportFacet.structure,
  'curious': ReportFacet.novelty,
  'practical': ReportFacet.action,
  'grounded': ReportFacet.structure,
  'visionary': ReportFacet.leadership,
  'protective': ReportFacet.people,
  'adaptable': ReportFacet.novelty,
  'creative': ReportFacet.novelty,
  'ambitious': ReportFacet.drive,
  'analytical': ReportFacet.thinking,
  'strategic': ReportFacet.thinking,
  'reflective': ReportFacet.thinking,
  'big_picture': ReportFacet.leadership,
  'detail_oriented': ReportFacet.structure,
  'fast_moving': ReportFacet.action,
  'systematic': ReportFacet.structure,
  'empathetic': ReportFacet.people,
  'sensitive': ReportFacet.emotion,
  'stable': ReportFacet.emotion,
  'expressive': ReportFacet.emotion,
  'reserved': ReportFacet.independent,
  'resilient': ReportFacet.drive,
  'calm_under_pressure': ReportFacet.emotion,
  'loyal': ReportFacet.people,
  'supportive': ReportFacet.people,
  'relationship_oriented': ReportFacet.people,
  'independent_in_relationships': ReportFacet.independent,
  'protective_of_others': ReportFacet.people,
  'diplomatic': ReportFacet.people,
  'builder': ReportFacet.action,
  'leader': ReportFacet.leadership,
  'explorer': ReportFacet.novelty,
  'specialist': ReportFacet.thinking,
  'teacher': ReportFacet.people,
  'entrepreneurial': ReportFacet.drive,
  'innovator': ReportFacet.novelty,
  'persistence': ReportFacet.drive,
  'communication': ReportFacet.people,
  'adaptability': ReportFacet.novelty,
  'leadership': ReportFacet.leadership,
  'creativity': ReportFacet.novelty,
  'empathy': ReportFacet.people,
  'reliability': ReportFacet.structure,
  'perfectionism': ReportFacet.caution,
  'impulsiveness': ReportFacet.action,
  'overthinking': ReportFacet.caution,
  'avoidance': ReportFacet.caution,
  'self_criticism': ReportFacet.caution,
  'control': ReportFacet.structure,
  'people_pleasing': ReportFacet.people,
  'trust_yourself_more': ReportFacet.drive,
  'open_to_collaboration': ReportFacet.people,
  'develop_patience': ReportFacet.emotion,
  'embrace_change': ReportFacet.novelty,
  'express_emotions_more_freely': ReportFacet.emotion,
  'balance_structure_with_flexibility': ReportFacet.structure,
};

// --- facet vocabulary -------------------------------------------------------

const Map<ReportFacet, ReportFacetData> _facetData = {
  ReportFacet.thinking: ReportFacetData(
    shortTrait: 'คิดละเอียด',
    identity: 'คนที่คิดก่อนทำ',
    essence: 'มองหลาย ๆ ด้านให้รอบก่อนจะลงมือ',
    want: 'อยากมั่นใจว่าคิดมาดีพอแล้วค่อยตัดสินใจ',
    gift: 'ช่วยให้คนรอบตัวตัดสินใจได้อย่างวางใจ',
    trigger: 'มีเวลาให้ได้ทบทวน',
    flip: 'คิดวนหลายรอบกว่าจะเลือก',
    meetingScene: 'ในที่ประชุม คุณมักเป็นคนที่ขอข้อมูลอีกนิด '
        'ก่อนจะออกความเห็น ทั้งที่ในใจเริ่มมีคำตอบแล้ว',
    decisionScene: 'เวลาต้องเลือกอะไรสักอย่าง '
        'คุณมักลิสต์ข้อดีข้อเสียในหัวอยู่เงียบ ๆ ก่อนเสมอ',
    relationalScene: 'เวลามีคนถามความเห็นเรื่องสำคัญ '
        'คุณอาจตอบว่า “ขอคิดดูก่อนนะ” ทั้งที่ใจเริ่มมีคำตอบแล้ว',
    quietScene: 'บางคืนคุณตั้งใจจะนอนเร็ว '
        'แต่ก็เผลอปล่อยให้ความคิดวิ่งต่อจนดึกกว่าที่ตั้งใจ',
    signals: [
      'วิธีที่คุณชั่งใจก่อนจะตอบ',
      'การที่คุณมองหลายมุมก่อนจะเชื่ออะไร',
      'ความที่คุณไม่ค่อยรีบสรุป',
    ],
    growthEdge: 'เชื่อสัญชาตญาณของตัวเองให้มากขึ้นอีกนิด',
    signature: 'การที่คุณคิดเยอะ ไม่ใช่เพราะลังเล แต่เพราะคุณแคร์ผลลัพธ์',
    discovery: 'คุณอาจไม่เคยสังเกตว่า เวลาที่คุณคิดนานที่สุด '
        'มักเป็นเรื่องที่คุณแคร์มากที่สุด',
  ),
  ReportFacet.action: ReportFacetData(
    shortTrait: 'ลงมือไว',
    identity: 'คนที่ลงมือก่อนลังเล',
    essence: 'พอเห็นว่าควรทำ ก็มักเริ่มเลยไม่รอจังหวะที่สมบูรณ์',
    want: 'อยากเห็นมันเกิดขึ้นจริง ไม่ใช่แค่อยู่ในหัว',
    gift: 'ทำให้สิ่งต่าง ๆ รอบตัวขยับและเดินหน้า',
    trigger: 'เห็นโอกาสอยู่ตรงหน้า',
    flip: 'ลงมือทันทีก่อนจะได้คิดให้รอบ',
    meetingScene: 'ในที่ประชุม พอได้ข้อสรุป '
        'คุณมักเป็นคนแรกที่ถามว่า “แล้วเราเริ่มกันเมื่อไหร่”',
    decisionScene: 'เวลาต้องเลือก '
        'คุณมักเชื่อความรู้สึกแรกแล้วลงมือเลย ค่อยปรับเอาทีหลัง',
    relationalScene: 'เวลาคนใกล้ตัวมีปัญหา '
        'คุณมักไม่รอให้เขาขอ แต่ลงมือช่วยจัดการให้เลย',
    quietScene: 'เวลาว่าง ๆ คุณมักอยู่ไม่ค่อยติด '
        'หาอะไรทำไปเรื่อยจนกว่าจะรู้สึกว่าวันนี้ได้ทำอะไรบ้าง',
    signals: [
      'วิธีที่คุณเริ่มก่อนที่ทุกอย่างจะพร้อม',
      'ความที่คุณไม่ชอบปล่อยให้เรื่องค้าง',
      'การที่คุณลงมือเร็วเวลาเห็นทางแล้ว',
    ],
    growthEdge: 'หยุดหายใจสักนิดก่อนจะพุ่งไปต่อ',
    signature: 'คุณไม่ได้ใจร้อน คุณแค่ไม่อยากปล่อยให้โอกาสหลุดมือ',
    discovery: 'คุณอาจไม่เคยรู้ว่า ความเร็วของคุณ '
        'จริง ๆ แล้วมาจากความกลัวที่จะเสียดายทีหลัง',
  ),
  ReportFacet.structure: ReportFacetData(
    shortTrait: 'รักความมั่นคง',
    identity: 'คนที่ชอบความเป็นระเบียบ',
    essence: 'ชอบให้สิ่งต่าง ๆ มีแบบแผนและอยู่ในที่ของมัน',
    want: 'อยากรู้สึกว่าทุกอย่างมั่นคงและพึ่งได้',
    gift: 'ทำให้คนรอบตัวรู้สึกอุ่นใจและวางใจ',
    trigger: 'ทุกอย่างไม่เป็นไปตามแผน',
    flip: 'รู้สึกอึดอัดจนต้องรีบจัดให้เข้าที่',
    meetingScene: 'ในที่ประชุม คุณมักเป็นคนที่ถามว่า '
        '“ตกลงใครรับผิดชอบส่วนไหน” เพื่อให้ทุกอย่างชัด',
    decisionScene: 'เวลาต้องเลือก '
        'คุณมักดูว่ามันมั่นคงในระยะยาวไหม มากกว่าว่ามันน่าตื่นเต้นแค่ไหน',
    relationalScene: 'คุณมักเป็นคนที่จำวันสำคัญของคนอื่นได้ '
        'และเตรียมอะไรเล็ก ๆ ไว้ล่วงหน้าโดยไม่บอก',
    quietScene: 'คุณมักรู้สึกดีขึ้นเวลาได้จัดข้าวของหรือวางแผนสัปดาห์ '
        'เหมือนใจได้กลับเข้าที่ไปด้วย',
    signals: [
      'วิธีที่คุณวางลำดับก่อนเริ่ม',
      'ความที่คุณไม่ชอบทิ้งอะไรค้างคา',
      'การที่คนอื่นมักพึ่งให้คุณดูเรื่องสำคัญ',
    ],
    growthEdge: 'ปล่อยให้บางอย่างไม่เป็นไปตามแผนได้บ้าง',
    signature: 'ความเป็นระเบียบของคุณ จริง ๆ แล้วคือวิธีดูแลคนรอบตัว',
    discovery: 'คุณอาจไม่เคยมองว่า การที่คุณชอบจัดทุกอย่างให้เข้าที่ '
        'คือวิธีที่คุณทำให้ใจตัวเองสงบ',
  ),
  ReportFacet.people: ReportFacetData(
    shortTrait: 'ใส่ใจคนรอบข้าง',
    identity: 'คนที่ใส่ใจคนรอบข้าง',
    essence: 'มักคิดถึงความรู้สึกของคนอื่นก่อนตัวเองเสมอ',
    want: 'อยากให้คนที่รักรู้สึกดีและปลอดภัย',
    gift: 'ทำให้คนรอบตัวรู้สึกว่ามีคนเข้าใจอยู่',
    trigger: 'มีคนต้องการคุณ',
    flip: 'ทุ่มเทให้เขาจนลืมดูแลตัวเอง',
    meetingScene: 'ในที่ประชุม คุณมักสังเกตว่าใครยังไม่ได้พูด '
        'แล้วหาจังหวะเปิดโอกาสให้เขา',
    decisionScene: 'เวลาต้องเลือก '
        'คำถามแรกในใจคุณมักเป็น “แล้วมันกระทบใครบ้าง”',
    relationalScene: 'เวลาคนใกล้ตัวไม่สบายใจ คุณมักไม่พูดอะไรมาก '
        'แต่จู่ ๆ ก็ทำสิ่งเล็ก ๆ ที่เขาชอบให้เงียบ ๆ',
    quietScene: 'แม้ในวันที่เหนื่อย '
        'คุณก็ยังอดคิดถึงคนที่บ้านหรือเพื่อนสักคนไม่ได้ว่าเขาเป็นยังไงบ้าง',
    signals: [
      'วิธีที่คุณฟังคนอื่นจริง ๆ ไม่ใช่แค่รอพูด',
      'การที่คุณจำเรื่องเล็ก ๆ ของคนสำคัญได้',
      'ความที่คุณมักนึกถึงคนอื่นก่อนตัวเอง',
    ],
    growthEdge: 'ใส่ใจความต้องการของตัวเองให้พอ ๆ กับที่ใส่ใจคนอื่น',
    signature: 'คุณมักคิดถึงความรู้สึกของคนอื่น ก่อนจะคิดถึงตัวเอง',
    discovery: 'คุณอาจไม่เคยรู้ว่า การดูแลคนอื่น '
        'คือวิธีที่คุณบอกรักโดยไม่ต้องใช้คำพูด',
  ),
  ReportFacet.independent: ReportFacetData(
    shortTrait: 'เป็นตัวของตัวเอง',
    identity: 'คนที่เดินด้วยตัวเองได้',
    essence: 'ชอบจัดการเรื่องของตัวเองมากกว่ารอให้ใครมาบอก',
    want: 'อยากมีพื้นที่และอิสระในแบบของตัวเอง',
    gift: 'ทำให้คนรอบตัววางใจว่าคุณดูแลตัวเองได้',
    trigger: 'มีคนพยายามเข้ามาช่วยมากเกินไป',
    flip: 'อยากถอยออกมาทำเอง',
    meetingScene: 'ในที่ประชุม คุณมักรับงานไปทำเงียบ ๆ '
        'แล้วเอาผลลัพธ์มาวางให้เลยโดยไม่ต้องถามระหว่างทาง',
    decisionScene: 'เวลาต้องเลือก '
        'คุณมักเชื่อการตัดสินใจของตัวเองก่อน แล้วค่อยฟังคนอื่นทีหลัง',
    relationalScene: 'แม้จะรักใครมาก '
        'คุณก็ยังต้องการเวลาส่วนตัวเพื่อกลับมาเป็นตัวเอง',
    quietScene: 'การได้อยู่กับตัวเองเงียบ ๆ สักพัก '
        'มักทำให้คุณรู้สึกเหมือนได้ชาร์จพลังกลับมา',
    signals: [
      'วิธีที่คุณจัดการเรื่องของตัวเองได้เอง',
      'ความที่คุณต้องการพื้นที่ส่วนตัว',
      'การที่คุณเชื่อการตัดสินใจของตัวเองก่อน',
    ],
    growthEdge: 'เปิดให้คนอื่นเข้ามาช่วยบ้าง โดยไม่รู้สึกว่าเป็นภาระ',
    signature: 'การพึ่งตัวเองของคุณ ไม่ใช่การปิดกั้นใคร แต่คือวิธีรู้สึกมั่นคง',
    discovery: 'คุณอาจไม่เคยสังเกตว่า การอยู่กับตัวเอง '
        'ไม่ได้แปลว่าเหงา แต่คือที่ที่คุณได้เป็นตัวเองที่สุด',
  ),
  ReportFacet.leadership: ReportFacetData(
    shortTrait: 'กล้านำ',
    identity: 'คนที่คนอื่นมองหาเวลาต้องการทิศทาง',
    essence: 'มักเห็นภาพรวมก่อน แล้วช่วยให้คนอื่นรู้ว่าจะไปทางไหน',
    want: 'อยากเห็นทุกคนไปถึงเป้าไปด้วยกัน',
    gift: 'ทำให้กลุ่มที่สับสนกลับมามีทิศทาง',
    trigger: 'ไม่มีใครกล้าก้าวออกมานำ',
    flip: 'ก้าวขึ้นมารับผิดชอบเองทั้งที่ไม่มีใครขอ',
    meetingScene: 'ในที่ประชุมที่เงียบงัน '
        'คุณมักเป็นคนที่เริ่มสรุปว่า “งั้นเราลองทำแบบนี้กันไหม”',
    decisionScene: 'เวลาต้องเลือก '
        'คุณมักคิดถึงผลกับทั้งทีม ไม่ใช่แค่ตัวเอง',
    relationalScene: 'เวลาคนรอบตัวท้อ '
        'คุณมักเป็นคนที่ช่วยให้เขาเห็นว่ายังมีทางไปต่อ',
    quietScene: 'บางครั้งคุณก็แอบเหนื่อย '
        'กับการเป็นคนที่ทุกคนคาดหวังให้เข้มแข็งตลอดเวลา',
    signals: [
      'วิธีที่คนอื่นหันมาถามคุณเวลาสับสน',
      'การที่คุณเห็นภาพรวมก่อนคนอื่น',
      'ความที่คุณไม่ทิ้งใครไว้ข้างหลัง',
    ],
    growthEdge: 'ยอมให้ตัวเองได้พักจากการเป็นที่พึ่งบ้าง',
    signature:
        'คนอื่นวางใจคุณ ไม่ใช่เพราะคุณไม่เคยกลัว แต่เพราะคุณไม่ทิ้งใครไว้ข้างหลัง',
    discovery: 'คุณอาจไม่เคยรู้ว่า เวลาคุณนำคนอื่น '
        'คุณกำลังให้สิ่งที่ตัวเองก็อยากได้ในวันที่อ่อนแอ',
  ),
  ReportFacet.novelty: ReportFacetData(
    shortTrait: 'ชอบลองสิ่งใหม่',
    identity: 'คนที่ชอบลองสิ่งใหม่',
    essence: 'เบื่อของซ้ำ ๆ และมักมองหาวิธีที่ต่างออกไป',
    want: 'อยากให้ชีวิตมีอะไรให้ตื่นเต้นอยู่เสมอ',
    gift: 'ทำให้สิ่งเดิม ๆ มีมุมใหม่ที่น่าสนใจ',
    trigger: 'ต้องอยู่กับอะไรเดิม ๆ นานเกินไป',
    flip: 'เริ่มกระวนกระวายและอยากเปลี่ยน',
    meetingScene: 'ในที่ประชุม '
        'คุณมักเป็นคนที่ถามว่า “ถ้าเราลองอีกแบบล่ะ จะเป็นยังไง”',
    decisionScene: 'เวลาต้องเลือก '
        'คุณมักเอนไปทางที่ได้ลองอะไรใหม่ มากกว่าทางที่ปลอดภัยแต่จำเจ',
    relationalScene: 'คุณมักเป็นคนที่ชวนคนใกล้ตัว '
        'ออกไปลองที่ใหม่ ๆ หรือทำอะไรที่ไม่เคยทำด้วยกัน',
    quietScene: 'เวลารู้สึกว่าชีวิตเริ่มนิ่งเกินไป '
        'คุณมักหาอะไรเล็ก ๆ มาเปลี่ยนบรรยากาศให้ตัวเอง',
    signals: [
      'วิธีที่คุณมองหาทางใหม่เสมอ',
      'ความที่คุณเบื่อง่ายกับของเดิม ๆ',
      'การที่คุณกล้าลองก่อนคนอื่น',
    ],
    growthEdge: 'อยู่กับบางอย่างให้นานพอจะเห็นผลของมัน',
    signature: 'ความไม่อยู่นิ่งของคุณ ไม่ใช่ความไม่แน่นอน แต่คือความอยากเติบโต',
    discovery: 'คุณอาจไม่เคยรู้ว่า ที่คุณชอบเปลี่ยนไปเรื่อย '
        'จริง ๆ แล้วคุณกำลังตามหาสิ่งที่ใช่สำหรับตัวเอง',
  ),
  ReportFacet.emotion: ReportFacetData(
    shortTrait: 'รู้สึกลึก',
    identity: 'คนที่รู้สึกลึกกว่าที่แสดงออก',
    essence: 'รับรู้อารมณ์รอบตัวได้ละเอียด ทั้งของตัวเองและคนอื่น',
    want: 'อยากให้ความสัมพันธ์รอบตัวจริงใจและอบอุ่น',
    gift: 'ทำให้คนรอบตัวรู้สึกว่าถูกเข้าใจจริง ๆ',
    trigger: 'เป็นเรื่องของคนที่คุณรัก',
    flip: 'ตัดสินใจด้วยใจเร็วกว่าที่ตั้งใจไว้',
    meetingScene: 'ในที่ประชุม '
        'คุณมักรับรู้บรรยากาศก่อนใคร ว่าตอนนี้ทุกคนรู้สึกยังไงกันอยู่',
    decisionScene: 'เวลาต้องเลือก '
        'สุดท้ายความรู้สึกมักมีน้ำหนักกับคุณมากกว่าเหตุผลบนกระดาษ',
    relationalScene: 'บางครั้งคำพูดเล็ก ๆ ของคนสำคัญ '
        'ก็อยู่ในใจคุณได้ทั้งวัน ทั้งที่เขาอาจพูดไปแล้วลืม',
    quietScene: 'มีบางคืนที่คุณนอนทบทวนความรู้สึกของวันนั้น '
        'ทั้งที่ทุกอย่างก็ผ่านไปแล้ว',
    signals: [
      'วิธีที่คุณรับรู้บรรยากาศได้ไวกว่าคนอื่น',
      'การที่คุณจำความรู้สึกได้นานกว่าจำเหตุการณ์',
      'ความที่คุณแคร์คนอื่นได้ลึก',
    ],
    growthEdge: 'แบ่งปันความรู้สึกออกมาบ้าง แทนที่จะเก็บไว้คนเดียว',
    signature: 'การที่คุณรู้สึกเยอะ ไม่ใช่ความอ่อนแอ '
        'แต่คือสิ่งที่คนส่วนใหญ่ไม่มี',
    discovery: 'คุณอาจไม่เคยรู้ว่า ความรู้สึกที่ท่วมท้นในบางวัน '
        'คือราคาของการที่คุณแคร์โลกใบนี้มากกว่าคนทั่วไป',
  ),
  ReportFacet.drive: ReportFacetData(
    shortTrait: 'ไม่ยอมหยุดพัฒนา',
    identity: 'คนที่ไม่ยอมหยุดอยู่กับที่',
    essence: 'พอตั้งใจแล้ว มักผลักดันตัวเองไปต่อจนกว่าจะถึง',
    want: 'อยากเห็นตัวเองเก่งขึ้นและไปได้ไกลกว่าเดิม',
    gift: 'เป็นแรงให้คนรอบตัวอยากพัฒนาตาม',
    trigger: 'เจอเป้าหมายที่ท้าทาย',
    flip: 'ทุ่มสุดตัวจนลืมพัก',
    meetingScene: 'ในที่ประชุม '
        'คุณมักเป็นคนที่ถามว่า “เราทำให้ดีกว่านี้ได้อีกไหม”',
    decisionScene: 'เวลาต้องเลือก '
        'คุณมักเลือกทางที่ทำให้ตัวเองได้โตขึ้น แม้มันจะเหนื่อยกว่า',
    relationalScene: 'คุณมักอยากให้คนที่รัก '
        'ได้เติบโตไปพร้อมกับคุณ ไม่ใช่หยุดอยู่กับที่',
    quietScene: 'แม้ในวันหยุด '
        'คุณก็มักรู้สึกผิดเล็ก ๆ ถ้าไม่ได้ทำอะไรที่รู้สึกว่ามีประโยชน์',
    signals: [
      'วิธีที่คุณไม่พอใจกับการอยู่กับที่',
      'ความที่คุณผลักตัวเองต่อแม้เหนื่อย',
      'การที่คุณมองหาเวอร์ชันที่ดีกว่าของตัวเองเสมอ',
    ],
    growthEdge: 'ยอมรับว่าตอนนี้ของคุณก็ดีพอแล้ว ระหว่างที่ยังเดินต่อ',
    signature: 'คุณไม่ได้กลัวความเหนื่อย คุณแค่กลัวการอยู่กับที่',
    discovery: 'คุณอาจไม่เคยรู้ว่า ที่คุณผลักตัวเองหนักขนาดนั้น '
        'ลึก ๆ คือการอยากพิสูจน์ให้ตัวเองเห็น ไม่ใช่ให้ใคร',
  ),
  ReportFacet.caution: ReportFacetData(
    shortTrait: 'รอบคอบ',
    identity: 'คนที่ระวังตัวและคิดละเอียด',
    essence: 'มักเห็นความเสี่ยงและสิ่งที่อาจผิดพลาดก่อนคนอื่น',
    want: 'อยากแน่ใจว่าจะไม่พลาดในเรื่องสำคัญ',
    gift: 'ช่วยให้กลุ่มไม่ตัดสินใจพลาดแบบที่เลี่ยงได้',
    trigger: 'ต้องตัดสินใจเร็วโดยไม่มีเวลาคิด',
    flip: 'ลังเลและกลับไปคิดวนอีกหลายรอบ',
    meetingScene: 'ในที่ประชุม '
        'คุณมักเป็นคนที่ถามว่า “แล้วถ้ามันไม่เป็นไปตามแผนล่ะ”',
    decisionScene: 'เวลาต้องเลือก '
        'คุณมักนึกถึงสิ่งที่อาจผิดพลาดไว้ก่อน เผื่อไว้เสมอ',
    relationalScene: 'คุณมักเป็นห่วงคนที่รักล่วงหน้า '
        'จนบางทีเตือนเขาในเรื่องที่ยังไม่ทันเกิด',
    quietScene: 'บางคืนคุณนอนคิดถึงเรื่องที่ยังไม่เกิด '
        'แล้วก็เผลอกังวลกับมันไปก่อนล่วงหน้า',
    signals: [
      'วิธีที่คุณเตรียมแผนสำรองไว้เสมอ',
      'ความที่คุณเห็นความเสี่ยงก่อนคนอื่น',
      'การที่คุณคิดเผื่อสิ่งที่ยังไม่เกิด',
    ],
    growthEdge: 'เชื่อว่าหลายอย่างจะผ่านไปได้ดี แม้คุณไม่ได้เตรียมทุกอย่าง',
    signature: 'ความกังวลของคุณ จริง ๆ แล้วคือความใส่ใจ '
        'ที่อยากให้ทุกอย่างออกมาดี',
    discovery: 'คุณอาจไม่เคยมองว่า ความระวังของคุณ '
        'คือเหตุผลที่คนรอบตัวรู้สึกปลอดภัยเวลาอยู่กับคุณ',
  ),
};

