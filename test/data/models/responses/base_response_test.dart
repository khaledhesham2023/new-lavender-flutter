import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/data/models/responses/base_response.dart';

void main() {
  test('PaginationMeta and PaginationLinks', () {
    final m = PaginationMeta.fromJson({
      'current_page': 1,
      'last_page': '3',
      'per_page': 10,
      'total': '25',
      'from': null,
    });
    expect(m.currentPage, 1);
    expect(m.lastPage, 3);
    expect(m.total, 25);
    expect(m.from, isNull);
    final l = PaginationLinks.fromJson({'first': 'a', 'next': 'b', 'prev': null});
    expect(l.next, 'b');
    expect(l.prev, isNull);
    expect(l.last, isNull);
  });
}
