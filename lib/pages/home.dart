import 'package:jaspr/jaspr.dart';
import '../components/method_selector.dart';

class Home extends StatelessComponent {
  /// A [GeminiFailure] name (or 'empty') when the last request failed.
  final String? error;

  /// The user's free-text request, so a failed one can be retried.
  final String query;

  const Home({super.key, this.error, this.query = ''});

  @override
  Component build(BuildContext context) {
    return MethodSelector(error: error, query: query);
  }
}
