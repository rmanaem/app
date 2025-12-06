# Auth Setup Checklist

Use this list to wire Google, Apple, and Email/Password auth with Firebase using the existing UI preview.

- [ ] **Firebase console**
  - [ ] Enable Email/Password, Google, and Apple providers.
  - [ ] Add SHA-1 and SHA-256 fingerprints for all Android apps (dev/prod) in Project Settings.
  - [ ] For Apple: create a Services ID + Key, set the redirect URI from Firebase, and enter Team ID + Key ID in the provider config.
  - [ ] Create a Web app to obtain the Web client ID (needed for Google on iOS/web and Apple redirect).

- [ ] **Regenerate configs**
  - [ ] Run `fvm flutterfire configure --project <project_id> --out lib/firebase_options_dev.dart --platforms android,ios,web` (and prod variants) so web/iOS/Android options include Auth + OAuth clients.
  - [ ] Replace `android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist` with the generated files; then run `flutter pub get`.

- [ ] **Dependencies**
  - [ ] Add `firebase_auth`, `firebase_ui_auth`, `firebase_ui_oauth_google`, `firebase_ui_oauth_apple`, `google_sign_in`, `sign_in_with_apple` to `pubspec.yaml`.
  - [ ] Run `flutter pub get`.

- [ ] **Platform wiring**
  - [ ] iOS: enable the **Sign in with Apple** capability; ensure the new `GoogleService-Info.plist` contains `REVERSED_CLIENT_ID`; add `NSFaceIDUsageDescription` if using Face ID.
  - [ ] Android: confirm the Google Services plugin remains applied and that SHA keys are present in Firebase; no extra manifest changes needed for FirebaseUI Google.

- [ ] **App initialization**
  - [ ] Keep `Firebase.initializeApp` in `bootstrap`; start using `FirebaseAuth.instance` in app state.
  - [ ] In the auth preview, pass the Web client ID to `GoogleProvider` on iOS/web.

- [ ] **UI & routing**
  - [ ] Replace preview button taps with a `SignInScreen` (from `firebase_ui_auth`) or custom flow using providers: `EmailAuthProvider()`, `GoogleProvider(clientId: '<web_client_id>')`, `AppleProvider()`.
  - [ ] Handle `AuthStateChangeAction<SignedIn>` to route into the main app shell.
  - [ ] Gate app routes on `FirebaseAuth.instance.authStateChanges()` and redirect unauthenticated users to the sign-in screen.

- [ ] **Testing**
  - [ ] Verify sign-in on Android emulator (Google + email) and iOS simulator (Apple + Google via Web client ID). Test web if needed.
  - [ ] Exercise sign-out/re-auth flows and network/error handling.

- [ ] **Security/keys**
  - [ ] Keep Apple private key out of the repo; store it in CI secrets if needed.
  - [ ] Maintain separate Firebase projects/configs for dev vs prod.

- [ ] **CI/build**
  - [ ] If CI exists, add steps to supply `google-services.json` / `GoogleService-Info.plist` per flavor/env.
  - [ ] Optionally add an auth smoke test (widget test ensuring providers render).
