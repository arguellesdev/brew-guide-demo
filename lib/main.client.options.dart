// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/client.dart';

import 'package:flutter_conf_jaspr_demo/pages/coffee.dart' deferred as _coffee;
import 'package:flutter_conf_jaspr_demo/pages/home.dart' deferred as _home;

/// Default [ClientOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.client.options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultClientOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ClientOptions get defaultClientOptions => ClientOptions(
  clients: {
    'coffee': ClientLoader(
      (p) => _coffee.Coffee(
        name: p['name'] as String,
        origin: p['origin'] as String,
        roast: p['roast'] as String,
        method: p['method'] as String,
        description: p['description'] as String,
        brewTime: p['brewTime'] as String,
        waterTemp: p['waterTemp'] as String,
        grind: p['grind'] as String,
        flavorNotes: (p['flavorNotes'] as List<Object?>).cast<String>(),
      ),
      loader: _coffee.loadLibrary,
    ),
    'home': ClientLoader(
      (p) => _home.Home(hasError: p['hasError'] as bool),
      loader: _home.loadLibrary,
    ),
  },
);
