# T06 - Local storage

## Goal
Replace Preferences DataStore + Proto DataStore with `shared_preferences`: a typed `AppPrefs` for the flags/tokens the
app really uses and a `UserStore` for the logged-in user. The network client (T07) reads the token and language from here.

## Read first
- `app/src/main/java/com/alalmiya/lavender/data/datasource/local/preferences/DataStoreRepoImp.kt`, `Keys.kt`
- `app/src/main/java/com/alalmiya/lavender/data/datasource/local/protoDataStore/ProtoDataRepositoryImpl.kt`
- `app/src/main/proto/data.proto`
- `app/src/main/java/com/alalmiya/lavender/presentation/auth/AuthViewModel.kt` (`saveUserModel`, `saveBearerToken`)
- `app/src/main/java/com/alalmiya/lavender/presentation/profile/ProfileViewModel.kt` (`logout`, `deleteAccount`, `getProfileData` → `updateUserFields`)
- `docs/migration/CONTEXT.md` §6

## Build
- `lib/core/storage/app_prefs.dart`
- `lib/core/storage/user_store.dart` (+ `UserData` class)
- `test/core/storage/app_prefs_test.dart`, `user_store_test.dart`

## Steps
1. `flutter pub add shared_preferences`.
2. `AppPrefs` wraps a `SharedPreferences` instance (constructor injection; `static Future<AppPrefs> create()`), synchronous getters, async setters:
   | Getter/setter | Key | Default |
   |---|---|---|
   | `String languageCode` | `app_language` | `"ar"` |
   | `bool isFirstTime` | `first_time` | `true` |
   | `bool isLoggedIn` | `login_status` | `false` |
   | `String? bearerToken` | `bearer_token` | `null` |
   | `String? deviceToken` | `device_token` | `null` |
   | `bool allowNotifications` | `allow_notifications` | `false` |
   | `String whatsAppNumber` | `whats_app_number` | `""` |
   - `setBearerToken(String token)` stores `"Bearer $token"` unless it already starts with `"Bearer"` (Android `saveBearerToken`).
   - `Future<void> clearForLogout()`: remove everything **except** `device_token`, then set `app_language = "ar"`.
     (Android `ProfileViewModel` clears everything incl. the device token, then sets language "ar". Keeping the device token is
     harmless because login always fetches a fresh FCM token first; it avoids a missing token before T39 refreshes it.)
     `first_time` is removed → onboarding shows again on next cold start (CONTEXT §6.1).
3. `UserData` (immutable, `Equatable`, `toJson/fromJson` for storage): id, name, image, email, phoneCode, phone, gender, lang,
   isVerified, allowNotification, isCompletedData, unreadNotifications, userType, countryId/name/image/phoneCode, cityId/name.
   `UserData.fromUserModel(UserModel)` maps like `ProtoDataRepositoryImpl.saveUserModel` (nulls → "" / 0 / false; lang default "ar";
   allowNotification default **true** there — keep).
4. `UserStore` (uses the same `SharedPreferences`, key `user_data` as a JSON string): `UserData? read()`, `Future<void> save(UserData)`,
   `Future<void> updateFields({String? name, String? phone, String? phoneCode, String? image, String? email})` (only non-null values change,
   like `updateUserFields`), `Future<void> clear()`.
5. Tests with `SharedPreferences.setMockInitialValues({})`: defaults; token prefix; `clearForLogout` keeps device token, resets language,
   removes first_time/login; user save/read round trip; updateFields partial.

## Done when
- `flutter analyze` → no issues; `flutter test` → pass; debug APK builds.

## Out of scope
- Who calls these (Session in T10, auth in T12/T14). Migrating old Android DataStore data (decision D13: not migrated).

## Gotchas
- Android getters use `runBlocking`; here getters are synchronous on the cached `SharedPreferences` instance — create it once in `main.dart` (T10).
- Do not store the token in plain `UserData.token` *and* prefs; the bearer token lives only in `AppPrefs`.

## Notes
- Done: `flutter analyze` clean, `flutter test` pass (9 new tests), debug APK builds. Added `shared_preferences`.
- `lib/core/storage/app_prefs.dart`: `AppPrefs` (sync getters, async setters, `create()`), keys exposed as `AppPrefs.key*` constants. `clearForLogout` keeps `device_token`, removes everything else (incl. `first_time`, `login_status`, `bearer_token`) and sets language `"ar"`. On re-login the language must be set from `UserData.lang` (Android `saveUserModel` does this), to be done in T12/T14.
- `lib/core/storage/user_store.dart`: `UserData` (hand-written `toJson/fromJson`, not json_serializable), `UserData.fromUserModel`, `UserStore` (`read/save/updateFields/clear`, key `user_data`). `updateFields` does nothing when no user is stored. `read()` returns null on corrupt JSON.
- `UserStore` imports `data/models/responses/user.dart` (path after the T05 restructure).
- `android/gradle.properties`: added `kotlin.incremental=false`. Without it the debug build failed in `shared_preferences_android:compileDebugKotlin` ("Could not close incremental caches"), probably because the project (D:) and the pub cache (C:) are on different drives.
- Parked for later review: `UserData` in `core/storage` depends on the data-layer `UserModel`; consider small interfaces for the token/language readers (T07, T10), moving the mapper out of `UserData` and switching it to json_serializable.
