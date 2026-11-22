import 'package:equatable/equatable.dart';

import '../../core/network/api_result.dart';
import '../../data/models/responses/appointment.dart';

class AddCommentState extends Equatable {
  final List<QuickComment> quickComments;
  final bool loadingQuickComments;
  final double rate;
  final bool sending;

  /// Server message after a successful send; the sheet toasts it and pops.
  final String? sentMessage;
  final ApiFailure<dynamic>? failure;

  const AddCommentState({
    this.quickComments = const [],
    this.loadingQuickComments = false,
    this.rate = 0,
    this.sending = false,
    this.sentMessage,
    this.failure,
  });

  AddCommentState copyWith({
    List<QuickComment>? quickComments,
    bool? loadingQuickComments,
    double? rate,
    bool? sending,
    String? sentMessage,
    ApiFailure<dynamic>? failure,
    bool clearFailure = false,
  }) => AddCommentState(
    quickComments: quickComments ?? this.quickComments,
    loadingQuickComments: loadingQuickComments ?? this.loadingQuickComments,
    rate: rate ?? this.rate,
    sending: sending ?? this.sending,
    sentMessage: sentMessage ?? this.sentMessage,
    failure: clearFailure ? null : (failure ?? this.failure),
  );

  @override
  List<Object?> get props => [
    quickComments,
    loadingQuickComments,
    rate,
    sending,
    sentMessage,
    failure,
  ];
}
