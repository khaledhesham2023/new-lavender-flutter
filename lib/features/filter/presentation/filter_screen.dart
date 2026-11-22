import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lavender/core/widgets/spacers.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/di/injection.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/network/api_result.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_svg.dart';
import '../../../core/widgets/failure_toast.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/state_view.dart';
import '../../../core/widgets/system_ui.dart';
import '../../../core/enums/enums.dart';
import '../../../shared/domain/repositories/search_repository.dart';
import '../../../app/router/route_args.dart';
import 'filter_cubit.dart';
import 'subspecialties_sheet.dart';

/// Port of `FilterFragment`: price range, doctor gender and subspecialties.
/// Pops the edited `SearchFilter` on "Show results" and nothing on back.
class FilterScreen extends StatelessWidget {
  final FilterArgs args;

  const FilterScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FilterCubit(sl<SearchRepository>(), args)..load(),
      child: const SystemUi(child: _FilterView()),
    );
  }
}

class _FilterView extends StatelessWidget {
  const _FilterView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FilterCubit>();
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: BlocListener<FilterCubit, FilterState>(
          listenWhen: (prev, curr) =>
              curr.failure is UnknownFailure && prev.failure != curr.failure,
          listener: (context, state) =>
              showFailureToast(context, state.failure!),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // "Remove all" only makes sense once the filter content shows.
              BlocSelector<FilterCubit, FilterState, bool>(
                selector: (s) => s.status == ViewStatus.success,
                builder: (context, loaded) =>
                    _Header(onReset: loaded ? cubit.reset : null),
              ),
              Expanded(
                child: BlocBuilder<FilterCubit, FilterState>(
                  buildWhen: (prev, curr) =>
                      prev.status != curr.status ||
                      prev.failure != curr.failure,
                  builder: (context, state) {
                    switch (state.status) {
                      case ViewStatus.initial:
                      case ViewStatus.loading:
                        return const LoadingView();
                      case ViewStatus.failure:
                        return switch (state.failure) {
                          NetworkFailure() => StateView.connectionLost(
                            onRetry: cubit.load,
                          ),
                          ServerFailure() => const StateView.serverError(),
                          // Unknown failures are only toasted.
                          _ => const SizedBox.expand(),
                        };
                      case ViewStatus.success:
                        return const _Content();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  /// Null hides "Remove all" (loading / error states).
  final VoidCallback? onReset;

  const _Header({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(
            start: 16,
            end: 16,
            top: 10,
          ),
          child: Row(
            children: [
              AppBackButton(onTap: () => context.pop(), size: 36, boxSize: 36),
              const HorizontalSpacer(16),
              Expanded(
                child: Text(
                  context.l10n.filterBy,
                  style: AppTextStyles.bold(16, AppColors.c0F0102),
                ),
              ),
              if (onReset != null)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onReset,
                  child: Text(
                    context.l10n.removeAll,
                    style: AppTextStyles.medium(14, AppColors.c47586E),
                  ),
                ),
            ],
          ),
        ),
        const VerticalSpacer(10),
        const Divider(height: 1, thickness: 1, color: AppColors.cD6D6D6),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    final hasPrice = context.select<FilterCubit, bool>(
      (c) => c.state.hasPriceRange,
    );
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _SubSpecialtiesSection(),
                const _Separator(),
                const _GenderSection(),
                if (hasPrice) ...[const _Separator(), const _PriceSection()],
                const VerticalSpacer(16),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: AppButton(
            text: context.l10n.showResults,
            onPressed: () =>
                context.pop(context.read<FilterCubit>().state.filter),
          ),
        ),
      ],
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 30, 16, 0),
      child: Divider(height: 1, thickness: 1, color: AppColors.cD9DBE9),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTextStyles.semiBold(14, AppColors.c251836));
}

class _SubSpecialtiesSection extends StatelessWidget {
  const _SubSpecialtiesSection();

  Future<void> _choose(BuildContext context) async {
    final cubit = context.read<FilterCubit>();
    final result = await showSubSpecialtiesSheet(
      context,
      all: cubit.state.allSubSpecialties,
      selected: cubit.state.filter.subSpecialties,
    );
    if (result != null) cubit.setSubSpecialties(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<FilterCubit, FilterState>(
      buildWhen: (prev, curr) =>
          prev.filter.subSpecialties != curr.filter.subSpecialties ||
          prev.data != curr.data,
      builder: (context, state) {
        final all = state.allSubSpecialties;
        final selected = state.filter.subSpecialties;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle(l10n.subSpecialties),
                        if (selected.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              all.isEmpty
                                  ? l10n.noSubspecialtiesBody
                                  : l10n.chooseSubSpecialities,
                              style: AppTextStyles.medium(
                                12,
                                AppColors.c3D4C5E,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (all.isNotEmpty)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _choose(context),
                      child: AppSvg(AppAssets.icArrowLeft),
                    ),
                ],
              ),
              if (selected.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final item in selected) _Chip(item.name ?? ''),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// `recycler_item_sub_specialities`: rounded (19) lilac pill.
class _Chip extends StatelessWidget {
  final String text;

  const _Chip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.only(end: 10, bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.cF8F6FA,
        border: Border.all(color: AppColors.cE9E3F0),
        borderRadius: BorderRadius.circular(19),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: AppTextStyles.medium(12, AppColors.c3D4C5E),
      ),
    );
  }
}

class _GenderSection extends StatelessWidget {
  const _GenderSection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<FilterCubit>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 29, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(l10n.gender),
          const VerticalSpacer(16),
          BlocSelector<FilterCubit, FilterState, String?>(
            selector: (s) => s.filter.gender,
            builder: (context, gender) => Row(
              children: [
                _GenderOption(
                  label: l10n.doctorM,
                  selected: gender == GenderType.male.value,
                  onTap: () => cubit.setGender(GenderType.male.value),
                ),
                const SizedBox(width: 32),
                _GenderOption(
                  label: l10n.doctorF,
                  selected: gender == GenderType.female.value,
                  onTap: () => cubit.setGender(GenderType.female.value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSvg(
            selected ? AppAssets.icCheckBoxTrue : AppAssets.icCheckBoxFalse,
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 10),
          Text(label, style: AppTextStyles.semiBold(14, AppColors.black)),
        ],
      ),
    );
  }
}

class _PriceSection extends StatelessWidget {
  const _PriceSection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<FilterCubit>();
    final min = cubit.state.minPrice;
    final max = cubit.state.maxPrice;
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SectionTitle(l10n.examinationPrice),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 53,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(AppAssets.icBgRangeSlider, fit: BoxFit.fill),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child:
                      BlocSelector<FilterCubit, FilterState, RangeValuesPair>(
                        selector: (s) => s.priceValues,
                        builder: (context, values) => SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 6,
                            activeTrackColor: AppColors.primary,
                            inactiveTrackColor: AppColors.cD9DBE9,
                            rangeThumbShape: const _RingThumbShape(),
                            showValueIndicator: ShowValueIndicator.onDrag,
                            valueIndicatorColor: AppColors.primary,
                            valueIndicatorTextStyle: AppTextStyles.medium(
                              12,
                              AppColors.white,
                            ),
                          ),
                          child: RangeSlider(
                            min: min,
                            max: max,
                            values: RangeValues(values.$1, values.$2),
                            labels: RangeLabels(
                              l10n.sar(values.$1.toInt().toString()),
                              l10n.sar(values.$2.toInt().toString()),
                            ),
                            onChanged: (v) =>
                                cubit.setPriceRange(v.start, v.end),
                          ),
                        ),
                      ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.priceWithValue(min.toInt().toString()),
                  style: AppTextStyles.medium(14, AppColors.c3D4C5E),
                ),
                Text(
                  l10n.priceWithValue(max.toInt().toString()),
                  style: AppTextStyles.medium(14, AppColors.c3D4C5E),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// `range_slider_custom_thumb`: 24dp white disc with an 8dp primary ring.
class _RingThumbShape extends RangeSliderThumbShape {
  const _RingThumbShape();

  static const double _size = 24;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size(_size, _size);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool? isOnTop,
    required SliderThemeData sliderTheme,
    TextDirection? textDirection,
    Thumb? thumb,
    bool? isPressed,
  }) {
    final canvas = context.canvas;
    canvas.drawCircle(center, _size / 2, Paint()..color = AppColors.white);
    canvas.drawCircle(
      center,
      _size / 2 - 4,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );
  }
}
