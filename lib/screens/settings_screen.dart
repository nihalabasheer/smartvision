import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:vibration/vibration.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isVibrationOn = true;
  double volume = 1.0;
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    flutterTts.setVolume(volume);
    _announceSettings();
  }

  void _announceSettings() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    flutterTts.speak(
        "Settings screen. You can say: turn on vibration, turn off vibration, or set volume to any percent.");
  }

  void _toggleVibration(bool value) async {
    setState(() => isVibrationOn = value);
    if (value && (await Vibration.hasVibrator() ?? false)) {
      Vibration.vibrate(duration: 300);
    }
    flutterTts.speak(value ? "Vibration turned on" : "Vibration turned off");
  }

  void _updateVolume(double value) {
    setState(() => volume = value.clamp(0.0, 1.0));
    flutterTts.setVolume(volume);
    flutterTts.speak("Volume set to ${(volume * 100).toInt()} percent");
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        flutterTts.speak("Speech recognition error occurred.");
        setState(() => _isListening = false);
      },
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            _handleVoiceCommand(result.recognizedWords.toLowerCase());
          }
        },
        listenFor: const Duration(seconds: 5),
        pauseFor: const Duration(seconds: 2),
        localeId: "en_US",
        partialResults: false,
      );
    } else {
      flutterTts.speak("Speech recognition not available");
    }
  }

  void _handleVoiceCommand(String command) {
    if (command.contains("turn on vibration")) {
      _toggleVibration(true);
    } else if (command.contains("turn off vibration")) {
      _toggleVibration(false);
    } else if (command.contains("volume")) {
      final match = RegExp(r'(?:set )?(?:volume(?: to)? )?(\d{1,3})').firstMatch(command);
      if (match != null) {
        int value = int.parse(match.group(1)!);
        if (value >= 0 && value <= 100) {
          _updateVolume(value / 100);
        } else {
          flutterTts.speak("Volume should be between 0 and 100 percent.");
        }
      } else {
        flutterTts.speak("I didn't catch the volume value.");
      }
    } else {
      flutterTts.speak("Sorry, I didn't understand that command.");
    }

    _speech.stop();
    setState(() => _isListening = false);
  }

  Widget _buildTapToSpeakButton() {
    return GestureDetector(
      onTap: () {
        if (!_isListening) _startListening();
      },
      child: Container(
        width: double.infinity,
        height: 64,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: _isListening ? Colors.redAccent : Colors.blueAccent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isListening ? Icons.hearing : Icons.mic,
              color: Colors.white,
              size: 28,
            ),
            SizedBox(width: 12),
            Text(
              _isListening ? "Listening..." : "Tap to Speak",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F3F6),
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        backgroundColor: Color(0xFF3A4D8A),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SwitchListTile(
                      title: Text(
                        "Vibration",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      value: isVibrationOn,
                      onChanged: _toggleVibration,
                      activeColor: Colors.deepPurple,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                  SizedBox(height: 30),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Announcement Volume",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          Slider(
                            value: volume,
                            min: 0.0,
                            max: 1.0,
                            divisions: 10,
                            label: "${(volume * 100).toInt()}%",
                            onChanged: _updateVolume,
                            activeColor: Colors.deepPurple,
                            thumbColor: Colors.deepPurpleAccent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildTapToSpeakButton(),
        ],
      ),
    );
  }
}
