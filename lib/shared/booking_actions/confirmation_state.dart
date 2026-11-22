import 'package:equatable/equatable.dart';

import '../../core/network/api_result.dart';

class ConfirmationState extends Equatable {
  final bool loading;

  /// Set after a failed confirm; the sheet toasts it and stays open.
  final ApiFailure<dynamic>? failure;

  /// True once the action succeeded; the sheet then pops with `true`.
  final bool done;

  const ConfirmationState({
    this.loading = false,
    this.failure,
    this.done = false,
  });

  @override
  List<Object?> get props => [loading, failure, done];
}
