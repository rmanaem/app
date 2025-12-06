Project Context & Design State: "Obsidian & Steel"

1. Core Identity & Visual DNA

Codename: Obsidian & Steel / Matte MonolithPhilosophy: "Precision Instrument." The app should feel like high-end audio equipment or a stealth fighter cockpit. It rejects "gamification" and "standard form inputs."

The Physics (Material System)

The Void (Canvas): Deep Onyx (#050505). Not pure black, but deep enough to absorb light.

The Material (Surface): Matte Ceramic (#1C1C1E). Solid, opaque, dense.

Crucial Pivot: We have abandoned Glassmorphism. Do not use BackdropFilter or blur. We use solid surfaces to ensure 120fps performance and a "heavy" physical feel.

The Edges: Milled Steel.

Idle: Dark Steel (#3A3A3C) borders define hierarchy.

Active: Polished Silver (#E5E5EA) borders indicate focus/touch.

Typography: Big, bold, condensed sans-serif (e.g., SF Pro Rounded). High contrast (White on Black).

Micro-Labels: Small, all-caps, wide-tracking grey text for section headers (e.g., "TARGET WEIGHT").

2. Architecture & Tech Stack

Framework: Flutter.

Architecture: Clean Architecture + MVVM.

UI Pattern: Atomic Design (Atoms -> Molecules -> Organisms -> Pages).

Navigation: go_router.

State: Provider / ChangeNotifier (Viewmodels).

3. Current Progress & Implemented Screens

We are currently building the Onboarding Flow.

A. Welcome Screen (WelcomePage)

Metaphor: "The Launchpad."

Components:

Physical Emblem: The logo is framed inside a ceramic tile with a steel border (not floating).

Action Stack:

Primary: "GET STARTED" (Silver/Ignited button).

Secondary: "LOG IN" (Outlined/Cold Steel button).

B. Step 1: Goal Selection (OnboardingGoalPage)

Metaphor: "The Command Deck."

Layout: Vertical stack of massive tappable cards (GoalTile).

Interaction:

No radio circles. The card itself changes state.

Selected: Silver border, White text, Glowing icon.

Unselected: Dark border, Grey text, Dimmed icon.

Navigation: The "NEXT" button is "Powered Down" (dark/disabled) until a selection is made.

C. Step 2: Stats / About You (OnboardingStatsPage)

Metaphor: "The Biometric Dashboard" (Bento Grid).

Layout:

Top: Birthday (Wide Tile).

Middle: Height & Weight (Square Tiles, side-by-side). The Number is the hero.

Bottom: Activity Level (Wide Tile).

Input Method: Tapping a tile opens an Immersive Sheet (100% height, Deep Onyx background).

Height/Weight: Tactile Ruler floating in the void (no container box).

Activity: Mode Dial (Horizontal swiping carousel with haptic snap).

Birthday: Ceramic Time Machine (Cupertino picker styled dark).

D. Step 3: Calibration / Goal Preview (GoalConfigurationPage)

Metaphor: "The Mixing Console" / "Flight Deck."

Layout: Restructured into 3 vertical zones.

Zone A (The Monitors): DualMonitorPanel. Two bento-style readouts for "Daily Budget" and "Est. Arrival."

Zone B (The Target): TactileRulerPicker (Unboxed). Floats directly on the background.

Zone C (The Fader): FaderSlider. Looks like a rectangular slide potentiometer on a mixing desk (not a round volume knob).

Safety: SafetyWarningBanner redesigned as a "System Alert" (Dark ceramic, red accent line, no yellow).

4. Custom Atoms & Widgets (The Library)

These custom components have been created to replace standard Flutter widgets:


AppButton: Handles "Ignited" (Silver), "Cold" (Outline), and "Powered Down" (Disabled/Dark) states.

BentoStatTile: Square/Wide tiles for the dashboard. Handles "Silver Border on Press" logic.

GoalTile: Large selectable cards for the Command Deck.

TactileRulerPicker: Physics-based scrollable ruler for height/weight.

ActivityModeDial: Horizontal snapping carousel for activity levels.

FaderSlider: Custom SliderTheme with a rectangular "Fader" thumb and milled track.

DualMonitorPanel: Combined readout for the Calibration page.

SafetyWarningBanner: Dark system-alert style warning.

5. Next Steps (To Do)

Step 4 (Summary): We need to design the final "Manifest" screen where the user confirms their plan before entering the app.

Main Shell: Designing the bottom navigation and the "Today" dashboard using this new "Bento/Console" aesthetic.

Performance Check: Ensure all BackdropFilter widgets have been removed (verified in code, but keep an eye out).



