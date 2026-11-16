import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/data/models/speciality.dart';

void main() {
  test('SpecialityModel defaults', () {
    final s = SpecialityModel.fromJson({'id': '3', 'name': 'Derma'});
    expect(s.id, 3);
    expect(s.appointmentsCount, 0);
    expect(s.image, isNull);
    expect(SpecialityModel.fromJson({'id': 1, 'appointments_count': '4'}).appointmentsCount, 4);
  });

  test('FilterData parses prices and sub specialties', () {
    final f = FilterData.fromJson({
      'max_price': '500.00',
      'min_price': 50,
      'specialties': [
        {'id': 1, 'name': 'A', 'image': 'i'},
        {'id': 2, 'name': 'B'},
      ],
    });
    expect(f.maxPrice, 500.0);
    expect(f.minPrice, 50.0);
    expect(f.specialties.length, 2);
    expect(f.specialties[1].image, isNull);
    expect(FilterData.fromJson({'specialties': null}).specialties, isEmpty);
  });

  test('DoctorsBySpecialityData', () {
    final d = DoctorsBySpecialityData.fromJson({
      'count': '2',
      'doctors': [
        {'id': 1},
        {'id': 2},
      ],
    });
    expect(d.count, 2);
    expect(d.doctors.length, 2);
  });
}
