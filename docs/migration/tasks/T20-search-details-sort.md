# T20 - Search details and sort sheet

## Goal
Port the doctors-by-specialty list with name search, sort sheet, filter entry point (screen in T21) and favorite toggles.

## Read first
- `app/src/main/java/com/alalmiya/lavender/presentation/searchdetails/screen/SearchDetailsFragment.kt`, `SearchDetailsViewModel.kt`, `SearchDetailsSharedViewModel.kt`
- `app/src/main/java/com/alalmiya/lavender/presentation/searchdetails/adapter/DoctorsSearchAdapter.kt`, `SortByAdapter.kt`
- `app/src/main/java/com/alalmiya/lavender/presentation/filter/sheet/SortBySheet.kt`
- Layouts: `res/layout/fragment_search_details.xml`, `sheet_sort_by.xml`, item layouts of both adapters
- `app/src/main/java/com/alalmiya/lavender/utils/enums/SortByStatus.kt`
- `docs/migration/CONTEXT.md` §7.4 (Search details, Sort sheet rows)
- `lib/features/home/widgets/doctor_card.dart`

## Build
- `lib/features/search_details/search_filter.dart` — `class SearchFilter extends Equatable { List<SubSpecialtyModel> subSpecialties; String? gender; double? minPrice; double? maxPrice; String? sortBy; bool get hasFilter => gender != null || minPrice != null || maxPrice != null || subSpecialties.isNotEmpty; }` + `copyWith`/`cleared()`.
- `lib/features/search_details/search_details_screen.dart`, `search_details_cubit.dart`, `widgets/doctor_search_card.dart` (if `DoctorsSearchAdapter` layout differs from the home card)
- `lib/features/search_details/sort_sheet.dart` — `Future<String?> showSortSheet(BuildContext, {String? current})` returning the value or `null` (cleared)
- Router: replace `searchDetails` (extra `SpecialityModel`); add `FilterArgs` class in `routes.dart` now: `FilterArgs(int specialtyId, SearchFilter current)`.
- `test/features/search_details/search_details_cubit_test.dart`

## Steps
1. `SearchDetailsCubit(SpecialitiesRepository, HomeRepository, SpecialityModel)`: state has `doctors`, `count`, `filter: SearchFilter`, `name` (search text), status, failure.
   `load()` → `getDoctors(id, sortBy, subSpecialtyIds, gender, maxPrice, minPrice, name)`. `setName` (debounced 1000 ms in the screen), `setSort`, `applyFilter(SearchFilter)` → each reloads.
   `toggleFavorite(index)`: optimistic flip + revert on failure.
2. Screen from `fragment_search_details.xml`: title (speciality name and/or `allDoctors(count)` — check), search field (`DebouncedSearchField`, 1000 ms),
   Sort button with red dot when `sortBy != null`, Filter button with red dot when `filter.hasFilter` (port `checkRedBadgeVisibility`),
   list of doctors (hearts only when logged in), empty state when no doctors (check Kotlin for icon/strings).
   Sort button hidden while loading/error (Kotlin hides `tvSort` on errors, shows on success).
3. Sort sheet: list of the 4 `SortByStatus` options with their strings, single selection with the current value preselected, confirm → returns value;
   clear (if present in the layout) → returns null. Apply via `setSort`.
4. Filter button → `final result = await context.push<SearchFilter>(Routes.filter, extra: FilterArgs(id, state.filter));` if `result != null` → `applyFilter(result)`.
5. Doctor tap → `await context.push(Routes.doctorDetails(id))`, then `load()` again (Android reloads in `onResume`, so favorites changed in details show).
6. Back → `context.pop()` (filters are discarded with the screen, like Android's `clearAll`).
7. Tests: filter → repository args (incl. subspecialty ids), favorite revert, red-dot logic (`hasFilter`).

## Done when
- `flutter analyze` → no issues; `flutter test` → pass; debug APK builds.
- On device: list matches Android for a specialty; typing a name filters after ~1 s; each sort option reorders as Android; red dot appears after sort.

## Out of scope
- Filter screen and subspecialties sheet (T21) — until then the Filter route is a placeholder that returns nothing.

## Gotchas
- Android sends `minPrice/maxPrice` as Float; keep doubles.
- The Android shared ViewModel lives across the screen and the filter; here the filter is passed in and returned — don't add a global filter state.
