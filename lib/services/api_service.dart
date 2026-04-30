import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// A robust API Service for AgroVision to handle all backend communications.
class ApiService {
  // ---------------------------------------------------------------------------
  // CONFIGURATION
  // ---------------------------------------------------------------------------
  
  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    } else if (Platform.isAndroid) {
      // 10.0.2.2 is the localhost alias for Android Emulators
      // If you use a physical Android device, replace with your laptop's WiFi IP: 'http://192.168.x.x:8000'
      return 'http://10.0.2.2:8000';
    } else {
      // iOS Simulator or Windows/Linux/Mac Desktop apps
      return 'http://127.0.0.1:8000';
    }
  }
  
  static const Duration _timeout = Duration(seconds: 30);
  static const Duration _voiceTimeout = Duration(seconds: 60);

  // ---------------------------------------------------------------------------
  // TEXT CHAT ENDPOINT
  // ---------------------------------------------------------------------------
  /// Sends a text message to the backend chatbot.
  /// Returns the response text.
  static Future<String> postChat(String message, {String language = 'en'}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          'language': language,
        }),
      ).timeout(_timeout);

      return _processJsonResponse(response, 'response');
    } on SocketException {
      throw Exception('Backend unavailable. Please ensure your FastAPI server is running at $_baseUrl.');
    } on http.ClientException catch (e) {
      throw Exception('Network connection failed: ${e.message}');
    } catch (e) {
      // Passes along TimeoutException, FormatException, etc.
      rethrow; 
    }
  }

  // ---------------------------------------------------------------------------
  // VOICE CHAT ENDPOINT
  // ---------------------------------------------------------------------------
  /// Sends an audio file to the backend for speech-to-text and AI response.
  /// Returns a map containing the transcribed text, response text, and the raw audio bytes of the response.
  static Future<Map<String, dynamic>> postVoice(String audioFilePath) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/voice'));
      request.files.add(await http.MultipartFile.fromPath('audio', audioFilePath));

      final streamedResponse = await request.send().timeout(_voiceTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final transcribed = response.headers['x-transcribed-text'] ?? 'Audio message';
        final replyText = response.headers['x-response-text'] ?? 'No text response';
        final audioBytes = response.bodyBytes;

        if (audioBytes.isEmpty) {
          throw Exception('Received an empty audio response from the server.');
        }

        return {
          'transcribed': transcribed,
          'replyText': replyText,
          'audioBytes': audioBytes,
        };
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } on SocketException {
      throw Exception('Backend unavailable. Please ensure your FastAPI server is running at $_baseUrl.');
    } on http.ClientException catch (e) {
      throw Exception('Network connection failed: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // HELPER METHODS
  // ---------------------------------------------------------------------------
  /// Helper to process standard JSON responses and handle HTTP errors
  static String _processJsonResponse(http.Response response, String expectedKey) {
    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        if (data.containsKey(expectedKey)) {
          return data[expectedKey] as String;
        } else {
          throw const FormatException('Invalid JSON: Missing expected response key.');
        }
      } catch (e) {
        throw FormatException('Failed to parse response: ${response.body}');
      }
    } else {
      throw Exception(_extractErrorMessage(response));
    }
  }

  /// Helper to extract error detail from a failed response
  static String _extractErrorMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      final detail = data['detail'] ?? 'Unknown error';
      return 'Server error (${response.statusCode}): $detail';
    } catch (_) {
      return 'Server error (${response.statusCode}): ${response.reasonPhrase}';
    }
  }
}
