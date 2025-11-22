# Technical Debt & TODOs

This document tracks known technical debt, simplifications, and future improvements needed across the codebase.

## Completed ✅

### ~~🔴 Restore Proper TDEE Calculation~~ **COMPLETED 2025-11-22**
**File:** `lib/src/features/onboarding/infrastructure/simple_preview_estimator.dart`  

**✅ Implemented:** 
- Mifflin-St Jeor BMR formula with gender-specific constants
- 5-level activity system (sedentary, lightly/moderatelypoll/very/extremely active)
- TDEE multipliers: 1.2, 1.375, 1.55, 1.725, 1.9
- Evidence-based calorie bounds (1200F / 1800M minimum, TDEE × 1.5 maximum)
- Proper 7700 kcal/kg conversion
- Performance-focused macro split (2.0g/kg protein, 0.8g/kg fat, remainder carbs)

**Tests:** All 40 tests passing  
**Analyzer:** Zero issues  

---

## High Priority


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
