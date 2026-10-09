import '../constants/theme.dart';
import 'brew_facts.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// Inline `onsubmit` handler for any form that waits on Gemini.
/// Runs after HTML validation passes, so the overlay never shows for a blocked submit.
const loadingOnSubmitJs = '''
var loc = window.location.pathname;
history.replaceState({}, "", loc);
var banner = document.querySelector(".error-banner");
if(banner) banner.style.display = "none";
document.getElementById("loading").style.display="flex";
window.addEventListener("pageshow", function(e) {
  if(e.persisted) { document.getElementById("loading").style.display="none"; }
}, {once: true});
''';

/// Full-screen overlay shown by [loadingOnSubmitJs] while the server waits on Gemini.
/// Render at most one per page: the script finds it by id.
class LoadingOverlay extends StatelessComponent {
  /// What we're waiting for, e.g. "Brewing your recommendation...".
  final String message;

  const LoadingOverlay({super.key, required this.message});

  @override
  Component build(BuildContext context) {
    return div(classes: 'loading-overlay', id: 'loading', [
      span(classes: 'cup', [Component.text('☕')]),
      p(classes: 'loading-text', [Component.text(message)]),
      const BrewFacts(),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.loading-overlay', [
      css('&').styles(
        display: Display.none,
        flexDirection: FlexDirection.column,
        justifyContent: JustifyContent.center,
        alignItems: AlignItems.center,
        gap: Gap.all(1.5.rem),
        backgroundColor: colorBackground,
        raw: {
          'position': 'fixed',
          'top': '0',
          'left': '0',
          'width': '100vw',
          'height': '100vh',
          'z-index': '999',
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
  ];
}
