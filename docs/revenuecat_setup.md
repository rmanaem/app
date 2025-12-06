# RevenueCat setup checklist

- [ ] Set real RevenueCat public SDK keys for dev/prod in `lib/src/config/env.dart` and ensure flavors pass them via `lib/main_dev.dart` / `lib/main_prod.dart` or `--dart-define`/`.env`.
- [ ] Configure the RevenueCat dashboard: create products/offerings/entitlements matching App Store/Play IDs and your updated bundle IDs in Android/iOS.
- [ ] Enhance bootstrap: keep `Purchases.configure` in `lib/src/bootstrap/bootstrap.dart`; optionally add `setLogLevel`, user identification (login/alias/anonymous), and listeners for customer info/transactions.
- [ ] Build the data layer: add `features/subscription/data/sources/revenuecat_source.dart` wrapping Purchases (offerings, purchase package, restore, customer info), map via `entitlement_mapper.dart`, and expose `SubscriptionRepositoryRc` implementing `SubscriptionRepository`; cover with unit tests.
- [ ] Wire presentation: implement a Subscription VM/page per `docs/ARCHITECTURE.md` to load entitlements, show offerings/paywall, trigger purchase/restore, handle errors/loading; register routes and inject the repo/use cases.
- [ ] Verify flows: run `fvm flutter run --flavor dev --target lib/main_dev.dart`, test purchase/restore with sandbox testers, confirm entitlements/receipts in the RevenueCat dashboard, and emit analytics events for the purchase lifecycle.
