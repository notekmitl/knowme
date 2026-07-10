import 'package:flutter/material.dart';

/// Inline 24-hour birth-time entry: two separate **hour (00–23)** and
/// **minute (00–59)** controls — never a scrolling wheel and never AM/PM.
///
/// Uses Material 3 [DropdownMenu]s so desktop users can click to open, **type**
/// to filter/enter a value, and navigate with the keyboard; the bounded
/// `menuHeight` keeps the popup fully on-screen. Mobile-friendly too.
class ThaiBetaTimeField extends StatelessWidget {
  const ThaiBetaTimeField({
    super.key,
    required this.hour,
    required this.minute,
    required this.onHourChanged,
    required this.onMinuteChanged,
  });

  /// Selected hour, or null when not yet chosen.
  final int? hour;
  final int minute;
  final ValueChanged<int?> onHourChanged;
  final ValueChanged<int> onMinuteChanged;

  static String two(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: DropdownMenu<int>(
            key: const Key('thai_beta_hour_menu'),
            initialSelection: hour,
            enableFilter: true,
            requestFocusOnTap: true,
            menuHeight: 260,
            expandedInsets: EdgeInsets.zero,
            label: const Text('ชั่วโมง'),
            leadingIcon: const Icon(Icons.access_time_rounded),
            onSelected: onHourChanged,
            dropdownMenuEntries: [
              for (var h = 0; h <= 23; h++)
                DropdownMenuEntry<int>(value: h, label: two(h)),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Padding(
            padding: EdgeInsets.only(top: 18),
            child: Text(':',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
        ),
        Expanded(
          child: DropdownMenu<int>(
            key: const Key('thai_beta_minute_menu'),
            initialSelection: minute,
            enableFilter: true,
            requestFocusOnTap: true,
            menuHeight: 260,
            expandedInsets: EdgeInsets.zero,
            label: const Text('นาที'),
            onSelected: (v) => onMinuteChanged(v ?? 0),
            dropdownMenuEntries: [
              for (var m = 0; m <= 59; m++)
                DropdownMenuEntry<int>(value: m, label: two(m)),
            ],
          ),
        ),
      ],
    );
  }
}
