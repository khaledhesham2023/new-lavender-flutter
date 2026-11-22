import 'package:equatable/equatable.dart';
import '../../../../core/network/api_result.dart';
import 'new_password_event.dart';

class NewPasswordState extends Equatable {
  final ViewStatus status;
  final ApiFailure<dynamic>? failure;
  final NewPasswordEvent event;

  const NewPasswordState({
    this.status = ViewStatus.initial,
    this.failure,
    this.event = NewPasswordEvent.none,
  });

  bool get isLoading => status == ViewStatus.loading;

  @override
  List<Object?> get props => [status, failure, event];
}
