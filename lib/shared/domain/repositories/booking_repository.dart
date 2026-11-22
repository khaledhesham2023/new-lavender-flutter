import '../../../core/network/api_result.dart';
import '../../../data/models/requests/appointment_requests.dart';
import '../../../data/models/responses/appointment.dart';
import '../../../data/models/responses/doctor.dart';

/// Appointments, used by booking, bookings and appointment_details.
/// `BookingRepositoryImpl` (shared data layer) implements it.
abstract interface class BookingRepository {
  Future<ApiResult<AppointmentData>> save(SaveAppointmentRequest request);

  /// [type] is `default` / `offer` / `not_offer` or null; [month] is `"3"`,
  /// `"6"`, `"12"` or null.
  Future<ApiResult<List<AppointmentData>>> list({
    required String status,
    String? month,
    String? keyword,
    String? type,
  });

  Future<ApiResult<AppointmentData>> details(int id);

  /// Same endpoint as [update], but with no body.
  Future<ApiResult<void>> cancel(int id);

  Future<ApiResult<void>> update(int id, UpdateAppointmentRequest request);

  Future<ApiResult<AppointmentData>> rebook(int id, RebookRequest request);

  /// Returns the server's confirmation message.
  Future<ApiResult<String>> addComment(AddCommentRequest request);

  Future<ApiResult<List<QuickComment>>> quickComments();

  /// A 404 (no times) stays a `ServerFailure(404, …)`.
  Future<ApiResult<List<WorkTimeModel>>> workTimes(int doctorId);
}
