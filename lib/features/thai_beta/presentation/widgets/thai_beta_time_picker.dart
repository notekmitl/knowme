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
          child: _ThaiBetaHourDropdown(
            hour: hour,
            onChanged: onHourChanged,
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

class _ThaiBetaHourDropdown extends StatefulWidget {
  const _ThaiBetaHourDropdown({
    required this.hour,
    required this.onChanged,
  });

  final int? hour;
  final ValueChanged<int?> onChanged;

  @override
  State<_ThaiBetaHourDropdown> createState() =>
      _ThaiBetaHourDropdownState();
}

class _ThaiBetaHourDropdownState extends State<_ThaiBetaHourDropdown> {
  late final TextEditingController _controller;
  int? _committedHour;
  bool _syncingController = false;

  @override
  void initState() {
    super.initState();
    _committedHour = widget.hour;
    _controller = TextEditingController(
      text: widget.hour == null ? '' : ThaiBetaTimeField.two(widget.hour!),
    )..addListener(_commitControllerValue);
  }

  @override
  void didUpdateWidget(covariant _ThaiBetaHourDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hour == _committedHour) return;
    _committedHour = widget.hour;
    _syncingController = true;
    _controller.text =
        widget.hour == null ? '' : ThaiBetaTimeField.two(widget.hour!);
    _syncingController = false;
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_commitControllerValue)
      ..dispose();
    super.dispose();
  }

  void _commitControllerValue() {
    if (_syncingController) return;
    final parsed = int.tryParse(_controller.text.trim());
    if (parsed == null || parsed < 0 || parsed > 23) return;
    _commit(parsed);
  }

  void _commit(int? value) {
    if (value == _committedHour) return;
    _committedHour = value;
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<int>(
      key: const Key('thai_beta_hour_menu'),
      controller: _controller,
      initialSelection: widget.hour,
      enableFilter: true,
      requestFocusOnTap: true,
      menuHeight: 260,
      expandedInsets: EdgeInsets.zero,
      label: const Text('ชั่วโมง'),
      leadingIcon: const Icon(Icons.access_time_rounded),
      onSelected: _commit,
      dropdownMenuEntries: [
        for (var h = 0; h <= 23; h++)
          DropdownMenuEntry<int>(
            value: h,
            label: ThaiBetaTimeField.two(h),
          ),
      ],
    );
  }
}
