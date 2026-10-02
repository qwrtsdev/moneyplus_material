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
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    unawaited(_loadLocale());
  }

  Future<void> _loadLocale() async {
    final languageCode = await getData('locale');
    if (!mounted || languageCode == null) return;

    final matchingLocales = AppLocalizations.supportedLocales.where(
      (locale) => locale.languageCode == languageCode,
    );
    if (matchingLocales.isNotEmpty) {
      setState(() => _locale = matchingLocales.first);
    }
  }

  void _setLocale(Locale locale) {
    setState(() => _locale = locale);
    unawaited(saveData('locale', locale.languageCode));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoneyPlus',
      locale: _locale,
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
      home: HomeScreen(onLocaleChanged: _setLocale),
    );
  }
}