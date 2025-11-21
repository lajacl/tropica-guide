import 'package:flutter/material.dart';

main() {
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
    );
  }
}
