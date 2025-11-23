import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const TropicaGuideApp());
}

class TropicaGuideApp extends StatelessWidget {
  const TropicaGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TropicaGuide',
      theme: ThemeData(primarySwatch: Colors.green),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
