import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(SmartVisionApp());
}

class SmartVisionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartVision',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}


