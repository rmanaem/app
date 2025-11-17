Flutter App Template
starter for mobile apps with Flutter, Firebase (incl. Analytics), and RevenueCat.

## Quick start
1. **Prereqs**: install [FVM](https://fvm.app/docs/getting_started/overview/) (`dart pub global activate fvm`) and ensure `$HOME/.pub-cache/bin` is on your PATH. Then run `fvm install` / `fvm use` for your desired Flutter channel. See [Linting setup](#linting-setup) for why FVM matters.
2. **Clone + deps**: `git clone <this_repo> <your_app>` and `cd <your_app>`. Run `npm install` (installs Lefthook hooks per [Git hooks](#git-hooks)) and `fvm flutter pub get`.
3. **Configure Firebase**: install the Firebase CLI, `firebase login`, and run `fvm flutterfire configure --project <your_project_id> --out lib/firebase_options.dart --platforms android,ios`. Details live in [Still required per project](#still-required-per-project).
4. **Env files**: copy `.env.example` → `.env` and fill secrets used by `flutter_dotenv` (see [Included tooling](#included-tooling)).
5. **Run it**: launch the dev flavor with `fvm flutter run --flavor dev --target lib/main_dev.dart`. After renaming identifiers and wiring flavors per [Still required per project](#still-required-per-project), repeat for prod as needed.
6. **Customize identifiers & services**: update bundle IDs, package names, Firebase/RevenueCat keys, and env-specific flavors to match your app. The sections below walk through every file that still needs customization before shipping.

## Template overview
### What’s already in place
- **Flutter scaffold** created via `fvm flutter create --org com.example.template --project-name starter_app .`.
- **Multienvironment bootstrap** (`lib/src/bootstrap/bootstrap.dart`, `lib/main_dev.dart`, `lib/main_prod.dart`) initializes Firebase and RevenueCat per environment.
- **Atomic design structure** under `lib/src/presentation/{atoms,molecules,organisms,templates,pages}` for UI components.
- **Routing & shell app** (`lib/src/app/app.dart`) wired with `go_router`.
- **Linting** enforced by Very Good Analysis (`analysis_options.yaml` + `dev_dependencies`).
- **Dependencies** for Firebase, RevenueCat, go_router, logging, and dotenv already added to `pubspec.yaml`.

### Included tooling
- **Firebase Core & Analytics** (`firebase_core`, `firebase_analytics`): run `flutterfire configure` per environment and replace `lib/firebase_options.dart` with the generated file.
- **Crash reporting** (`firebase_crashlytics` - optional): Firebase Crashlytics captures uncaught fatal/nonfatal crashes from production builds. This template does not wire it in by default; add `firebase_crashlytics` to `pubspec.yaml`, rerun `fvm flutterfire configure` so `firebase_options.dart`, `google-services.json`, and `GoogleService-Info.plist` include Crashlytics, then hook `FirebaseCrashlytics.instance` into `lib/src/bootstrap/bootstrap.dart` (assign to `FlutterError.onError`, wrap `runApp` in `runZonedGuarded`, and enable/disable collection per env). Finally, apply the Google Services + Crashlytics Gradle plugins and run `pod install` so Android/iOS builds upload crash reports.
- **RevenueCat** (`purchases_flutter`): set `Env.dev`/`Env.prod` keys and integrate entitlements throughout your code.
- **Routing** (`go_router`): adjust `GoRouter` definitions in `lib/src/app` or feature modules to reflect your navigation graph.
- **Logging** (`logger`, `logging`): central utility available for structured logs; configure sinks/filters as needed.
- **Environment variables** (`flutter_dotenv`): load configuration from `.env`; never commit real secrets. A starter `.env.example` is included—copy it to `.env` locally and fill in keys (or keep secrets server-side if you prefer compile-time separation).
- **Code generation & testing**: `build_runner`, `json_serializable`, and `freezed` are ready for data-layer scaffolding, while `mocktail` supports mocking in tests.
- **Branding helpers**: `flutter_launcher_icons` and `flutter_native_splash` let you generate platform icons and splash screens; configure their sections in `pubspec.yaml` and run the provided CLI commands when customizing the template.

## Required setup
### Still required per project
- Replace bundle identifiers & package names (`android/app/build.gradle`, `android/...`, `ios/...`, `pubspec.yaml`).
- Set up Firebase yourself: install the Firebase CLI, run `firebase login`, then execute `fvm flutterfire configure --project <your_project_id> --out lib/firebase_options.dart --platforms android,ios` (repeat per flavor/alias if needed). Commit or ignore the generated `firebase_options.dart` per your security policy.
- Update `Env.dev` / `Env.prod` in `lib/src/config/env.dart` with real RevenueCat public SDK keys.
- Create `.env` and project-specific `.env` files for secrets read via `flutter_dotenv`.
- Flesh out routers, presentation layers, and features beyond the placeholder home page.
- Wire platform flavors:
  - **Android**: edit `android/app/build.gradle` to add `flavorDimensions "env"` plus `dev`/`prod` product flavors (e.g., suffix `.dev`, versionName suffix). Create `android/app/src/dev` and `android/app/src/prod` for flavor-specific resources.
  - **iOS**: open `ios/Runner.xcworkspace` in Xcode, duplicate the Runner scheme into per-flavor schemes (Runner-dev, Runner-prod), and adjust Bundle Identifiers (e.g., `.dev`) in the appropriate configurations. FlutterFire handles `FirebaseApp.configure()` via `firebase_options.dart`.

### Finalize the template clone
- Remove or ignore machine-specific artifacts (`.fvm/flutter_sdk`, `.dart_tool`, `build/`).
- Run `fvm flutter pub get` and a minimal build (`fvm flutter test` or `fvm flutter build apk`) to ensure your renamed project compiles.
- Commit your renamed project to its new repository; the template should no longer reference this repo afterward.
- For iOS, run `cd ios && pod install && cd ..` after updating bundle IDs so CocoaPods stays in sync.
- Once your Firebase config exists, verify flavors with `fvm flutter run --flavor dev --target lib/main_dev.dart` (and similarly for prod). Without a real `firebase_options.dart`, the flavor run intentionally throws (or shows a blank screen on web) because the stub throws `UnimplementedError`. Generate the real file via `flutterfire configure` before running.

## Development workflow
### Linting setup
- The template ships with **Very Good Analysis** enabled by default (`analysis_options.yaml` includes `package:very_good_analysis/analysis_options.yaml` with stricter inference and raw-type checks).
- If you prefer the official baseline instead, change the include to `package:flutter_lints/flutter.yaml` and remove `very_good_analysis` from `dev_dependencies`.
- Run `fvm flutter analyze` after renaming packages to make sure the chosen lint rules are satisfied. Ensure FVM has permission to write to its Flutter SDK cache.

### Smoke test
- A widget smoke test (`test/app_smoke_test.dart`) verifies the template renders the root `App` widget.
- Run it (with coverage) using `fvm flutter test --coverage`. If the command can’t write to the Flutter SDK cache, adjust permissions or relocate the SDK before rerunning. The full test suite (`fvm flutter test`) should pass once Firebase options are configured.
- Static analysis via `fvm flutter analyze` passes when the template is renamed and Firebase is configured.
- Launching `fvm flutter run --flavor dev --target lib/main_dev.dart -d <device>` will boot the app and log Firebase initialization once you’ve generated real `firebase_options.dart`.

### Git hooks
- Hooks are standardized with [Lefthook](https://github.com/evilmartians/lefthook); install them via `npm install` (runs `lefthook install` through the `prepare` script) or manually with `npx lefthook install`.
- The `pre-commit` hook runs `fvm dart format --set-exit-if-changed .`, `fvm flutter analyze`, and `fvm flutter test -j 1` to keep commits linted and tested. Ensure `fvm` is available on your PATH.
- The `commit-msg` hook executes `npx --no-install commitlint --edit <msg>` to enforce Conventional Commits. Node/npm are required for Commitlint + Lefthook.
- Customize hook behavior via `lefthook.yml` and commit the changes so every developer shares the same workflow.
- GitHub Actions (`.github/workflows/ci.yml`) reruns the analyzer and tests on every push/PR, and PR templates/code owners enforce clean contributions throughout the review cycle.

### Continuous integration
- `.github/workflows/ci.yml` runs the same analyze/test steps in GitHub Actions (`flutter analyze`, `flutter test --coverage`). Add a macOS runner job later for iOS builds if you want CI builds; start simple here.

## Architecture
### Feature modules & MVVM
- The atomic components in `lib/src/presentation/{atoms,molecules,organisms,templates,pages}` stay UI-only. Treat them as “views” in MVVM.
- Application logic lives inside feature folders under `lib/src/features/<feature>/` with `data/`, `domain/`, and `presentation/` subdirectories. Example counter slice:

  ```
  lib/src/features/sample_counter/
    data/counter_repository.dart
    domain/use_cases/increment_counter.dart
    presentation/viewmodels/sample_counter_view_model.dart
    presentation/pages/sample_counter_page.dart
  ```

- Each feature exposes ViewModels (e.g., `SampleCounterViewModel` extends `ChangeNotifier`) that talk to use cases/repositories and feed data down into atomic widgets. Pages such as `SampleCounterPage` compose atoms (like `AppButton`) and bubble user intents back up to the ViewModel.
- Inject ViewModels however you prefer (Provider, Riverpod, Bloc, GetIt). The sample counter page shows manual wiring; swap it for your DI/locator when integrating with GoRouter.
- For deeper architectural guidance (clean layers, Atomic Design rules, import boundaries, and a RevenueCat subscription walkthrough), see `docs/ARCHITECTURE.md`.

### Atomic design note
UI elements under `lib/src/presentation` follow the atoms → molecules → organisms → templates → pages hierarchy (per Brad Frost’s Atomic Design). When adding new widgets:
- Keep the smallest reusable UI parts in `atoms`.
- Compose them into `molecules` and `organisms`.
- Use `templates` for layout skeletons and `pages` to bind real content/state to those templates.

We’ve seeded the atoms layer with a stock `AppButton` (`lib/src/presentation/atoms/app_button.dart`) so higher-level components can share button styling from day one. As you grow, compose atoms into molecules/organisms, plug into templates, then render as pages. This “Russian nesting doll” composition keeps patterns DRY and testable.
- Feature folders (`lib/src/features/...`) should import these atomic components so composition scales cleanly as teams build new screens.

### Golden tests
- Golden tests aren’t included by default to keep the template lean. Once you add rich UI components, install `golden_toolkit` (dev dependency), configure your golden directories, and run `fvm flutter test --update-goldens` to capture snapshots. Use them for atoms/molecules/organisms that benefit from visual regression coverage.

## Automation
- **Release Please** (`.github/workflows/release-please.yml`): listens to pushes on `main` and uses Conventional Commits to create release PRs/tags/changelogs automatically. Merge release PRs to tag template versions.
- **Dependabot** (`.github/dependabot.yml`): opens weekly PRs for both pub dependencies and GitHub Actions versions so the template stays up to date.
- **Contribution templates & ownership**: `.github/PULL_REQUEST_TEMPLATE.md` (PR checklist) and `.github/ISSUE_TEMPLATE/bug_report.md` (guided bug report) help keep contributions consistent. `CODEOWNERS` ensures `@your-org/mobile-core` reviews changes by default.
- **Contributing docs**: see `docs/CONTRIBUTING.md` for coding standards (use FVM, run format/analyze/test, follow Conventional Commits) and helpful scripts. `docs/AI_PROMPTS.md` captures guidance/templates for working with AI assistants while respecting repo conventions.
- **Editor configuration**: `.editorconfig` keeps spacing/formatting consistent across editors; adjust it if your team uses different conventions.

## Next steps
- Add feature modules (e.g., `lib/src/features/auth`) as your app grows, while keeping reusable UI building blocks in the atomic presentation layers.
- Instrument Firebase Analytics: wire a `GoRouterObserver` for screen views and emit custom events around key flows once your app logic exists.
- Replace the placeholder RevenueCat keys in `Env.dev`/`Env.prod` and add a sample paywall page to validate the monetization flow.
- Expand testing with golden tests (via `golden_toolkit`) and integration tests using the `integration_test` package.
- Introduce Fastlane scripts and a macOS GitHub Actions job when you’re ready to automate iOS builds and releases.
