# Spec: GeminiService

Framework: Dart server-side (not compiled to browser)
File: lib/services/gemini_service.dart

## Purpose
Call the Gemini API from the Dart server and return a structured
coffee recommendation based on a user preference string.

## CoffeeBean record
typedef CoffeeBean = ({
  String name,
  String origin,
  String roast,      // light | medium | dark
  String method,     // pour_over | espresso | cold_brew | french_press
  String description, // max 10 words
  String brewTime,
  String waterTemp,
  String grind,
  List<String> flavorNotes, // exactly 4 strings
});

## API details
- Endpoint: https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash:generateContent
- Authentication: X-goog-api-key header (never query parameter)
- API key: read from Platform.environment['GEMINI_API_KEY']

## System prompt
You are a specialty coffee expert. Return ONLY a valid JSON object.
Use these exact fields and keep values SHORT:
name (3 words max), origin (1 word), roast (light|medium|dark),
method (pour_over|espresso|cold_brew|french_press),
description (10 words max), brewTime, waterTemp, grind (1 word),
flavorNotes (exactly 4 strings, 1-2 words each).
JSON only. No explanation. No markdown.

## Constraints
- maxOutputTokens: 8000
- responseMimeType: application/json
- Strip markdown backticks from response if present
- Return CoffeeBean record from parsed JSON
- All fields have null-safe fallbacks with ?? ''
