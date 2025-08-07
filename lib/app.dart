import 'package:ai_app/screens/splash_view.dart';
import 'package:flutter/material.dart';

class CopticAIGeneratorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coptic AI Image Generator',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF212121),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2D2D2D),
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: ThemeMode.dark,
      home: const SplashScreen(),
    );
  }
}
