import 'package:equatable/equatable.dart';
import '../../../core/network/api_result.dart';
import '../../../data/models/responses/offer.dart';

class SessionDetailsState extends Equatable {
  final ViewStatus status;
  final SessionDetailsModel? session;
  final ApiFailure<dynamic>? failure;

  const SessionDetailsState({
    this.status = ViewStatus.initial,
    this.session,
    this.failure,
  });

  @override
  List<Object?> get props => [status, session, failure];
}
