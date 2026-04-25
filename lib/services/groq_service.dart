import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GroqService {
  final String _apiKey = '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';
  final String _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  
  // Using the latest Llama 3.2 vision model available on Groq
  final String _model = 'llama-3.2-90b-vision-preview';

  Future<Map<String, dynamic>?> analyzeImage(Uint8List imageBytes, String mimeType) async {
    final String base64Image = base64Encode(imageBytes);

    final Map<String, dynamic> payload = {
      "model": _model,
      "messages": [
        {
          "role": "user",
          "content": [
            {
              "type": "text",
              "text": "Analyze the attached image. Respond ONLY in valid JSON format using the following structure: {'smart_name': '...', 'description': '...', 'tags': ['...', '...'], 'lighting_quality': '8/10', 'sharpness': '9/10'}. Do NOT include any markdown formatting like ```json, just the raw JSON object."
            },
            {
              "type": "image_url",
              "image_url": {
                "url": "data:$mimeType;base64,$base64Image"
              }
            }
          ]
        }
      ],
      "temperature": 0.1, // low temperature for more structured data
    };

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode != 200) {
        throw Exception("Groq API error: ${response.statusCode} - ${response.body}");
      }

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      String rawJson = responseData['choices'][0]['message']['content'].trim();

      // Clean up markdown block if the model ignores the instruction
      if (rawJson.startsWith('```json')) {
        rawJson = rawJson.substring(7, rawJson.length - 3).trim();
      } else if (rawJson.startsWith('```')) {
         rawJson = rawJson.substring(3, rawJson.length - 3).trim();
      }

      final Map<String, dynamic> jsonMap = jsonDecode(rawJson);
      return jsonMap;
    } catch (e) {
      debugPrint("Error generating AI content via Groq: $e");
      return null;
    }
  }
}
