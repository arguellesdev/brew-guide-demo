// ignore: unused_import
import 'dart:convert';
import 'dart:io';
import 'package:jaspr/server.dart';
import '../services/gemini_service.dart';

Future<Response> handleGeminiRequest(Request request) async {
  try {
    final apiKey = Platform.environment['GEMINI_API_KEY'] ?? '';
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
   final ts = DateTime.now().millisecondsSinceEpoch;
return Response.found('/?error=1&t=$ts');
  }
}