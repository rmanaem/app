# Settings Tab – UX & Implementation Spec (v2)

## 1. Purpose

The **Settings** tab is the app’s control center.

- App‑level configuration (units, theme, notifications).
- Account controls (sign out, later: delete account).
- Legal & privacy access (ToS, Privacy, Health disclaimer).
- A home for **future** coaching/strategy settings (paid features).

For MVP, Settings is intentionally **simple and stable**, with a single page and no deep navigation trees.

---

## 2. UX / Layout

### 2.1 Overall structure

Single scrollable page with grouped sections:

1. **Account**
2. **Preferences**
3. **Notifications**
4. **Legal & Privacy**
5. **About**
6. **(Future) Coaching & Strategy** – placeholder only (post‑MVP)

Visual rules:

- Use standard page layout shared across tabs:
  - `Scaffold` + `SafeArea`
  - Background: `AppColors.bg`
  - Content: `Padding(horizontal: 16, vertical: 12)`
- Section title text: `textTheme.titleMedium` with `AppColors.ink`.
- Rows/cards:
  - Background: `AppColors.surface2`
  - Border: `AppColors.ringTrack`
  - Radius: 12–16
  - Row height: ~56dp for tappable rows.

### 2.2 Section details

#### 2.2.1 Account

**Goal:** Basic identity info + sign‑out.

Content:

- Row: **Email**
  - Label left: `Email`
  - Value right: user’s email address from auth.
  - Non‑tappable (MVP).
- Row: **Sign out**
  - Label left: `Sign out`
  - Trailing icon: `Icons.logout`
  - Tapping → confirm dialog → Firebase Auth signOut → back to Welcome / Auth flow.

Optional (post‑MVP):

- Row: **Delete account**
  - Red text.
  - For now: show a “Not yet available” dialog or hide entirely until backend support exists.

States:

- If anonymous / Apple / Google sign‑in:
  - You still show whichever primary identifier you have (e.g. Apple relay email).

#### 2.2.2 Preferences

**Goal:** Let the user make the app feel “like theirs” without breaking onboarding/plan logic.

Subsections (could be a single card with multiple rows):

1. **Units**
   - Row: `Weight units`
     - Value: `kg` or `lb`
     - On tap: open bottom sheet with radio options:
       - `Kilograms (kg)`
       - `Pounds (lb)`
   - Row: `Height units`
     - Value: `cm` or `ft/in`
     - On tap: bottom sheet:
       - `Centimeters (cm)`
       - `Feet & inches`
   - Row: `Training weight units`
     - Value: `kg` or `lb` (can mirror weight units by default).

   > **Important:** These must stay consistent with units used in onboarding + Today/Nutrition/Training. Changes may require converting stored values or at least updating presentation. MVP can be display‑only if conversion is complex; but the UX should be wired for it.

2. **Theme**
   - Row: `Appearance`
     - Value: `System`, `Dark`, or `Light`.
     - On tap: bottom sheet with:
       - `Use system setting` (default)
       - `Dark`
       - `Light`
   - Changes should update the app via a theme controller (e.g. a top‑level provider/notifier).

#### 2.2.3 Notifications

**Goal:** Minimal control over key reminders.

Rows:

- `Food logging reminders`
  - Trailing switch.
  - Hint text: `Remind me to log meals.` (tooltip / supporting text line).
- `Weight reminders`
  - Trailing switch.
  - Hint: `Remind me to weigh in.` 
- `Training reminders`
  - Trailing switch.
  - Hint: `Remind me about planned workouts.`

Behavior:

- MVP: toggles update local preferences; actual OS‑level notification scheduling can be a stub.
- Later: connect to real local notifications.

#### 2.2.4 Legal & Privacy

**Goal:** Easy access to all legal docs and health disclaimers.

Rows:

- `Terms of Service`
- `Privacy Policy`
- `Health Disclaimer`
  - This corresponds to the MacroFactor‑style “diet responsibly / consumer health data” page.
- `Open‑source licenses` (optional MVP; can be added later via standard Flutter licenses page).

Behavior:

- On tap: navigate to either:
  - In‑app markdown page, or
  - WebView / external browser with hosted docs.
- MVP is allowed to simply open a web URL.

#### 2.2.5 About

**Goal:** Minimal app metadata + a simple way to contact you.

Rows:

- `Version`
  - Value: e.g. `1.0.0 (100)` from `package_info_plus`.
  - Non‑tappable.
- `Contact support`
  - Tapping opens:
    - `mailto:` intent, or
    - Placeholder dialog: “Email us at support@example.com”.

No heavy support tooling is required for MVP.

#### 2.2.6 (Future) Coaching & Strategy

**Not in MVP**, but we reserve a place here:

- Section header: `Coaching & strategy` (can be hidden until Pro is live).
- Will contain:
  - Diet coach controls: goal mode, rate aggressiveness, check‑in day, etc.
  - Training coach controls: split type, days/week, fatigue flags, auto‑progression mode, etc.
- Most of these will be **paid features**, so either:
  - Hidden until subscription active, or
  - Shown with lock icon and paywall link.

For now, this section **does not appear** in the UI.

---

## 3. Widget & file structure

### 3.1 Files

Feature root:

- `lib/src/features/settings/presentation/pages/settings_page.dart`

Subwidgets (either in same file or split later as they grow):

- `settings_section_header.dart` (optional shared for Settings)
- `settings_list_tile.dart` (optional reusable wrapper with correct paddings/borders)
- `_AccountSection`
- `_PreferencesSection`
- `_NotificationsSection`
- `_LegalSection`
- `_AboutSection`

Domain/data (minimal for MVP):

- `lib/src/features/settings/domain/entities/user_preferences.dart`
  - Units + theme + notification toggles.
- `lib/src/features/settings/domain/repositories/settings_repository.dart`
  - `Future<UserPreferences> getPreferences()`
  - `Future<void> savePreferences(UserPreferences prefs)`

Data implementation (later or simple in‑memory for now):

- `lib/src/features/settings/data/repositories_impl/settings_repository_local.dart`
  - Backed by SharedPreferences / secure storage later.
  - For now, can be an in‑memory fake seeded with sane defaults.

---

## 4. Presentation layer

### 4.1 SettingsViewState

We keep this **UI‑ready** and flat:

```dart
class SettingsViewState {
  const SettingsViewState({
    required this.isLoading,
    this.errorMessage,
    required this.email,
    required this.weightUnit,
    required this.heightUnit,
    required this.trainingWeightUnit,
    required this.themeMode, // system/dark/light
    required this.foodReminderEnabled,
    required this.weightReminderEnabled,
    required this.trainingReminderEnabled,
    required this.appVersion,
  });

  final bool isLoading;
  final String? errorMessage;

  final String email;

  final WeightUnit weightUnit;
  final HeightUnit heightUnit;
  final WeightUnit trainingWeightUnit;

  final AppThemeMode themeMode;

  final bool foodReminderEnabled;
  final bool weightReminderEnabled;
  final bool trainingReminderEnabled;

  final String appVersion;

  bool get hasError => errorMessage != null;
}
