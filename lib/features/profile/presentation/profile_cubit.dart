import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_result.dart';
import '../../../shared/session/session_cubit.dart';
import '../domain/repositories/profile_repository.dart';
import 'profile_state.dart';

/// Port of `ProfileViewModel.getProfileData`: re-reads the profile and stores it
/// in the session. The header itself reads the user from [SessionCubit].
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repository, this._session) : super(const ProfileState());

  final ProfileRepository _repository;
  final SessionCubit _session;

  /// Called every time the tab is shown (Android `onResume`). Guests have no
  /// profile, so nothing is requested.
  Future<void> refresh() async {
    if (!_session.state.isLoggedIn) return;
    final result = await _repository.getProfile();
    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data):
        await _session.updateUser(
          name: data.name,
          phone: data.phone,
          phoneCode: data.phoneCode,
          image: data.image,
          email: data.email,
        );
      case ApiFailure():
        emit(ProfileState(failure: result));
    }
  }

  void consumeFailure() => emit(const ProfileState());
}
