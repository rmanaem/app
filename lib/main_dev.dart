import 'package:starter_app/firebase_options_dev.dart' as firebase_dev_options;
import 'package:starter_app/src/app/app.dart';
import 'package:starter_app/src/bootstrap/bootstrap.dart';
import 'package:starter_app/src/config/env.dart';

/// Entry point for running the template against the dev environment.
Future<void> main() async {
  await bootstrap(
    () async => const App(envName: 'dev'),
    env: Env.dev,
    firebaseOptions:
        firebase_dev_options.DefaultFirebaseOptions.currentPlatform,
  );
}
