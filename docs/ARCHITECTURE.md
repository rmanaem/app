# ARCHITECTURE.md — Atomic Design + MVVM for the Mobile App Template

> **Audience:** Mobile engineers and AI assistants contributing to this repository.  
> **Goals:** Keep the codebase **readable, testable, and scalable** by applying **Atomic Design** for the UI and **MVVM** for presentation logic, while enforcing clean architecture boundaries (presentation ↔ domain ↔ data).

---

## 1) Architectural Overview

We separate concerns across **three vertical layers** and **five horizontal UI strata**:

- **Vertical (Clean layers)**
  - **Presentation**: Widgets, pages, view models (UI-only logic) and view-state DTOs.
  - **Domain**: Pure Dart. Entities, value objects, use cases (application services), and repository interfaces.
  - **Data**: Integrations. Concretions for repositories (Firebase/RevenueCat/HTTP), DTOs, mappers.

- **Horizontal (Atomic Design)**
  - **Atoms → Molecules → Organisms → Templates → Pages**
  - Atoms/molecules/organisms are **purely presentational**; **Templates** place regions; **Pages** bind a **ViewModel** (MVVM) to a template and wire navigation/analytics.

**One-way flow:** ViewModel exposes **ViewState** → View renders; View raises **events** → ViewModel executes **use cases** → new ViewState.

---

## 2) Folder & Module Structure

```
lib/
└─ src/
   ├─ app/                 # App root: MaterialApp/router/theme and app-wide providers
   │  ├─ app.dart
   │  ├─ router.dart
   │  └─ design_system/
   ├─ bootstrap/           # Startup, env selection, third-party SDK init
   │  └─ bootstrap.dart
   ├─ config/              # Environment configuration
   │  └─ env.dart
   ├─ core/                # Cross-cutting; NO Flutter UI imports
   │  ├─ analytics/analytics_service.dart
   │  ├─ errors/failure.dart
   │  ├─ result/result.dart
   │  ├─ logging/logger.dart
   │  └─ utils/
   ├─ presentation/        # Atomic UI library (UI-only, no business rules)
   │  ├─ atoms/
   │  ├─ molecules/
   │  ├─ organisms/
   │  ├─ templates/
   │  └─ pages/            # Page shells only (no feature logic)
   └─ features/
      └─ <feature>/
         ├─ domain/
         │  ├─ entities/
         │  ├─ value_objects/
         │  ├─ repositories/        # abstract interfaces
         │  └─ usecases/            # pure application services
         ├─ data/
         │  ├─ dtos/
         │  ├─ mappers/
         │  ├─ sources/             # firebase, http, local
         │  └─ repositories_impl/   # implements domain repositories
         └─ presentation/
            ├─ viewmodels/
            ├─ viewstate/
            ├─ widgets/             # feature-specific atoms/molecules/organisms
            └─ pages/               # page binds VM to a template
```

> **Import rules:**  
> - `presentation` **can depend on** `domain` (viewmodels call usecases).  
> - `domain` **depends on nothing** (pure Dart).  
> - `data` **depends on** `domain` (implements repository interfaces).  
> - `presentation` **MUST NOT** import from `data` (use the interface only).  
> - Atomic components (`lib/src/presentation/...`) **never import** feature code; they’re shared UI only.

---

## 3) Atomic Design — How to author components

**Atoms:** simplest building blocks (buttons, text, icons). No business logic.  
**Molecules:** combinations of atoms forming a small, reusable pattern (e.g., `LabeledTextField`).  
**Organisms:** larger sections (e.g., `MealCard`, `WorkoutSummary`). Light UI state only.  
**Templates:** page layout regions; **no** feature data.  
**Pages:** concrete pages wiring a **ViewModel** (state + commands) to a **Template**.

**Golden tests** (`golden_toolkit`) cover atoms/molecules/organisms. Pages are covered by widget/integration tests.

---

## 4) MVVM — Where logic lives

**ViewModel responsibilities**  
- Hold **ViewState** (immutable data for the view).  
- Expose **commands** (methods the view calls on user intents).  
- Map **domain entities → ViewState** (formatting, label building).  
- Orchestrate flows across use cases, handle loading & error states.  
- **No** rendering, theme access, or `BuildContext` heavy use (only for navigation via an injected router abstraction if needed).

**View responsibilities**  
- Render ViewState through **atomic components**.  
- Forward user events to VM commands.  
- Provide accessibility labels and compose layout via templates.

**Domain responsibilities**  
- Pure policies: business rules, invariants, value objects, usecases.  
- No Flutter imports, no IO.

---

## 5) Example: Subscription (RevenueCat) Feature

### 5.1 Domain
```
features/subscription/domain/entities/entitlement.dart
features/subscription/domain/repositories/subscription_repo.dart
features/subscription/domain/usecases/refresh_entitlements.dart
```

```dart
// entities/entitlement.dart
class Entitlement {
  const Entitlement({required this.id, required this.active});
  final String id;
  final bool active;
}
```

```dart
// repositories/subscription_repo.dart
abstract class SubscriptionRepository {
  Future<List<Entitlement>> fetchEntitlements();
  Future<void> restorePurchases();
}
```

```dart
// usecases/refresh_entitlements.dart
class RefreshEntitlements {
  RefreshEntitlements(this._repo);
  final SubscriptionRepository _repo;

  Future<List<Entitlement>> call() => _repo.fetchEntitlements();
}
```

### 5.2 Data
```
features/subscription/data/sources/revenuecat_source.dart
features/subscription/data/mappers/entitlement_mapper.dart
features/subscription/data/repositories_impl/subscription_repo_rc.dart
```

```dart
// repositories_impl/subscription_repo_rc.dart
class SubscriptionRepositoryRc implements SubscriptionRepository {
  SubscriptionRepositoryRc(this._source);
  final RevenueCatSource _source;

  @override
  Future<List<Entitlement>> fetchEntitlements() async {
    final rcEntitlements = await _source.getEntitlements();
    return rcEntitlements.map(EntitlementMapper.fromRc).toList(growable: false);
  }

  @override
  Future<void> restorePurchases() => _source.restore();
}
```

### 5.3 Presentation (MVVM)
```
features/subscription/presentation/viewstate/subscription_view_state.dart
features/subscription/presentation/viewmodels/subscription_vm.dart
features/subscription/presentation/pages/subscription_page.dart
features/subscription/presentation/widgets/subscription_card.dart
```

```dart
// viewstate/subscription_view_state.dart
class SubscriptionViewState {
  const SubscriptionViewState({
    required this.items,
    this.loading = false,
    this.error,
  });

  final List<SubscriptionItemVm> items;
  final bool loading;
  final String? error;
}

class SubscriptionItemVm {
  const SubscriptionItemVm({required this.title, required this.active});
  final String title;
  final bool active;
}
```

```dart
// viewmodels/subscription_vm.dart (ChangeNotifier or Riverpod Notifier, your choice)
class SubscriptionVm extends ChangeNotifier {
  SubscriptionVm(this._refreshEntitlements);
  final RefreshEntitlements _refreshEntitlements;

  SubscriptionViewState _state = const SubscriptionViewState(items: [], loading: false);
  SubscriptionViewState get state => _state;

  Future<void> load() async {
    _state = SubscriptionViewState(items: state.items, loading: true);
    notifyListeners();
    try {
      final ents = await _refreshEntitlements();
      final items = ents.map((e) => SubscriptionItemVm(title: e.id, active: e.active)).toList();
      _state = SubscriptionViewState(items: items, loading: false);
    } catch (e) {
      _state = SubscriptionViewState(items: const [], loading: false, error: 'Unable to load entitlements.');
    }
    notifyListeners();
  }
}
```

```dart
// pages/subscription_page.dart (bind VM to a Template)
class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  late final SubscriptionVm vm;

  @override
  void initState() {
    super.initState();
    vm = SubscriptionVm(context.read<RefreshEntitlements>())..load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscription')),
      body: AnimatedBuilder(
        animation: vm,
        builder: (_, __) {
          if (vm.state.loading) return const Center(child: CircularProgressIndicator());
          if (vm.state.error != null) return Center(child: Text(vm.state.error!));
          return ListView(
            children: vm.state.items.map((it) => SubscriptionCard(title: it.title, active: it.active)).toList(),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }
}
```

---

## 6) Analytics & Navigation

**Analytics**
- Create a single `AnalyticsService` in `core/analytics/` that exposes **typed methods**.  
- Map **RevenueCat** lifecycle to analytics (e.g., trial started, renewal, cancellation).  
- Never log raw strings in views; always call the service methods.

**Navigation**
- Use `go_router` with typed route params.  
- Keep deep-link mapping in `router.dart`. A page’s ViewModel must not depend on concrete router APIs; inject a small `AppNavigator` interface when needed (testable).

---

## 7) Error Handling, Results, and Loading

- Use a simple `Result<T>` (success/failure) in the **domain** layer.  
- Surface **typed failures** (network, permission, not-found) and map them to user-friendly messages in the **ViewModel**.  
- Drive the page with a **finite state**: `idle` → `loading` → `data/error`. This avoids “phantom” UI states.

---

## 8) Testing Strategy (what goes where)

- **Unit tests (domain & viewmodels)**: use pure Dart tests; mock repositories/use cases using `mocktail`.  
- **Widget tests (presentation)**: exercise pages and organisms with fake VMs / stubbed providers.
- **Golden tests** (`golden_toolkit`): atoms/molecules/organisms snapshots across themes/screen sizes.  
- **Integration/E2E**: critical flows (sign-in, paywall, workout start/complete, meal log).

**Test layout**
```
test/
 ├─ domain/
 ├─ data/
 ├─ presentation/
 ├─ features/
 │  └─ <feature>/...
 └─ golden/
```

---

## 9) Naming, Conventions, and Style

- **Files**: `snake_case.dart`; tests mirror source paths.  
- **Classes**: `PascalCase`; view models end with `Vm`, view-state ends with `ViewState`.  
- **Use cases**: verb phrase (e.g., `RefreshEntitlements`).  
- **Repositories**: `<Entity>Repository` (interface) and `<Entity>RepositoryXxx` (implementation).  
- **Widgets**: atoms/molecules/organisms reflect their “atomic” role (`PrimaryButton`, `MealCard`).  
- **Lints**: keep `very_good_analysis` as the baseline; treat analyzer warnings as errors in CI.

---

## 10) Boundaries (do/don’t)

**Do**
- Keep **presentation** free of Firebase/HTTP; only call use cases.
- Keep **domain** pure; no Flutter imports, no Firebase classes.
- Map DTOs ↔ Entities in **data** mappers; never expose DTOs upward.
- Pass **ViewState** to UI; don’t leak entities to widgets.

**Don’t**
- Put business logic in widgets or atomic components.
- Access revenue/purchase SDKs from a View or ViewModel directly; go through a repository/use case.
- Create a ViewModel per atom/molecule; restrict VMs to pages (and occasionally organisms).

---

## 11) Environment & Secrets

- Keep environment selection in `config/env.dart`.  
- Pass per-flavor keys via `--dart-define` or `.env` (never commit secrets).  
- Keep **Firebase** initialization and **RevenueCat** configuration centralized in `bootstrap/bootstrap.dart`.

---

## 12) Definition of Done (per PR)

- All lints pass (`flutter analyze`), code formatted.  
- Unit tests for any new logic; widget/golden tests for new UI components.  
- Analytics events added through `AnalyticsService`.  
- No cross-layer imports violated.  
- Updated docs where needed (README/feature ADRs).

---

## 13) Appendix — Minimal Interfaces

```dart
// core/result/result.dart
sealed class Result<T> {
  const Result();
}

class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}

// core/errors/failure.dart
sealed class Failure {
  const Failure(this.message);
  final String message;
}

class NetworkFailure extends Failure { const NetworkFailure(super.message); }
class PermissionFailure extends Failure { const PermissionFailure(super.message); }
class UnknownFailure extends Failure { const UnknownFailure([super.message = 'Unknown error']); }
```

---

**Questions?** Use this doc as the single source of truth for structure and logic decisions. If a change requires bending these rules, add a short ADR (Architecture Decision Record) under `docs/adr/` explaining the trade-off.