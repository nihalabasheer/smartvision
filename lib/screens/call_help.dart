import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'add_emergencycontact.dart';
import 'call_emergencycontact.dart';




class CallHelpScreen extends StatefulWidget {
  const CallHelpScreen({super.key});

  @override
  State<CallHelpScreen> createState() => _CallHelpScreenState();
}

class _CallHelpScreenState extends State<CallHelpScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  final Color mainBlue = const Color(0xFF3A4D8A);

  @override
  void initState() {
    super.initState();
    _announceOptions();
  }

  void _announceOptions() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    flutterTts.speak(
      "Call Help screen. You can say: add an emergency contact, or call someone. You may also tap one of the icons below.",
    );
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        String command = result.recognizedWords.toLowerCase();
        _handleVoiceCommand(command);
      });
    } else {
      flutterTts.speak("Speech recognition not available");
    }
  }

  void _handleVoiceCommand(String command) {
    command = command.toLowerCase();

    if (command.contains("add")) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const AddEmergencyContactPage()),
      );
    } else if (command.contains("call")) {
      Navigator.pushNamed(context, '/call_emergency_contact');
    } else {
      flutterTts.speak("Sorry, I didn't understand. Please say add or call.");
    }

    _speech.stop();
    setState(() => _isListening = false);
  }

  Widget _buildLargeOption({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: MediaQuery
                .of(context)
                .size
                .width * 0.85,
            height: 120,
            decoration: BoxDecoration(
              color: mainBlue,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 40, color: Colors.white),
                  const SizedBox(width: 16),
                  Flexible(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTapToSpeakButton() {
    return GestureDetector(
      onTap: () {
        if (!_isListening) {
          _startListening();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: _isListening ? Colors.redAccent : mainBlue,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isListening ? Icons.hearing : Icons.mic,
              color: Colors.white,
              size: 30,
            ),
            const SizedBox(width: 16),
            Text(
              _isListening ? "Listening..." : "Tap to Speak",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    _speech.stop();
    super.dispose();
  }

  @override
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      appBar: AppBar(
        title: const Text("Call Help"),
        centerTitle: true,
        backgroundColor: mainBlue,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildLargeOption(
            label: "Add Emergency Contact",
            icon: Icons.person_add,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEmergencyContactPage(),
                ),
              );
            },
          ),
          _buildLargeOption(
            label: "Call Emergency Contact",
            icon: Icons.phone,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CallEmergencyContactPage(),
                ),
              );
            },
          ),
          const Spacer(),
          _buildTapToSpeakButton(),
        ],
      ),
    );
  }
}