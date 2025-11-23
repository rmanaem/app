Main shell structure (based on our discussions)

Navigation pattern

One root shell with bottom navigation, implemented as an indexed stack (e.g. StatefulShellRoute / ShellRoute with BottomNavigationBar).

4 primary tabs + central + button (consistent with MacroFactor / Strong inspirations):

Today (Dashboard / fusion view)

Nutrition

Training

Settings

Center floating + button for quick actions:

Quick food log

Quick weigh‑in

Quick workout log / “Start workout”

(Later: add note, fast, etc.)

Recommended feature modules (matching your clean/atomic style)

Roughly:

lib/src/features/today/...

lib/src/features/nutrition/...

lib/src/features/training/...

lib/src/features/settings/...

Each feature following the same internal structure you already use:

domain/ – entities, value objects, repositories

application/ or use_cases/ – coordinators / controllers

presentation/

pages/

widgets/ (atoms/molecules)

viewmodels/ or controllers/

Tab 1 – Today (Dashboard)

This is the “feels premium” screen that fuses diet + training.

Header

Date (today) + subtle “Today” label.

Optional streak / last weigh‑in text.

Cards (scrollable vertical)

Diet card

Macro rings or progress bars:

Calories / Protein / Carbs / Fats.

Tabs for Consumed / Remaining (like MacroFactor).

Tap → opens the Nutrition tab focused on today.

Training card

“Next workout” summary: name, day, main lifts.

“Last session” summary: RPE/highlight, best set, or note.

Tap → opens Training on the appropriate program/workout.

Weigh‑in card

7‑day sparkline + last weight.

Short trend text (“Down 0.4 kg in 7 days”).

Quick actions row

Small pill buttons:

“Log food”

“Weigh in”

“Start workout”

(Maybe “Add note” later)

Everything respects the design system we set up (black/white core, navy variant later, performance minimalism).

Tab 2 – Nutrition

Goal: log fast, understand progress at a glance.

Top area

Today’s date + mini weekly strip (Mon‑Sun) to move between days.

Compact macro summary (like the dashboard card, but always visible).

Body

Time‑line food log like your MacroFactor screenshot:

7am / 8am / 9am with plus buttons.

Tapping a slot opens the log sheet:

Search

Scan

Quick add

Favourites / recipes

Bottom search bar + barcode icon.

The floating + opens the same quick‑action sheet, weighted to nutrition items.

Later (post‑MVP): weekly/period analytics screen reachable from here.

Tab 3 – Training

Goal: see program, start today’s work, and review history.

Top

Week strip (Mon‑Sun) or simple “This week” header + “Next / Previous week” arrows.

Quick summary: “3 / 4 workouts done”.

Cards

Upcoming workout

Name, day, key lifts, expected duration.

Big “Start workout” button.

Last workout

Date, volume, key PRs.

Short note summary (and, later, surface last session comments).

Program card

Current program name, split (e.g. ULxULx), end date.

“Manage program” → program builder (later in MVP or v2).

Within Training flows (later screens)

Template / program creator inspired by Strong:

Exercise library with filters (body part, equipment, type).

Exercise editor with sets, reps, weight, RPE, comment per exercise.

Ability to schedule that workout on certain days.

Tab 4 – Settings

Sections:

Account & Auth

Email, Apple, Google, sign‑out.

Units & Preferences

Weight: kg/lb

Height: cm/ft-in

Date format, time format.

Coaching / Strategy (for monetization)

“Nutrition coach” toggle/status.

“Training coach” toggle/status.

“Manage plan”: re‑run goal setting / frequency / fatigue flags (paid feature later).

App

Theme (system / light / dark).

Legal: Terms, Privacy, Health disclaimer.

The main shell is basically: one root scaffold + these four feature areas, each internally clean and testable.