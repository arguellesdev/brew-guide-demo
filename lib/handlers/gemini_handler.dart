// ignore: unused_import
import 'dart:convert';
import 'package:dotenv/dotenv.dart';
import 'package:jaspr/server.dart';
import '../services/gemini_service.dart';

// Reads .env from the project root once, falling back to the shell environment.
final _env = DotEnv(includePlatformEnvironment: true)..load();

Future<Response> handleGeminiRequest(Request request) async {
  try {
    final apiKey = _env['GEMINI_API_KEY'] ?? '';
    final body = await request.readAsString();
    final params = Uri.splitQueryString(body);
    final preference = params['preference'] ?? '';
    final bean = await recommendCoffee(preference, apiKey);
    final redirectUri = Uri(
      path: '/coffee',
      queryParameters: {
        'name': bean.name,
        'origin': bean.origin,
        'roast': bean.roast,
        'method': bean.method,
        'description': bean.description,
        'brewTime': bean.brewTime,
        'waterTemp': bean.waterTemp,
        'grind': bean.grind,
        'flavorNotes': bean.flavorNotes.join(','),
      },
    );
    return Response.found(redirectUri);
  } catch (e) {
    print('[gemini] request failed: $e');
    final ts = DateTime.now().millisecondsSinceEpoch;
    return Response.found('/?error=1&t=$ts');
  }
}