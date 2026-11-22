import 'package:equatable/equatable.dart';
import '../../../core/network/api_result.dart';

class ProfileState extends Equatable {
  /// One-shot: the last refresh failed (the screen toasts it, then calls
  /// [ProfileCubit.consumeFailure]).
  final ApiFailure<dynamic>? failure;

  const ProfileState({this.failure});

  @override
  List<Object?> get props => [failure];
}
