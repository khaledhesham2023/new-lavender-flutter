import 'package:equatable/equatable.dart';
import '../../../core/network/api_result.dart';

class GeneralState extends Equatable {
  final bool loading;

  /// One-shot: the account was logged out / deleted (the sheet closes and the
  /// app goes to the Start screen).
  final bool done;

  /// One-shot failure (toasted, then [GeneralCubit.consumeFailure]).
  final ApiFailure<dynamic>? failure;

  const GeneralState({this.loading = false, this.done = false, this.failure});

  @override
  List<Object?> get props => [loading, done, failure];
}
