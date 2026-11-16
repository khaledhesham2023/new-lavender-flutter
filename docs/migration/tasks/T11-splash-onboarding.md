# T11 - Splash and onboarding

## Goal
Port the launch flow: animated splash (Lottie logo, then loader GIF once), the decision onboarding / home / auth, and the
3-page onboarding. It is the entry point of every test run from now on.

## Read first
- `app/src/main/java/com/alalmiya/lavender/presentation/splash/SplashActivity.kt` + `res/layout/activity_splash.xml`
- `app/src/main/java/com/alalmiya/lavender/presentation/onboarding/screen/OnboardingActivity.kt` + `res/layout/activity_onboarding.xml`
- `app/src/main/java/com/alalmiya/lavender/utils/extensions/ViewExtFunctions.kt` (`LottieAnimationView.configure`, `ImageView.loadGif`)
- `res/values/themes.xml` (`Theme.Splash`, `bg_splash` drawable), strings `all_your_medical_services_in_one_place`, `no_need_to_search_in_multiple_places`,
  `book_easily_anytime`, `browse_the_list_of_doctors_and_services`, `regular_monitoring_of_your_health`,
  `keep_a_digital_medical_record_that_includes_your_previous_appointments`, `next`, `start_now`
- `docs/migration/CONTEXT.md` §7.1, §7.2

## Build
- `lib/features/splash/splash_screen.dart`
- `lib/features/onboarding/onboarding_screen.dart`
- `lib/core/push/device_token.dart` — `class DeviceTokenProvider { Future<String?> getToken() }` returning `prefs.deviceToken` for now
  (T39 replaces the body with FCM). Provide it with `RepositoryProvider` in `main.dart`.
- Router: replace the `splash` and `onboarding` placeholders.

## Steps
1. Splash UI from `activity_splash.xml`: full-screen `bg_splash` background (rebuild the drawable: check if it is a color/gradient/bitmap),
   centered `Lottie.asset(AppAssets.lavenderLogo)` played once at **2× speed** (`controller.duration / 2`; use an `AnimationController`
   with `duration: composition.duration ~/ 2`). When it completes, show `Image.asset(AppAssets.loaderGif)` below/in place as the layout does.
   Status bar color = primary with light icons (`AnnotatedRegion`).
2. The GIF plays once in Android and navigation happens at the GIF end (~3.6 s). Flutter `Image.asset` loops GIFs; instead, start a
   `Timer(const Duration(milliseconds: 3600))` when the GIF appears, then navigate. (Read the frame count/duration of `loader.gif` with
   any tool and use its real total duration if it differs; note it.)
3. Navigation decision (port `handleNavigation`): `prefs.isFirstTime` → `context.go(Routes.onboarding)`; else `session.isLoggedIn` →
   `context.go(Routes.home)`; else `context.go(Routes.authStart)`.
4. Onboarding UI from `activity_onboarding.xml`: white status/nav bar with dark icons; Lottie per page by language
   (`ar` → `onbaording_N_ar.json`, else `onboarding_N_en.json` — note the Arabic file name typo `onbaording`), title, body, 3 dots
   indicator (non-interactive, selected dot style from the TabLayout/tab drawable), button "Next" (`l10n.next`).
5. Behavior: no swipe. Next: index++ ; when index becomes 2 → button text `l10n.startNow`; pressing on index 2 → `prefs.isFirstTime = false`,
   `context.go(Routes.authStart)`. Lottie loops? Check `activity_onboarding.xml` `lottie_loop`/`lottie_autoPlay` attributes and match.
6. Remove the temporary splash buttons added in T10.

## Done when
- `flutter analyze` → no issues; `flutter test` → pass; debug APK builds.
- Fresh install: splash logo animation → loader GIF → onboarding (Arabic art + Arabic text, RTL). Next ×2 changes label to "ابدأ الآن"/Start now;
  third tap → auth placeholder. Kill and relaunch → goes straight to auth placeholder. With `isLoggedIn` forced true (temporary) → home.
- Back on onboarding exits the app (Android Activity root).

## Out of scope
- FCM token retrieval (T39). Native Android splash before Flutter draws (T41).

## Gotchas
- Splash and onboarding are Activities in Android; back from them leaves the app. Since they are `go` roots in Flutter, back already exits.
- Android preloads the next Lottie to avoid jank; use `Lottie.asset(..., frameRate: FrameRate.max)` and precache with `AssetLottie(...).load()` if a stutter shows.
- Language for the Lottie choice is `prefs.languageCode` (default "ar").
