import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  
  bool _isListening = false;
  String _recognizedText = "Press the microphone to start speaking.";
  String _assistantReply = "";

  // replace <MY_COMPUTER_IP> with laptop IPv4 address
  final String chatbotApiUrl = "http://10.116.114.230:8000/chat";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _initTts();
  }
  
  void _initTts() async {
    _flutterTts.setStartHandler(() {
      debugPrint("TTS Started");
    });
    _flutterTts.setCompletionHandler(() {
      debugPrint("TTS Completed");
    });
    _flutterTts.setErrorHandler((msg) {
      debugPrint("TTS Error: $msg");
    });

    dynamic isTamilAvailable = await _flutterTts.isLanguageAvailable("ta-IN");
    if (isTamilAvailable == true) {
      await _flutterTts.setLanguage("ta-IN");
    } else {
      dynamic isEnglishInAvailable = await _flutterTts.isLanguageAvailable("en-IN");
      if (isEnglishInAvailable == true) {
        await _flutterTts.setLanguage("en-IN");
      } else {
        await _flutterTts.setLanguage("en-US");
      }
    }
    
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done') {
            setState(() => _isListening = false);
          }
        },
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _recognizedText = val.recognizedWords;
          }),
          localeId: "ta_IN",
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      if (_recognizedText.isNotEmpty && _recognizedText != "Press the microphone to start speaking.") {
        sendMessageToBackend(_recognizedText);
      }
    }
  }

  Future<void> sendMessageToBackend(String message) async {
    setState(() {
      _assistantReply = "Thinking...";
    });

    try {
      final response = await http.post(
        Uri.parse(chatbotApiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String aiResponse = "";
        
        if (data.containsKey("response")) {
          aiResponse = data["response"];
        } else if (data.containsKey("reply")) {
          aiResponse = data["reply"];
        } else if (data.containsKey("answer")) {
          aiResponse = data["answer"];
        } else {
          aiResponse = "No valid response field found.";
        }

        setState(() {
          _assistantReply = aiResponse;
        });
        await _flutterTts.stop();
        await _flutterTts.speak(aiResponse);
      } else {
        throw Exception("Failed to connect");
      }
    } catch (e) {
      const String errorText = "Backend connect aagala. Please check server.";
      setState(() {
        _assistantReply = errorText;
      });
        await _flutterTts.stop();
      await _flutterTts.speak(errorText);
    }
  }
  
  void _testSpeaker() async {
    String testText = "வணக்கம். அக்ரோவிஷன் குரல் உதவியாளர் தயாராக உள்ளது.";
    setState(() {
      _assistantReply = testText;
    });
    await _flutterTts.stop();
    await _flutterTts.speak(testText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Assistant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Recognized Speech:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _recognizedText,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Assistant Reply:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _assistantReply.isEmpty ? "No reply yet." : _assistantReply,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _testSpeaker,
              child: const Text('Test Speaker'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _listen,
              icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
              label: Text(_isListening ? 'Stop Listening' : 'Start Listening'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: _isListening ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
