import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../constants/theme.dart';

@client
class Coffee extends StatelessComponent {
  final String name;
  final String origin;
  final String roast;
  final String method;
  final String description;
  final String brewTime;
  final String waterTemp;
  final String grind;
  final List<String> flavorNotes;

  const Coffee({
    super.key,
    required this.name,
    required this.origin,
    required this.roast,
    required this.method,
    required this.description,
    required this.brewTime,
    required this.waterTemp,
    required this.grind,
    required this.flavorNotes,
  });

  String _formatMethod(String m) {
    switch (m.toLowerCase()) {
      case 'pour_over': return 'Pour over';
      case 'espresso': return 'Espresso';
      case 'cold_brew': return 'Cold brew';
      case 'french_press': return 'French press';
      default: return m.replaceAll('_', ' ');
    }
  }

  String _formatRoast(String r) {
    if (r.isEmpty) return 'Unknown roast';
    return '${r[0].toUpperCase()}${r.substring(1)} roast';
  }

@override
Component build(BuildContext context) {
  return div(classes: 'coffee-page', [
    a(
      href: '/',
      classes: 'back-link',
      [Component.text('☕ Brew Guide')],
    ),
    article(classes: 'coffee-detail', [
      div(classes: 'tags', [
        span(classes: 'tag method', [Component.text(_formatMethod(method))]),
        span(classes: 'tag roast', [Component.text(_formatRoast(roast))]),
        span(classes: 'tag origin', [Component.text(origin)]),
      ]),
      h1([Component.text(name)]),
      p(classes: 'description', [Component.text(description)]),
      dl(classes: 'metrics', [
        dt([Component.text('Grind')]),
        dd([Component.text(grind)]),
        dt([Component.text('Water')]),
        dd([Component.text(waterTemp)]),
        dt([Component.text('Time')]),
        dd([Component.text(brewTime)]),
      ]),
      if (flavorNotes.isNotEmpty)
        ul(
          classes: 'flavor-notes',
          flavorNotes.map((note) => li([Component.text(note)])).toList(),
        ),
    ]),
  ]);
}

  @css
  static List<StyleRule> get styles => [
    css('.coffee-page', [
  css('&').styles(
    display: Display.flex,
    flexDirection: FlexDirection.column,
    alignItems: AlignItems.center,
    padding: Padding.all(2.rem),
  ),
  css('.back-link').styles(
    display: Display.block,
    
    fontFamily: const .list([FontFamily('Playfair Display'), FontFamilies.serif]),
    fontSize: 1.2.rem,
    fontWeight: FontWeight.w500,
    color: colorTextDark,
    textDecoration: TextDecoration(line: TextDecorationLine.none),
  ),
]),
    css('.coffee-detail', [
      css('&').styles(
        display: Display.flex,
        maxWidth: 600.px,
        padding: Padding.all(2.5.rem),
        margin: Margin.symmetric(vertical: 4.rem, horizontal: Unit.auto),
        border: Border.all(style: BorderStyle.solid, color: colorBorder, width: 1.px),
        radius: BorderRadius.circular(16.px),
        shadow: BoxShadow(
          offsetX: Unit.zero,
          offsetY: 4.px,
          blur: 12.px,
          color: const Color('#0000000a'),
        ),
        flexDirection: FlexDirection.column,
        alignItems: AlignItems.center,
        backgroundColor: colorSurface,
      ),
      css('.tags', [
        css('&').styles(
          display: Display.flex,
          margin: Margin.only(bottom: 1.5.rem),
          gap: Gap.all(0.5.rem),
        ),
        css('.tag', [
          css('&').styles(
            padding: Padding.symmetric(vertical: 0.25.rem, horizontal: 0.75.rem),
            radius: BorderRadius.circular(20.px),
            fontSize: 0.8.rem,
            fontWeight: FontWeight.w500,
          ),
          css('&.method').styles(
            color: scaBlueberry,
            backgroundColor: const Color('#2659B11a'),
          ),
          css('&.roast').styles(
            color: scaChocolate,
            backgroundColor: const Color('#74301E1a'),
          ),
          css('&.origin').styles(
            color: scaHerb,
            backgroundColor: const Color('#3263591a'),
          ),
        ]),
      ]),
      css('h1').styles(
        margin: Margin.only(bottom: 1.rem),
        color: colorTextDark,
        textAlign: TextAlign.center,
        fontSize: 2.5.rem,
      ),
      css('.description').styles(
        margin: Margin.only(bottom: 2.rem),
        color: colorTextMid,
        textAlign: TextAlign.center,
        fontSize: 1.05.rem,
        lineHeight: 1.6.em,
      ),
      css('.metrics', [
        css('&').styles(
          display: Display.grid,
          width: 100.percent,
          padding: Padding.symmetric(vertical: 1.rem, horizontal: Unit.zero),
          margin: Margin.only(bottom: 2.rem),
          border: Border.symmetric(
            horizontal: BorderSide(style: BorderStyle.solid, color: colorBorder, width: 1.px),
          ),
          justifyContent: JustifyContent.spaceAround,
          gridTemplate: const GridTemplate(
            rows: GridTracks([
              GridTrack(TrackSize.auto),
              GridTrack(TrackSize.auto),
            ]),
          ),
          gap: Gap.all(1.5.rem),
          raw: {'grid-auto-flow': 'column'},
        ),
        css('dt').styles(
          margin: Margin.only(bottom: 0.25.rem),
          color: colorTextMuted,
          textAlign: TextAlign.center,
          fontSize: 0.85.rem,
          textTransform: TextTransform.upperCase,
        ),
        css('dd').styles(
          margin: Margin.zero,
          color: colorTextDark,
          textAlign: TextAlign.center,
          fontSize: 1.1.rem,
          fontWeight: FontWeight.bold,
        ),
      ]),
      css('.flavor-notes', [
        css('&').styles(
          display: Display.flex,
          padding: Padding.zero,
          margin: Margin.zero,
          flexWrap: FlexWrap.wrap,
          justifyContent: JustifyContent.center,
          gap: Gap.all(0.5.rem),
          listStyle: ListStyle.none,
        ),
        css('li').styles(
          padding: Padding.symmetric(vertical: 0.4.rem, horizontal: 0.8.rem),
          border: Border.all(style: BorderStyle.solid, color: const Color('#C28DBE33'), width: 1.px),
          radius: BorderRadius.circular(8.px),
          color: scaWine,
          fontSize: 0.9.rem,
          fontWeight: FontWeight.w500,
          backgroundColor: const Color('#C28DBE1a'),
        ),
      ]),
    ]),
  ];
}