import 'package:flutter/material.dart';
import 'package:moneyplus_material/l10n/app_localizations.dart';

/// Text size choices: Normal, Big, Biggest.
const kTextScales = [1.0, 1.5, 2.0];

class SettingsTab extends StatefulWidget {
  const SettingsTab({
    super.key,
    this.locale,
    this.onLocaleChanged,
    this.textScale = 1.0,
    this.onTextScaleChanged,
  });

  final Locale? locale;
  final ValueChanged<Locale?>? onLocaleChanged;
  final double textScale;
  final ValueChanged<double>? onTextScaleChanged;

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sizeLabel = switch (widget.textScale) {
      1.0 => l10n.settings_text_size_normal,
      1.5 => l10n.settings_text_size_big,
      _ => l10n.settings_text_size_biggest,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings_appbar),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 'system' stands in for a null locale (follow device language)
          DropdownButtonFormField<String>(
            value: widget.locale?.languageCode ?? 'system',
            decoration: const InputDecoration(
              labelText: 'Language / ภาษา',
              border: OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(
                value: 'system',
                child: Text(l10n.settings_system_default),
              ),
              for (final locale in AppLocalizations.supportedLocales)
                DropdownMenuItem(
                  value: locale.languageCode,
                  child: Text(switch (locale.languageCode) {
                    'th' => 'ไทย',
                    'en' => 'English',
                    _ => locale.languageCode,
                  }),
                ),
            ],
            onChanged: (code) {
              if (code == null) return;
              widget.onLocaleChanged?.call(
                code == 'system' ? null : Locale(code),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            '${l10n.settings_text_size}: $sizeLabel',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Slider(
            // Opt into the current Material 3 slider look (handle + stop dots)
            // ignore: deprecated_member_use
            year2023: false,
            value: kTextScales.indexOf(widget.textScale).toDouble(),
            max: kTextScales.length - 1,
            divisions: kTextScales.length - 1,
            label: sizeLabel,
            onChanged: (index) =>
                widget.onTextScaleChanged?.call(kTextScales[index.round()]),
          ),
        ],
      ),
    );
  }
}
