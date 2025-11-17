# Contributing

- Use FVM `fvm flutter ...`
- `flutter format`, `flutter analyze`, and `flutter test` must pass locally.
- Commit style: Conventional Commits (feat:, fix:, chore:, refactor:, test:, docs:) enforced via Commitlint (`npx commitlint --edit "$1"` runs from the `commit-msg` hook). Ensure Node/npm are installed locally.

## Useful scripts
- `fvm flutter pub get`
- `fvm flutter test --coverage`
