import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/data/models/search.dart';

void main() {
  test('SearchResultsData with a null list', () {
    final s = SearchResultsData.fromJson({
      'doctors': [
        {'id': 1, 'name': 'Dr'},
      ],
      'specialties': null,
    });
    expect(s.doctors.single.name, 'Dr');
    expect(s.specialties, isEmpty);
  });

  test('RecentSearchModel', () {
    final r = RecentSearchModel.fromJson({'id': '3', 'search': 'skin'});
    expect(r.id, 3);
    expect(r.search, 'skin');
    expect(RecentSearchModel.fromJson({}).search, isNull);
  });
}
