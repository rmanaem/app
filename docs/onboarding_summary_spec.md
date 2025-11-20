# Onboarding Summary Redesign Spec

Goal: reshape the summary (step 4) so it mirrors the flow of the provided reference while still using our design system tokens.

## 1. Hero Summary Card
- **Layout:** full-width card using `AppColors.surface2` with rounded corners.
- **Sections:**
  - Title `Summary of your plan`.
  - Custom graph organism (line chart) showing start weight → target weight. Two labeled markers (start + target) and a “maintain” segment. Colors pulled from our accent palette (no external neon theme).
  - 3–4 bullet rows (icon + text) summarizing the plan: e.g., “Lose weight then maintain”, “Reach 75 kg by Jan 14, 2026”, “Projected end date …”, “Tailored to your activity level”. Strings come from the ViewModel.
- **Data:** start weight from stats, target weight and projected date supplied by `GoalConfigurationVm`.

## 2. Nutrition Recommendations Card
- **Title:** “Your nutritional recommendations” with supporting caption (“Adjust your nutritional goals anytime”).
- **Content:** row of metrics.
  - Calorie tile (big number + `kcal` label).
  - Three macro chips (Carbs/Protein/Fat) with percentage and small ring indicator (simple `CircularProgressIndicator` or custom painter). Percentages are surfaced by the ViewModel (can start with 50/20/30 split).
- **Styling:** keep typography and colors within our design system (e.g., `AppColors.heroPositive`, `ink`, `inkSubtle`).

## 3. CTA
- Move the CTA below the nutrition card.
- Copy: `Get started`.
- Use existing `FilledButton` styling; no screenshot colors.

## 4. ViewModel Updates
- Expose:
  - Start weight (from stats).
  - Bullet point strings (goal phrasing, projected date, habit note).
  - Macro percentages (initially constants, future logic ready).
  - Graph data (start/target weights, projected date).

## 5. Layout Flow
- Keep `OnboardingProgressBar` at top.
- Stack cards inside a padded `ListView`.
- Maintain scaffold background and typography from `AppTheme`.
