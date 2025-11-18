import 'package:starter_app/firebase_options_prod.dart'
    as firebase_prod_options;
import 'package:starter_app/src/app/app.dart';
import 'package:starter_app/src/bootstrap/bootstrap.dart';
import 'package:starter_app/src/config/env.dart';

/// Entry point for running the template against the production environment.
Future<void> main() async {
  await bootstrap(
    () async => const App(envName: 'prod'),
    env: Env.prod,
    firebaseOptions:
        firebase_prod_options.DefaultFirebaseOptions.currentPlatform,
  );
}
