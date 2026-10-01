import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoneyPlus',
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
      home: const HomeScreen(),
    );
  }
}