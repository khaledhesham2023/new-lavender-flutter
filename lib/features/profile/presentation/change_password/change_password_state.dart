import 'package:equatable/equatable.dart';
import '../../../../core/network/api_result.dart';
import 'change_password_event.dart';

class ChangePasswordState extends Equatable {
  final bool saving;
  final bool sendingCode;
  final ChangePasswordEvent event;
  final ApiFailure<dynamic>? failure;

  const ChangePasswordState({
    this.saving = false,
    this.sendingCode = false,
    this.event = ChangePasswordEvent.none,
    this.failure,
  });

  @override
  List<Object?> get props => [saving, sendingCode, event, failure];
}
