import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/responses/user.dart';
import '../storage/app_prefs.dart';
import '../storage/user_store.dart';

class SessionState extends Equatable {
  final bool isLoggedIn;
  final String languageCode;
  final UserData? user;

  const SessionState({
    this.isLoggedIn = false,
    this.languageCode = 'ar',
    this.user,
  });

  @override
  List<Object?> get props => [isLoggedIn, languageCode, user];
}

/// App-wide session: login state, language and the stored user.
class SessionCubit extends Cubit<SessionState> {
  SessionCubit(this._prefs, this._userStore)
      : super(SessionState(
          isLoggedIn: _prefs.isLoggedIn,
          languageCode: _prefs.languageCode,
          user: _userStore.read(),
        ));

  final AppPrefs _prefs;
  final UserStore _userStore;

  /// Android's verified-login save (`AuthViewModel.login` / `verifyPhone`).
  Future<void> onAuthenticated(UserModel user) async {
    final language = user.lang ?? 'ar';
    final data = UserData.fromUserModel(user);
    await _prefs.setLoggedIn(true);
    await _prefs.setBearerToken(user.token ?? '');
    await _prefs.setFirstTime(false);
    await _userStore.save(data);
    await _prefs.setLanguageCode(language);
    await _prefs.setAllowNotifications(user.allowNotification ?? false);
    emit(SessionState(isLoggedIn: true, languageCode: language, user: data));
  }

  Future<void> onLoggedOut() async {
    await _prefs.clearForLogout();
    await _userStore.clear();
    emit(const SessionState());
  }

  Future<void> changeLanguage(String code) async {
    await _prefs.setLanguageCode(code);
    emit(SessionState(
      isLoggedIn: state.isLoggedIn,
      languageCode: code,
      user: state.user,
    ));
  }

  Future<void> updateUser({
    String? name,
    String? phone,
    String? phoneCode,
    String? image,
    String? email,
  }) async {
    await _userStore.updateFields(
      name: name,
      phone: phone,
      phoneCode: phoneCode,
      image: image,
      email: email,
    );
    emit(SessionState(
      isLoggedIn: state.isLoggedIn,
      languageCode: state.languageCode,
      user: _userStore.read(),
    ));
  }
}
