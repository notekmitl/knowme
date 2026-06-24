import 'package:knowme/core/themes/theme_catalog_v1.dart';



import '../models/thai_mirror_consumer_view_state.dart';

import 'thai_mirror_content_context.dart';

import 'thai_mirror_content_engine.dart';

import 'thai_mirror_lagna_influence.dart';

import 'thai_mirror_theme_phrases.dart';

import 'thai_mirror_theme_variants.dart';



/// Consumer-facing Thai copy — person-first, no engine or internal labels.

enum _HeadlinePattern {

  personLabel,

  decisionMoment,

  othersSee,

  priorityFocus,

}



abstract final class ThaiMirrorConsumerCopy {

  static const _bannedInOutput = <String>[

    'ธีม',

    'แพทเทิร์น',

    'แนวโน้ม',

    'ลัคนา',

    'เจ้าเรือน',

    'มหาภูติ',

    'เลข 7 ตัว',

    'Signal',

    'Pattern',

    'Life Pattern',

    'Relationship Oriented',

    'Analytical',

    'Reflective',

  ];



  static const consumerDisclaimers = <String>[

    'ผลลัพธ์นี้เป็นมุมมองเพื่อทำความเข้าใจตัวเอง ไม่ใช่คำทำนาย',

    'สิ่งที่อ่านอาจตรงหรือไม่ตรงกับตัวคุณทั้งหมด — ใช้เป็นจุดเริ่มสังเกตตัวเอง',

  ];



  static ThaiMirrorContentContext buildContext({

    required List<String> allThemeIds,

    required List<String> topThemeIds,

    required int profileSeed,

    String? lagnaKey,

    List<String> growthPathIds = const [],

  }) {

    return ThaiMirrorContentContext(

      allThemeIds: allThemeIds,

      topThemeIds: topThemeIds,

      profileSeed: profileSeed,

      lagnaKey: lagnaKey,

      growthPathIds: growthPathIds,

    );

  }



  static String tagLabel(String themeId) => ThaiMirrorThemePhrases.phrase(themeId).tag;



  static String buildHeadline(

    List<String> themeIds, {

    int profileSeed = 0,

    String? lagnaKey,

    ThaiMirrorContentContext? ctx,

  }) {

    if (themeIds.isEmpty) {

      return 'คุณมีสไตล์เป็นของตัวเอง — ลองอ่านด้านล่างดูว่าตรงไหน';

    }



    final context = ctx ??

        ThaiMirrorContentContext(

          allThemeIds: themeIds,

          topThemeIds: themeIds,

          profileSeed: profileSeed,

          lagnaKey: lagnaKey,

        );



    final rotated = _rotateThemeIds(themeIds, context.profileSeed);

    final lead = rotated[(context.profileSeed.abs() + 3) % rotated.length];

    final restPool = rotated.where((id) => id != lead).toList(growable: false);

    final rest = _pickSpacedThemes(restPool, context.profileSeed + 1, 2);

    final picked = [lead, ...rest];

    final phrases = picked.map(ThaiMirrorThemePhrases.phrase).toList();



    final pattern = _headlinePattern(context.profileSeed, context.lagnaKey);



    final base = switch (pattern) {

      _HeadlinePattern.decisionMoment => _headlineDecision(phrases),

      _HeadlinePattern.othersSee => _headlineOthersSee(phrases),

      _HeadlinePattern.priorityFocus => _headlinePriority(phrases),

      _HeadlinePattern.personLabel => _headlinePerson(phrases),

    };



    final lagnaTail = ThaiMirrorContentEngine.heroHeadlineTail(context);

    final sigTheme = rotated[(context.profileSeed.abs() + 7) % rotated.length];

    final sigPhrase = ThaiMirrorThemePhrases.phrase(sigTheme);

    final primaryTag =
        ThaiMirrorThemePhrases.phrase(context.allThemeIds.first).tag;

    var signature = '$primaryTag · ${sigPhrase.tag} · ${sigPhrase.heroDetail}';

    final altTheme = context.allThemeIds[
        (context.profileSeed.abs() + 11) % context.allThemeIds.length];
    final altTag = ThaiMirrorThemePhrases.phrase(altTheme).tag;
    signature = '$signature · $altTag';



    if (lagnaTail.isEmpty) return '$base · $signature';

    return '$base — $lagnaTail · $signature';

  }



  static _HeadlinePattern _headlinePattern(
    int profileSeed,
    String? lagnaKey,
  ) {
    var hash = profileSeed * 37;
    if (lagnaKey != null && lagnaKey.isNotEmpty) {
      hash ^= lagnaKey.hashCode * 13;
    }
    return _HeadlinePattern.values[hash.abs() % _HeadlinePattern.values.length];
  }



  static String _headlinePerson(List<ThaiThemePhrase> phrases) {

    final parts = phrases.map((p) => p.heroDetail).toList();

    if (parts.length == 1) return 'คุณเป็นคน${parts[0]}';

    if (parts.length == 2) return 'คุณ${parts[0]} และ${parts[1]}';

    return 'คุณ${parts[0]} ${parts[1]} และ${parts[2]}';

  }



  static String _headlineDecision(List<ThaiThemePhrase> phrases) {

    final lead = phrases.first.headlinePart;

    if (phrases.length == 1) {

      return 'เวลาตัดสินใจเรื่องสำคัญ คุณมัก$lead';

    }

    return 'เวลาตัดสินใจเรื่องสำคัญ คุณมัก$lead และ${phrases[1].headlinePart}';

  }



  static String _headlineOthersSee(List<ThaiThemePhrase> phrases) {

    final lead = phrases.first.headlinePart;

    if (phrases.length == 1) {

      return 'คนรอบตัวมักเห็นคุณเป็น$lead';

    }

    return 'คนรอบตัวมักเห็นคุณเป็น$lead — โดยเฉพาะ${phrases[1].headlinePart}';

  }



  static String _headlinePriority(List<ThaiThemePhrase> phrases) {

    final parts = phrases.map((p) => p.headlinePart).toList();

    if (parts.length == 1) return 'คุณให้ความสำคัญกับ${parts[0]}';

    if (parts.length == 2) {

      return 'คุณให้ความสำคัญกับ${parts[0]} และ${parts[1]}';

    }

    return 'คุณให้ความสำคัญกับ${parts[0]} ${parts[1]} และ${parts[2]}';

  }



  static String buildHeroSummary(

    List<String> themeIds, {

    int profileSeed = 0,

    ThaiMirrorContentContext? ctx,

  }) {

    if (themeIds.isEmpty) {

      return fallbackHeroSummary;

    }



    final context = ctx ??

        ThaiMirrorContentContext(

          allThemeIds: themeIds,

          topThemeIds: themeIds,

          profileSeed: profileSeed,

        );



    final rotated = _rotateThemeIds(themeIds, context.profileSeed + 5);

    final details = <String>[];



    final maxDetails = 2 + (context.profileSeed.abs() % 3);

    for (var i = 0; i < rotated.length && details.length < maxDetails; i++) {

      details.add(ThaiMirrorThemePhrases.phrase(rotated[i]).heroDetail);

    }



    final accent = ThaiMirrorContentEngine.heroSummaryAccent(context, 0);

    var summary = details.join(' ');

    final lagnaAccent = ThaiMirrorLagnaInfluence.heroAccentVariant(
      context.lagnaKey,
      context.profileSeed,
    );
    if (lagnaAccent.isNotEmpty) {
      summary = '$summary · $lagnaAccent';
    }

    if (accent.isEmpty || lagnaAccent.isNotEmpty) return summary;

    return '$summary $accent';

  }



  static List<String> _pickSpacedThemes(

    List<String> themeIds,

    int profileSeed,

    int count,

  ) {

    if (themeIds.length <= count) return themeIds;

    final picks = <String>[];

    final step = 2 + (profileSeed.abs() % 2);

    var index = profileSeed.abs() % themeIds.length;

    var attempts = 0;

    while (picks.length < count && attempts < themeIds.length * 2) {

      final themeId = themeIds[index];

      if (!picks.contains(themeId)) picks.add(themeId);

      index = (index + step) % themeIds.length;

      attempts++;

    }

    if (picks.length < count) {

      for (final themeId in themeIds) {

        if (picks.length >= count) break;

        if (!picks.contains(themeId)) picks.add(themeId);

      }

    }

    return picks;

  }



  static List<String> _rotateThemeIds(List<String> ids, int seed) {

    if (ids.isEmpty) return ids;

    final start = seed.abs() % ids.length;

    return [for (var i = 0; i < ids.length; i++) ids[(start + i) % ids.length]];

  }



  static ThemeCopyVariant strengthForTheme({

    required String themeId,

    required ThaiMirrorContentContext ctx,

    required int cardIndex,

  }) {

    return ThaiMirrorContentEngine.selectStrengthVariant(

      themeId: themeId,

      ctx: ctx,

      cardIndex: cardIndex,

    );

  }



  static String? cautionTitle(String themeId) =>

      ThaiMirrorThemePhrases.phrase(themeId).cautionTitle;



  static String? cautionBody(String themeId) =>

      ThaiMirrorThemePhrases.phrase(themeId).cautionBody;



  static String lifeAspectSummary({

    required String aspect,

    required List<String> priorityThemeIds,

    required List<String> allThemeIds,

    required int profileSeed,

    Set<String> usedSummaries = const {},

    String? lagnaKey,

    List<String> growthPathIds = const [],

  }) {

    final ctx = ThaiMirrorContentContext(

      allThemeIds: allThemeIds,

      topThemeIds: priorityThemeIds.isNotEmpty ? priorityThemeIds : allThemeIds,

      profileSeed: profileSeed,

      lagnaKey: lagnaKey,

      growthPathIds: growthPathIds,

    );



    final candidates = <String>[];

    final seen = <String>{};



    void addCandidates(List<String> ids) {

      for (final id in ids) {

        if (seen.add(id)) candidates.add(id);

      }

    }



    final secondaryThemes = allThemeIds

        .where((id) => !priorityThemeIds.contains(id))

        .toList(growable: false);

    addCandidates(_rotateThemeIds(secondaryThemes, profileSeed));

    addCandidates(_rotateThemeIds(priorityThemeIds, profileSeed + 7));

    addCandidates(_rotateThemeIds(allThemeIds, profileSeed + 13));



    if (candidates.isEmpty) {

      return ThaiMirrorContentEngine.selectDashboardHint(

        aspect: aspect,

        themeId: 'independent',

        ctx: ctx,

        aspectOffset: 0,

      );

    }



    final aspectOffset = switch (aspect) {

      'work' => 0,

      'money' => 1,

      'love' => 2,

      'health' => 3,

      'luck' => 4,

      _ => 0,

    };



    final growthThemeId = growthPathIds.isNotEmpty
        ? growthPathIds[(profileSeed.abs() + aspectOffset) % growthPathIds.length]
        : null;

    final start = (profileSeed.abs() + aspectOffset) % candidates.length;



    for (var i = 0; i < candidates.length; i++) {

      final themeId = candidates[(start + i) % candidates.length];

      final enriched = ThaiMirrorContentEngine.selectDashboardHint(

        aspect: aspect,

        themeId: themeId,

        ctx: ctx,

        aspectOffset: aspectOffset,

        growthThemeId: growthThemeId,

      );

      if (enriched.isNotEmpty && !usedSummaries.contains(enriched)) return enriched;

    }



    for (var i = 0; i < candidates.length; i++) {

      final themeId = candidates[(start + i) % candidates.length];

      final enriched = ThaiMirrorContentEngine.selectDashboardHint(

        aspect: aspect,

        themeId: themeId,

        ctx: ctx,

        aspectOffset: aspectOffset,

        growthThemeId: growthThemeId,

      );

      if (enriched.isNotEmpty) return enriched;

    }



    return '';

  }



  static String buildSecretTip(List<String> themeIds) {

    if (themeIds.isEmpty) return secretTipFallback;



    for (final themeId in themeIds) {

      final advice = ThaiMirrorThemeVariants.adviceVariants(themeId);

      if (advice.isNotEmpty) {

        return 'เคล็ดลับ: ${advice.first}';

      }

    }



    final detail = ThaiMirrorThemePhrases.phrase(themeIds.first).heroDetail;

    return 'เคล็ดลับ: $detail';

  }



  static String buildAdviceBody(

    List<String> themeIds, {

    List<String> allThemeIds = const [],

    List<String> topThemeIds = const [],

    int profileSeed = 0,

    String? lagnaKey,

  }) {

    if (themeIds.isEmpty && allThemeIds.isEmpty) return defaultAdviceBody;



    final ctx = ThaiMirrorContentContext(

      allThemeIds: allThemeIds,

      topThemeIds: topThemeIds,

      profileSeed: profileSeed,

      lagnaKey: lagnaKey,

      growthPathIds: themeIds,

    );



    if (themeIds.isNotEmpty) {

      final advice = ThaiMirrorContentEngine.selectAdvice(

        growthThemeId: themeIds.first,

        ctx: ctx,

      );

      if (advice.isNotEmpty) return advice;

    }



    for (final themeId in allThemeIds) {

      final advice = ThaiMirrorContentEngine.selectAdvice(

        growthThemeId: themeId,

        ctx: ctx,

      );

      if (advice.isNotEmpty) return advice;

    }



    return defaultAdviceBody;

  }



  static String sanitizeDisplayText(String text) {

    var result = text.trim();

    if (result.isEmpty) return result;



    for (final theme in ThemeCatalogV1.all) {

      result = result.replaceAll(theme.name, '');

      result = result.replaceAll(theme.id, '');

    }



    for (final banned in _bannedInOutput) {

      result = result.replaceAll(banned, '');

    }



    result = result.replaceAll(RegExp(r'[A-Za-z]{2,}'), '');

    result = result.replaceAll(RegExp(r'\s{2,}'), ' ');

    return result.trim();

  }



  static bool containsBannedCopy(String text) {

    if (RegExp(r'[A-Za-z]{3,}').hasMatch(text)) return true;

    for (final banned in _bannedInOutput) {

      if (text.contains(banned)) return true;

    }

    return false;

  }



  static const fallbackHeroSummary =

      'คุณมีวิธีคิดและวิธีใช้ชีวิตที่เป็นแบบฉบับของตัวเอง '

      'ลองอ่านด้านล่างแล้วดูว่าตรงกับตัวคุณตรงไหนบ้าง';



  static const defaultAdviceBody =

      'ช่วงนี้ลองสังเกตว่าอะไรทำให้คุณมีพลัง และอะไรที่ทำให้เหนื่อยโดยไม่จำเป็น '

      'แล้วเลือกปรับทีละอย่างที่ทำได้จริงในสัปดาห์นี้';



  static const dataUsedWithBirthTime =

      'ใช้วัน เดือน ปีเกิด เวลาเกิด และจังหวัดที่เกิดจากโปรไฟล์ของคุณ';



  static const dataUsedWithoutBirthTime =

      'ใช้วัน เดือน ปีเกิด และจังหวัดที่เกิดจากโปรไฟล์ของคุณ '

      '(ไม่มีเวลาเกิด — บางส่วนอาจคลาดเคลื่อนเล็กน้อย)';



  static const calculationExplanation =

      'นำข้อมูลวันเกิดของคุณมาประมวลผลตามหลักดวงไทย '

      'แล้วแปลงเป็นภาษาที่อ่านเข้าใจง่าย โดยไม่แสดงรายละเอียดเชิงเทคนิค';



  static const resultsMeaning =

      'เป็นแนวทางดูตัวเอง ไม่ใช่คำฟันธง — ชีวิตเปลี่ยนได้เสมอตามการกระทำของคุณ';



  static const footerDisclaimer =

      'สิ่งที่อ่านเป็นเพียงมุมมองหนึ่ง ไม่ใช่คำตัดสินขั้นสุดท้าย — คุณเลือกเดินชีวิตของตัวเองได้เสมอ';



  static const secretTipFallback =

      'เคล็ดลับ: สังเกตสิ่งที่ทำซ้ำในชีวิตประจำวัน มักบอกคุณมากกว่าที่คิด';



  static ThaiMirrorBirthDataConfidenceState birthDataConfidence({

    required bool hasBirthTime,

  }) {

    if (hasBirthTime) {

      return const ThaiMirrorBirthDataConfidenceState(

        isComplete: true,

        title: 'ข้อมูลวันเกิดครบถ้วน',

        body: 'ใช้วันเกิดและเวลาเกิดในการวิเคราะห์ ผลลัพธ์ด้านบุคลิกน่าเชื่อถือมากขึ้น',

      );

    }

    return const ThaiMirrorBirthDataConfidenceState(

      isComplete: false,

      title: 'ไม่มีเวลาเกิด',

      body:

          'ใช้เฉพาะวัน เดือน ปีเกิดในการวิเคราะห์ '

          'ผลลัพธ์บางส่วนอาจคลาดเคลื่อน โดยเฉพาะด้านบุคลิกเชิงลึก',

    );

  }

}


