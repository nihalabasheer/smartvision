import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:smartvision/services/contact_store.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:permission_handler/permission_handler.dart';

class CallEmergencyContactPage extends StatefulWidget {
  const CallEmergencyContactPage({super.key});

  @override
  State<CallEmergencyContactPage> createState() => _CallEmergencyContactPageState();
}

class _CallEmergencyContactPageState extends State<CallEmergencyContactPage> {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  final Color mainBlue = const Color(0xFF3A4D8A);
  List<Map<String, String>> contacts = [];

  @override
  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  void _loadContacts() async {
    contacts = await ContactStore.getContacts();
    setState(() {}); // Refresh UI
    _announceContacts();
  }


  void _announceContacts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    if (contacts.isEmpty) {
      await flutterTts.speak("No emergency contacts saved yet.");
    } else {
      String names = contacts.map((c) => c['name']).join(", ");
      await flutterTts.speak("Your emergency contacts are: $names. Tap the mic and say a name to call.");
    }
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        String spokenName = result.recognizedWords.toLowerCase();
        _handleVoiceCommand(spokenName);
      });
    } else {
      await flutterTts.speak("Speech recognition is not available.");
    }
  }

  Future<void> _handleVoiceCommand(String nameSpoken) async {
    for (var contact in contacts) {
      if (contact['name']!.toLowerCase() == nameSpoken) {
        String name = contact['name']!.trim();
        await flutterTts.setPitch(1.0);
        await flutterTts.setVolume(1.0);
        await flutterTts.speak("Calling $name");
        _makeDirectCall(contact['phone']!);
        return;
      }
    }
    await flutterTts.speak("Sorry, I couldn't find a contact named $nameSpoken.");
  }

  Future<void> _makeDirectCall(String phoneNumber) async {
    PermissionStatus status = await Permission.phone.status;

    if (status.isDenied) {
      status = await Permission.phone.request();
    }

    if (status.isGranted) {
      await FlutterPhoneDirectCaller.callNumber(phoneNumber);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone permission not granted')),
      );
    }
  }

  Widget _buildTapToSpeakButton() {
    return GestureDetector(
      onTap: () {
        if (!_isListening) {
          _startListening();
        }
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 20),
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
            Icon(_isListening ? Icons.hearing : Icons.mic, color: Colors.white, size: 30),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      appBar: AppBar(
        title: const Text("Call Emergency Contact"),
        backgroundColor: mainBlue,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: contacts.isEmpty
                ? const Center(child: Text("No contacts available."))
                : ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return ListTile(
                  leading: const Icon(Icons.person, color: Colors.black54),
                  title: Text(contact['name']!),
                  subtitle: Text(contact['phone']!),
                  trailing: IconButton(
                    icon: const Icon(Icons.call, color: Colors.green),
                    onPressed: () async {
                      String name = contact['name']!.trim();
                      await flutterTts.setPitch(1.0);
                      await flutterTts.setVolume(1.0);
                      await flutterTts.speak("Calling $name");
                      _makeDirectCall(contact['phone']!);
                    },
                  ),
                );
              },
            ),
          ),
          _buildTapToSpeakButton(),
        ],
      ),
    );
  }
}
