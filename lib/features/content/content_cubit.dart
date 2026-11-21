import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_result.dart';
import '../../data/models/responses/about.dart';
import '../../data/repositories/profile_repository.dart';

/// Which server page a [ContentCubit] loads.
enum ContentKind { aboutApp, aboutUs, terms, privacy }

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

/// Loads one `AboutModel`: `aboutApp()`, `aboutUs()`, `terms()` or `policy()` of
/// `ProfileViewModel` (the four content fragments share it).
class ContentCubit extends Cubit<ContentState> {
  ContentCubit(this._profile, this.kind) : super(const ContentState());

  final ProfileRepository _profile;
  final ContentKind kind;

  Future<void> load() async {
    if (state.isLoading) return;
    emit(ContentState(status: ViewStatus.loading, model: state.model));
    final result = switch (kind) {
      ContentKind.aboutApp => await _profile.aboutApp(),
      ContentKind.aboutUs => await _profile.aboutUs(),
      ContentKind.terms => await _profile.terms(),
      ContentKind.privacy => await _profile.policy(),
    };
    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data):
        emit(ContentState(status: ViewStatus.success, model: data));
      case ApiFailure():
        emit(
          ContentState(
            status: ViewStatus.failure,
            model: state.model,
            failure: result,
          ),
        );
    }
  }

  void consumeFailure() =>
      emit(ContentState(status: state.status, model: state.model));
}
