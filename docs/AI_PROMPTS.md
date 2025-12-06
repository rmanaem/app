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

> Inspect the staged file(s) and generate the appropriate conventional commit message
> Inspect the changed file(s) and generate the appropriate conventional commit message


**Implementation**

> Follows (and does not bypass) the repository’s architecture and design principles including atomic design and mvvm pattern and other principles from architecture.md, apply Flutter, mobile development, and general software design best practices, and ensure all code fully complies with very_good_analysis linting rules (do not by pass or ignore the rules) see VERY_GOOD_ANALYSIS.md for reference. Do not hard code colors and design tokens, instead use design tokens in the design system. Keep implementation clean, simple, and maintainable and avoid coupling, complicating and over-engineering.

> I have the following files that contain features and design changes from what we have in the repo. Thoroughly analyze these files compare them to what we currently have in the repo and give me a report on what the differences are and I'll instruct you about the changes that need to be made

> Do not run flutter commands (like format or run) as you can't access flutter from the sandbox.


**Design**
> You are senior designer expert in designing and optimizing mobile apps for UX to captivate users. What would you use here to elevate the design?


**Testing**
> make sure tests are high‑signal across unit, widget/UI, integration, and e2e levels verify observable behavior and public contracts (not implementation details); keep them fast, deterministic, and independent using Arrange–Act–Assert, clear naming, and mocks/fakes for I/O, time, and external services. For widgets/UI, use keys/semantics and pump/pumpAndSettle to check state, interactions, and accessibility; for integration/e2e, cover critical user journeys with realistic stubs; for golden tests, snapshot only stable surfaces with fixed fonts/locale/theme and review changes intentionally. Follow Flutter + mobile best practices (simple, clean, readable, maintainable), avoid trivial or redundant assertions, structure under `test/` and `integration_test/`, and ensure coverage meaningfully tests functionality.

## Gemini prompts

### Starting prompts
> You are a senior designer expert in designing and optimizing mobile apps for UX to captivate users. thoroughly Familiarize yourself with the app by thoroughly reading and comprehending the attached documents: DNA.md, context.md, architecture.md, and VERY_GOOD_ANALYSIS.md.

> We are currently in the process of designing a program builder page: The screen where users  create the program/plan (e.g., choose split "Push/Pull/Legs", days, workouts, then we would need a workout creator screen that would allow them to create workouts within a training plan or program) that populates the Training tab. Currently, the "Edit" button on the Training tab leads nowhere.. Thoroughly examine the uploaded trainingv2.md and the uploaded screenshots of the training tab and the rest of the app screens to familiarize yourself with the current design.
Assess the current implementation and provide your verdict as the design, UI and Ux expert.

> We want to redesign this screen to elevate design and ux and transform it into a premium screen with minimalist look and vibe that would captivate and capture the users.
I want you as the design and ui, ux expert to create a comprehensive plan to design the page to have a premium look, feel and vibe.
before u move onto implementation or generate any code always make sure to ask for the files you need to modify using repo structure doc as reference/context. When generating files make sure your implementation Follows (and does not bypass) the repository’s architecture and design principles including atomic design and mvvm pattern and other principles from architecture.md, apply Flutter, mobile development, and general software design best practices, and ensure all code fully complies with very_good_analysis linting rules (do not by pass or ignore the rules) see VERY_GOOD_ANALYSIS.md for reference. Do not hard code colors and design tokens, instead use design tokens in the design system. Keep implementation clean, simple, and maintainable and avoid coupling, complicating and over-engineering.Now which files do you need for redesigning the settings screen.

> Before we move onto implementation here are some screenshots of the other currently implemented and approved screens. Make sure your comprehensive redesign plan aligns with existing design.

> When generating code do not generate code in canvas and refrain from adding metaphors in the code in any way. 

> Assume all design system tokens are currently used in app so if you want you can make changes and updates or extend the tokens but do not delete any tokens.



> Give me your verdict as the design and ux, UI expert on the above notes

> refrain from adding metaphors in the code in any way. 

> Changes implemented. Design notes: