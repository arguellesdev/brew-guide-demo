library;

import 'package:jaspr/server.dart';
import 'app.dart';
import 'main.server.options.dart';

void main() {
  Jaspr.initializeApp(options: defaultServerOptions);
  runApp(Document(
    title: 'Brew Guide',
    styles: [],
    body: App(),
  ));
}