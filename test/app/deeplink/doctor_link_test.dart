import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/app/deeplink/doctor_link.dart';

void main() {
  int? id(String url) => parseDoctorId(Uri.parse(url));

  test('reads the id of /doctor/<id>', () {
    expect(id('https://lavander.doha.aait-d.com/doctor/12'), 12);
    expect(id('https://lavander.doha.aait-d.com/doctor/12/'), 12);
    expect(id('http://lavander.doha.aait-d.com/doctor/7?x=1'), 7);
  });

  test('anything else is null', () {
    expect(id('https://lavander.doha.aait-d.com/doctor'), isNull);
    expect(id('https://lavander.doha.aait-d.com/doctor/abc'), isNull);
    expect(id('https://lavander.doha.aait-d.com/'), isNull);
    expect(id('https://lavander.doha.aait-d.com/doctors/1'), isNull);
  });

  test('regex is unanchored like Android: a prefix before /doctor/ still matches', () {
    expect(id('https://lavander.doha.aait-d.com/x/doctor/5'), 5);
  });
}
