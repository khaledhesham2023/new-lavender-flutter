import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/data/models/responses/about.dart';
import 'package:lavender/features/content/data/repositories/content_repository_impl.dart';

import '../../../../data/repositories/fake_api.dart';

void main() {
  test('contactUs uses query params and no body', () async {
    final (api, a) = await makeApi(body: {'message': 'thanks'});
    final r = await ContentRepositoryImpl(api)
        .contactUs(fullName: 'Sara', title: 'Hi', content: 'Hello');
    expect(a.method, 'POST');
    expect(a.path, 'client/contact');
    expect(a.query, {'full_name': 'Sara', 'title': 'Hi', 'content': 'Hello'});
    expect(a.data, isNull);
    expect((r as ApiSuccess<void>).message, 'thanks');
  });

  test('about pages hit their own paths and parse AboutModel', () async {
    final (api, a) = await makeApi(
      body: {
        'data': {'id': 1, 'name': '<p>x</p>'},
      },
    );
    final repo = ContentRepositoryImpl(api);
    final calls = {
      'client/about': repo.aboutUs,
      'client/about-app': repo.aboutApp,
      'client/term': repo.terms,
      'client/policy': repo.policy,
    };
    for (final e in calls.entries) {
      final r = await e.value();
      expect(a.method, 'GET');
      expect(a.path, e.key);
      expect((r as ApiSuccess<AboutModel>).data.name, '<p>x</p>');
    }
  });
}
