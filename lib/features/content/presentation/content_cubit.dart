import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_result.dart';
import '../domain/repositories/content_repository.dart';
import 'content_kind.dart';
import 'content_state.dart';

/// Loads one `AboutModel`: `aboutApp()`, `aboutUs()`, `terms()` or `policy()` of
/// `ProfileViewModel` (the four content fragments share it).
class ContentCubit extends Cubit<ContentState> {
  ContentCubit(this._profile, this.kind) : super(const ContentState());

  final ContentRepository _profile;
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
