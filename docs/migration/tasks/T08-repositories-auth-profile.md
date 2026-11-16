# T08 - Repositories: auth, profile, general, notifications

## Goal
Implement the repositories for authentication, profile/content, general (upload, settings) and notifications on top of
`ApiClient`, one method per endpoint, with tests for request building. Auth and profile screens and the session depend on them.

## Read first
- `app/src/main/java/com/alalmiya/lavender/data/datasource/remote/ServiceApi.kt` (auth, profile, base, notifications sections)
- `app/src/main/java/com/alalmiya/lavender/data/repository/AuthRepoImpl.kt`, `ProfileRepoImpl.kt`, `GeneralRepoImpl.kt`, `NotificationsRepoImpl.kt`
- `app/src/main/java/com/alalmiya/lavender/data/paging/NotificationsPagingSource.kt`
- `docs/migration/CONTEXT.md` §5.3 (rows: client/login … client/user/allow-notifications, general/attachments, general/settings)
- `lib/core/network/api_client.dart`, `lib/data/models/*`

## Build
In `lib/data/repositories/`:
- `auth_repository.dart` — `AuthRepository(ApiClient)`
- `profile_repository.dart` — `ProfileRepository(ApiClient)`
- `general_repository.dart` — `GeneralRepository(ApiClient)`
- `notifications_repository.dart` — `NotificationsRepository(ApiClient)`
Tests in `test/data/repositories/` using a fake adapter that records the request (method, path, query, body).

## Steps
1. Each method returns `Future<ApiResult<X>>` and parses `json['data']` with the model's `fromJson`. Methods without data return `ApiResult<void>` (or `ApiResult<String>` with the message when the UI shows the message).
2. `AuthRepository`:
   - `login(AuthRequest)` → `POST client/login` → `UserModel`
   - `register(AuthRequest)` → `POST client/register` → `UserModel`
   - `verifyPhone(AuthRequest)` → `POST client/verify` → `UserModel`
   - `resendCode(AuthRequest)` → `POST client/resend` → `UserModel?`
   - `resetPassword(AuthRequest)` → `POST client/password/reset` → `UserModel?`
   - `verifyForgetPassword(AuthRequest)` → `POST client/password/verify` → `UserModel?`
   - `changePassword(AuthRequest)` → `POST client/password/change` → void
   - `logout(String? deviceToken)` → `POST client/logout` body `{device_token}` → void
   - `verifyChangedPhone(AuthRequest)` → `POST client/user/verify` → `UserModel?`
3. `ProfileRepository`:
   - `getProfile()` → `GET client/user` → `UserModel`
   - `updateProfile(AuthRequest)` → `POST client/user/update-profile` → `UserModel?`
   - `updatePhone(String phone, String phoneCode)` → `POST client/user/update-phone` → void
   - `changeUserPassword(AuthRequest)` → `POST client/user/change-password` → void
   - `deleteAccount()` → `DELETE client/user` → void
   - `contactUs({fullName, title, content})` → `POST client/contact` with these as **query** params, no body → void
   - `aboutUs()` `GET client/about`, `aboutApp()` `GET client/about-app`, `terms()` `GET client/term`, `policy()` `GET client/policy` → `AboutModel`
   - `changeLang(String lang)` → `POST client/user/change-lang?lang=` → void
   - `getReports(ReportType type)` → `GET client/my-reports?type=` → `List<DayReportsModel>`
4. `GeneralRepository`:
   - `uploadImage(String filePath)` → `upload general/attachments` field `file`, query `model=users`, `attachment_type=image` → `String` (`data`)
   - `getSettings()` → `GET general/settings` → `SettingModel`
5. `NotificationsRepository`:
   - `getPage(int page)` → `GET client/notifications?page=` → `NotificationsPage { List<NotificationModel> items; bool isLast }` where
     `isLast = items.isEmpty` (Android: next key null when the page is empty) — also expose `meta.last_page` if present.
   - `delete(String id)` → `DELETE client/notifications/{id}`; `markRead(String id)` → `GET client/notifications/read/{id}`;
     `readAll()` → `GET client/notifications/read-all` (kept for completeness; unused by UI);
     `toggleAllow()` → `POST client/user/allow-notifications?_method=PUT` → `bool` (`data.allow_notification`).
6. Tests: for each repository at least: correct method+path, query/body keys, parse of a sample success response, and a failure passes through
   unchanged. Specifically test `contactUs` uses query params, `toggleAllow` sends `_method=PUT`, `logout` body.

## Done when
- `flutter analyze` → no issues; `flutter test` → pass; debug APK builds.

## Out of scope
- Side effects like saving the user/token (done by the screen Cubits/SessionCubit in T10/T12/T14). Other repositories (T09).

## Gotchas
- `verifyForgetPassword` sends the Authorization header in Android (harmless; our client adds it only if logged in).
- `general/attachments` returns the stored file name/URL in `data`; `update-profile` then receives it as `image`.
- Reports and specialities lists can be `[]` or missing `data` — return empty lists, not failures.
