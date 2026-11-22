import '../../../data/models/requests/appointment_requests.dart';

/// Result of [ChangeAppointmentCubit.confirm].
sealed class ChangeConfirm {
  const ChangeConfirm();
}

class ChangeConfirmed extends ChangeConfirm {
  final ChangeAppointmentRequest request;
  const ChangeConfirmed(this.request);
}

class ChangeNeedsDay extends ChangeConfirm {
  const ChangeNeedsDay();
}

class ChangeNeedsTime extends ChangeConfirm {
  const ChangeNeedsTime();
}
