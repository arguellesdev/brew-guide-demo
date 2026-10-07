import 'dart:async';
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

/// Why a recommendation failed, so the UI can respond to each case differently.
enum GeminiFailure {
  /// Overloaded or rate limited (429/5xx). Worth retrying.
  busy,

  /// No answer within [_timeout].
  timeout,

  /// The reply was missing or wasn't the JSON we asked for. Worth retrying.
  badResponse,

  /// Our side is misconfigured (bad or missing API key, bad request).
  unavailable,
}

class GeminiException implements Exception {
  final GeminiFailure failure;
  final String detail;
  GeminiException(this.failure, this.detail);

  @override
  String toString() => 'GeminiException(${failure.name}): $detail';
}

const _timeout = Duration(seconds: 30);

/// Asks Gemini for a recommendation, retrying once on temporary failures.
Future<CoffeeBean> recommendCoffee(String preference, String apiKey) async {
  try {
    return await _requestOnce(preference, apiKey);
  } on GeminiException catch (e) {
    if (e.failure != GeminiFailure.busy && e.failure != GeminiFailure.badResponse) {
      rethrow;
    }
    print('[gemini] retrying after: $e');
    await Future<void>.delayed(const Duration(seconds: 1));
    return _requestOnce(preference, apiKey);
  }
}

Future<CoffeeBean> _requestOnce(String preference, String apiKey) async {
  final url = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash:generateContent',
  );

  const systemPrompt =
      'You are a specialty coffee expert. Return ONLY a valid JSON object. '
      'Use these exact fields and keep values SHORT: '
      'name (3 words max), origin (1 word), roast (light|medium|dark), '
      'method (pour_over|espresso|cold_brew|french_press), '
      'description (10 words max), '
      'brewTime (format: "X min" or "X-Y sec"), '
      'waterTemp (format: "XXX°C"), '
      'grind (1 word: Coarse|Medium|Fine), '
      'flavorNotes (exactly 4 strings, 1-2 words each). '
      'JSON only. No explanation. No markdown.';

  final stopwatch = Stopwatch()..start();
  final http.Response response;
  try {
    response = await http
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'X-goog-api-key': apiKey,
          },
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': preference},
                ],
              },
            ],
            'systemInstruction': {
              'parts': [
                {'text': systemPrompt},
              ],
            },
            'generationConfig': {
              'responseMimeType': 'application/json',
              'maxOutputTokens': 8000,
            },
          }),
        )
        .timeout(_timeout);
  } on TimeoutException {
    throw GeminiException(GeminiFailure.timeout, 'no response after ${_timeout.inSeconds}s');
  } on http.ClientException catch (e) {
    throw GeminiException(GeminiFailure.busy, 'network error: ${e.message}');
  }

  print('[gemini] ${stopwatch.elapsedMilliseconds} ms | status ${response.statusCode}');

  if (response.statusCode != 200) {
    final failure = response.statusCode == 429 || response.statusCode >= 500
        ? GeminiFailure.busy
        : GeminiFailure.unavailable;
    throw GeminiException(failure, 'HTTP ${response.statusCode}: ${response.body}');
  }

  try {
    return _parseBean(response.body, stopwatch);
  } on GeminiException {
    rethrow;
  } catch (e) {
    // FormatException from jsonDecode, TypeError from an unexpected shape.
    throw GeminiException(GeminiFailure.badResponse, '$e');
  }
}

CoffeeBean _parseBean(String body, Stopwatch stopwatch) {
  final responseBody = jsonDecode(body) as Map<String, dynamic>;
  final usage = responseBody['usageMetadata'] as Map<String, dynamic>?;
  print(
    '[gemini] ${stopwatch.elapsedMilliseconds} ms | '
    'thinking tokens: ${usage?['thoughtsTokenCount'] ?? 0} | '
    'answer tokens: ${usage?['candidatesTokenCount']}',
  );
  final candidates = responseBody['candidates'] as List<dynamic>;
  if (candidates.isEmpty) {
    throw GeminiException(GeminiFailure.badResponse, 'no candidates in response');
  }

  final content = candidates[0]['content'] as Map<String, dynamic>;
  final parts = content['parts'] as List<dynamic>;
  if (parts.isEmpty) {
    throw GeminiException(GeminiFailure.badResponse, 'no parts in response content');
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
    flavorNotes: (json['flavorNotes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? <String>[],
  );
}
