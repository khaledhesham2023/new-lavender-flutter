# T03 - Assets, fonts and theme

## Goal
Bring every visual resource into Flutter: fonts, PNG/JPG/GIF images, Lottie files, and the 143 Android vector drawables
converted to SVG by a repeatable script. Define `AppColors`, `AppTextStyles`, `AppTheme` and the generated `AppAssets`
constants. Screens need these before they can be built 1:1.

## Read first
- `app/src/main/res/values/colors.xml`, `app/src/main/res/values/themes.xml`, `app/src/main/res/values/styles.xml`
- `app/src/main/res/font/` (14 ttf), `app/src/main/res/raw/` (Lottie json), `app/src/main/res/drawable/` and `drawable-ar/`
- 3 sample vectors to understand the format, e.g. `app/src/main/res/drawable/ic_gift.xml`, `ic_more.xml`, one with `<gradient>`
  (find with: `Select-String -Path app/src/main/res/drawable/*.xml -Pattern '<gradient' -List`)
- `docs/migration/CONTEXT.md` §9, §12
- `docs/migration/PLAN.md` §3, §4.6

## Build
- `lavender-flutter/tool/vd2svg.dart` — converts `<vector>` drawables to SVG and generates `lib/core/theme/app_assets.dart`.
- `lavender-flutter/assets/svg/*.svg` (generated), `assets/images/*.png|jpg`, `assets/images/ar/*.png`, `assets/gifs/*.gif`,
  `assets/lottie/*.json`, `assets/fonts/*.ttf` (copied).
- `lavender-flutter/lib/core/theme/app_colors.dart`, `app_text_styles.dart`, `app_theme.dart`, `app_assets.dart` (generated).
- `pubspec.yaml` — assets + font families.
- `lavender-flutter/test/tool/vd2svg_test.dart`.

## Steps
1. `flutter pub add flutter_svg lottie`.
2. Copy files (keep names, they become the asset names):
   - `res/font/*.ttf` → `assets/fonts/`
   - `res/drawable/*.png`, `*.jpg` → `assets/images/`; `res/drawable-ar/*.png` → `assets/images/ar/`
   - `res/drawable/*.gif` → `assets/gifs/`
   - `res/raw/*.json` except `map_style.json` → `assets/lottie/`
3. Write `tool/vd2svg.dart` (run `dart run tool/vd2svg.dart`):
   - Read `../lavenderk/app/src/main/res/values/colors.xml` into a map name → `#AARRGGBB`/`#RRGGBB`.
   - For each `../lavenderk/app/src/main/res/drawable/*.xml` whose root is `<vector>`: write `assets/svg/<name>.svg` with
     `width/height` = `android:width/height` without `dp`, `viewBox="0 0 viewportWidth viewportHeight"`.
   - `<path>` → `<path d="pathData">` with: `fillColor` → `fill` (+ `fill-opacity` from alpha byte), `fillAlpha` → multiply into `fill-opacity`,
     no fillColor → `fill="none"`; `strokeColor` → `stroke` (+ opacity), `strokeWidth` → `stroke-width`, `strokeAlpha` → `stroke-opacity`,
     `strokeLineCap` → `stroke-linecap`, `strokeLineJoin` → `stroke-linejoin`, `fillType="evenOdd"` → `fill-rule="evenodd"`.
   - Colors: `#AARRGGBB` → `#RRGGBB` + opacity `AA/255`; `#RGB`/`#ARGB` short forms expanded; `@color/x` → lookup; `@android:color/white|black|transparent` known values.
     `@color/colorGray` (not defined in this project) → `#888888` (owner decision). Any other unknown reference → `#888888` too, print a warning list and record it in Notes.
   - `<group>` with `translateX/Y`, `scaleX/Y`, `rotation`, `pivotX/Y` → `<g transform="...">`.
   - `<clip-path android:pathData>` inside a group → `<clipPath>` in `<defs>` + `clip-path` on the group.
   - `<aapt:attr name="android:fillColor"><gradient ...>` → `<linearGradient>` (`type="linear"`, startX/Y endX/Y, `gradientUnits="userSpaceOnUse"`)
     or `<radialGradient>` (`centerX/Y`, `gradientRadius`) in `<defs>` with `<stop offset color>` (from `<item android:offset android:color>`); fill = `url(#gN)`.
   - `android:autoMirrored="true"` → put the asset name in a generated `const Set<String> autoMirroredSvgs` in `app_assets.dart`
     (the `AppSvg` widget in T04 mirrors these in RTL).
   - Non-vector drawables (shape, selector, layer-list, transition): do not convert; print their names to `tool/non_vector_drawables.txt`
     (screens rebuild them as `BoxDecoration` in code).
   - Generate `lib/core/theme/app_assets.dart`: `abstract final class AppAssets { static const icGift = 'assets/svg/ic_gift.svg'; ... }`
     for every svg; also constants for every png/jpg (`assets/images/...`, Arabic variants with suffix `Ar`), gif and lottie file.
     Name = lowerCamelCase of the file name.
4. Run the script. Open 5 random SVGs in Chrome and compare with Android Studio's preview of the same XML.
5. `pubspec.yaml`:
   ```yaml
   flutter:
     generate: true
     uses-material-design: true
     assets:
       - assets/svg/
       - assets/images/
       - assets/images/ar/
       - assets/gifs/
       - assets/lottie/
     fonts:
       - family: UrwDinArabic
         fonts:
           - { asset: assets/fonts/urw_din_arabic_thin.ttf, weight: 100 }
           - { asset: assets/fonts/urw_din_arabic_xlight.ttf, weight: 200 }
           - { asset: assets/fonts/urw_din_arabic_light.ttf, weight: 300 }
           - { asset: assets/fonts/urw_din_arabic_regular.ttf, weight: 400 }
           - { asset: assets/fonts/urw_din_arabic_medium.ttf, weight: 500 }
           - { asset: assets/fonts/urw_din_arabic_semi_bold.ttf, weight: 600 }
           - { asset: assets/fonts/urw_din_arabic_bold.ttf, weight: 700 }
           - { asset: assets/fonts/urw_din_arabic_black.ttf, weight: 900 }
       - family: Messiri
         fonts:
           - { asset: assets/fonts/messiri_regular.ttf, weight: 400 }
           - { asset: assets/fonts/messiri_medium.ttf, weight: 500 }
           - { asset: assets/fonts/messiri_semibold.ttf, weight: 600 }
           - { asset: assets/fonts/messiri_bold.ttf, weight: 700 }
       - family: ComicSans
         fonts:
           - { asset: assets/fonts/comic_sans_ms.ttf, weight: 400 }
           - { asset: assets/fonts/comic_sans_ms_bold.ttf, weight: 700 }
   ```
6. `app_colors.dart`: `abstract final class AppColors` with a `static const Color` for **every** entry in `colors.xml`
   (name: `colorPrimary` → `primary`, `colorPrimaryDark` → `primaryDark`, `c_251836` → `c251836`, `white`, `black`, `transparent`).
   Android 8-digit values are `#AARRGGBB`, which is also Flutter's `Color(0xAARRGGBB)` order: `#090B0E1A` → `Color(0x090B0E1A)`;
   6-digit `#6A449A` → `Color(0xFF6A449A)`. Three entries in colors.xml end with a stray `"` after `</color>` — ignore it.
7. `app_text_styles.dart`: helpers matching Android styles: `bold(size, color)`, `medium(...)`, `regular(...)`, `semiBold(...)`
   (family UrwDinArabic, weights 700/500/400/600, `height: 1.0` to mimic `includeFontPadding=false`),
   `messiriBold/semiBold(...)`, `discount(...)` (ComicSans 700). Default color `AppColors.c251836`.
8. `app_theme.dart`: `ThemeData light()` — `useMaterial3: true`, `fontFamily: 'UrwDinArabic'`, default text weight medium,
   `colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: Brightness.light).copyWith(primary: AppColors.primary)`,
   `scaffoldBackgroundColor: AppColors.white`, `bottomSheetTheme` transparent background, no splash ink color changes beyond defaults.
   Use it in `app.dart`.
9. Tests (`test/tool/vd2svg_test.dart`): color conversion (`#80FF0000` → fill `#FF0000` opacity ~0.502), a path with stroke, a group
   transform, a gradient → `linearGradient` element, unknown color reference → `#888888`.
10. Run the checks. On the temporary home screen show `SvgPicture.asset(AppAssets.icGift)` and one Lottie (`AppAssets.lavenderLogo`) to verify.

## Done when
- `dart run tool/vd2svg.dart` produces 143 SVGs and `app_assets.dart`; rerun is idempotent.
- `flutter analyze` → no issues; `flutter test` → pass; debug APK builds.
- On device: the test SVG and Lottie render; Arabic text uses URW DIN Arabic (compare letter shapes with the Android app).

## Out of scope
- Rebuilding shape/selector drawables (done per screen). Launcher icon and native splash (T41). Shared widgets (T04).

## Gotchas
- Android vectors default `fillColor` is none (transparent) and `strokeWidth` 0.
- `fillAlpha`/`strokeAlpha` multiply with the color's own alpha.
- `@color/colorGray` is used by 119 paths but is not defined in this project. Owner decision: use `#888888`.
- `drawable-ar` PNGs are the Arabic versions of onboarding art; T11 picks by language.
- Keep the script; rerun it if Android drawables change.

## Notes
- Done: fonts/images/GIFs/Lottie copied (`map_style.json` skipped); `tool/vd2svg.dart` generates 143 SVGs, `tool/non_vector_drawables.txt` (106 names)
  and `lib/core/theme/app_assets.dart`; rerun verified idempotent (it also deletes SVGs whose vector no longer exists).
  `AppColors` (143 entries, generated once from `colors.xml`, now hand-maintained), `AppTextStyles`, `AppTheme.light()` (used in `app.dart`),
  pubspec assets + fonts. Temporary home shows `icGift` + `lavenderLogo` Lottie.
- Dependency change: `flutter_svg` needs `xml <=7.0.1`, so the dev dependency `xml` was relaxed from `^7.1.0` to `^7.0.1` (resolves to 7.0.1).
- Only unresolved color reference: `@color/colorGray` → `#888888` (as decided). No other warnings.
- `AppAssets` names: lowerCamelCase of the file name; `drawable-ar` images get suffix `Ar` (e.g. `icOnBoardingL1Ar`).
  `autoMirroredSvgs` (12 entries) holds the asset **paths** (same strings as the `AppAssets` constants), for `AppSvg` in T04.
- Android `strokeWidth` defaults to 0, so strokes with no width are dropped (gradient strokes in 196 paths mostly fall in this case).
  `<clip-path>` clips the rest of its group: the converter nests the remaining siblings in `<g clip-path="url(#cN)">`.
- `AppTextStyles.bold/semiBold/medium/regular/messiriBold/messiriSemiBold/discount(double size, [Color color = AppColors.c251836])`.
- Not verified: on-device rendering (SVG, Lottie, Arabic font) and the visual comparison of SVGs with Android Studio's preview — the
  in-app browser cannot render local files. Checks run: `flutter analyze` clean, `flutter test` pass, debug APK builds, all 143 SVGs parse as XML.
