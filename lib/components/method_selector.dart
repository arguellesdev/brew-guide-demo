import '../constants/theme.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class MethodSelector extends StatelessComponent {
  final bool hasError;
  const MethodSelector({super.key, this.hasError = false});

  @override
  Component build(BuildContext context) {
    const onClickJs = '''
var loc = window.location.pathname;
history.replaceState({}, "", loc);
var banner = document.querySelector(".error-banner");
if(banner) banner.style.display = "none";
document.getElementById("loading").style.display="flex";
window.addEventListener("pageshow", function(e) {
  if(e.persisted) { document.getElementById("loading").style.display="none"; }
}, {once: true});
''';

    return section(classes: 'method-selector', [
      h1([Component.text('Brew Guide')]),
      p(classes: 'subtitle', [Component.text('Select a brewing method')]),
      if (hasError)
        div(classes: 'error-banner', [
          Component.text('Something went wrong. Please try again.'),
        ]),
      div(classes: 'method-grid', [
        form(method: FormMethod.post, action: '/api/gemini', [
          input(type: InputType.hidden, name: 'preference',
            attributes: {'value': 'Pour over coffee recommendation, light roast, floral and clean'}),
          button(type: ButtonType.submit, classes: 'method-card',
            attributes: {'onclick': onClickJs}, [
            h3([Component.text('Pour over')]),
            p([Component.text('Clean, floral, bright')]),
          ]),
        ]),
        form(method: FormMethod.post, action: '/api/gemini', [
          input(type: InputType.hidden, name: 'preference',
            attributes: {'value': 'Espresso coffee recommendation, dark roast, bold and intense with crema'}),
          button(type: ButtonType.submit, classes: 'method-card',
            attributes: {'onclick': onClickJs}, [
            h3([Component.text('Espresso')]),
            p([Component.text('Bold, intense, crema')]),
          ]),
        ]),
        form(method: FormMethod.post, action: '/api/gemini', [
          input(type: InputType.hidden, name: 'preference',
            attributes: {'value': 'Cold brew coffee recommendation, smooth and low acid, refreshing'}),
          button(type: ButtonType.submit, classes: 'method-card',
            attributes: {'onclick': onClickJs}, [
            h3([Component.text('Cold brew')]),
            p([Component.text('Smooth, low acid')]),
          ]),
        ]),
        form(method: FormMethod.post, action: '/api/gemini', [
          input(type: InputType.hidden, name: 'preference',
            attributes: {'value': 'French press coffee recommendation, medium dark roast, full body'}),
          button(type: ButtonType.submit, classes: 'method-card',
            attributes: {'onclick': onClickJs}, [
            h3([Component.text('French press')]),
            p([Component.text('Full body, rich')]),
          ]),
        ]),
      ]),
      form(classes: 'gemini-input', method: FormMethod.post, action: '/api/gemini', [
        input(
          type: InputType.text,
          name: 'preference',
          attributes: {'placeholder': 'Tell us a coffee to explore...'},
        ),
        button(type: ButtonType.submit,
          attributes: {'onclick': onClickJs},
          [Component.text('Ask Gemini')],
        ),
      ]),
      div(classes: 'loading-overlay', id: 'loading', [
        span(classes: 'cup', [Component.text('☕')]),
        p([Component.text('Brewing your recommendation...')]),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.error-banner').styles(
      padding: Padding.symmetric(vertical: 0.75.rem, horizontal: 1.5.rem),
      margin: Margin.only(bottom: 1.5.rem),
      radius: BorderRadius.circular(8.px),
      alignSelf: AlignSelf.center,
      color: scaWine,
      textAlign: TextAlign.center,
      fontSize: 0.95.rem,
      backgroundColor: const Color('#6927291a'),
    ),
    css('.loading-overlay', [
      css('&').styles(
        display: Display.none,
        flexDirection: FlexDirection.column,
        justifyContent: JustifyContent.center,
        alignItems: AlignItems.center,
        gap: Gap.all(1.5.rem),
        raw: {
          'position': 'fixed',
          'top': '0',
          'left': '0',
          'width': '100vw',
          'height': '100vh',
          'z-index': '999',
          'background-color': '#F5EFE4',
        },
      ),
      css('.cup').styles(
        fontSize: 4.rem,
        raw: {'animation': 'spin 1.5s linear infinite', 'display': 'block'},
      ),
      css('p').styles(
        color: colorTextMuted,
        fontSize: 1.1.rem,
      ),
    ]),
    css('@keyframes spin', [
      css('from').styles(raw: {'transform': 'rotate(0deg)'}),
      css('to').styles(raw: {'transform': 'rotate(360deg)'}),
    ]),
    css('.method-selector', [
      css('&').styles(
        display: Display.flex,
        maxWidth: 900.px,
        padding: Padding.symmetric(vertical: 4.rem, horizontal: 2.rem),
        margin: Margin.symmetric(vertical: Unit.zero, horizontal: Unit.auto),
        flexDirection: FlexDirection.column,
        alignItems: AlignItems.stretch,
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
          gap: Gap.all(0.5.rem),
          raw: {'width': '100%', 'box-sizing': 'border-box'},
        ),
        css('input', [
          css('&').styles(
            minWidth: Unit.zero,
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
            padding: Padding.symmetric(vertical: 0.8.rem, horizontal: 2.5.rem),
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
            raw: {'white-space': 'nowrap'},
          ),
          css('&:hover').styles(opacity: 0.9),
          css('&:active').styles(transform: Transform.scale(0.98)),
        ]),
      ]),
    ]),
  ];
}