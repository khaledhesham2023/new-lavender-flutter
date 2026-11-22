import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_result.dart';
import '../../../shared/domain/repositories/search_repository.dart';
import 'search_mode.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit(
    this._repository, {
    required this.isLoggedIn,
    this.debounce = const Duration(milliseconds: 500),
  }) : super(const SearchState());

  final SearchRepository _repository;
  final bool isLoggedIn;
  final Duration debounce;

  Timer? _timer;

  /// Bumped on every request so a slow, superseded response is dropped.
  int _requestId = 0;

  Future<void> showMostSelected() async {
    final id = ++_requestId;
    emit(
      state.copyWith(
        mode: SearchMode.mostSelected,
        status: ViewStatus.loading,
        clearFailure: true,
      ),
    );
    final result = await _repository.mostSelected();
    if (isClosed || id != _requestId) return;
    switch (result) {
      case ApiSuccess(:final data):
        emit(state.copyWith(status: ViewStatus.success, mostSelected: data));
      case ApiFailure():
        emit(state.copyWith(status: ViewStatus.failure, failure: result));
    }
  }

  /// Guests never see recent searches.
  Future<void> showRecent() async {
    if (!isLoggedIn) return;
    final id = ++_requestId;
    emit(
      state.copyWith(
        mode: SearchMode.recent,
        status: ViewStatus.loading,
        clearFailure: true,
      ),
    );
    final result = await _repository.recent();
    if (isClosed || id != _requestId) return;
    switch (result) {
      case ApiSuccess(:final data):
        emit(state.copyWith(status: ViewStatus.success, recent: data));
      case ApiFailure():
        emit(state.copyWith(status: ViewStatus.failure, failure: result));
    }
  }

  Future<void> search(String text) async {
    final id = ++_requestId;
    emit(
      state.copyWith(
        mode: SearchMode.results,
        status: ViewStatus.loading,
        clearFailure: true,
      ),
    );
    final result = await _repository.search(text);
    if (isClosed || id != _requestId) return;
    switch (result) {
      case ApiSuccess(:final data):
        emit(state.copyWith(status: ViewStatus.success, results: data));
      case ApiFailure():
        emit(state.copyWith(status: ViewStatus.failure, failure: result));
    }
  }

  /// "Remove all": afterwards the empty "try searching" view shows.
  Future<void> clearRecent() async {
    final id = ++_requestId;
    emit(
      state.copyWith(
        mode: SearchMode.recent,
        status: ViewStatus.loading,
        clearFailure: true,
      ),
    );
    final result = await _repository.clearRecent();
    if (isClosed || id != _requestId) return;
    switch (result) {
      case ApiSuccess():
        emit(state.copyWith(status: ViewStatus.success, recent: const []));
      case ApiFailure():
        emit(state.copyWith(status: ViewStatus.failure, failure: result));
    }
  }

  /// The search field gained focus: logged in + empty field -> recent searches.
  void onFocusGained(String text) {
    if (isLoggedIn && text.trim().isEmpty) showRecent();
  }

  void onTextChanged(String text, {required bool hasFocus}) {
    _timer?.cancel();
    if (text.trim().isNotEmpty) {
      _timer = Timer(debounce, () => search(text));
      return;
    }
    if (isLoggedIn && hasFocus) {
      showRecent();
    } else {
      showMostSelected();
    }
  }

  /// The keyboard closed: a pending search is dropped and, with a blank field,
  /// the most selected specialities show again.
  void onKeyboardClosed(String text) {
    _timer?.cancel();
    if (text.trim().isNotEmpty) return;
    if (state.mostSelected.isEmpty) {
      showMostSelected();
      return;
    }
    // Invalidate any in-flight recent/search request.
    _requestId++;
    emit(
      state.copyWith(
        mode: SearchMode.mostSelected,
        status: ViewStatus.success,
        clearFailure: true,
      ),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
