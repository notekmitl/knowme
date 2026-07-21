import 'package:flutter/material.dart';
import 'package:knowme/features/astrology/chinese_zodiac/domain/zodiac_personality_profile.dart';
import 'package:knowme/presentation/pages/bazi/bazi_result_copy.dart';

/// Year Animal personality section for the BaZi result page.
class ZodiacPersonalitySection extends StatelessWidget {
  const ZodiacPersonalitySection({
    super.key,
    required this.profile,
    required this.animalDisplayName,
    required this.lang,
  });

  final ZodiacPersonalityProfile profile;
  final String animalDisplayName;
  final String lang;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              BaziResultCopy.zodiacPersonalityTitle(lang),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              animalDisplayName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade900,
              ),
            ),
            const SizedBox(height: 12),
            _subsection(
              BaziResultCopy.zodiacCoreTraitsTitle(lang),
              Text(
                profile.coreTraits,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.grey.shade900,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _subsection(
              BaziResultCopy.zodiacWorkStyleTitle(lang),
              Text(
                profile.workStyle,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.grey.shade900,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _subsection(
              BaziResultCopy.zodiacRelationshipStyleTitle(lang),
              Text(
                profile.relationshipStyle,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.grey.shade900,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _subsection(
              BaziResultCopy.zodiacStrengthsTitle(lang),
              _bulletList(profile.strengths),
            ),
            const SizedBox(height: 12),
            _subsection(
              BaziResultCopy.zodiacChallengesTitle(lang),
              _bulletList(profile.challenges),
            ),
            const SizedBox(height: 12),
            _subsection(
              BaziResultCopy.zodiacGrowthSuggestionsTitle(lang),
              _bulletList(profile.growthSuggestions),
            ),
          ],
        ),
      ),
    );
  }

  Widget _subsection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _bulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(
                  '•',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  items[i],
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.38,
                    color: Colors.grey.shade900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
