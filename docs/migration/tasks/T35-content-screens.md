# T35 - Contact us, about app, about us, terms, privacy

## Goal
Port the five simple content screens reachable from Profile (and Terms from Register/Purchase).

## Read first
- `app/src/main/java/com/alalmiya/lavender/presentation/profile/contactUs/ContactUsFragment.kt`
- `app/src/main/java/com/alalmiya/lavender/presentation/profile/about/AboutFragment.kt`, `about/adapter/SocialAdapter.kt`
- `app/src/main/java/com/alalmiya/lavender/presentation/profile/aboutUs/AboutUsFragment.kt`
- `app/src/main/java/com/alalmiya/lavender/presentation/profile/privacypolicy/screen/TermsOfUseFragment.kt`, `PrivacyPolicyFragment.kt`
- `app/src/main/java/com/alalmiya/lavender/utils/extensions/ViewExtFunctions.kt` (`setHtmlContent`)
- Layouts: `res/layout/fragment_contact_us.xml`, `fragment_about.xml`, `fragment_about_us.xml`, `fragment_terms_of_use.xml`, `fragment_privacy_policy.xml`, social item layout
- `docs/migration/CONTEXT.md` §7.4 (Contact us, About app, About us, Terms / Privacy rows)
- `lib/core/utils/launchers.dart` (T32)

## Build
- `lib/features/content/contact_us_screen.dart`, `contact_us_cubit.dart`
- `lib/features/content/about_app_screen.dart`, `about_us_screen.dart`, `html_page_screen.dart` (shared for terms & privacy: `HtmlPageScreen(kind: terms|privacy)`), `content_cubit.dart` (loads one `AboutModel` by kind)
- Router: replace `contactUs`, `aboutApp`, `aboutUs`, `terms`, `privacy`.

## Steps
1. `flutter pub add flutter_widget_from_html_core`. HTML text styled like the Android `TextView` (font, size, color from each layout).
2. Contact us: name (prefilled from `session.user?.name`), title, message — each must be ≥ 2 chars (errors per Kotlin `isValid`). Send → `contactUs(fullName, title, content)` →
   `await showSuccessDialog(context, l10n.yourComplainSentSuccessfully)` → pop (check what Android does after the dialog). WhatsApp icon → `openUrl('https://api.whatsapp.com/send?phone=${prefs.whatsAppNumber}')`.
3. About app: `aboutApp()` → HTML `name`; social icons row from `links` where key ∈ {facebook, twitter, youtube, instagram, link} with icons `ic_facebook`, `ic_twitter_icon`, `ic_youtube`, `ic_instagram`
   (check the adapter for `link`); tap → `openUrl(value)` and on failure toast `noSuitableAppFoundToOpenTheLink` (warning). Rows "Terms of use" → `Routes.terms`, "Privacy policy" → `Routes.privacy`.
4. About us: `aboutUs()` → HTML `name` + up to 3 images in the layout's card slots (hide unused slots).
5. Terms (`terms()`) / Privacy (`policy()`): header + HTML body.
6. All: loading view; errors per each Kotlin `observerAllErrors` (mostly toast); back → pop.

## Done when
- `flutter analyze` → no issues; `flutter test` → pass; debug APK builds.
- On device: each screen shows the same server content as Android in ar and en; contact form validation and success; WhatsApp opens the chat; social links open.

## Out of scope
- Profile menu (T32).

## Gotchas
- These endpoints send Authorization when logged in; guests can open them too (no header — D10).
