import '../constants/theme.dart';
import 'error_banner.dart';
import 'loading_overlay.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// Messages for each failure the server can send back (see GeminiFailure).
const _errorMessages = {
  'busy': 'Gemini is busy brewing for others. Give it a moment and try again.',
  'timeout': 'That took longer than expected. Please try again.',
  'badResponse': 'Gemini\'s answer came out a bit garbled. Please try again.',
  'unavailable': 'Our AI barista is offline right now. Pick a brewing method above for a house recipe.',
  'rateLimited': 'That\'s a lot of coffee in a short time. Please wait a few minutes and try again.',
  'empty': 'Tell us what kind of coffee you\'d like to explore.',
};

const _methods = [
  (
    id: 'pour_over',
    title: 'Pour over',
    subtitle: 'Clean, floral, bright',
    preference: 'Pour over coffee recommendation, light roast, floral and clean',
  ),
  (
    id: 'espresso',
    title: 'Espresso',
    subtitle: 'Bold, intense, crema',
    preference: 'Espresso coffee recommendation, dark roast, bold and intense with crema',
  ),
  (
    id: 'cold_brew',
    title: 'Cold brew',
    subtitle: 'Smooth, low acid',
    preference: 'Cold brew coffee recommendation, smooth and low acid, refreshing',
  ),
  (
    id: 'french_press',
    title: 'French press',
    subtitle: 'Full body, rich',
    preference: 'French press coffee recommendation, medium dark roast, full body',
  ),
];

class MethodSelector extends StatelessComponent {
  /// Why the last request failed, if it did. Keys into [_errorMessages].
  final String? error;

  /// The user's last free-text request, refilled so retrying is one click.
  final String query;

  const MethodSelector({super.key, this.error, this.query = ''});

  @override
  Component build(BuildContext context) {
    final errorMessage = error == null ? null : _errorMessages[error] ?? 'Something went wrong. Please try again.';
    final canRetry = error != null && query.isNotEmpty;

    return section(classes: 'method-selector', [
      h1([Component.text('Brew Guide')]),
      p(classes: 'subtitle', [Component.text('Select a brewing method')]),
      if (errorMessage != null) ErrorBanner(message: errorMessage),
      div(classes: 'method-grid', [
        for (final m in _methods)
          form(
            method: FormMethod.post,
            action: '/api/gemini',
            attributes: {'onsubmit': loadingOnSubmitJs},
            [
              input(type: InputType.hidden, name: 'preference', attributes: {'value': m.preference}),
              // Lets the server fall back to a house guide for this method if Gemini fails.
              input(type: InputType.hidden, name: 'method', attributes: {'value': m.id}),
              button(type: ButtonType.submit, classes: 'method-card', [
                h3([Component.text(m.title)]),
                p([Component.text(m.subtitle)]),
              ]),
            ],
          ),
      ]),
      form(
        classes: 'gemini-input',
        method: FormMethod.post,
        action: '/api/gemini',
        attributes: {'onsubmit': loadingOnSubmitJs},
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
        ],
      ),
      a(href: '/compare', classes: 'compare-link', [Component.text('Compare methods & bust myths')]),
      const LoadingOverlay(message: 'Brewing your recommendation...'),
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
            // Fill the grid cell; buttons otherwise shrink to their text.
            width: 100.percent,
            height: 100.percent,
            padding: Padding.all(1.5.rem),
            boxSizing: BoxSizing.borderBox,
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
      css('.compare-link', [
        css('&').styles(
          display: Display.flex,
          minHeight: 3.rem,
          padding: Padding.symmetric(horizontal: 1.5.rem),
          margin: Margin.only(top: 1.5.rem),
          border: Border.all(style: BorderStyle.solid, color: scaHerb, width: 2.px),
          radius: BorderRadius.circular(8.px),
          transition: Transition('background-color', duration: const Duration(milliseconds: 200), curve: Curve.ease),
          justifyContent: JustifyContent.center,
          alignItems: AlignItems.center,
          color: scaHerb,
          fontSize: 0.95.rem,
          fontWeight: FontWeight.w700,
          textDecoration: TextDecoration(line: TextDecorationLine.none),
        ),
        css('&:hover').styles(backgroundColor: scaHerbTint),
        css('&:focus-visible').styles(
          outline: Outline(style: OutlineStyle.solid, color: scaHerb, width: OutlineWidth(2.px), offset: 2.px),
        ),
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
