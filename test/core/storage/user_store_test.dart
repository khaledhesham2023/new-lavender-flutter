import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/storage/user_store.dart';
import 'package:lavender/data/models/responses/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<UserStore> _make() async {
  SharedPreferences.setMockInitialValues({});
  return UserStore(await SharedPreferences.getInstance());
}

void main() {
  const user = UserData(
    id: 7,
    name: 'Ali',
    email: 'a@b.c',
    phone: '555',
    phoneCode: '966',
    lang: 'en',
    countryId: 1,
    countryName: 'KSA',
    cityId: 2,
    cityName: 'Riyadh',
  );

  test('read is null when empty', () async {
    expect((await _make()).read(), isNull);
  });

  test('save/read round trip and clear', () async {
    final s = await _make();
    await s.save(user);
    expect(s.read(), user);
    await s.clear();
    expect(s.read(), isNull);
  });

  test('updateFields changes only non-null values', () async {
    final s = await _make();
    await s.save(user);
    await s.updateFields(name: 'Omar', image: 'img.png');
    final r = s.read()!;
    expect(r.name, 'Omar');
    expect(r.image, 'img.png');
    expect(r.email, 'a@b.c');
    expect(r.phone, '555');
    expect(r.cityName, 'Riyadh');
  });

  test('fromUserModel maps nulls to defaults', () {
    final d = UserData.fromUserModel(const UserModel());
    expect(d.id, 0);
    expect(d.name, '');
    expect(d.lang, 'ar');
    expect(d.allowNotification, true);
    expect(d.isVerified, false);
    expect(d.countryId, 0);
  });

  test('fromUserModel maps country and city', () {
    final d = UserData.fromUserModel(const UserModel(
      id: 3,
      isVerified: true,
      country: CountryModel(id: 9, name: 'KSA', phoneCode: '966'),
      city: CityModel(id: 4, name: 'Jeddah'),
    ));
    expect(d.id, 3);
    expect(d.isVerified, true);
    expect(d.countryName, 'KSA');
    expect(d.countryPhoneCode, '966');
    expect(d.cityName, 'Jeddah');
  });
}
