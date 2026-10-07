import '../constants/theme.dart';
import 'brew_facts.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// Messages for each failure the server can send back (see GeminiFailure).
const _errorMessages = {
  'busy': 'Gemini is busy brewing for others. Give it a moment and try again.',
  'timeout': 'That took longer than expected. Please try again.',
  'badResponse': 'Gemini\'s answer came out a bit garbled. Please try again.',
  'unavailable': 'Our AI barista is offline right now. Pick a brewing method above for a house recipe.',
  'empty': 'Tell us what kind of coffee you\'d like to explore.',
};

const _methods = [
  (id: 'pour_over', title: 'Pour over', subtitle: 'Clean, floral, bright',
    preference: 'Pour over coffee recommendation, light roast, floral and clean'),
  (id: 'espresso', title: 'Espresso', subtitle: 'Bold, intense, crema',
    preference: 'Espresso coffee recommendation, dark roast, bold and intense with crema'),
  (id: 'cold_brew', title: 'Cold brew', subtitle: 'Smooth, low acid',
    preference: 'Cold brew coffee recommendation, smooth and low acid, refreshing'),
  (id: 'french_press', title: 'French press', subtitle: 'Full body, rich',
    preference: 'French press coffee recommendation, medium dark roast, full body'),
];

// Runs on form submit (after HTML validation passes), so the overlay never shows for a blocked submit.
const _onSubmitJs = '''
var loc = window.location.pathname;
history.replaceState({}, "", loc);
var banner = document.querySelector(".error-banner");
if(banner) banner.style.display = "none";
document.getElementById("loading").style.display="flex";
window.addEventListener("pageshow", function(e) {
  if(e.persisted) { document.getElementById("loading").style.display="none"; }
}, {once: true});
''';

class MethodSelector extends StatelessComponent {
  /// Why the last request failed, if it did. Keys into [_errorMessages].
  final String? error;

  /// The user's last free-text request, refilled so retrying is one click.
  final String query;

  const MethodSelector({super.key, this.error, this.query = ''});

  @override
  Component build(BuildContext context) {
    final errorMessage = error == null
        ? null
        : _errorMessages[error] ?? 'Something went wrong. Please try again.';
    final canRetry = error != null && query.isNotEmpty;

    return section(classes: 'method-selector', [
      h1([Component.text('Brew Guide')]),
      p(classes: 'subtitle', [Component.text('Select a brewing method')]),
      if (errorMessage != null)
        div(classes: 'error-banner', [Component.text(errorMessage)]),
      div(classes: 'method-grid', [
        for (final m in _methods)
          form(method: FormMethod.post, action: '/api/gemini', attributes: {'onsubmit': _onSubmitJs}, [
            input(type: InputType.hidden, name: 'preference', attributes: {'value': m.preference}),
            // Lets the server fall back to a house guide for this method if Gemini fails.
            input(type: InputType.hidden, name: 'method', attributes: {'value': m.id}),
            button(type: ButtonType.submit, classes: 'method-card', [
              h3([Component.text(m.title)]),
              p([Component.text(m.subtitle)]),
            ]),
          ]),
      ]),
      form(
          classes: 'gemini-input',
          method: FormMethod.post,
          action: '/api/gemini',
          attributes: {'onsubmit': _onSubmitJs},
          [
        input(
          type: InputType.text,
          name: 'preference',
          attributes: {
            'placeholder': 'Tell us a coffee to explore...',
            'value': query,
            // The browser blocks empty submits before they reach the server.
            'required': '',
          },
        ),
        button(
          type: ButtonType.submit,
          [Component.text(canRetry ? 'Try again' : 'Ask Gemini')],
        ),
      ]),
      div(classes: 'loading-overlay', id: 'loading', [
        span(classes: 'cup', [Component.text('☕')]),
        p(classes: 'loading-text', [Component.text('Brewing your recommendation...')]),
        const BrewFacts(),
      ]),
      a(
        href: '/docs/brew-guide-run-guide.pdf',
        classes: 'guide-link',
        attributes: {'target': '_blank'},
        [Component.text('📋 Run Guide')],
      ),
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
      css('.loading-text').styles(
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
      css('.guide-link').styles(
        color: colorTextMuted,
        fontSize: 0.8.rem,
        textDecoration: TextDecoration(line: TextDecorationLine.none),
        raw: {
          'position': 'fixed',
          'bottom': '1.5rem',
          'right': '1.5rem',
          'opacity': '0.4',
          'z-index': '100',
        },
      ),
    ]),
  ];
}