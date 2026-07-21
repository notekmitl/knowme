import 'package:flutter/material.dart';

import '../thai_beta_province_options.dart';

/// Searchable province picker (type-ahead autocomplete) replacing the plain
/// dropdown. Typing `เชียง` narrows to เชียงใหม่ / เชียงราย; supports keyboard
/// navigation, mouse selection, and touch. The options popup is height-bounded
/// so it never runs off small screens.
class ThaiBetaProvinceField extends StatelessWidget {
  const ThaiBetaProvinceField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ThaiBetaProvinceOption? value;
  final ValueChanged<ThaiBetaProvinceOption?> onChanged;

  Iterable<ThaiBetaProvinceOption> _filter(String raw) {
    final query = raw.trim().toLowerCase();
    if (query.isEmpty) return kThaiBetaProvinces;
    return kThaiBetaProvinces.where((p) =>
        p.labelTh.toLowerCase().contains(query) ||
        p.resolverKey.toLowerCase().contains(query));
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<ThaiBetaProvinceOption>(
      initialValue: TextEditingValue(text: value?.labelTh ?? ''),
      displayStringForOption: (o) => o.labelTh,
      optionsBuilder: (editing) => _filter(editing.text),
      onSelected: onChanged,
      fieldViewBuilder: (context, controller, focusNode, onSubmit) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'จังหวัดที่เกิด (ถ้าทราบ)',
            hintText: 'พิมพ์เพื่อค้นหา เช่น เชียง',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.location_on_outlined),
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'ล้าง',
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      controller.clear();
                      onChanged(null);
                    },
                  ),
          ),
          onChanged: (text) {
            // Keep the selection in sync with exact text; otherwise clear it so
            // a half-typed name is never silently treated as a province.
            final match = kThaiBetaProvinces
                .where((p) => p.labelTh == text.trim())
                .cast<ThaiBetaProvinceOption?>()
                .firstWhere((_) => true, orElse: () => null);
            if (match?.resolverKey != value?.resolverKey) onChanged(match);
          },
          onFieldSubmitted: (_) => onSubmit(),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        final theme = Theme.of(context);
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280, maxWidth: 560),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return InkWell(
                    onTap: () => onSelected(option),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Text(option.labelTh,
                          style: theme.textTheme.bodyLarge),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
