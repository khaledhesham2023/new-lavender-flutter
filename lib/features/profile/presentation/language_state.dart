import 'package:equatable/equatable.dart';
import '../../../core/network/api_result.dart';

class LanguageState extends Equatable {
  /// `ar` or `en`.
  final String selected;
  final bool loading;

  /// One-shot: the language was applied (the sheet closes and the app goes to
  /// Home).
  final bool done;

  /// One-shot failure (toasted, then [LanguageCubit.consumeFailure]).
  final ApiFailure<dynamic>? failure;

  const LanguageState({
    required this.selected,
    this.loading = false,
    this.done = false,
    this.failure,
  });

  LanguageState copyWith({
    String? selected,
    bool? loading,
    bool? done,
    ApiFailure<dynamic>? failure,
    bool clearFailure = false,
  }) => LanguageState(
    selected: selected ?? this.selected,
    loading: loading ?? this.loading,
    done: done ?? this.done,
    failure: clearFailure ? null : (failure ?? this.failure),
  );

  @override
  List<Object?> get props => [selected, loading, done, failure];
}
