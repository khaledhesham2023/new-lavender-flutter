# T19 - Search (last search and results)

## Goal
Port the Search tab: most-selected specialties, recent searches (logged in), live search with two result tabs
(specialities / doctors).

## Read first
- `app/src/main/java/com/alalmiya/lavender/presentation/lastsearch/screen/LastSearchFragment.kt` (whole file), `LastSearchViewModel.kt`,
  `SearchResultFragment.kt`, `SearchResultSharedViewModel.kt`
- `app/src/main/java/com/alalmiya/lavender/presentation/lastsearch/adapter/*.kt`
- Layouts: `res/layout/fragment_last_search.xml` and its includes (`lMostPopular`, `lRecentSearch`, `lSearchResult`), `fragment_search_result.xml`, item layouts of the adapters
- `docs/migration/CONTEXT.md` §7.4 (Search row)

## Build
- `lib/features/search/search_screen.dart`, `search_cubit.dart`
- `lib/features/search/widgets/most_selected_list.dart`, `recent_searches_list.dart`, `search_results_view.dart` (tabs + two lists)
- Router: replace `search` (shell tab).
- `test/features/search/search_cubit_test.dart`

## Steps
1. `SearchCubit(SearchRepository, bool isLoggedIn)` with a `mode` in state: `mostSelected`, `recent`, `results`, plus data lists and status/failure.
   - `showMostSelected()` → `mostSelected()`.
   - `showRecent()` (only if logged in) → `recent()`; empty list → empty state (check Kotlin `observeGetRecentSearches` for which view/strings).
   - `search(String text)` → `search(text)` → results mode.
   - `clearRecent()` → `clearRecent()` then show the cleared state as Android does (`observeClearSearch`).
2. Screen behavior (port `setupListeners` exactly):
   - On open: field empty → `showMostSelected()`.
   - Focus gained, logged in, field empty → `showRecent()`.
   - Text changed: cancel previous job; if not blank → after **500 ms** `search(text)`; if blank → guest: `showMostSelected()`; logged in: focused → `showRecent()`, else `showMostSelected()`.
   - Keyboard closed (Android global layout listener) → unfocus the field (use `MediaQuery.viewInsetsOf(context).bottom == 0` change detection or `KeyboardVisibility` via `WidgetsBindingObserver.didChangeMetrics`).
   - "Cancel" text → behaves like back.
   - Recent item tap → put its text in the field (triggers the search via the change listener).
   - Most-selected item: if `name == l10n.medicalOffers` → `context.push(Routes.offers)` else `context.push(Routes.searchDetails, extra: item)`.
3. Results view: two tabs "specialities" / "doctors" (`TabBar` styled like the layout, `TabBarView` — Android ViewPager2 here allows swipe unless disabled; check `isUserInputEnabled`).
   Specialities list → search details; doctors list → `context.push(Routes.doctorDetails(id))`. Empty per tab (check `SearchResultFragment` for icons/strings, e.g. `noSearchResultsTitle`, `trySearchForDoctorOrSpeciality`).
4. Errors: `observeAllErrors` in Kotlin — server/network views with retry → `showMostSelected()`.
5. Back (system) → the shell handles (go Home); also unfocus first.
6. Tests: debounce (only last text searched; use `fakeAsync`), guest never calls `recent()`, blank text returns to the right mode.

## Done when
- `flutter analyze` → no issues; `flutter test` → pass; debug APK builds.
- On device (logged in and guest): same initial list, recent searches on focus, delete all clears them, typing shows two tabs with results, taps open the right screens.

## Out of scope
- Search details (T20), doctor details (T22).

## Gotchas
- The "Medical offers" check compares the **display name** with the localized string (Android does that) — the most-selected API returns a real specialty list; keep the comparison.
- Do not fire a search on the initial empty text.
