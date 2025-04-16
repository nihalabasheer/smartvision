import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FlutterTts flutterTts = FlutterTts();
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _recognizedText = "Say 'Detection', 'Call Help', or 'Settings'";

  @override
  void initState() {
    super.initState();
    _speakOptions();
  }

  // Method to speak the available options
  void _speakOptions() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.5); // Slow down the speech output
    await flutterTts.speak("You have three available options: Detection, Call Help, and Settings. Click the 'Tap to Speak' button at the bottom to select your choice.");
  }

  // Method to start listening for voice commands
  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
      });
      _speech.listen(onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
        });
        _handleVoiceCommand(_recognizedText);
      });
    } else {
      flutterTts.speak("Voice recognition is not available.");
    }
  }

  // Method to handle recognized voice command
  void _handleVoiceCommand(String command) {
    if (command.toLowerCase().contains("detection")) {
      flutterTts.speak("Opening Detection screen.");
      // Navigate to Detection screen here (or add your detection logic)
    } else if (command.toLowerCase().contains("call help")) {
      flutterTts.speak("Calling for help.");
      // Trigger emergency logic here
    } else if (command.toLowerCase().contains("settings")) {
      flutterTts.speak("Opening Settings.");
      // Navigate to Settings screen here
    } else {
      flutterTts.speak("Sorry, I didn't recognize that command. Please say 'Detection', 'Call Help', or 'Settings'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('SmartVision', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 90,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0C0E47), Color(0xFF3A4D8A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            HomeButton(
              icon: Icons.visibility,
              label: 'Detection',
              onTap: () {
                flutterTts.speak("Opening Detection screen.");
                // Navigate to Detection screen
              },
            ),
            SizedBox(height: 25),
            HomeButton(
              icon: Icons.phone,
              label: 'Call Help',
              onTap: () {
                flutterTts.speak("Calling for help.");
                // Trigger emergency logic
              },
            ),
            SizedBox(height: 25),
            HomeButton(
              icon: Icons.settings,
              label: 'Settings',
              onTap: () {
                flutterTts.speak("Opening Settings.");
                // Navigate to Settings screen
              },
            ),
            Spacer(),  // Push the button to the bottom
            ElevatedButton(
              onPressed: _startListening,
              child: Text(
                _isListening ? "Listening..." : "Tap to Speak",
                style: TextStyle(fontSize: 30), // Increased size for the button
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 80), // Bigger button size
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.symmetric(vertical: 18),
                elevation: 5,
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class HomeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const HomeButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 50),
      label: Text(label, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 70),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.symmetric(vertical: 18),
        elevation: 5,
      ),
    );
  }
}
