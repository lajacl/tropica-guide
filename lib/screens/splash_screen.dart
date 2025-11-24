import 'package:flutter/material.dart';
import 'dart:async';

import 'package:tropica_guide/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _imgSwapped = false;
  double _opacity = 0;

  void swapImage() {
    setState(() {
      _imgSwapped = true;
    });
  }

  void _animate() {
    setState(() {
      _opacity = 1;
    });
  }

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 1), () {
      swapImage();
    });
    Timer(Duration(seconds: 1), () {
      _animate();
    });
    Timer(Duration(seconds: 3), () {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Ensure the container fills the entire screen
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green, Colors.blue],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedOpacity(
                opacity: _opacity,
                duration: const Duration(seconds: 1),
                curve: Curves.easeOut,
                child: Column(
                  children: [
                    Text(
                      'TropicaGuide',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Stress Free Trip Planning",
                      style: TextStyle(color: Colors.yellow, fontSize: 20),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50),
              _imgSwapped
                  ? Image.asset('assets/suitcase_closed.png')
                  : Image.asset('assets/suitcase_open.png'),
            ],
          ),
        ),
      ),
    );
  }
}
