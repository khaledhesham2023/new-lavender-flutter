import 'dart:io';

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'lavender_api.g.dart';

/// Every endpoint of the backend (port of the Kotlin Retrofit interfaces).
/// Paths are relative: the base URL ends with `/api/`, so no leading slash.
///
/// Methods return the raw [HttpResponse]; `ApiClient.call` turns it into an
/// `ApiResult` (the client accepts every status code, so error bodies arrive
/// here too). Request headers are added by the `ApiClient` interceptor.
@RestApi()
abstract class LavenderApi {
  factory LavenderApi(Dio dio, {String? baseUrl}) = _LavenderApi;

  // ---- Auth ----
  @POST('client/login')
  Future<HttpResponse<dynamic>> login(@Body() Map<String, dynamic> body);

  @POST('client/register')
  Future<HttpResponse<dynamic>> register(@Body() Map<String, dynamic> body);

  @POST('client/verify')
  Future<HttpResponse<dynamic>> verify(@Body() Map<String, dynamic> body);

  @POST('client/resend')
  Future<HttpResponse<dynamic>> resend(@Body() Map<String, dynamic> body);

  @POST('client/password/reset')
  Future<HttpResponse<dynamic>> passwordReset(
    @Body() Map<String, dynamic> body,
  );

  @POST('client/password/verify')
  Future<HttpResponse<dynamic>> passwordVerify(
    @Body() Map<String, dynamic> body,
  );

  @POST('client/password/change')
  Future<HttpResponse<dynamic>> passwordChange(
    @Body() Map<String, dynamic> body,
  );

  @POST('client/logout')
  Future<HttpResponse<dynamic>> logout(@Body() Map<String, dynamic> body);

  // ---- User ----
  @GET('client/user')
  Future<HttpResponse<dynamic>> getUser();

  @DELETE('client/user')
  Future<HttpResponse<dynamic>> deleteUser();

  @POST('client/user/update-profile')
  Future<HttpResponse<dynamic>> updateProfile(
    @Body() Map<String, dynamic> body,
  );

  @POST('client/user/update-phone')
  Future<HttpResponse<dynamic>> updatePhone(@Body() Map<String, dynamic> body);

  @POST('client/user/verify')
  Future<HttpResponse<dynamic>> verifyPhone(@Body() Map<String, dynamic> body);

  @POST('client/user/change-password')
  Future<HttpResponse<dynamic>> changePassword(
    @Body() Map<String, dynamic> body,
  );

  @POST('client/user/change-lang')
  Future<HttpResponse<dynamic>> changeLang(@Query('lang') String lang);

  /// Laravel method spoofing: `_method=PUT` on a POST.
  @POST('client/user/allow-notifications')
  Future<HttpResponse<dynamic>> allowNotifications(
    @Query('_method') String method,
  );

  // ---- Static pages / contact ----
  /// The backend reads these as query parameters; no body is sent.
  @POST('client/contact')
  Future<HttpResponse<dynamic>> contact(
    @Query('full_name') String fullName,
    @Query('title') String title,
    @Query('content') String content,
  );

  @GET('client/about')
  Future<HttpResponse<dynamic>> about();

  @GET('client/about-app')
  Future<HttpResponse<dynamic>> aboutApp();

  @GET('client/term')
  Future<HttpResponse<dynamic>> terms();

  @GET('client/policy')
  Future<HttpResponse<dynamic>> policy();

  // ---- Notifications ----
  @GET('client/notifications')
  Future<HttpResponse<dynamic>> notifications(@Query('page') int page);

  @DELETE('client/notifications/{id}')
  Future<HttpResponse<dynamic>> deleteNotification(@Path('id') String id);

  @GET('client/notifications/read/{id}')
  Future<HttpResponse<dynamic>> readNotification(@Path('id') String id);

  @GET('client/notifications/read-all')
  Future<HttpResponse<dynamic>> readAllNotifications();

  // ---- Home / doctors / specialties ----
  @GET('client/home')
  Future<HttpResponse<dynamic>> home();

  @GET('client/fav')
  Future<HttpResponse<dynamic>> favorites({
    @Query('doctor_name') String? doctorName,
  });

  @POST('client/fav')
  Future<HttpResponse<dynamic>> toggleFavorite(
    @Body() Map<String, dynamic> body,
  );

  @GET('client/specialty')
  Future<HttpResponse<dynamic>> specialties();

  /// [filters] keys: `sort_by`, `gender`, `max_price`, `min_price`,
  /// `doctor_name` and `sub_specialty[<i>]`. Null values are dropped.
  @GET('client/specialty/{id}')
  Future<HttpResponse<dynamic>> specialtyDoctors(
    @Path('id') int id,
    @Queries() Map<String, dynamic> filters,
  );

  // ---- Search ----
  @GET('client/search/most')
  Future<HttpResponse<dynamic>> searchMost();

  @GET('client/search')
  Future<HttpResponse<dynamic>> recentSearches();

  /// The keyword goes in the query string; no body is sent.
  @POST('client/search')
  Future<HttpResponse<dynamic>> search(@Query('keyword') String keyword);

  @DELETE('client/search/clear')
  Future<HttpResponse<dynamic>> clearSearch();

  // ---- General ----
  @GET('general/filter-details/{id}')
  Future<HttpResponse<dynamic>> filterDetails(@Path('id') int specialtyId);

  @GET('general/doctor/{id}')
  Future<HttpResponse<dynamic>> doctor(@Path('id') int id);

  @GET('general/work-times/{id}')
  Future<HttpResponse<dynamic>> workTimes(@Path('id') int doctorId);

  @GET('general/quick-comments')
  Future<HttpResponse<dynamic>> quickComments();

  @GET('general/countries')
  Future<HttpResponse<dynamic>> countries();

  @GET('general/settings')
  Future<HttpResponse<dynamic>> settings();

  @POST('general/attachments')
  @MultiPart()
  Future<HttpResponse<dynamic>> uploadAttachment(
    @Part(name: 'file') File file,
    @Query('model') String model,
    @Query('attachment_type') String attachmentType,
  );

  // ---- Appointments ----
  @POST('client/appointments')
  Future<HttpResponse<dynamic>> saveAppointment(
    @Body() Map<String, dynamic> body,
  );

  @GET('client/appointments')
  Future<HttpResponse<dynamic>> appointments({
    @Query('status') required String status,
    @Query('month') String? month,
    @Query('keyword') String? keyword,
    @Query('type') String? type,
  });

  @GET('client/appointments/{id}')
  Future<HttpResponse<dynamic>> appointment(@Path('id') int id);

  @POST('client/appointments/{id}')
  Future<HttpResponse<dynamic>> updateAppointment(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  /// Same endpoint as [updateAppointment], with no body.
  @POST('client/appointments/{id}')
  Future<HttpResponse<dynamic>> cancelAppointment(@Path('id') int id);

  @POST('client/appointments/recreate/{id}')
  Future<HttpResponse<dynamic>> rebookAppointment(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  @POST('client/reviews')
  Future<HttpResponse<dynamic>> addReview(@Body() Map<String, dynamic> body);

  @GET('client/my-reports')
  Future<HttpResponse<dynamic>> myReports(@Query('type') String type);

  // ---- Offers ----
  @GET('client/offers')
  Future<HttpResponse<dynamic>> offers(@Query('specialty_id') int specialtyId);

  @POST('client/offers')
  Future<HttpResponse<dynamic>> buyOffer(@Body() Map<String, dynamic> body);

  @GET('client/offers/{id}')
  Future<HttpResponse<dynamic>> offer(@Path('id') int id);

  @GET('client/my-offers')
  Future<HttpResponse<dynamic>> myOffers();

  @GET('client/my-offers/{id}')
  Future<HttpResponse<dynamic>> myOffer(@Path('id') int id);

  @GET('client/session/{id}')
  Future<HttpResponse<dynamic>> session(@Path('id') int id);
}
