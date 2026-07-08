import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../constants/theme.dart';

class Header extends StatelessComponent {
  const Header({super.key});

  @override
  Component build(BuildContext context) {
    return header([
      nav([
        Link(
          to: '/',
          child: .text('Brew Guide'),
        ),
      ]),
    ]);
  }

@css
  static List<StyleRule> get styles => [
    css('header', [
      css('&').styles(
        display: .flex,
        padding: .symmetric(vertical: 1.em, horizontal: 2.em),
        justifyContent: .start,
        backgroundColor: colorSurface,
        border: .only(bottom: .solid(color: colorBorder, width: 1.px)),
      ),
      css('nav', [
        css('&').styles(
          display: .flex,
          alignItems: .center,
        ),
        css('a').styles(
          fontFamily: const .list([FontFamily('Playfair Display'), FontFamilies.serif]),
          fontSize: 1.3.rem,
          fontWeight: .w500,
          color: colorTextDark,
          textDecoration: TextDecoration(line: .none),
        ),
      ]),
    ]),
  ];
}

