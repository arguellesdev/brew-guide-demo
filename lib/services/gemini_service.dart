import 'dart:convert';
import 'package:http/http.dart' as http;

typedef CoffeeBean = ({
  String name,
  String origin,
  String roast,
  String method,
  String description,
  String brewTime,
  String waterTemp,
  String grind,
  List<String> flavorNotes,
});

Future<CoffeeBean> recommendCoffee(String preference, String apiKey) async {
  final url = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash:generateContent',
  );

  const systemPrompt =
    'You are a specialty coffee expert. Return ONLY a valid JSON object with these exact fields: '
    'name (string), origin (string), roast (light|medium|dark), '
    'method (pour_over|espresso|cold_brew|french_press), '
    'description (string, MAX 20 words), '
    'brewTime (string), waterTemp (string), grind (string), '
    'flavorNotes (array of exactly 4 strings). '
    'No explanation. No markdown. No backticks. JSON only.';

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'X-goog-api-key': apiKey,
    },
    body: jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': preference}
          ]
        }
      ],
      'systemInstruction': {
        'parts': [
          {'text': systemPrompt}
        ]
      },
      'generationConfig': {
        'responseMimeType': 'application/json',
        'maxOutputTokens': 1024,
      },
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to recommend coffee: ${response.body}');
  }

  final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
  final candidates = responseBody['candidates'] as List<dynamic>;
  if (candidates.isEmpty) {
    throw Exception('No recommendations found in the response.');
  }

  final content = candidates[0]['content'] as Map<String, dynamic>;
  final parts = content['parts'] as List<dynamic>;
  if (parts.isEmpty) {
    throw Exception('No parts found in the response content.');
  }

  String text = parts[0]['text'] as String;
  text = text.trim();

  if (text.startsWith('```json')) {
    text = text.substring(7);
  } else if (text.startsWith('```')) {
    text = text.substring(3);
  }
  if (text.endsWith('```')) {
    text = text.substring(0, text.length - 3);
  }
  text = text.trim();

  final json = jsonDecode(text) as Map<String, dynamic>;

  return (
    name: json['name'] as String? ?? '',
    origin: json['origin'] as String? ?? '',
    roast: json['roast'] as String? ?? '',
    method: json['method'] as String? ?? '',
    description: json['description'] as String? ?? '',
    brewTime: json['brewTime'] as String? ?? '',
    waterTemp: json['waterTemp'] as String? ?? '',
    grind: json['grind'] as String? ?? '',
    flavorNotes: (json['flavorNotes'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        <String>[],
  );
}