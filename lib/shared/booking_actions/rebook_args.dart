import 'package:equatable/equatable.dart';

import '../../core/enums/enums.dart';

/// Arguments of `ChooseRebookAppointmentSheetFragment`.
class RebookArgs extends Equatable {
  final int appointmentId;
  final int doctorId;
  final BookingStatus status;

  /// `"book"` (change a pending / confirmed booking) or `"rebook"`.
  final String type;
  final bool forOffer;

  const RebookArgs({
    required this.appointmentId,
    required this.doctorId,
    required this.status,
    required this.type,
    this.forOffer = false,
  });

  @override
  List<Object?> get props => [appointmentId, doctorId, status, type, forOffer];
}
