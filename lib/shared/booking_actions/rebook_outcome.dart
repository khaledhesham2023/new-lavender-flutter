import '../../data/models/requests/appointment_requests.dart';

/// What the rebook sheet resolves to.
sealed class RebookOutcome {
  const RebookOutcome();
}

/// Pending / confirmed: the new slot, still to be confirmed by the caller.
class ChangeRequested extends RebookOutcome {
  final UpdateAppointmentRequest request;
  const ChangeRequested(this.request);
}

/// Completed / canceled / rejected: the new appointment was created.
class Rebooked extends RebookOutcome {
  final int newId;
  final bool forOffer;
  const Rebooked(this.newId, this.forOffer);
}
