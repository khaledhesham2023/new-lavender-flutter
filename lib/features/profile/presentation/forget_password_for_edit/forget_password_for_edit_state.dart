import 'package:equatable/equatable.dart';
import '../../../../core/network/api_result.dart';
import 'forget_password_for_edit_event.dart';

class ForgetPasswordForEditState extends Equatable {
  final bool loading;
  final ForgetPasswordForEditEvent event;
  final ApiFailure<dynamic>? failure;

  const ForgetPasswordForEditState({
    this.loading = false,
    this.event = ForgetPasswordForEditEvent.none,
    this.failure,
  });

  @override
  List<Object?> get props => [loading, event, failure];
}
