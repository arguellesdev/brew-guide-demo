import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../constants/theme.dart';

class MethodSelector extends StatelessComponent {
  const MethodSelector({super.key});

  @override
  Component build(BuildContext context) {
    return section(classes: 'method-selector', [
      h1([Component.text('Brew Guide')]),
      p(classes: 'subtitle', [Component.text('Select a brewing method')]),
      div(classes: 'method-grid', [
        a(classes: 'method-card', href: '/coffee/pour_over', [
          h3([Component.text('Pour over')]),
          p([Component.text('Clean, floral, bright')]),
        ]),
        a(classes: 'method-card', href: '/coffee/espresso', [
          h3([Component.text('Espresso')]),
          p([Component.text('Bold, intense, crema')]),
        ]),
        a(classes: 'method-card', href: '/coffee/cold_brew', [
          h3([Component.text('Cold brew')]),
          p([Component.text('Smooth, low acid')]),
        ]),
        a(classes: 'method-card', href: '/coffee/french_press', [
          h3([Component.text('French press')]),
          p([Component.text('Full body, rich')]),
        ]),
      ]),
      form(classes: 'gemini-input', method: FormMethod.post, action: '/api/gemini', [
        input(
          type: InputType.text,
          name: 'preference',
          attributes: {'placeholder': 'Describe what you are looking for...'},
        ),
        button(
          type: ButtonType.submit,
          [Component.text('Ask Gemini')],
        ),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.method-selector', [
      css('&').styles(
        display: Display.flex,
        maxWidth: 800.px,
        padding: Padding.symmetric(vertical: 4.rem, horizontal: 2.rem),
        margin: Margin.symmetric(vertical: Unit.zero, horizontal: Unit.auto),
        flexDirection: FlexDirection.column,
        alignItems: AlignItems.center,
      ),
      css('h1').styles(
        margin: Margin.only(bottom: 0.5.rem),
        textAlign: TextAlign.center,
        fontSize: 3.rem,
      ),
      css('.subtitle').styles(
        margin: Margin.only(bottom: 3.rem),
        color: colorTextMuted,
        textAlign: TextAlign.center,
        fontSize: 1.1.rem,
      ),
      css('.method-grid', [
        css('&').styles(
          display: Display.grid,
          width: 100.percent,
          margin: Margin.only(bottom: 3.rem),
          gridTemplate: GridTemplate(
            columns: GridTracks([
              GridTrack.repeat(TrackRepeat(2), [GridTrack(TrackSize.fr(1))]),
            ]),
          ),
          gap: Gap.all(1.5.rem),
        ),
        css('.method-card', [
          css('&').styles(
            display: Display.flex,
            padding: Padding.all(1.5.rem),
            border: Border.all(style: BorderStyle.solid, color: colorBorder, width: 2.px),
            radius: BorderRadius.circular(12.px),
            cursor: Cursor.pointer,
            transition: Transition.combine([
              Transition('border-color', duration: const Duration(milliseconds: 200), curve: Curve.ease),
              Transition('transform', duration: const Duration(milliseconds: 200), curve: Curve.ease),
              Transition('box-shadow', duration: const Duration(milliseconds: 200), curve: Curve.ease),
            ]),
            flexDirection: FlexDirection.column,
            textDecoration: TextDecoration(line: TextDecorationLine.none),
            backgroundColor: colorBackground,
          ),
          css('&:hover').styles(
            border: Border.all(style: BorderStyle.solid, color: scaHerb, width: 2.px),
            shadow: BoxShadow(
              offsetX: Unit.zero,
              offsetY: 8.px,
              blur: 24.px,
              color: const Color('#2b6a5d1a'),
            ),
            transform: Transform.translate(y: (-4).px),
          ),
          css('h3').styles(
            margin: Margin.zero,
            color: colorTextDark,
            fontSize: 1.3.rem,
            fontWeight: FontWeight.w700,
          ),
          css('p').styles(
            margin: Margin.only(top: 0.5.rem),
            color: colorTextMid,
            fontSize: 0.9.rem,
          ),
        ]),
      ]),
      css('.gemini-input', [
        css('&').styles(
          display: Display.flex,
          width: 100.percent,
          maxWidth: 500.px,
          gap: Gap.all(0.5.rem),
        ),
        css('input', [
          css('&').styles(
            padding: Padding.symmetric(vertical: 0.8.rem, horizontal: 1.rem),
            border: Border.all(style: BorderStyle.solid, color: colorBorder, width: 1.px),
            radius: BorderRadius.circular(8.px),
            outline: Outline(style: OutlineStyle.none),
            transition: Transition('border-color', duration: const Duration(milliseconds: 200), curve: Curve.ease),
            flex: const Flex(grow: 1),
            color: colorTextDark,
            fontSize: 0.95.rem,
            backgroundColor: colorSurface,
          ),
          css('&:focus').styles(
            border: Border.all(style: BorderStyle.solid, color: scaHerb, width: 1.px),
          ),
        ]),
        css('button', [
          css('&').styles(
            padding: Padding.symmetric(vertical: 0.8.rem, horizontal: 1.5.rem),
            border: Border.none,
            radius: BorderRadius.circular(8.px),
            cursor: Cursor.pointer,
            transition: Transition.combine([
              Transition('opacity', duration: const Duration(milliseconds: 200), curve: Curve.ease),
              Transition('transform', duration: const Duration(milliseconds: 100), curve: Curve.ease),
            ]),
            color: scaCitrus,
            fontSize: 0.95.rem,
            fontWeight: FontWeight.w700,
            backgroundColor: scaWine,
          ),
          css('&:hover').styles(
            opacity: 0.9,
          ),
          css('&:active').styles(
            transform: Transform.scale(0.98),
          ),
        ]),
      ]),
    ]),
  ];
}
