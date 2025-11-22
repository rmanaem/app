# Technical Debt & TODOs

This document tracks known technical debt, simplifications, and future improvements needed across the codebase.

## High Priority

### 🔴 Restore Proper TDEE Calculation in SimplePreviewEstimator
**File:** `lib/src/features/onboarding/infrastructure/simple_preview_estimator.dart`  
**Issue:** Calorie calculation was simplified to static dummy data during test implementation.

**Current (Simplified):**
```dart
var dailyKcal = 2000.0;
if (goal == Goal.gain) dailyKcal += 500;
if (goal == Goal.lose) dailyKcal -= 500;
dailyKcal += weeklyRateKg * 1000;  // Wrong conversion factor
```

**Original (Correct) Logic:**
```dart
final activityFactor = switch (activityLevel) {
  ActivityLevel.low => 1.4,
  ActivityLevel.moderate => 1.6,
  ActivityLevel.high => 1.8,
};
final tdee = 22.0 * currentWeightKg * activityFactor;
final dailyDelta = (weeklyRateKg * 7700.0) / 7.0;
final dailyBudget = (tdee + dailyDelta).clamp(900.0, 5000.0);
```

**What's Missing:**
- ❌ Current weight factor (using static 2000 instead of calculated TDEE)
- ❌ Activity level multiplier (1.4x, 1.6x, 1.8x)
- ❌ Proper calorie/kg conversion (should be 7700/7, not 1000)
- ❌ Safe clamping (900-5000 kcal range)
- ❌ Height, age, gender factors (for future BMR-based calculation)

**Action Required:**
1. Restore original TDEE calculation
2. Update tests to validate dynamic behavior
3. Consider upgrading to Mifflin-St Jeor or Harris-Benedict equation

**Created:** 2025-11-22  
**Severity:** High - Affects core calorie budgeting functionality

---

## Medium Priority

### 🟡 Add Widget Keys for Robust Test Selectors
**Files:** All widget files in `lib/src/features/onboarding/presentation/pages/`  
**Issue:** Tests currently use text-based selectors which are brittle.

**Action Required:**
- Add semantic `Key` to all interactive widgets (buttons, inputs)
- Update tests to use `find.byKey()` instead of `find.text()`
- Improves test maintainability and i18n readiness

**Created:** 2025-11-22  
**Severity:** Medium - Improves test quality

---

### 🟡 Add Accessibility/Semantics Testing
**Files:** All widget test files  
**Issue:** No semantic labels or accessibility testing implemented.

**Action Required:**
- Add semantic labels to all interactive widgets
- Add `matchesSemantics()` assertions in widget tests
- Test screen reader compatibility
- Validate touch target sizes (minimum 44x44 points)

**Created:** 2025-11-22  
**Severity:** Medium - Required for accessibility compliance

---

### 🟡 Add Error Path Integration Tests
**File:** `integration_test/onboarding_flow_test.dart`  
**Issue:** Only happy path tested; no error scenarios.

**Action Required:**
- Test network failure scenarios
- Test validation error flows
- Test repository save failures
- Test navigation edge cases

**Created:** 2025-11-22  
**Severity:** Medium - Improves reliability

---

## Low Priority

### 🟢 Consider Golden Tests for Visual Regression
**Files:** New directory `test/goldens/`  
**Issue:** No visual regression testing.

**Action Required:**
- Set up golden test infrastructure (fonts, locale, theme)
- Snapshot onboarding screens (light/dark)
- Snapshot Today tab (light/dark)
- Establish review process for golden file changes

**Created:** 2025-11-22  
**Severity:** Low - Deferred until UI is stable

---

### 🟢 Add Gender Parameter Properly
**File:** `lib/src/features/onboarding/infrastructure/simple_preview_estimator.dart:122`  
**Issue:** Currently hardcoded `isMale: true`

**Action Required:**
- Add gender to onboarding stats collection
- Pass actual value to estimator
- Use for BMR calculation differences

**Created:** 2025-11-22  
**Severity:** Low - Nice to have for accuracy

---

## Documentation

### 📝 Document Test Doubles Strategy
**File:** `docs/testing_plan.md`  
**Enhancement:** Add section on when to use mocks vs. fakes vs. stubs.

**Created:** 2025-11-22

---

## Template for New TODOs

When adding a new TODO:

```markdown
### 🔴/🟡/🟢 Brief Description
**File:** Path to affected file(s)  
**Issue:** What's wrong or missing

**Action Required:**
- Specific steps to resolve

**Created:** YYYY-MM-DD  
**Severity:** High/Medium/Low - Impact description
```

**Severity Levels:**
- 🔴 **High** - Breaks functionality, security issue, or critical bug
- 🟡 **Medium** - Quality improvement, tech debt, or enhancement  
- 🟢 **Low** - Nice to have, future consideration, or optimization
