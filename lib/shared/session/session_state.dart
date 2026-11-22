import 'package:equatable/equatable.dart';
import 'user_store.dart';

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
