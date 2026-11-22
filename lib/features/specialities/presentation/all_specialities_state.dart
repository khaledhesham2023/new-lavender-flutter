import 'package:equatable/equatable.dart';

import '../../../core/network/api_result.dart';
import '../../../data/models/responses/speciality.dart';

class AllSpecialitiesState extends Equatable {
  final ViewStatus status;
  final List<SpecialityModel> specialities;

  /// Failure of `getSpecialities`; the screen picks the view from its type.
  final ApiFailure<dynamic>? failure;

  const AllSpecialitiesState({
    this.status = ViewStatus.initial,
    this.specialities = const [],
    this.failure,
  });

  @override
  List<Object?> get props => [status, specialities, failure];
}
