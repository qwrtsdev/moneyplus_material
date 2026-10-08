import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'screens/settings_tab.dart';
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
  // null = follow system language
  Locale? _locale;
  double _textScale = 1.0;

  @override
  void initState() {
    super.initState();
    unawaited(_loadLocale());
    unawaited(_loadTextScale());
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

  Future<void> _loadTextScale() async {
    final scale = double.tryParse(await getData('textScale') ?? '');
    // Ignore values that aren't a dropdown choice (e.g. old slider steps)
    if (!mounted || !kTextScales.contains(scale)) return;
    setState(() => _textScale = scale!);
  }

  void _setLocale(Locale? locale) {
    setState(() => _locale = locale);
    unawaited(saveData('locale', locale?.languageCode ?? 'system'));
  }

  void _setTextScale(double scale) {
    setState(() => _textScale = scale);
    unawaited(saveData('textScale', scale.toString()));
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
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(_textScale),
        ),
        child: child!,
      ),
      home: HomeScreen(
        locale: _locale,
        onLocaleChanged: _setLocale,
        textScale: _textScale,
        onTextScaleChanged: _setTextScale,
      ),
    );
  }
}