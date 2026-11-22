import 'package:equatable/equatable.dart';
import '../../../../core/network/api_result.dart';
import 'forget_password_event.dart';

class ForgetPasswordState extends Equatable {
  final ViewStatus status;
  final ApiFailure<dynamic>? failure;
  final ForgetPasswordEvent event;

  const ForgetPasswordState({
    this.status = ViewStatus.initial,
    this.failure,
    this.event = ForgetPasswordEvent.none,
  });

  bool get isLoading => status == ViewStatus.loading;

  @override
  List<Object?> get props => [status, failure, event];
}
