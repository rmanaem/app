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


**Implementation**

> Follow the repository’s architecture and design principles from architecture.md, apply Flutter, mobile development, and general software design best practices, and ensure all code fully complies with very_good_analysis linting rules
