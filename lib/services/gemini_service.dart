import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  // Insert your actual Gemini API Key here
  final String _apiKey = 'AIzaSyBGTfEb9RlLLmOlAgDzApR0jYnuymTI7PU';
  // Using the incredible free and fast Flash model
  final String _model = 'gemini-2.5-flash';

  Future<Map<String, dynamic>?> analyzeImage(Uint8List imageBytes, String mimeType) async {
    final String base64Image = base64Encode(imageBytes);

    final String _apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey';

    final Map<String, dynamic> payload = {
      "contents": [
        {
          "parts": [
            {
              "text": "Analyze the attached image. Respond ONLY in valid JSON format using the exact following structure: {\"smart_name\": \"...\", \"description\": \"...\", \"tags\": [\"...\", \"...\"], \"lighting_quality\": \"8/10\", \"sharpness\": \"9/10\"}. Do NOT include any markdown formatting like ```json, just output the raw JSON object."
            },
            {
              "inline_data": {
                "mime_type": mimeType,
                "data": base64Image
              }
            }
          ]
        }
      ],
      "generationConfig": {
        "temperature": 0.2
      }
    };

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception("Gemini API error: ${response.statusCode} - ${response.body}");
      }

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      String rawJson = responseData['candidates'][0]['content']['parts'][0]['text'].trim();

      if (rawJson.startsWith('```json')) {
        rawJson = rawJson.substring(7, rawJson.length - 3).trim();
      } else if (rawJson.startsWith('```')) {
         rawJson = rawJson.substring(3, rawJson.length - 3).trim();
      }

      final Map<String, dynamic> jsonMap = jsonDecode(rawJson);
      return jsonMap;
    } catch (e) {
      debugPrint("Network error or Gemini issue: $e");
      // FAILSAFE MOCK if key is invalid
      return {
        'smart_name': 'MOCK_GEMINI_TEST.jpg',
        'description': 'The Gemini API call failed. Have you replaced YOUR_GEMINI_API_KEY_HERE with your real key in gemini_service.dart?',
        'tags': ['Error', 'Mock', 'API-Missing'],
        'lighting_quality': '0/10',
        'sharpness': '0/10'
      };
    }
  }
}
