import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:starter_app/src/config/env.dart';

/// Initializes Flutter bindings, Firebase, and RevenueCat before running
/// [builder].
Future<void> bootstrap(
  Future<Widget> Function() builder, {
  required Env env,
  required FirebaseOptions firebaseOptions,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: firebaseOptions,
  );

  await Purchases.configure(
    PurchasesConfiguration(env.revenuecatPublicSdkKey),
  );

  // Firebase Analytics is initialized via firebase_core; grabbing the instance
  // ensures the linkage happens before the widget tree builds.
  FirebaseAnalytics.instance;

  runApp(await builder());
}
