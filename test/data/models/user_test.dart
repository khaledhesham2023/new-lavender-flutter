import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/data/models/user.dart';

void main() {
  test('UserModel parses mixed types and nested objects', () {
    final u = UserModel.fromJson({
      'id': '12',
      'name': 'Sara',
      'phone': 512345678,
      'is_ban': 0,
      'is_verified': '1',
      'allow_notification': true,
      'unread_notifications': '3',
      'country': {'id': 1, 'name': 'KSA', 'phone_number_limit': '9'},
      'city': {'id': 4, 'name': 'Riyadh'},
      'token': 'abc',
    });
    expect(u.id, 12);
    expect(u.phone, '512345678');
    expect(u.isBan, false);
    expect(u.isVerified, true);
    expect(u.allowNotification, true);
    expect(u.unreadNotifications, 3);
    expect(u.country!.phoneNumberLimit, 9);
    expect(u.city!.name, 'Riyadh');
    expect(u.email, isNull);
    expect(u.isCompletedData, isNull);
  });

  test('CountryModel defaults apply when keys are missing', () {
    final c = CountryModel.fromJson({'id': 1});
    expect(c.showPhoneCode, '+966');
    expect(c.phoneNumberLimit, 9);
    expect(c.prefix, ['5']);
    final d = CountryModel.fromJson({
      'show_phone_code': '+20',
      'phone_number_limit': 10,
      'prefix': ['10', '11'],
    });
    expect(d.showPhoneCode, '+20');
    expect(d.phoneNumberLimit, 10);
    expect(d.prefix, ['10', '11']);
  });

  test('AuthRequest.toJson omits nulls and uses backend keys', () {
    const r = AuthRequest(
      phone: '512345678',
      phoneCode: '+966',
      fullName: 'Sara',
      passwordConfirmation: 'x',
      termsAndConditions: 1,
    );
    expect(r.toJson(), {
      'phone': '512345678',
      'phone_code': '+966',
      'full_name': 'Sara',
      'password_confirmation': 'x',
      'terms_and_conditions': 1,
    });
    expect(const AuthRequest().toJson(), isEmpty);
  });

  test('equality', () {
    expect(const CityModel(id: 1, name: 'a'), const CityModel(id: 1, name: 'a'));
  });
}
