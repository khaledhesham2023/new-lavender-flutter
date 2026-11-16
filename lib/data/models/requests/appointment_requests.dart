import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'appointment_requests.g.dart';

@JsonSerializable(createFactory: false)
class SaveAppointmentRequest extends Equatable {
  final int? doctorId;
  final String? day;
  final String? time;
  final int? userOfferId;
  final String? notes;

  const SaveAppointmentRequest({
    this.doctorId,
    this.day,
    this.time,
    this.userOfferId,
    this.notes,
  });

  Map<String, dynamic> toJson() => _$SaveAppointmentRequestToJson(this);

  @override
  @JsonKey(includeToJson: false)
  List<Object?> get props => [doctorId, day, time, userOfferId, notes];
}

@JsonSerializable(createFactory: false)
class UpdateAppointmentRequest extends Equatable {
  final int doctorId;
  final String day;
  final String time;

  const UpdateAppointmentRequest({
    required this.doctorId,
    required this.day,
    required this.time,
  });

  Map<String, dynamic> toJson() =>
      {..._$UpdateAppointmentRequestToJson(this), '_method': 'put'};

  @override
  @JsonKey(includeToJson: false)
  List<Object?> get props => [doctorId, day, time];
}

@JsonSerializable(createFactory: false)
class RebookRequest extends Equatable {
  final String? day;
  final String? time;

  const RebookRequest({this.day, this.time});

  Map<String, dynamic> toJson() => _$RebookRequestToJson(this);

  @override
  @JsonKey(includeToJson: false)
  List<Object?> get props => [day, time];
}

@JsonSerializable(createFactory: false)
class AddCommentRequest extends Equatable {
  /// Null when 0 stars.
  final double? rate;
  final String? comment;
  final int? doctorId;
  final int? quickCommentId;
  final int? clientAppointmentId;

  const AddCommentRequest({
    this.rate,
    this.comment,
    this.doctorId,
    this.quickCommentId,
    this.clientAppointmentId,
  });

  Map<String, dynamic> toJson() => _$AddCommentRequestToJson(this);

  @override
  @JsonKey(includeToJson: false)
  List<Object?> get props =>
      [rate, comment, doctorId, quickCommentId, clientAppointmentId];
}

@JsonSerializable(createFactory: false)
class ChangeAppointmentRequest extends Equatable {
  final int doctorId;
  final String day;
  @JsonKey(name: 'dayName')
  final String dayName;
  final String time;

  const ChangeAppointmentRequest({
    required this.doctorId,
    required this.day,
    required this.dayName,
    required this.time,
  });

  Map<String, dynamic> toJson() => _$ChangeAppointmentRequestToJson(this);

  @override
  @JsonKey(includeToJson: false)
  List<Object?> get props => [doctorId, day, dayName, time];
}

/// Query of `GetBookingsRequest`.
@JsonSerializable(createFactory: false)
class GetBookingsRequest extends Equatable {
  final String? status;

  const GetBookingsRequest({this.status});

  Map<String, dynamic> toJson() => _$GetBookingsRequestToJson(this);

  @override
  @JsonKey(includeToJson: false)
  List<Object?> get props => [status];
}
