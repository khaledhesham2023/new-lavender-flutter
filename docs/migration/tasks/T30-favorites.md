# T30 - Favorites

## Goal
Port the Favorites tab: guest prompt, list of favorite doctors with search, un-favorite removes the row, pull to refresh.

## Read first
- `app/src/main/java/com/alalmiya/lavender/presentation/favorites/screen/FavoritesFragment.kt` (whole file), `FavoritesViewModel.kt`
- `app/src/main/java/com/alalmiya/lavender/presentation/favorites/adapter/FavoriteDoctorsAdapter.kt`
- `res/layout/fragment_favorites.xml` and the adapter item layout
- `docs/migration/CONTEXT.md` §7.4 (Favorites row)
- `lib/features/home/widgets/doctor_card.dart`

## Build
- `lib/features/favorites/favorites_screen.dart`, `favorites_cubit.dart`
- `lib/features/favorites/widgets/favorite_doctor_card.dart` (only if the item layout differs from the home doctor card)
- Router: replace `favorites` (shell tab).
- `test/features/favorites/favorites_cubit_test.dart`

## Steps
1. Cubit: `load({String? name})` → `getFavorites(name)`; `unfavorite(int index)` → `toggleFavorite(id)`; on success remove the row (Android removes only after success — check `observeToggleFavorite`); failure → toast.
2. Guest: `StateView.empty` must-login (check the Kotlin for exact title/body/icon) with Login → `context.push(Routes.authStart)`; refresh disabled.
3. Logged in: search field (debounce 1000 ms; blank → name null), list, `RefreshIndicator`.
   Empty with no keyword → favorites empty state (`noFavoriteDoctorsTitle` + body/icon from Kotlin); empty with keyword → "no results" state (check Kotlin strings).
4. Tap → `await context.push(Routes.doctorDetails(id))` then `load(name)` (favorite may have changed).
5. Errors per `observeAllErrors` (server/network with retry, unknown toast). Back → shell.
6. Tests: un-favorite removes the item; empty-with-keyword vs empty states.

## Done when
- `flutter analyze` → no issues; `flutter test` → pass; debug APK builds.
- On device: same favorites as Android; removing a heart removes the row; search filters; guest sees the prompt.

## Out of scope
- Doctor details (done).

## Gotchas
- `client/fav` toggles — calling it on a favorite removes it.

## Notes
- Built with T29 on branch `T29-T30-session-details-favorites`.
- `FavoritesScreen` + `FavoritesCubit` in `features/favorites/`; reuses `DoctorCard` (full width) since the Android item is the search doctor card. Guest uses `youMustLoginBody` (not the bookings variant).
- Like Android, the heart flips at once and the row is removed only after the toggle succeeds; failure flips it back and toasts.
- Search debounce 1000 ms; blank keyword -> null (empty-with-keyword shows the "no results" state). Doctor details pop reloads the list.
- Not verified on a device (analyze, 347 tests and the debug APK build pass).
