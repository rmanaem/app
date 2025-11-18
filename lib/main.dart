import 'package:starter_app/main_dev.dart' as dev;

/// Default entry point proxies to the dev flavor so `flutter run` works out
/// of the box without passing `--target`.
Future<void> main() => dev.main();
