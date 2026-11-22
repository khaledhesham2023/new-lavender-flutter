import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_result.dart';
import '../../../../shared/session/session_cubit.dart';
import '../../../../data/models/requests/auth_requests.dart';
import '../../../../shared/domain/repositories/general_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import 'edit_profile_event.dart';
import 'edit_profile_state.dart';

/// Port of the Edit profile part of `ProfileViewModel`
/// (`getProfileData`, `uploadImage`, `updateProfile`, `changePhone`).
class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit(this._profile, this._general, this._session)
    : super(_initial(_session));

  final ProfileRepository _profile;
  final GeneralRepository _general;
  final SessionCubit _session;

  /// Starts from the stored user so the screen is filled before the request returns.
  static EditProfileState _initial(SessionCubit session) {
    final user = session.state.user;
    if (user == null) return const EditProfileState();
    return EditProfileState(
      name: user.name,
      email: user.email,
      phone: user.phone,
      phoneCode: user.phoneCode.isEmpty ? '966' : user.phoneCode,
      image: user.image,
    );
  }

  Future<void> load() async {
    final result = await _profile.getProfile();
    if (isClosed) return;
    switch (result) {
      case ApiFailure():
        emit(state.copyWith(failure: result));
      case ApiSuccess(:final data):
        await _session.updateUser(
          name: data.name,
          phone: data.phone,
          phoneCode: data.phoneCode,
          image: data.image,
          email: data.email,
        );
        if (isClosed) return;
        final code = data.phoneCode;
        emit(
          state.copyWith(
            name: data.name ?? '',
            email: data.email ?? '',
            phone: data.phone ?? '',
            phoneCode: (code == null || code.isEmpty) ? '966' : code,
            image: data.image ?? '',
            event: EditProfileEvent.loaded,
          ),
        );
    }
  }

  /// Shows [path] at once, then uploads it. The photo is applied on [save].
  Future<void> pickedImage(String path) async {
    emit(
      state.copyWith(
        localImage: () => path,
        uploadedImage: () => null,
        uploadingImage: true,
      ),
    );
    final result = await _general.uploadImage(path);
    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data):
        emit(state.copyWith(uploadingImage: false, uploadedImage: () => data));
      case ApiFailure():
        emit(
          state.copyWith(
            uploadingImage: false,
            localImage: () => null,
            failure: result,
          ),
        );
    }
  }

  void rejectImage() =>
      emit(state.copyWith(event: EditProfileEvent.invalidImage));

  Future<void> save(String name, String email) async {
    if (state.saving) return;
    emit(state.copyWith(saving: true));
    final result = await _profile.updateProfile(
      AuthRequest(
        fullName: name,
        image: state.uploadedImage,
        // Android sends the email only when it changed.
        email: email != state.email ? email : null,
      ),
    );
    if (isClosed) return;
    switch (result) {
      case ApiFailure():
        emit(state.copyWith(saving: false, failure: result));
      case ApiSuccess(:final data, :final message):
        await _session.updateUser(
          name: data?.name ?? name,
          email: data?.email ?? email,
          image: data?.image ?? state.uploadedImage,
        );
        if (isClosed) return;
        emit(
          state.copyWith(
            saving: false,
            event: EditProfileEvent.saved,
            message: message,
          ),
        );
    }
  }

  Future<void> changePhone(String phone) async {
    if (state.changingPhone) return;
    emit(state.copyWith(changingPhone: true));
    final result = await _profile.updatePhone(phone, state.apiPhoneCode);
    if (isClosed) return;
    switch (result) {
      case ApiFailure():
        emit(state.copyWith(changingPhone: false, failure: result));
      case ApiSuccess():
        emit(
          state.copyWith(
            changingPhone: false,
            event: EditProfileEvent.phoneCodeSent,
            newPhone: phone,
          ),
        );
    }
  }

  /// Called by the screen after it handled the event / failure.
  void consumeEvent() => emit(state.copyWith());
}
