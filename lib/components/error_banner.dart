import '../constants/theme.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// A human-readable failure message. [loadingOnSubmitJs] hides it when the user retries.
class ErrorBanner extends StatelessComponent {
  final String message;

  const ErrorBanner({super.key, required this.message});

  @override
  Component build(BuildContext context) {
    return p(classes: 'error-banner', attributes: {'role': 'alert'}, [Component.text(message)]);
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
      backgroundColor: scaWineTint,
    ),
  ];
}
