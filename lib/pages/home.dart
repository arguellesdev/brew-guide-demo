import 'package:jaspr/jaspr.dart';
import '../components/method_selector.dart';

@client
class Home extends StatelessComponent {
  final bool hasError;
  const Home({super.key, this.hasError = false});

  @override
  Component build(BuildContext context) {
    return MethodSelector(hasError: hasError);
  }
}