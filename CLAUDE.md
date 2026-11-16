# Lavender — Android → Flutter migration

Lavender is a patient medical-booking app (doctors, appointments, prepaid offers with Tap payments, reports, FCM push; Arabic default + English).

- `D:\flutter\New folder\lavenderk\` (this repo) — original native Android app in `app/` (Kotlin). **Source of truth for behavior. Never modify it.**
  Android paths in the docs (`app/...`) are relative to this folder.
- `D:\flutter\New folder\lavender-flutter\` (sibling folder, `../lavender-flutter`) — the Flutter port (Android only, package `com.alalmiya.lavender`).
  Flutter paths in the docs (`lib/...`, `android/...`, `test/...`) are relative to that folder.
- `docs/migration/` — `CONTEXT.md` (what the Android app does), `PLAN.md` (decisions, structure, conventions, task checklist), `tasks/Txx-*.md` (one file per task).

Start sessions in this repo (so this file and the docs load) with `../lavender-flutter` added as a working directory.

## Commands (run in `D:\flutter\New folder\lavender-flutter`)
- Run: `flutter run --dart-define-from-file=env/debug.json`
- Checks: `flutter analyze` · `flutter test` · `flutter build apk --debug --dart-define-from-file=env/debug.json`
- Regenerate JSON models: `dart run build_runner build --delete-conflicting-outputs`
- Regenerate strings: `dart run tool/strings2arb.dart && flutter gen-l10n` · icons: `dart run tool/vd2svg.dart`
- `env/*.json` (except `example.json`) and `android/key.properties` hold secrets: never commit them, never use `env/release.json` for test payments.

## Working rules
- Work on **one task only**. Read its task file and everything listed under "Read first" before writing code.
- The Android code is the source of truth for behavior; don't change it.
- Follow `PLAN.md` §4 conventions. Don't change the plan on your own: if the task file is wrong or something blocks you, stop and tell the user.
- Don't commit; the user reviews and commits.
- When done: run the checks in "Done when", tick the task in `PLAN.md` §5, and add a short `## Notes` section at the end of the task file (what was done, anything later tasks should know).
