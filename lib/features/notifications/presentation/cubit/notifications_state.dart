part of 'notifications_cubit.dart';

class NotificationsState extends Equatable {
  /// The "allow notifications" switch (initialized from the stored value).
  final bool allowed;

  /// A toggle request is in flight.
  final bool toggling;

  /// One-shot: the toggle failed and the switch was put back (the screen
  /// toasts it, then calls [NotificationsCubit.consumeToggleFailure]).
  final ApiFailure<dynamic>? toggleFailure;

  const NotificationsState({
    required this.allowed,
    this.toggling = false,
    this.toggleFailure,
  });

  @override
  List<Object?> get props => [allowed, toggling, toggleFailure];
}
