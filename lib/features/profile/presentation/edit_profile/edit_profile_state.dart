import 'package:equatable/equatable.dart';
import '../../../../core/network/api_result.dart';
import 'edit_profile_event.dart';

class EditProfileState extends Equatable {
  /// Values as stored on the server (the "unchanged" baseline).
  final String name;
  final String email;
  final String phone;
  final String phoneCode;
  final String image;

  /// Picked photo, shown at once; null when none was picked.
  final String? localImage;

  /// Name returned by the upload, sent with the next update.
  final String? uploadedImage;

  final bool uploadingImage;
  final bool saving;
  final bool changingPhone;

  final EditProfileEvent event;
  final ApiFailure<dynamic>? failure;
  final String message;
  final String newPhone;

  const EditProfileState({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.phoneCode = '966',
    this.image = '',
    this.localImage,
    this.uploadedImage,
    this.uploadingImage = false,
    this.saving = false,
    this.changingPhone = false,
    this.event = EditProfileEvent.none,
    this.failure,
    this.message = '',
    this.newPhone = '',
  });

  /// Keeps every value; the one-shot fields (event, failure, message, newPhone)
  /// reset unless given.
  EditProfileState copyWith({
    String? name,
    String? email,
    String? phone,
    String? phoneCode,
    String? image,
    String? Function()? localImage,
    String? Function()? uploadedImage,
    bool? uploadingImage,
    bool? saving,
    bool? changingPhone,
    EditProfileEvent event = EditProfileEvent.none,
    ApiFailure<dynamic>? failure,
    String message = '',
    String newPhone = '',
  }) {
    return EditProfileState(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      phoneCode: phoneCode ?? this.phoneCode,
      image: image ?? this.image,
      localImage: localImage != null ? localImage() : this.localImage,
      uploadedImage: uploadedImage != null
          ? uploadedImage()
          : this.uploadedImage,
      uploadingImage: uploadingImage ?? this.uploadingImage,
      saving: saving ?? this.saving,
      changingPhone: changingPhone ?? this.changingPhone,
      event: event,
      failure: failure,
      message: message,
      newPhone: newPhone,
    );
  }

  /// Android enables Save when the name or email differs; a freshly uploaded photo
  /// also counts, otherwise it could never be saved on its own.
  bool canSave(String name, String email) =>
      !saving &&
      !uploadingImage &&
      (name != this.name || email != this.email || uploadedImage != null);

  /// Code as the API wants it (`966`, no plus).
  String get apiPhoneCode =>
      phoneCode.startsWith('+') ? phoneCode.substring(1) : phoneCode;

  @override
  List<Object?> get props => [
    name,
    email,
    phone,
    phoneCode,
    image,
    localImage,
    uploadedImage,
    uploadingImage,
    saving,
    changingPhone,
    event,
    failure,
    message,
    newPhone,
  ];
}
