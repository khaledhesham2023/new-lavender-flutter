# T07 - Network client

## Goal
Port Retrofit/OkHttp + the `NetworkResponse` call adapter to a single `ApiClient` on top of `dio` that adds the same
headers, uses the same timeouts and maps every outcome to `ApiResult`. All repositories use it.

## Read first
- `app/src/main/java/com/alalmiya/lavender/di/AppModule.kt`
- `app/src/main/java/com/alalmiya/lavender/data/datasource/remote/network/NetworkResponse.kt`, `NetworkResponseCall.kt`
- `app/src/main/java/com/alalmiya/lavender/base/BaseRepository.kt`
- `app/src/main/java/com/alalmiya/lavender/utils/utilities/MultiPartHelper.kt`
- `app/src/main/java/com/alalmiya/lavender/utils/constants/Urls.kt`
- `docs/migration/CONTEXT.md` §5.1–§5.3, §11 items 1–2
- `docs/migration/PLAN.md` §4.2, decisions D10, D11
- `lib/core/network/api_result.dart` (from T04), `lib/core/storage/app_prefs.dart` (T06)

## Build
- `lib/core/network/endpoints.dart` — all paths.
- `lib/core/network/api_client.dart`.
- `test/core/network/api_client_test.dart` with a fake `HttpClientAdapter`.

## Steps
1. `flutter pub add dio`.
2. `endpoints.dart`: `abstract final class Endpoints` with one `static const` per path in CONTEXT §5.3 and helper functions for ids,
   e.g. `static String doctor(int id) => 'general/doctor/$id';`, `appointment(int id)`, `rebook(int id)`, `workTimes(int doctorId)`,
   `specialtyDoctors(int id)`, `filterDetails(int id)`, `offer(int id)`, `myOffer(int id)`, `session(int id)`, `notification(String id)`,
   `readNotification(String id)`. Paths have **no** leading slash (base URL ends with `/api/`).
3. `ApiClient(AppPrefs prefs, {Dio? dio})`:
   - `BaseOptions(baseUrl: Env.baseUrl, connectTimeout/receiveTimeout/sendTimeout: 25 s, responseType: json, validateStatus: (_) => true)`.
   - Interceptor adding headers on every request: `Accept: application/json`, `Content-Type: application/json` (except multipart),
     `lang` and `Accept-Language` = `prefs.languageCode`, `os: android`, `type: android`, and `Authorization: prefs.bearerToken` **only if non-null** (D10).
   - `LogInterceptor(requestBody: true, responseBody: true)` only in `kDebugMode`.
   - Methods: `Future<ApiResult<T>> get<T>(String path, {Map<String, dynamic>? query, required T Function(dynamic json) parse})`,
     same for `post` (with `Object? body`), `delete`, and `upload<T>(String path, {required String filePath, required String field, Map<String, dynamic>? query, required parse})`
     (multipart `FormData` with `MultipartFile.fromFile(filePath, filename: basename)`).
   - Also `Future<ApiResult<String>> postNoData(...)` style is not needed: endpoints with no data use `parse: (_) => null` and `T = void`/`Null`.
4. Result mapping (single private `_handle` function):
   - Exception from dio: `DioExceptionType.connectionTimeout|sendTimeout|receiveTimeout|connectionError` or an underlying `SocketException`
     → `NetworkFailure()`; `cancel` → `UnknownFailure('cancelled')`; others → `UnknownFailure(e.message ?? '')`.
   - Status 200–299: body must be a JSON object; `parse(body)` where `body` is the **whole** map (repositories read `body['data']`);
     message = `body['message'] ?? ''`. Body null/empty → `UnknownFailure()` (Android: success with null body → UnknownError). `parse` throwing → `UnknownFailure(error.toString())`.
   - Status ≥ 300: if body is a JSON map → `ServerFailure(status, body['message']?.toString() ?? '')`; else → `UnknownFailure()`.
   - 401: no special handling (D11).
5. Query maps with null values: drop nulls before sending (Retrofit skips null `@Query`).
6. Encoded query keys: `sub_specialty[0]=12` must not be percent-encoded. Use `ListFormat.multiCompatible` is not enough — build the
   query string manually in the repository (T09) via a helper here: `String buildQuery(Map<String, Object?> q)` that encodes values but
   leaves `[` `]` in keys, and an overload `get(path + '?' + query)` when `rawQuery` is given. Test it.
7. Tests (fake adapter returning canned `ResponseBody`): headers present with and without token; 200 parse; 200 with `null` body;
   422 with `{"message":"invalid"}` → `ServerFailure(422,"invalid")`; 500 HTML body → `UnknownFailure`; timeout → `NetworkFailure`;
   null query values dropped; `buildQuery({'sub_specialty[0]': 3, 'gender': 'male'})` keeps brackets.

## Done when
- `flutter analyze` → no issues; `flutter test` → pass; debug APK builds.

## Out of scope
- Repositories (T08/T09). Logout on 401 (D11 says none).

## Gotchas
- Android always sends `Content-Type: application/json`, even on GET. Keep it (some Laravel middleware may rely on it).
- Do not throw from `ApiClient`; every path returns an `ApiResult`.
- Base URL must end with `/` or dio joins paths wrongly — assert it in debug.

## Notes (Retrofit change)
- Endpoints now live in `lib/core/network/lavender_api.dart` (`@RestApi`, generated `lavender_api.g.dart`); `endpoints.dart`, `ApiClient.get/post/delete/upload` and `buildQuery` were removed.
- `ApiClient` still owns Dio (headers, timeouts, logger) and exposes `service` and `call(request, parse:)`, which keeps the same ApiResult mapping. Repositories keep their signatures and call `_api.call((s) => s.xxx(...), parse: ...)`.
- `@Queries()` (used by `specialtyDoctors`) does NOT drop null values: the repository removes them itself. Sub-specialty keys `sub_specialty[0]` are now sent percent-encoded (`%5B0%5D`) instead of raw brackets; servers decode both the same.
- Multipart upload takes a `File`; Retrofit derives the filename by splitting on the platform separator (fine on Android).
- Adding an endpoint: add a method to `LavenderApi`, then `dart run build_runner build --delete-conflicting-outputs`.
