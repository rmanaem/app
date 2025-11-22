# AI assistant prompts (pair programming)

**Style gates**: Follow `very_good_analysis` lints; no unused code; prefer pure functions.
**Architecture**: Place UI in atomic layers (atoms/molecules/organisms/templates/pages). Keep widgets small and testable.
**When asking for code**: Provide file path, purpose, and interfaces. Ask for tests. Request idempotent patches.

Template:
> You are coding in Flutter/Dart. Follow the repository's `analysis_options.yaml`. 
> File: lib/src/presentation/atoms/app_button.dart
> Task: Extend button to support loading state, disabled state, and semantic labels. Add widget tests.
> Constraints: No third-party UI packages. Keep public API simple.

**Conventional commit message**

> Check the staged file(s) and generate the appropriate conventional commit message
> Check the changed file(s) and generate the appropriate conventional commit message


**Implementation**

> Follow (and does not bypass) the repository’s architecture and design principles including atomic design and mvvm pattern and other principles from architecture.md, apply Flutter, mobile development, and general software design best practices, and ensure all code fully complies with very_good_analysis linting rules (do not by pass or ignore the rules). Do not hard code colors and design tokens, instead use design tokens in the design system. Keep implementation clean, simple, and maintainable and avoid coupling, complicating and over-engineering.

> I have the following files that contain features and design changes from what we have in the repo. Thoroughly analyze these files compare them to what we currently have in the repo and give me a report on what the differences are and I'll instruct you about the changes that need to be made

> Do not run flutter commands (like format or run) as you can't access flutter from the sandbox.


**Design**
> You are senior designer expert in designing and optimizing mobile apps for UX to captivate users. What would you use here to elevate the design?


**Testing**
> make sure tests are high‑signal across unit, widget/UI, integration, and e2e levels verify observable behavior and public contracts (not implementation details); keep them fast, deterministic, and independent using Arrange–Act–Assert, clear naming, and mocks/fakes for I/O, time, and external services. For widgets/UI, use keys/semantics and pump/pumpAndSettle to check state, interactions, and accessibility; for integration/e2e, cover critical user journeys with realistic stubs; for golden tests, snapshot only stable surfaces with fixed fonts/locale/theme and review changes intentionally. Follow Flutter + mobile best practices (simple, clean, readable, maintainable), avoid trivial or redundant assertions, structure under `test/` and `integration_test/`, and ensure coverage meaningfully tests functionality.

