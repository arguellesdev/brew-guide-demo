import 'package:jaspr/dom.dart';

// SCA Specialty Coffee Association flavor palette.
const scaCitrus     = Color('#FEC844');
const scaStrawberry = Color('#FF5658');
const scaChocolate  = Color('#74301E');
const scaFloral     = Color('#C28DBE');
const scaBlueberry  = Color('#2659B1');
const scaFerment    = Color('#CDAF29');
const scaWine       = Color('#692729');
const scaHerb       = Color('#30622D');
const scaBay        = Color('#143D37');

// Neutral surface palette.
const colorBackground = Color('#F5EFE4');
const colorSurface    = Color('#FFFDF8');
const colorBorder     = Color('#E2D5BE');
const colorTextDark   = Color('#1C1208');
const colorTextMid    = Color('#5C4A2A');
const colorTextMuted  = Color('#8C7355');

// Used by counter.dart. Remove when Counter is deleted.
const primaryColor = scaBlueberry;

@css
List<StyleRule> get styles => [
  css.import(
    'https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500&family=DM+Sans:wght@300;400;500&display=swap',
  ),
  css('html, body').styles(
    width: 100.percent,
    minHeight: 100.vh,
    padding: .zero,
    margin: .zero,
    backgroundColor: colorBackground,
    fontFamily: const .list([FontFamily('DM Sans'), FontFamilies.sansSerif]),
  ),
  css('h1').styles(
    margin: .unset,
    fontFamily: const .list([FontFamily('Playfair Display'), FontFamilies.serif]),
    fontSize: 2.5.rem,
    color: colorTextDark,
  ),
  css('h2').styles(
    fontFamily: const .list([FontFamily('Playfair Display'), FontFamilies.serif]),
    fontSize: 1.5.rem,
    color: colorTextDark,
    margin: .unset,
  ),
  css('p').styles(
    color: colorTextMid,
    fontSize: 0.9.rem,
    lineHeight: 1.7.em,
  ),
];