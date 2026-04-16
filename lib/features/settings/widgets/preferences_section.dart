import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'section_card.dart';
import 'setting_row.dart';

class PreferencesSection extends StatefulWidget {
  const PreferencesSection({super.key});

  @override
  State<PreferencesSection> createState() => _PreferencesSectionState();
}

class _PreferencesSectionState extends State<PreferencesSection> {
  String _defaultCurrency = 'USD (\$)';
  String _lengthSystem = 'Metric';

  static const _currencies = [
    'USD (\$)',
    'EUR (€)',
    'GBP (£)',
    'GHS (₵)',
    'NGN (₦)',
  ];

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Preferences',
      icon: Icons.language_rounded,
      children: [
        const SettingRow(
          title: 'Default Currency',
          subtitle: 'Preferred currency for all automated conversions.',
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0EFFE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _defaultCurrency,
              isExpanded: true,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppTheme.dark,
              ),
              items: _currencies
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _defaultCurrency = v!),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const SettingRow(
          title: 'Default Length Unit',
          subtitle: 'System-wide standard for length and distance.',
        ),
        const SizedBox(height: 8),
        Row(
          children: ['Metric', 'Imperial'].map((s) {
            final selected = _lengthSystem == s;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _lengthSystem = s),
                child: Container(
                  margin: EdgeInsets.only(right: s == 'Metric' ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color:
                        selected ? AppTheme.primary : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    s,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
