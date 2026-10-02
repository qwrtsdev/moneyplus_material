import 'package:flutter/material.dart';
import 'package:moneyplus_material/l10n/app_localizations.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key, this.onLocaleChanged});

  final ValueChanged<Locale>? onLocaleChanged;

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context);
    final selectedLocale = AppLocalizations.supportedLocales.firstWhere(
      (locale) => locale.languageCode == currentLocale.languageCode,
      orElse: () => AppLocalizations.supportedLocales.first,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('ตั้งค่า')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<Locale>(
            value: selectedLocale,
            decoration: const InputDecoration(
              labelText: 'Language / ภาษา',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final locale in AppLocalizations.supportedLocales)
                DropdownMenuItem(
                  value: locale,
                  child: Text(switch (locale.languageCode) {
                    'th' => 'ไทย',
                    'en' => 'English',
                    _ => locale.languageCode,
                  }),
                ),
            ],
            onChanged: (locale) {
              if (locale != null) widget.onLocaleChanged?.call(locale);
            },
          ),
        ],
      ),
    );
  }
}
