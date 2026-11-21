import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/data/models/responses/about.dart';
import 'package:lavender/data/repositories/profile_repository.dart';
import 'package:lavender/features/content/contact_us_cubit.dart';
import 'package:lavender/features/content/content_cubit.dart';

class _FakeProfileRepository implements ProfileRepository {
  ApiResult<AboutModel> aboutResult = const ApiSuccess(
    AboutModel(name: '<p>hello</p>'),
  );
  ApiResult<void> contactResult = const ApiSuccess(null);
  final List<String> calls = [];
  final List<(String, String, String)> contacts = [];

  @override
  Future<ApiResult<AboutModel>> aboutApp() async {
    calls.add('aboutApp');
    return aboutResult;
  }

  @override
  Future<ApiResult<AboutModel>> aboutUs() async {
    calls.add('aboutUs');
    return aboutResult;
  }

  @override
  Future<ApiResult<AboutModel>> terms() async {
    calls.add('terms');
    return aboutResult;
  }

  @override
  Future<ApiResult<AboutModel>> policy() async {
    calls.add('policy');
    return aboutResult;
  }

  @override
  Future<ApiResult<void>> contactUs({
    required String fullName,
    required String title,
    required String content,
  }) async {
    contacts.add((fullName, title, content));
    return contactResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('ContentCubit', () {
    test('each kind calls its own endpoint', () async {
      final repo = _FakeProfileRepository();
      for (final kind in ContentKind.values) {
        await ContentCubit(repo, kind).load();
      }
      expect(repo.calls, ['aboutApp', 'aboutUs', 'terms', 'policy']);
    });

    test('load keeps the model on success', () async {
      final cubit = ContentCubit(_FakeProfileRepository(), ContentKind.terms);
      await cubit.load();
      expect(cubit.state.status, ViewStatus.success);
      expect(cubit.state.model!.name, '<p>hello</p>');
    });

    test('a failure is reported once and keeps an earlier model', () async {
      final repo = _FakeProfileRepository();
      final cubit = ContentCubit(repo, ContentKind.aboutApp);
      await cubit.load();
      repo.aboutResult = const NetworkFailure();
      await cubit.load();
      expect(cubit.state.failure, isA<NetworkFailure<dynamic>>());
      expect(cubit.state.model, isNotNull);
      cubit.consumeFailure();
      expect(cubit.state.failure, isNull);
    });
  });

  group('ContactUsCubit', () {
    test('send trims the texts and reports success', () async {
      final repo = _FakeProfileRepository();
      final cubit = ContactUsCubit(repo);
      await cubit.send('  Sara ', ' Help ', ' Please  ');
      expect(repo.contacts.single, ('Sara', 'Help', 'Please'));
      expect(cubit.state.sent, isTrue);
      expect(cubit.state.sending, isFalse);
    });

    test('a failure is reported', () async {
      final repo = _FakeProfileRepository()
        ..contactResult = const ServerFailure(422, 'bad');
      final cubit = ContactUsCubit(repo);
      await cubit.send('Sara', 'Help', 'Please');
      expect(cubit.state.failure, isA<ServerFailure<dynamic>>());
      expect(cubit.state.sent, isFalse);
    });
  });
}
