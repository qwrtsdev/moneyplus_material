import 'package:flutter/material.dart';
import 'package:moneyplus_material/l10n/app_localizations.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({
    super.key,
    this.languagePreference = 'default',
    this.onLanguageChanged,
  });

  final String languagePreference;
  final ValueChanged<String>? onLanguageChanged;

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings_appbar),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            value: widget.languagePreference,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ).copyWith(
              labelText: l10n.settings_language_label,
            ),
            items: [
              DropdownMenuItem(
                value: 'default',
                child: Text(l10n.settings_language_default),
              ),
              for (final locale in AppLocalizations.supportedLocales)
                DropdownMenuItem(
                  value: locale.languageCode,
                  child: Text(switch (locale.languageCode) {
                    'th' => l10n.settings_language_thai,
                    'en' => l10n.settings_language_english,
                    _ => locale.languageCode,
                  }),
                ),
            ],
            onChanged: (languagePreference) {
              if (languagePreference != null) {
                widget.onLanguageChanged?.call(languagePreference);
              }
            },
          ),
        ],
      ),
    );
  }
}
