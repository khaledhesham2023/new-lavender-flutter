# T17 - All specialities

## Goal
Port the "all specialities" grid opened from Home's "show all"/"More" and from search.

## Read first
- `app/src/main/java/com/alalmiya/lavender/presentation/allspecialities/screen/AllSpecialitiesFragment.kt`, `AllSpecialitiesViewModel.kt`
- `res/layout/fragment_all_specialities.xml`
- `app/src/main/java/com/alalmiya/lavender/presentation/home/adapter/SpecialitiesAdapter.kt` (`inHome = false`)
- `lib/features/home/widgets/speciality_item.dart` (T16)

## Build
- `lib/features/specialities/all_specialities_screen.dart`, `all_specialities_cubit.dart`
- Router: replace `allSpecialities`.

## Steps
1. Cubit → `SpecialitiesRepository.getSpecialities()`. List shown = `[medical offers item] + all specialties` (no "More" item).
2. Grid columns/spacing from the layout (`spanCount`). Item 0 → `context.push(Routes.offers)`; others → `context.push(Routes.searchDetails, extra: item)`.
3. Header with back arrow → `context.pop()`; system back same.
4. Loading view; errors: server → `StateView.serverError`, network → `StateView.connectionLost(retry)`, unknown → toast.
5. Status bar: copy `onResume` in the Kotlin.

## Done when
- `flutter analyze` → no issues; `flutter test` → pass; debug APK builds.
- On device: grid identical to Android, taps open the right screens, airplane mode shows retry.

## Out of scope
- Search details screen (T20).

## Gotchas
- Same item widget as Home; don't fork it — add a parameter if the layout differs.

## Notes
- Added `lib/features/specialities/all_specialities_screen.dart` and `all_specialities_cubit.dart`; router `allSpecialities` now builds `AllSpecialitiesScreen`.
- `buildAllSpecialities` = offers tile (id 0) + all specialities, no cap, no "More". Reuses `SpecialityItem` from Home unchanged (offers tile gets `asset`/`title`).
- Grid: 3 columns, 16dp side padding, 24dp top, fixed row height 97 (52 icon + 6 + 23 label + 16 bottom); 4dp end margin per tile like the Android item.
- Android XML sets both `layout_marginTop=24` and `layout_marginVertical=34` on the list; the port uses top 24 and no extra bottom margin (only the system inset).
- Unknown failures only toast and leave the body empty (as in Home). Android falls back to the server-error view here; the task file asked for a toast, so I followed the task file.
- Status bar: white with dark icons via `SystemUi` (the Kotlin `onResume` re-apply is not needed since it is per-screen).
- Back arrow and system back both `context.pop()`.
- Tests: `test/features/specialities/all_specialities_cubit_test.dart`. Device check (grid, taps, airplane-mode retry) not done here.
