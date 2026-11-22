import 'package:equatable/equatable.dart';
import '../../../core/network/api_result.dart';
import '../../../data/models/responses/about.dart';

class ContentState extends Equatable {
  final ViewStatus status;
  final AboutModel? model;

  /// One-shot failure (toasted, then [ContentCubit.consumeFailure]).
  final ApiFailure<dynamic>? failure;

  const ContentState({
    this.status = ViewStatus.initial,
    this.model,
    this.failure,
  });

  bool get isLoading => status == ViewStatus.loading;

  @override
  List<Object?> get props => [status, model, failure];
}
