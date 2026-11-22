import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/di/injection.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../core/network/api_result.dart';
import '../../shared/session/session_cubit.dart';
import '../../core/theme/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/spacers.dart';
import '../../core/widgets/app_svg.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/state_view.dart';
import '../../core/widgets/system_ui.dart';
import '../../shared/domain/repositories/search_repository.dart';
import '../../app/router/routes.dart';
import 'search_cubit.dart';
import 'widgets/most_selected_list.dart';
import 'widgets/recent_searches_list.dart';
import 'widgets/search_results_view.dart';

/// Port of `LastSearchFragment` (the Search tab).
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchCubit(
        sl<SearchRepository>(),
        isLoggedIn: context.read<SessionCubit>().state.isLoggedIn,
      )..showMostSelected(),
      child: const SystemUi(
        statusBarColor: AppColors.white,
        child: _SearchView(),
      ),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> with WidgetsBindingObserver {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  late final SearchCubit _cubit = context.read<SearchCubit>();
  String _lastText = '';
  bool _keyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller.addListener(_onControllerChanged);
    _focus.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  /// Fires for typing and for `controller.text = ...` (a tapped recent search);
  /// selection-only changes are ignored.
  void _onControllerChanged() {
    final text = _controller.text;
    if (text == _lastText) return;
    _lastText = text;
    _cubit.onTextChanged(text, hasFocus: _focus.hasFocus);
  }

  void _onFocusChanged() {
    if (_focus.hasFocus) _cubit.onFocusGained(_controller.text);
  }

  /// Android's global-layout keyboard listener: when the keyboard closes the
  /// field loses focus.
  @override
  void didChangeMetrics() {
    if (!mounted) return;
    final visible = View.of(context).viewInsets.bottom > 0;
    final closed = _keyboardVisible && !visible;
    _keyboardVisible = visible;
    if (closed) {
      _cubit.onKeyboardClosed(_controller.text);
      _focus.unfocus();
    }
  }

  void _goBack() {
    _focus.unfocus();
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // The shell takes the pop (goes Home); this only drops the focus first.
      onPopInvokedWithResult: (didPop, _) => _focus.unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _SearchField(
                        controller: _controller,
                        focusNode: _focus,
                        hint: context.l10n.searchBySpecialityOrDoctor,
                      ),
                    ),
                    const HorizontalSpacer(10),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _goBack,
                      child: Text(
                        context.l10n.cancel,
                        style: AppTextStyles.semiBold(14, AppColors.c1A0304),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _Body(onRecentTap: (text) => _controller.text = text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final ValueChanged<String> onRecentTap;

  const _Body({required this.onRecentTap});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SearchCubit>();
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        switch (state.status) {
          case ViewStatus.initial:
          case ViewStatus.loading:
            return const LoadingView();
          case ViewStatus.failure:
            return Padding(
              padding: const EdgeInsets.only(top: 20),
              child: switch (state.failure) {
                NetworkFailure() => StateView.connectionLost(
                  onRetry: cubit.showMostSelected,
                ),
                _ => const StateView.serverError(),
              },
            );
          case ViewStatus.success:
            return switch (state.mode) {
              SearchMode.mostSelected => MostSelectedList(
                items: state.mostSelected,
                onTap: (item) {
                  // Android compares the display name with the localized label.
                  if (item.name == context.l10n.medicalOffers) {
                    context.push(Routes.offers);
                  } else {
                    context.push(Routes.searchDetails, extra: item);
                  }
                },
              ),
              SearchMode.recent =>
                state.recent.isEmpty
                    ? const TrySearchView()
                    : RecentSearchesList(
                        items: state.recent,
                        onTap: (item) => onRecentTap(item.search ?? ''),
                        onRemoveAll: cubit.clearRecent,
                      ),
              SearchMode.results => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SearchResultsView(
                  results: state.results,
                  onSpeciality: (s) =>
                      context.push(Routes.searchDetails, extra: s),
                  onDoctor: (d) {
                    final id = d.id;
                    if (id != null) context.push(Routes.doctorDetailsOf(id));
                  },
                ),
              ),
            };
        }
      },
    );
  }
}

/// `etSearch`: 50dp, grey fill, 1dp stroke, 16dp radius, search icon at the
/// start. Debouncing is the cubit's job.
class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;

  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.cE6E6E6),
    );
    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        maxLines: 1,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.search,
        style: AppTextStyles.medium(12, AppColors.c251836),
        cursorColor: AppColors.c251836,
        cursorWidth: 2,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.medium(12, AppColors.c666666),
          filled: true,
          fillColor: AppColors.cFAFAFA,
          contentPadding: const EdgeInsetsDirectional.only(start: 16, end: 16),
          prefixIcon: const Padding(
            padding: EdgeInsetsDirectional.only(start: 16, end: 10),
            child: AppSvg(AppAssets.icSearch),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          enabledBorder: border,
          focusedBorder: border,
        ),
      ),
    );
  }
}
