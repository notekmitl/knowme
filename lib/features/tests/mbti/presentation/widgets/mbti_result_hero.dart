import 'package:flutter/material.dart';

/// Top hero for MBTI result — type, role title, summary, optional keyword chips.
class MbtiResultHero extends StatelessWidget {
  const MbtiResultHero({
    super.key,
    required this.typeCode,
    required this.roleTitle,
    required this.summaryText,
    this.keywordChips = const [],
  });

  final String typeCode;
  final String roleTitle;
  final String summaryText;
  final List<String> keywordChips;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple.shade700,
            Colors.deepPurple.shade500,
            Colors.deepPurple.shade400,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            typeCode,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          if (roleTitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              roleTitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.92),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (summaryText.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              summaryText,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (keywordChips.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: keywordChips
                  .take(3)
                  .map(
                    (label) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
