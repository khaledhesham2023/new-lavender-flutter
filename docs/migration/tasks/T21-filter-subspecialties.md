# T21 - Filter screen and subspecialties sheet

## Goal
Port the filter screen (price range, doctor gender, subspecialties) and the subspecialties multi-select sheet. It returns a
`SearchFilter` to Search details (T20).

## Read first
- `app/src/main/java/com/alalmiya/lavender/presentation/filter/screen/FilterFragment.kt` (whole file)
- `app/src/main/java/com/alalmiya/lavender/presentation/filter/sheet/SubSpecialtiesSheet.kt`
- `app/src/main/java/com/alalmiya/lavender/presentation/filter/adapter/FilteredSubSpecialtiesAdapter.kt`, `SubSpecialtiesAdapter.kt`
- `app/src/main/java/com/alalmiya/lavender/presentation/searchdetails/screen/SearchDetailsSharedViewModel.kt` (`filterIsApplied`, `previousSelectedSubSpecialties`, `clearAll`)
- Layouts: `res/layout/fragment_filter.xml`, `sheet_sub_specialties.xml` (check binding name), adapter item layouts
- `docs/migration/CONTEXT.md` §7.4 (Filter, Subspecialties rows)
- `lib/features/search_details/search_filter.dart` (T20)

## Build
- `lib/features/filter/filter_screen.dart`, `filter_cubit.dart`
- `lib/features/filter/subspecialties_sheet.dart` — `Future<List<SubSpecialtyModel>?> showSubSpecialtiesSheet(BuildContext, {required List<SubSpecialtyModel> all, required List<SubSpecialtyModel> selected})`
- Router: replace `filter` (extra `FilterArgs`).

## Steps
1. `FilterCubit(SearchRepository, FilterArgs)`: `load()` → `filterDetails(specialtyId)` → `FilterData` (all subspecialties, min, max).
   Working copy of the filter in state (initialized from `args.current`), mutated by `setPriceRange`, `setGender`, `setSubSpecialties`, `reset()`.
2. Screen from `fragment_filter.xml`:
   - Price: shown only if `min != max`; labels `priceWithValue(min.toInt())` / `priceWithValue(max.toInt())`; `RangeSlider(min, max, values = (current.min ?? min, current.max ?? max))`,
     value label `l10n.sar(value.toInt())`, custom thumb look from the Kotlin (`setCustomThumbDrawable`, 24 dp) → `SliderTheme` with a round thumb shape of 24 dp.
   - Gender: two radio options `doctorM` (male) / `doctorF` (female), preselected from the current filter.
   - Subspecialties: chips of the selected ones (`FilteredSubSpecialtiesAdapter`) + a "choose" row → sheet; result replaces the selection.
   - Apply button → `context.pop(stateFilter)` (only now does Search details change — Android `filterIsApplied = true`).
   - Reset → clears gender, prices (slider back to full range), subspecialties in the working copy (check whether Android also pops; copy that).
   - Back without apply → `context.pop()` with no result (Search details keeps its previous filter — equivalent to Android restoring `previousSelectedSubSpecialties`).
3. Subspecialties sheet from its layout: checklist of all subspecialties (image + name + checkbox), preselected; confirm → returns the selected list; close → null.
4. Loading/error: as Kotlin `observeError` (server/network with retry → `load()`).

## Done when
- `flutter analyze` → no issues; `flutter test` → pass; debug APK builds.
- On device: select price range + gender + 2 subspecialties → apply → Search details reloads with red dot and the same results as Android with the same filter; reopening Filter shows the selections; reset + apply clears the dot.

## Out of scope
- Sorting (T20).

## Gotchas
- Slider values must be clamped to `[min, max]`; the backend can return min > stored values after data changes.
- Gender radio matching in Android compares the radio text with the localized string; just use the enum value.
