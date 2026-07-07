library;

import 'package:jaspr/server.dart';
import 'app.dart';
import 'handlers/gemini_handler.dart';
import 'main.server.options.dart';

void main() {
  Jaspr.initializeApp(options: defaultServerOptions);

  ServerApp.addMiddleware((handler) {
    return (request) async {
      if (request.method == 'POST' &&
          request.url.path == 'api/gemini') {
        return handleGeminiRequest(request);
      }
      return handler(request);
    };
  });

  runApp(Document(
    title: 'Brew Guide',
    styles: [],
    body: App(),
  ));
}