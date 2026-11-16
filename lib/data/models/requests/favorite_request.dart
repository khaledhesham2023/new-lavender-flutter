import 'package:equatable/equatable.dart';

/// Body of `ToggleFavoriteRequest`; `doctor_id` is sent as a **String**.
class ToggleFavoriteRequest extends Equatable {
  final int doctorId;

  const ToggleFavoriteRequest(this.doctorId);

  Map<String, dynamic> toJson() => {'doctor_id': doctorId.toString()};

  @override
  List<Object?> get props => [doctorId];
}
