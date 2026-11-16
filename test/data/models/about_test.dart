import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/data/models/about.dart';

void main() {
  test('AboutModel parses image, links and images', () {
    final a = AboutModel.fromJson({
      'id': 1,
      'name': '<p>Hello</p>',
      'image': {'id': 1, 'media': 'http://x/a.png'},
      'links': [
        {'id': 1, 'key': 'facebook', 'value': 'http://fb'},
      ],
      'images': null,
    });
    expect(a.name, '<p>Hello</p>');
    expect(a.image!.media, 'http://x/a.png');
    expect(a.links.single.key, 'facebook');
    expect(a.images, isEmpty);
  });
}
