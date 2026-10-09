import 'package:dotenv/dotenv.dart';
import 'package:jaspr/server.dart';
import '../data/house_guides.dart';
import '../services/compare_signature.dart';
import '../services/gemini_service.dart';

// Reads .env from the project root once, falling back to the shell environment.
final _env = DotEnv(includePlatformEnvironment: true)..load();

Future<Response> handleGeminiRequest(Request request) async {
  final params = Uri.splitQueryString(await request.readAsString());
  final preference = (params['preference'] ?? '').trim();
  // Only the preset method cards send this; free-text requests don't.
  final presetMethod = params['method'];

  if (preference.isEmpty) {
    return _backHome('empty', preference);
  }

  try {
    final apiKey = _env['GEMINI_API_KEY'] ?? '';
    final bean = await recommendCoffee(preference, apiKey);
    return _showGuide(bean);
  } catch (e) {
    print('[gemini] request failed: $e');
    final failure = e is GeminiException ? e.failure : GeminiFailure.unavailable;

    final houseGuide = houseGuides[presetMethod];
    if (houseGuide != null) {
      return _showGuide(houseGuide, isFallback: true);
    }
    return _backHome(failure.name, preference);
  }
}

Response _showGuide(CoffeeBean bean, {bool isFallback = false}) {
  return Response.found(
    Uri(
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
        if (isFallback) 'fallback': '1',
      },
    ),
  );
}

/// Back to the home page with the reason and the user's text, so they can retry in one click.
Response _backHome(String error, String preference) {
  return Response.found(
    Uri(
      path: '/',
      queryParameters: {
        'error': error,
        if (preference.isNotEmpty) 'q': preference,
      },
    ),
  );
}

/// Longest method name we forward to Gemini. Method names are short; this caps what user text can carry.
const _maxMethodLength = 40;

/// Longest text we put in the /compare redirect, per field. The prompt already asks Gemini for short text;
/// this keeps the URL well under the ~2 KB some proxies and log pipelines cut at if it ignores that.
const _maxNameLength = 40;
const _maxServingLength = 40;
const _maxFilterLength = 40;
const _maxDescriptionLength = 160;
const _maxMythLength = 160;
const _maxTruthLength = 300;

/// Cuts [text] to [max] characters at a word boundary, adding an ellipsis. Never rejects: a retry costs a new call.
String _clip(String text, int max) {
  if (text.length <= max) return text;
  final cut = text.substring(0, max - 1);
  final lastSpace = cut.lastIndexOf(' ');
  return '${(lastSpace > max ~/ 2 ? cut.substring(0, lastSpace) : cut).trimRight()}…';
}

Future<Response> handleCompareRequest(Request request) async {
  final params = Uri.splitQueryString(await request.readAsString());
  var methodName = (params['method'] ?? '').trim().replaceAll(RegExp(r'\s+'), ' ');
  if (methodName.length > _maxMethodLength) {
    methodName = methodName.substring(0, _maxMethodLength);
  }

  if (methodName.isEmpty) {
    return _backToCompare('empty', methodName);
  }

  try {
    if (!hasCompareSigningKey) throw StateError('COMPARE_SIGNING_KEY is not set');
    final apiKey = _env['GEMINI_API_KEY'] ?? '';
    final comparison = await compareMethod(methodName, apiKey);
    final p = comparison.profile;
    final fields = {
      'name': _clip(p.name, _maxNameLength),
      'serving': _clip(p.serving, _maxServingLength),
      'filter': _clip(p.filter, _maxFilterLength),
      'description': _clip(p.description, _maxDescriptionLength),
      'tds': '${p.tds}',
      'caffeine': '${p.caffeineMg}',
      'yield': '${p.extractionYield}',
      'body': '${p.body}',
      'acidity': '${p.acidity}',
      'myth': _clip(comparison.myth.claim, _maxMythLength),
      'truth': _clip(comparison.myth.truth, _maxTruthLength),
    };
    // Signed after clipping: the page checks the exact strings in the URL.
    return Response.found(
      Uri(path: '/compare', queryParameters: {...fields, 'sig': signCompareParams(fields)}),
    );
  } catch (e) {
    print('[gemini] compare failed: $e');
    final failure = e is GeminiException ? e.failure : GeminiFailure.unavailable;
    return _backToCompare(failure.name, methodName);
  }
}

/// Back to /compare with the reason and the user's text, so they can retry in one click.
Response _backToCompare(String error, String methodName) {
  return Response.found(
    Uri(
      path: '/compare',
      queryParameters: {
        'error': error,
        if (methodName.isNotEmpty) 'q': methodName,
      },
    ),
  );
}
