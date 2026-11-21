import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_result.dart';
import '../../core/session/session_cubit.dart';
import '../../core/storage/app_prefs.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/profile_repository.dart';

/// Which confirmation the general sheet shows.
enum GeneralType { logout, deleteAccount }

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

/// Port of the `Logout` / `DeleteAccount` events of `ProfileViewModel`.
class GeneralCubit extends Cubit<GeneralState> {
  GeneralCubit(
    this._type,
    this._auth,
    this._profile,
    this._session,
    this._prefs,
  ) : super(const GeneralState());

  final GeneralType _type;
  final AuthRepository _auth;
  final ProfileRepository _profile;
  final SessionCubit _session;
  final AppPrefs _prefs;

  Future<void> confirm() async {
    if (state.loading) return;
    emit(const GeneralState(loading: true));
    final result = switch (_type) {
      // Logout sends `device_token` in the body.
      GeneralType.logout => await _auth.logout(_prefs.deviceToken),
      GeneralType.deleteAccount => await _profile.deleteAccount(),
    };
    if (isClosed) return;
    switch (result) {
      case ApiSuccess():
        // Clears the stored session; language goes back to Arabic.
        await _session.onLoggedOut();
        if (isClosed) return;
        emit(const GeneralState(done: true));
      case ApiFailure():
        emit(GeneralState(failure: result));
    }
  }

  void consumeFailure() => emit(const GeneralState());
}
