import '../../data/models/requests/appointment_requests.dart';

/// What the confirmation sheet does when Confirm is tapped.
sealed class ConfirmAction {
  const ConfirmAction();
}

class CancelAction extends ConfirmAction {
  final int id;
  const CancelAction(this.id);
}

class UpdateAction extends ConfirmAction {
  final int id;
  final UpdateAppointmentRequest request;
  const UpdateAction(this.id, this.request);
}
