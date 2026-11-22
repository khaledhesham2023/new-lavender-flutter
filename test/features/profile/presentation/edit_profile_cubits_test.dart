import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/shared/session/session_cubit.dart';
import 'package:lavender/core/storage/app_prefs.dart';
import 'package:lavender/shared/session/user_store.dart';
import 'package:lavender/data/models/requests/auth_requests.dart';
import 'package:lavender/data/models/responses/user.dart';
import 'package:lavender/shared/domain/repositories/auth_repository.dart';
import 'package:lavender/shared/domain/repositories/general_repository.dart';
import 'package:lavender/features/profile/domain/repositories/profile_repository.dart';
import 'package:lavender/features/profile/presentation/edit_profile/edit_profile_cubit.dart';
import 'package:lavender/features/profile/presentation/otp_change_phone/otp_change_phone_cubit.dart';
import 'package:lavender/app/router/route_args.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeProfileRepository implements ProfileRepository {
  ApiResult<UserModel> profileResult = const ApiSuccess(
    UserModel(
      name: 'Sara',
      email: 'sara@x.com',
      phone: '512345678',
      phoneCode: '966',
      image: 'img.png',
    ),
  );
  ApiResult<UserModel?> updateResult = const ApiSuccess(null, message: 'Saved');
  ApiResult<void> phoneResult = const ApiSuccess(null);
  final List<AuthRequest> updates = [];
  final List<(String, String)> phones = [];

  @override
  Future<ApiResult<UserModel>> getProfile() async => profileResult;

  @override
  Future<ApiResult<UserModel?>> updateProfile(AuthRequest request) async {
    updates.add(request);
    return updateResult;
  }

  @override
  Future<ApiResult<void>> updatePhone(String phone, String phoneCode) async {
    phones.add((phone, phoneCode));
    return phoneResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGeneralRepository implements GeneralRepository {
  ApiResult<String> uploadResult = const ApiSuccess('up.jpg');

  @override
  Future<ApiResult<String>> uploadImage(String filePath) async => uploadResult;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthRepository implements AuthRepository {
  ApiResult<UserModel?> verifyChangedResult = const ApiSuccess(null);
  ApiResult<UserModel?> verifyForgetResult = const ApiSuccess(null);
  ApiResult<UserModel?> resendResult = const ApiSuccess(null, message: 'Sent');
  final List<AuthRequest> changed = [];
  final List<AuthRequest> forget = [];
  final List<AuthRequest> resent = [];

  @override
  Future<ApiResult<UserModel?>> verifyChangedPhone(AuthRequest r) async {
    changed.add(r);
    return verifyChangedResult;
  }

  @override
  Future<ApiResult<UserModel?>> verifyForgetPassword(AuthRequest r) async {
    forget.add(r);
    return verifyForgetResult;
  }

  @override
  Future<ApiResult<UserModel?>> resendCode(AuthRequest r) async {
    resent.add(r);
    return resendResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<SessionCubit> _session() async {
  SharedPreferences.setMockInitialValues({});
  final sp = await SharedPreferences.getInstance();
  final prefs = AppPrefs(sp);
  final session = SessionCubit(prefs, UserStore(sp));
  await session.onAuthenticated(
    const UserModel(
      id: 1,
      name: 'Old',
      email: 'old@x.com',
      phone: '500000000',
      phoneCode: '966',
      token: 't',
    ),
  );
  return session;
}

void main() {
  group('EditProfileCubit', () {
    late _FakeProfileRepository profile;
    late _FakeGeneralRepository general;
    late SessionCubit session;
    late EditProfileCubit cubit;

    setUp(() async {
      profile = _FakeProfileRepository();
      general = _FakeGeneralRepository();
      session = await _session();
      cubit = EditProfileCubit(profile, general, session);
    });

    test('starts from the stored user', () {
      expect(cubit.state.name, 'Old');
      expect(cubit.state.phone, '500000000');
      expect(cubit.state.apiPhoneCode, '966');
    });

    test('load fills the state and the session', () async {
      await cubit.load();
      expect(cubit.state.name, 'Sara');
      expect(cubit.state.email, 'sara@x.com');
      expect(cubit.state.event, EditProfileEvent.loaded);
      expect(session.state.user!.name, 'Sara');
    });

    test('load failure is reported', () async {
      profile.profileResult = const NetworkFailure();
      await cubit.load();
      expect(cubit.state.failure, isA<NetworkFailure<dynamic>>());
    });

    test('pickedImage keeps the uploaded name and the local preview', () async {
      await cubit.pickedImage('/tmp/a.jpg');
      expect(cubit.state.localImage, '/tmp/a.jpg');
      expect(cubit.state.uploadedImage, 'up.jpg');
      expect(cubit.state.uploadingImage, isFalse);
      // a fresh upload makes Save available without a text change
      expect(cubit.state.canSave('Old', 'old@x.com'), isTrue);
    });

    test('failed upload drops the preview and reports the failure', () async {
      general.uploadResult = const NetworkFailure();
      await cubit.pickedImage('/tmp/a.jpg');
      expect(cubit.state.localImage, isNull);
      expect(cubit.state.uploadedImage, isNull);
      expect(cubit.state.failure, isA<NetworkFailure<dynamic>>());
    });

    test('canSave only when something changed', () {
      expect(cubit.state.canSave('Old', 'old@x.com'), isFalse);
      expect(cubit.state.canSave('New', 'old@x.com'), isTrue);
      expect(cubit.state.canSave('Old', 'new@x.com'), isTrue);
    });

    test('save sends the image, the email only when changed, then stores it', () async {
      await cubit.pickedImage('/tmp/a.jpg');
      await cubit.save('New name', 'old@x.com');
      expect(profile.updates.single.fullName, 'New name');
      expect(profile.updates.single.image, 'up.jpg');
      expect(profile.updates.single.email, isNull);
      expect(cubit.state.event, EditProfileEvent.saved);
      expect(cubit.state.message, 'Saved');
      expect(session.state.user!.name, 'New name');
      expect(session.state.user!.image, 'up.jpg');
    });

    test('save sends a changed email', () async {
      await cubit.save('Old', 'new@x.com');
      expect(profile.updates.single.email, 'new@x.com');
    });

    test('save failure keeps the screen', () async {
      profile.updateResult = const ServerFailure(422, 'bad');
      await cubit.save('Old', 'old@x.com');
      expect(cubit.state.saving, isFalse);
      expect(cubit.state.failure, isA<ServerFailure<dynamic>>());
      expect(cubit.state.event, EditProfileEvent.none);
    });

    test('changePhone asks for the code with the account code', () async {
      await cubit.changePhone('511111111');
      expect(profile.phones.single, ('511111111', '966'));
      expect(cubit.state.event, EditProfileEvent.phoneCodeSent);
      expect(cubit.state.newPhone, '511111111');
    });

    test('changePhone failure is reported', () async {
      profile.phoneResult = const ServerFailure(422, 'taken');
      await cubit.changePhone('511111111');
      expect(cubit.state.changingPhone, isFalse);
      expect(cubit.state.failure, isA<ServerFailure<dynamic>>());
    });
  });

  group('OtpChangePhoneCubit', () {
    late _FakeAuthRepository auth;
    late SessionCubit session;

    OtpChangePhoneCubit make(OtpDestination d) => OtpChangePhoneCubit(
      auth,
      session,
      OtpArgs(phone: '511111111', phoneCode: '+966', fromDestination: d),
    );

    setUp(() async {
      auth = _FakeAuthRepository();
      session = await _session();
    });

    test('edit profile: verifies, stores the new phone', () async {
      final cubit = make(OtpDestination.editProfile);
      await cubit.verify('1234');
      expect(auth.changed.single.otp, '1234');
      expect(auth.changed.single.phone, '511111111');
      expect(auth.changed.single.phoneCode, '966');
      expect(cubit.state.event, OtpChangePhoneEvent.phoneChanged);
      expect(session.state.user!.phone, '511111111');
      await cubit.close();
    });

    test('forgot password from profile: goes on with the code', () async {
      final cubit = make(OtpDestination.editProfileAddNewPassword);
      await cubit.verify('1234');
      expect(auth.forget.single.otp, '1234');
      expect(auth.changed, isEmpty);
      expect(cubit.state.event, OtpChangePhoneEvent.navigateNewPassword);
      expect(cubit.state.otp, '1234');
      await cubit.close();
    });

    test('server answer shows the inline code error, no toast', () async {
      auth.verifyChangedResult = const ServerFailure(422, 'wrong');
      final cubit = make(OtpDestination.editProfile);
      await cubit.verify('0000');
      expect(cubit.state.codeError, isTrue);
      expect(cubit.state.failure, isNull);
      expect(cubit.state.loading, isFalse);
      await cubit.close();
    });

    test('connection problem toasts and keeps the line hidden', () async {
      auth.verifyChangedResult = const NetworkFailure();
      final cubit = make(OtpDestination.editProfile);
      await cubit.verify('0000');
      expect(cubit.state.codeError, isFalse);
      expect(cubit.state.failure, isA<NetworkFailure<dynamic>>());
      await cubit.close();
    });
  });
}
