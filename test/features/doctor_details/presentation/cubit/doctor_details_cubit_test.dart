import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/network/api_result.dart';
import 'package:lavender/data/models/responses/doctor.dart';
import 'package:lavender/features/doctor_details/domain/repositories/doctor_repository.dart';
import 'package:lavender/features/doctor_details/presentation/cubit/doctor_details_cubit.dart';

class _FakeDoctorRepository implements DoctorRepository {
  ApiResult<DoctorModel> doctorResult = const ApiSuccess(DoctorModel(id: 7));
  ApiResult<void> favoriteResult = const ApiSuccess(null);
  final List<int> favoriteCalls = [];

  @override
  Future<ApiResult<DoctorModel>> getDoctor(int id) async => doctorResult;

  @override
  Future<ApiResult<void>> toggleFavorite(int id) async {
    favoriteCalls.add(id);
    return favoriteResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _day = WorkTimeModel(
  day: 'sat',
  dayTranslated: 'Saturday',
  date: '2025-03-08T00:00:00.000000Z',
  formatedDate: '08 March 2025',
  isActive: 1,
);
const _time = TimeModel(time: '10:00 AM', timeFormatted: '10:00');

void main() {
  late _FakeDoctorRepository repo;
  late DoctorDetailsCubit cubit;

  setUp(() {
    repo = _FakeDoctorRepository();
    cubit = DoctorDetailsCubit(repo, 7);
  });

  tearDown(() => cubit.close());

  test('load stores the doctor and its favorite flag', () async {
    repo.doctorResult = const ApiSuccess(DoctorModel(id: 7, isFav: true));
    await cubit.load();
    expect(cubit.state.status, ViewStatus.success);
    expect(cubit.state.doctor?.id, 7);
    expect(cubit.state.isFav, isTrue);
  });

  test('load failure keeps the failure', () async {
    repo.doctorResult = NetworkFailure();
    await cubit.load();
    expect(cubit.state.status, ViewStatus.failure);
    expect(cubit.state.failure, isA<NetworkFailure>());
  });

  test('load resets the selection', () async {
    await cubit.load();
    cubit.selectDay(_day);
    cubit.selectTime(_time);
    await cubit.load();
    expect(cubit.state.selectedDay, isNull);
    expect(cubit.state.selectedTime, isNull);
  });

  test('selecting another day clears the time', () async {
    await cubit.load();
    cubit.selectDay(_day);
    cubit.selectTime(_time);
    expect(cubit.state.selectedTime, _time);
    cubit.selectDay(_day);
    expect(cubit.state.selectedTime, isNull);
  });

  test('buildDraft is null before the doctor is loaded', () {
    expect(cubit.buildDraft(), isNull);
  });

  test('buildDraft copies the doctor and the selection', () async {
    repo.doctorResult = const ApiSuccess(
      DoctorModel(
        id: 7,
        name: 'Dr A',
        image: 'img',
        specialty: 'Dental',
        subSpecialty: 'Braces',
        stars: 4.5,
        rate: 4.6,
        reviewsCount: 12,
        duration: '30',
        price: '150.0',
      ),
    );
    await cubit.load();
    cubit.selectDay(_day);
    cubit.selectTime(_time);
    final draft = cubit.buildDraft()!;
    expect(draft.doctorId, 7);
    expect(draft.doctorName, 'Dr A');
    expect(draft.doctorImage, 'img');
    expect(draft.doctorSpecialization, 'Braces');
    expect(draft.stars, 4.5);
    expect(draft.rate, 4.6);
    expect(draft.reviewsCount, 12);
    expect(draft.duration, '30');
    expect(draft.examinationPrice, '150.0');
    expect(draft.day, 'Saturday');
    expect(draft.date, '2025-03-08T00:00:00.000000Z');
    expect(draft.formattedDate, '08 March 2025');
    expect(draft.time, '10:00');
    expect(draft.userOfferId, isNull);
  });

  test('buildDraft falls back to specialty without a sub specialty', () async {
    repo.doctorResult = const ApiSuccess(
      DoctorModel(id: 7, specialty: 'Dental'),
    );
    await cubit.load();
    expect(cubit.buildDraft()!.doctorSpecialization, 'Dental');
  });

  group('toggleFavorite', () {
    test('flips only after the request succeeded', () async {
      await cubit.load();
      final future = cubit.toggleFavorite();
      expect(cubit.state.isFav, isFalse, reason: 'not optimistic');
      await future;
      expect(cubit.state.isFav, isTrue);
      expect(repo.favoriteCalls, [7]);
      await cubit.toggleFavorite();
      expect(cubit.state.isFav, isFalse);
    });

    test('failure leaves the heart and exposes the failure', () async {
      await cubit.load();
      repo.favoriteResult = ServerFailure(500, 'boom');
      await cubit.toggleFavorite();
      expect(cubit.state.isFav, isFalse);
      expect(cubit.state.favoriteFailure, isA<ServerFailure>());
      cubit.consumeFavoriteFailure();
      expect(cubit.state.favoriteFailure, isNull);
    });
  });
}
