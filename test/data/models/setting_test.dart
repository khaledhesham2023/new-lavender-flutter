import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/data/models/setting.dart';

void main() {
  test('SettingModel', () {
    final s = SettingModel.fromJson({
      'allow_notification': 1,
      'whats_app_number': 966500000000,
    });
    expect(s.allowNotification, true);
    expect(s.whatsAppNumber, '966500000000');
    expect(SettingModel.fromJson({}).allowNotification, isNull);
  });
}
