// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/server.dart';
import 'package:flutter_conf_jaspr_demo/components/header.dart' as _header;
import 'package:flutter_conf_jaspr_demo/components/method_selector.dart'
    as _method_selector;
import 'package:flutter_conf_jaspr_demo/constants/theme.dart' as _theme;
import 'package:flutter_conf_jaspr_demo/pages/about.dart' as _about;
import 'package:flutter_conf_jaspr_demo/pages/home.dart' as _home;
import 'package:flutter_conf_jaspr_demo/app.dart' as _app;

/// Default [ServerOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.server.options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultServerOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ServerOptions get defaultServerOptions => ServerOptions(
  clientId: 'main.client.dart.js',
  clients: {
    _about.About: ClientTarget<_about.About>('about'),
    _home.Home: ClientTarget<_home.Home>('home'),
  },
  styles: () => [
    ..._theme.styles,
    ..._app.App.styles,
    ..._header.Header.styles,
    ..._method_selector.MethodSelector.styles,
    ..._about.About.styles,
  ],
);
