import 'package:jaspr/jaspr.dart';
import '../components/method_selector.dart';

@client
class Home extends StatelessComponent {
  const Home({super.key});

  @override
  Component build(BuildContext context) {
    return const MethodSelector();
  }
}