import 'dart:async';

import '../constants/theme.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

const _facts = [
  'The Caffeine Myth: An ounce of espresso is dense, but a full mug of drip coffee packs more total caffeine.',
  'French Press: Metal mesh lets microscopic bean solids slip through, giving every sip that signature heavy body.',
  'Crema Magic: Espresso crema isn\'t foam; it\'s an emulsion of aromatic oils suspended by tiny CO₂ bubbles.',
  'AeroPress: Invented by an aerodynamics engineer in 2005 to cut brew bitterness down to 60 seconds.',
  'Turkish Coffee: Powder-fine grinds boiled directly in water make this the oldest unfiltered brewing method still practiced.',
];

/// Rotates coffee facts while the loading overlay is visible.
@client
class BrewFacts extends StatefulComponent {
  const BrewFacts({super.key});

  @override
  State<BrewFacts> createState() => _BrewFactsState();

  @css
  static List<StyleRule> get styles => [
    css('.brew-fact').styles(
      maxWidth: 28.rem,
      padding: Padding.symmetric(horizontal: 1.5.rem),
      color: colorTextMid,
      textAlign: TextAlign.center,
      fontSize: 0.95.rem,
      raw: {'line-height': '1.5', 'animation': 'fact-fade-in 0.6s ease'},
    ),
    css('@keyframes fact-fade-in', [
      css('from').styles(opacity: 0, raw: {'transform': 'translateY(6px)'}),
      css('to').styles(opacity: 1, raw: {'transform': 'translateY(0)'}),
    ]),
  ];
}

class _BrewFactsState extends State<BrewFacts> {
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // initState also runs during server rendering; only tick in the browser.
    if (kIsWeb) {
      _timer = Timer.periodic(const Duration(seconds: 4), (_) {
        setState(() => _index = (_index + 1) % _facts.length);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    final [title, body] = _facts[_index].split(': ');
    // A new key per fact recreates the element, which replays the fade-in animation.
    return p(key: ValueKey(_index), classes: 'brew-fact', [
      strong([Component.text('$title: ')]),
      Component.text(body),
    ]);
  }
}
