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
