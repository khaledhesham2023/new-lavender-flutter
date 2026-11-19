import '../../core/network/api_client.dart';
import '../../core/network/api_result.dart';
import '../json/json_utils.dart';
import '../models/requests/appointment_requests.dart';
import '../models/responses/appointment.dart';
import '../models/responses/doctor.dart';
import 'repository_parsers.dart';

class BookingRepository {
  BookingRepository(this._api);

  final ApiClient _api;

  Future<ApiResult<AppointmentData>> save(SaveAppointmentRequest request) =>
      _api.call(
        (s) => s.saveAppointment(request.toJson()),
        parse: parseObject(AppointmentData.fromJson),
      );

  /// [type] is `default` / `offer` / `not_offer` or null; [month] is `"3"`,
  /// `"6"`, `"12"` or null.
  Future<ApiResult<List<AppointmentData>>> list({
    required String status,
    String? month,
    String? keyword,
    String? type,
  }) => _api.call(
    (s) => s.appointments(
      status: status,
      month: month,
      keyword: keyword,
      type: type,
    ),
    parse: parseList(AppointmentData.fromJson),
  );

  Future<ApiResult<AppointmentData>> details(int id) => _api.call(
    (s) => s.appointment(id),
    parse: parseObject(AppointmentData.fromJson),
  );

  /// Same endpoint as [update], but with no body.
  Future<ApiResult<void>> cancel(int id) =>
      _api.call((s) => s.cancelAppointment(id), parse: parseVoid);

  Future<ApiResult<void>> update(int id, UpdateAppointmentRequest request) =>
      _api.call(
        (s) => s.updateAppointment(id, request.toJson()),
        parse: parseVoid,
      );

  Future<ApiResult<AppointmentData>> rebook(int id, RebookRequest request) =>
      _api.call(
        (s) => s.rebookAppointment(id, request.toJson()),
        parse: parseObject(AppointmentData.fromJson),
      );

  /// Returns the server's confirmation message.
  Future<ApiResult<String>> addComment(AddCommentRequest request) => _api.call(
    (s) => s.addReview(request.toJson()),
    parse: (j) => asString(asMap(j)?['message']) ?? '',
  );

  Future<ApiResult<List<QuickComment>>> quickComments() => _api.call(
    (s) => s.quickComments(),
    parse: parseList(QuickComment.fromJson),
  );

  /// A 404 (no times) stays a `ServerFailure(404, …)`.
  Future<ApiResult<List<WorkTimeModel>>> workTimes(int doctorId) => _api.call(
    (s) => s.workTimes(doctorId),
    parse: parseList(WorkTimeModel.fromJson),
  );
}
