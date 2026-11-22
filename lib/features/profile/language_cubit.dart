import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_result.dart';
import '../../shared/session/session_cubit.dart';
import '../../data/repositories/profile_repository.dart';

class LanguageState extends Equatable {
  /// `ar` or `en`.
  final String selected;
  final bool loading;

  /// One-shot: the language was applied (the sheet closes and the app goes to
  /// Home).
  final bool done;

  /// One-shot failure (toasted, then [LanguageCubit.consumeFailure]).
  final ApiFailure<dynamic>? failure;

  const LanguageState({
    required this.selected,
    this.loading = false,
    this.done = false,
    this.failure,
  });

  LanguageState copyWith({
    String? selected,
    bool? loading,
    bool? done,
    ApiFailure<dynamic>? failure,
    bool clearFailure = false,
  }) => LanguageState(
    selected: selected ?? this.selected,
    loading: loading ?? this.loading,
    done: done ?? this.done,
    failure: clearFailure ? null : (failure ?? this.failure),
  );

  @override
  List<Object?> get props => [selected, loading, done, failure];
}

/// Port of `ChangeLanguageSheet` + `ProfileViewModel.changeLang`.
class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit(this._repository, this._session)
    : super(LanguageState(selected: _session.state.languageCode));

  final ProfileRepository _repository;
  final SessionCubit _session;

  void select(String code) {
    if (state.loading) return;
    emit(state.copyWith(selected: code));
  }

  /// A logged-in user tells the backend first (a failure keeps the sheet
  /// open); a guest only changes the app language.
  Future<void> confirm() async {
    if (state.loading) return;
    final code = state.selected;
    emit(state.copyWith(loading: true));
    if (_session.state.isLoggedIn) {
      final result = await _repository.changeLang(code);
      if (isClosed) return;
      if (result is ApiFailure) {
        emit(state.copyWith(loading: false, failure: result));
        return;
      }
    }
    await _session.changeLanguage(code);
    if (isClosed) return;
    emit(state.copyWith(loading: false, done: true));
  }

  void consumeFailure() => emit(state.copyWith(clearFailure: true));
}
