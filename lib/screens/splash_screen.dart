import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'home_screen.dart';
import 'dart:async';
import 'package:camera/camera.dart';  // Import CameraDescription

class SplashScreen extends StatefulWidget {
  final List<CameraDescription> cameras;  // Add cameras here

  // Modify constructor to accept cameras
  SplashScreen({required this.cameras});  // Accept cameras in the constructor

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _speakWelcome();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(cameras: widget.cameras),  // Pass cameras here
        ),
      );
    });
  }

  Future<void> _speakWelcome() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5); // Slow and clear
    await flutterTts.setPitch(1.0);
    await flutterTts.speak("Opening SmartVision App");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0C0E47), // Dark blue background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo3.png',
              height: 120,
              width: 120,
            ),
            SizedBox(height: 10),
            Text(
              'SmartVision',
              style: TextStyle(
                fontFamily: 'Times New Roman',
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Beyond Eyes.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
