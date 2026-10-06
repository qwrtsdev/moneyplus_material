import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'package:moneyplus_material/l10n/app_localizations.dart';
import 'package:moneyplus_material/systems/preference.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const _defaultLanguage = 'default';
  String _languagePreference = _defaultLanguage;

  @override
  void initState() {
    super.initState();
    unawaited(_loadLocale());
  }

  Future<void> _loadLocale() async {
    final languagePreference = await getData('locale');
    if (!mounted || languagePreference == null) return;

    final isSupportedLanguage = AppLocalizations.supportedLocales.any(
      (locale) => locale.languageCode == languagePreference,
    );
    if (languagePreference == _defaultLanguage || isSupportedLanguage) {
      setState(() => _languagePreference = languagePreference);
    }
  }

  void _setLanguagePreference(String languagePreference) {
    setState(() => _languagePreference = languagePreference);
    unawaited(saveData('locale', languagePreference));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoneyPlus',
      locale: _languagePreference == _defaultLanguage
          ? null
          : Locale(_languagePreference),
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        final languageCode = deviceLocale?.languageCode == 'th' ? 'th' : 'en';
        return supportedLocales.firstWhere(
          (locale) => locale.languageCode == languageCode,
          orElse: () => supportedLocales.first,
        );
      },
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.notoSansThaiTextTheme(
          const TextTheme(
            bodyMedium: TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
        ),
      ),
      home: HomeScreen(
        languagePreference: _languagePreference,
        onLanguageChanged: _setLanguagePreference,
      ),
    );
  }
}