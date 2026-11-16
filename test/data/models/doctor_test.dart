import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/data/models/doctor.dart';

void main() {
  final json = <String, dynamic>{
    'id': 7,
    'name': 'Dr. Ali',
    'price': 150.0,
    'duration': '30',
    'experience': 12,
    'rate': '4.5',
    'stars': 4,
    'five': 3,
    'is_fav': 1,
    'reviews_count': '2',
    'reviews': [
      {
        'id': 1,
        'rate': 5,
        'created_at': '2024-01-01',
        'comment': 'Great',
        'client_name': 'Sara',
      },
    ],
    'work_times': [
      {
        'day': 'sunday',
        'day_translated': 'الأحد',
        'is_active': '1',
        'times': [
          {'time': '10:00 AM', 'is_reserved': 0, 'time_formatted': '10:00:00'},
          {'time': '10:30 AM', 'is_reserved': true, 'time_formatted': '10:30:00'},
        ],
      },
    ],
    'certificates': [
      {'id': 1, 'media': 'http://x/c.png'},
    ],
    'user_offers': null,
    // sub_specialty missing
  };

  test('DoctorModel parses string numbers and keeps String types', () {
    final d = DoctorModel.fromJson(json);
    expect(d.id, 7);
    expect(d.price, '150.0');
    expect(d.duration, '30');
    expect(d.experience, '12');
    expect(d.rate, 4.5);
    expect(d.stars, 4.0);
    expect(d.five, 3.0);
    expect(d.four, isNull);
    expect(d.isFav, true);
    expect(d.reviewsCount, 2);
    expect(d.reviews.single.date, '2024-01-01');
    expect(d.reviews.single.rate, 5.0);
    expect(d.workTimes.single.isActive, 1);
    expect(d.workTimes.single.dayTranslated, 'الأحد');
    expect(d.workTimes.single.times[0].isReserved, false);
    expect(d.workTimes.single.times[1].isReserved, true);
    expect(d.workTimes.single.times[0].timeFormatted, '10:00:00');
    expect(d.certificates.single.media, 'http://x/c.png');
  });

  test('null list and missing keys give defaults', () {
    final d = DoctorModel.fromJson(json);
    expect(d.userOffers, isEmpty);
    expect(d.subSpecialty, isNull);
    expect(d.doctorWorkTimesDays, isEmpty);
    final e = DoctorModel.fromJson({});
    expect(e.isFav, false);
    expect(e.workTimes, isEmpty);
    expect(WorkTimeModel.fromJson({}).isActive, 0);
  });

  test('copyWith(isFav)', () {
    final d = DoctorModel.fromJson(json);
    final f = d.copyWith(isFav: false);
    expect(f.isFav, false);
    expect(f.name, d.name);
    expect(f.reviews, d.reviews);
    expect(d.copyWith(), d);
  });

  test('ToggleFavoriteRequest sends doctor_id as String', () {
    expect(const ToggleFavoriteRequest(5).toJson(), {'doctor_id': '5'});
  });
}
