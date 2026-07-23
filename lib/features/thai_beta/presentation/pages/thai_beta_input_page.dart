import 'dart:async';

import 'package:flutter/material.dart';

import '../../application/thai_beta_analysis.dart';
import '../../application/thai_beta_current_analysis.dart';
import '../../domain/thai_beta_input.dart';
import '../thai_beta_province_options.dart';
import '../widgets/thai_beta_progress_bar.dart';
import '../widgets/thai_beta_province_field.dart';
import '../widgets/thai_beta_time_picker.dart';
import 'thai_beta_summary_page.dart';

/// `/beta/thai` — the public Thai Astrology Research entry form.
class ThaiBetaInputPage extends StatefulWidget {
  const ThaiBetaInputPage({super.key});

  @override
  State<ThaiBetaInputPage> createState() => _ThaiBetaInputPageState();
}

class _ThaiBetaInputPageState extends State<ThaiBetaInputPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();

  DateTime? _birthDate;
  int? _birthHour;
  int _birthMinute = 0;
  bool _birthTimeUnknown = false;
  ThaiBetaProvinceOption? _province;
  String? _gender;

  /// Session start — drives `durationSeconds` on the persisted record.
  final DateTime _startedAt = DateTime.now();

  static const _genders = ['ชาย', 'หญิง', 'อื่น ๆ', 'ไม่ระบุ'];

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 25, 1, 1),
      firstDate: DateTime(1920),
      lastDate: now,
      helpText: 'เลือกวันเกิด',
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกวันเกิด')),
      );
      return;
    }

    final input = ThaiBetaInput(
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      birthDate: _birthDate!,
      birthHour: _birthTimeUnknown ? null : _birthHour,
      birthMinute: _birthTimeUnknown ? 0 : _birthMinute,
      birthTimeUnknown: _birthTimeUnknown || _birthHour == null,
      province: _province?.labelTh,
      provinceKey: _province?.resolverKey,
      gender: _gender,
    );

    unawaited(_submitAnalysis(input));
  }

  Future<void> _submitAnalysis(ThaiBetaInput input) async {
    // New attempt must not leave a prior success exportable if this run fails.
    ThaiBetaCurrentAnalysis.clear();
    final analysis = await ThaiBetaAnalysisRunner.runAsync(
      input,
      startedAt: _startedAt,
    );
    if (!mounted) return;
    ThaiBetaCurrentAnalysis.set(analysis);

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ThaiBetaSummaryPage(analysis: analysis),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dateLabel = _birthDate == null
        ? 'เลือกวันเกิด'
        : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('ดูดวงไทย — งานวิจัย'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const ThaiBetaProgressBar(current: ThaiBetaStep.fillIn),
            Expanded(
              child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'กรอกข้อมูลเพื่อดูผลวิเคราะห์ดวงไทยของคุณ',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ระบบนี้อยู่ในช่วงเก็บข้อมูลวิจัย ความคิดเห็นของคุณจะช่วยให้เราพัฒนาให้แม่นยำขึ้น',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _firstName,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'ชื่อจริง *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'กรุณากรอกชื่อจริง' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lastName,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'นามสกุล *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'กรุณากรอกนามสกุล'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _FieldButton(
                      icon: Icons.calendar_today_rounded,
                      label: 'วันเกิด *',
                      value: dateLabel,
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 16),
                    if (!_birthTimeUnknown) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('เวลาเกิด (24 ชั่วโมง)',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant)),
                      ),
                      const SizedBox(height: 8),
                      ThaiBetaTimeField(
                        hour: _birthHour,
                        minute: _birthMinute,
                        onHourChanged: (v) => setState(() => _birthHour = v),
                        onMinuteChanged: (v) =>
                            setState(() => _birthMinute = v),
                      ),
                      const SizedBox(height: 4),
                    ],
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _birthTimeUnknown,
                      onChanged: (v) =>
                          setState(() => _birthTimeUnknown = v ?? false),
                      title: const Text('ฉันไม่ทราบเวลาเกิด'),
                    ),
                    if (_birthTimeUnknown)
                      Container(
                        margin: const EdgeInsets.only(top: 4, bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: scheme.secondaryContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline_rounded,
                                size: 18, color: scheme.onSecondaryContainer),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'ผลวิเคราะห์บางส่วนอาจคลาดเคลื่อน แต่ยังสามารถวิเคราะห์พื้นฐานได้',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSecondaryContainer,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    ThaiBetaProvinceField(
                      value: _province,
                      onChanged: (v) => setState(() => _province = v),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _gender,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'เพศ (ถ้าต้องการระบุ)',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        for (final g in _genders)
                          DropdownMenuItem(value: g, child: Text(g)),
                      ],
                      onChanged: (v) => setState(() => _gender = v),
                    ),
                    const SizedBox(height: 28),
                    FilledButton(
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('เริ่มวิเคราะห์'),
                    ),
                  ],
                ),
              ),
            ),
          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldButton extends StatelessWidget {
  const _FieldButton({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(value)),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}
