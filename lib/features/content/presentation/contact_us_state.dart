import 'package:equatable/equatable.dart';
import '../../../core/network/api_result.dart';

class ContactUsState extends Equatable {
  final bool sending;

  /// One-shot: the complaint was sent (the screen shows the success dialog).
  final bool sent;

  /// One-shot failure (toasted, then [ContactUsCubit.consumeEvent]).
  final ApiFailure<dynamic>? failure;

  const ContactUsState({this.sending = false, this.sent = false, this.failure});

  @override
  List<Object?> get props => [sending, sent, failure];
}
