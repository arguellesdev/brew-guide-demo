import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'components/header.dart';
import 'pages/coffee.dart';
import 'pages/home.dart';

class App extends StatelessComponent {
  const App({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'main', [
      const Header(),
      Router(routes: [
        Route(
          path: '/',
          title: 'Home',
          builder: (context, state) => Home(
            hasError: state.queryParams['error'] == '1',
          ),
        ),
        Route(
          path: '/coffee',
          title: 'Brew Guide',
          builder: (context, state) => Coffee(
            name: state.queryParams['name'] ?? '',
            origin: state.queryParams['origin'] ?? '',
            roast: state.queryParams['roast'] ?? '',
            method: state.queryParams['method'] ?? '',
            description: state.queryParams['description'] ?? '',
            brewTime: state.queryParams['brewTime'] ?? '',
            waterTemp: state.queryParams['waterTemp'] ?? '',
            grind: state.queryParams['grind'] ?? '',
            flavorNotes: (state.queryParams['flavorNotes'] ?? '').split(','),
          ),
        ),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.main', [
      css('&').styles(
        display: .flex,
        height: 100.vh,
        flexDirection: .column,
        flexWrap: .wrap,
      ),
      css('section').styles(
        display: .flex,
        flexDirection: .column,
        justifyContent: .center,
        alignItems: .center,
        flex: Flex(grow: 1),
      ),
    ]),
  ];
}