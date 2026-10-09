import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dotenv/dotenv.dart';

// Reads .env from the project root once, falling back to the shell environment.
final _env = DotEnv(includePlatformEnvironment: true)..load();

/// The /compare query params the signature covers, in signing order.
const signedCompareFields = [
  'name',
  'serving',
  'filter',
  'description',
  'tds',
  'caffeine',
  'yield',
  'body',
  'acidity',
  'myth',
  'truth',
];

/// Whether a signing key is configured. Checked before calling Gemini so a missing key doesn't waste a paid call.
bool get hasCompareSigningKey => (_env['COMPARE_SIGNING_KEY'] ?? '').isNotEmpty;

/// HMAC-SHA256 (hex) over the raw query strings of [signedCompareFields], so only text our server
/// produced can render under the "AI estimate" tag. Throws [StateError] when no signing key is set,
/// so a misconfigured server fails instead of issuing forgeable links.
String signCompareParams(Map<String, String> params) {
  final key = _env['COMPARE_SIGNING_KEY'] ?? '';
  if (key.isEmpty) throw StateError('COMPARE_SIGNING_KEY is not set');
  return _sign(params, key);
}

/// Whether [params] carry a valid `sig`. False when the key is missing, the signature is absent or any signed
/// field was edited.
bool verifyCompareParams(Map<String, String> params) {
  final key = _env['COMPARE_SIGNING_KEY'] ?? '';
  final sig = params['sig'];
  if (key.isEmpty || sig == null) return false;
  return _constantTimeEquals(_sign(params, key), sig);
}

String _sign(Map<String, String> params, String key) {
  // JSON keeps field boundaries unambiguous, unlike a plain join.
  final payload = jsonEncode([for (final field in signedCompareFields) params[field] ?? '']);
  return Hmac(sha256, utf8.encode(key)).convert(utf8.encode(payload)).toString();
}

bool _constantTimeEquals(String a, String b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return diff == 0;
}
