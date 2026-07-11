import 'package:jaspr/dom.dart';

// SCA Specialty Coffee Association flavor palette.
const scaCitrus     = Color('#F6B36F');
const scaStrawberry = Color('#FF5658');
const scaChocolate  = Color('#74301E');
const scaFloral     = Color('#C28DBE');
const scaBlueberry  = Color('#2659B1');
const scaFerment    = Color('#CDAF29');
const scaWine       = Color('#692729');
const scaHerb       = Color('#326359');
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
    'https://fonts.googleapis.com/css2?family=Playfair+Display:wght@500;700&family=DM+Sans:wght@400;500;700&display=swap',
  ),
  css('html, body').styles(
    width: 100.percent,
    minHeight: 100.vh,
    padding: .zero,
    margin: .zero,
    fontFamily: const .list([FontFamily('DM Sans'), FontFamilies.sansSerif]),
    backgroundColor: colorBackground,
  ),
  css('h1').styles(
    margin: .unset,
    color: colorTextDark,
    fontFamily: const .list([FontFamily('Playfair Display'), FontFamilies.serif]),
    fontSize: 3.rem,
    fontWeight: .w700,
  ),
  css('h2').styles(
    margin: .unset,
    color: colorTextDark,
    fontFamily: const .list([FontFamily('Playfair Display'), FontFamilies.serif]),
    fontSize: 2.rem,
    fontWeight: .w500,
  ),
  css('h3').styles(
    margin: .unset,
    color: colorTextDark,
    fontFamily: const .list([FontFamily('DM Sans'), FontFamilies.sansSerif]),
    fontSize: 1.2.rem,
    fontWeight: .w700,
  ),
  css('p').styles(
    color: colorTextMid,
    fontSize: 1.rem,
    fontWeight: .w400,
    lineHeight: 1.7.em,
  ),
];