# T09 - Repositories: home, specialities, search, doctor, booking, favorites, offers

## Goal
Implement the remaining repositories (everything that is not auth/profile/notifications), with tests for the tricky
request shapes. After this task the whole API is available to screens.

## Read first
- `app/src/main/java/com/alalmiya/lavender/data/datasource/remote/ServiceApi.kt` (Home, Favorites, Specialities, Search, Doctor details, Appointments, Reports, Offers)
- `app/src/main/java/com/alalmiya/lavender/data/repository/HomeRepoImpl.kt`, `SpecialitiesRepoImpl.kt`, `SearchRepoImpl.kt`,
  `DoctorDetailsRepoImpl.kt`, `BookingRepoImpl.kt`, `FavoritesRepoImpl.kt`, `OffersRepoImpl.kt`
- `docs/migration/CONTEXT.md` §5.3 (remaining rows)
- `lib/core/network/api_client.dart` (incl. `buildQuery`), `lib/data/models/*`

## Build
In `lib/data/repositories/`: `home_repository.dart`, `specialities_repository.dart`, `search_repository.dart`, `doctor_repository.dart`,
`booking_repository.dart`, `favorites_repository.dart`, `offers_repository.dart`. Tests in `test/data/repositories/`.

## Steps
1. `HomeRepository`: `getHome()` → `GET client/home` → `HomeData`; `toggleFavorite(int doctorId)` → `POST client/fav {doctor_id: "$id"}` → void.
2. `SpecialitiesRepository`: `getSpecialities()` → `GET client/specialty` → `List<SpecialityModel>`;
   `getDoctors(int specialtyId, {String? sortBy, List<int> subSpecialtyIds = const [], String? gender, double? maxPrice, double? minPrice, String? name})`
   → `GET client/specialty/{id}` with query `sort_by, gender, max_price, min_price, doctor_name` (nulls dropped) and
   `sub_specialty[0]=<id0>`, `sub_specialty[1]=<id1>`… with **unencoded brackets** (use `ApiClient.buildQuery`) → `DoctorsBySpeciality { List<DoctorModel> doctors; int count }`.
   Prices are sent as Kotlin `Float.toString()` would (e.g. `150.0`).
3. `SearchRepository`: `mostSelected()` `GET client/search/most` → `List<SpecialityModel>`; `recent()` `GET client/search` → `List<RecentSearchModel>`;
   `search(String keyword)` `POST client/search?keyword=` (query, no body) → `SearchResultsData`; `clearRecent()` `DELETE client/search/clear`;
   `filterDetails(int specialtyId)` `GET general/filter-details/{id}` → `FilterData`.
4. `DoctorRepository`: `getDoctor(int id)` → `GET general/doctor/{id}` → `DoctorModel`; `toggleFavorite(int id)` (same endpoint as home).
5. `BookingRepository`:
   - `save(SaveAppointmentRequest)` → `POST client/appointments` → `AppointmentData`
   - `list({required String status, String? month, String? keyword, String? type})` → `GET client/appointments` → `List<AppointmentData>`
   - `details(int id)` → `GET client/appointments/{id}` → `AppointmentData`
   - `cancel(int id)` → `POST client/appointments/{id}` with **no body** → void
   - `update(int id, UpdateAppointmentRequest)` → `POST client/appointments/{id}` body incl. `_method: put` → void
   - `rebook(int id, RebookRequest)` → `POST client/appointments/recreate/{id}` → `AppointmentData`
   - `addComment(AddCommentRequest)` → `POST client/reviews` → `String` message
   - `quickComments()` → `GET general/quick-comments` → `List<QuickComment>`
   - `workTimes(int doctorId)` → `GET general/work-times/{id}` → `List<WorkTimeModel>` (a 404 stays a `ServerFailure(404, …)`; T27 checks it)
6. `FavoritesRepository`: `getFavorites({String? name})` → `GET client/fav?doctor_name=` → `List<DoctorModel>`; `toggleFavorite(int id)`.
7. `OffersRepository`: `bySpecialty(int id)` `GET client/offers?specialty_id=`; `details(int id)` `GET client/offers/{id}`; `myOffers()` `GET client/my-offers` → `MyOffersData`;
   `myOfferDetails(int id)` `GET client/my-offers/{id}` → `OfferModel`; `buy(int offerId)` `POST client/offers {offer_id}` → `OfferModel`;
   `session(int id)` `GET client/session/{id}` → `SessionDetailsModel`.
8. Tests: `getDoctors` with 2 subspecialties + gender + null sort → exact URL `client/specialty/5?gender=male&sub_specialty[0]=1&sub_specialty[1]=2`
   (order as built); `cancel` has no body; `update` body has `_method`; `search` keyword in query; `toggleFavorite` doctor_id is a string;
   `workTimes` 404 → ServerFailure(404); a sample parse for home and doctor details.

## Done when
- `flutter analyze` → no issues; `flutter test` → pass; debug APK builds.

## Out of scope
- Any UI or Cubit. Payment (T37).

## Gotchas
- `client/offers` GET endpoints don't send Authorization in Android; ours adds it when logged in — harmless, keep the shared client.
- Booking list `type` is `default` / `offer` / `not_offer` or null; `month` is `"3"`, `"6"`, `"12"` or null.
