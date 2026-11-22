import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_result.dart';
import '../domain/repositories/content_repository.dart';

class ContactUsState extends Equatable {
  final bool sending;

  /// One-shot: the complaint was sent (the screen shows the success dialog).
  final bool sent;

  /// One-shot failure (toasted, then [ContactUsCubit.consumeEvent]).
  final ApiFailure<dynamic>? failure;

  const ContactUsState({this.sending = false, this.sent = false, this.failure});

  @override
  List<Object?> get props => [sending, sent, failure];
}

/// Port of the `ContactUs` event of `ProfileViewModel`.
class ContactUsCubit extends Cubit<ContactUsState> {
  ContactUsCubit(this._profile) : super(const ContactUsState());

  final ContentRepository _profile;

  /// The three texts are trimmed, like Android.
  Future<void> send(String fullName, String title, String content) async {
    if (state.sending) return;
    emit(const ContactUsState(sending: true));
    final result = await _profile.contactUs(
      fullName: fullName.trim(),
      title: title.trim(),
      content: content.trim(),
    );
    if (isClosed) return;
    switch (result) {
      case ApiSuccess():
        emit(const ContactUsState(sent: true));
      case ApiFailure():
        emit(ContactUsState(failure: result));
    }
  }

  void consumeEvent() => emit(const ContactUsState());
}
