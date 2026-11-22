import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/di/injection.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../core/network/api_result.dart';
import '../../core/theme/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/failure_toast.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/state_view.dart';
import '../../core/widgets/system_ui.dart';
import '../../data/models/responses/speciality.dart';
import '../../data/repositories/specialities_repository.dart';
import '../../app/router/routes.dart';
import '../home/widgets/speciality_item.dart';
import 'all_specialities_cubit.dart';

/// Port of `AllSpecialitiesFragment`: 3-column grid of every speciality, opened
/// from Home ("show all" / "More").
class AllSpecialitiesScreen extends StatelessWidget {
  const AllSpecialitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AllSpecialitiesCubit(sl<SpecialitiesRepository>())..load(),
      child: const SystemUi(
        statusBarColor: AppColors.white,
        child: _AllSpecialitiesView(),
      ),
    );
  }
}

class _AllSpecialitiesView extends StatelessWidget {
  const _AllSpecialitiesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Header(),
            Expanded(
              child: BlocConsumer<AllSpecialitiesCubit, AllSpecialitiesState>(
                listenWhen: (prev, curr) =>
                    curr.failure is UnknownFailure &&
                    prev.failure != curr.failure,
                listener: (context, state) =>
                    showFailureToast(context, state.failure!),
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
                            onRetry: context.read<AllSpecialitiesCubit>().load,
                          ),
                          ServerFailure() => StateView.serverError(),
                          // Unknown failures are only toasted (Android falls to
                          // the server-error view; the task asks for a toast).
                          _ => const SizedBox.expand(),
                        },
                      );
                    case ViewStatus.success:
                      return _Grid(specialities: state.specialities);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Back arrow (36dp at 16/10), centered bold title and a 1dp separator.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 46,
          child: Stack(
            children: [
              PositionedDirectional(
                start: 16,
                top: 10,
                child: AppBackButton(
                  onTap: () => context.pop(),
                  size: 36,
                  boxSize: 36,
                ),
              ),
              PositionedDirectional(
                start: 16,
                end: 16,
                top: 18,
                child: Text(
                  context.l10n.allMedicalSpecialities,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bold(16, AppColors.c0F0102),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const SizedBox(height: 1, child: ColoredBox(color: AppColors.cE6E6E6)),
      ],
    );
  }
}

class _Grid extends StatelessWidget {
  static const int columns = 3;

  /// Tile height: 52 icon + 6 gap + 23 label + 16 bottom margin.
  static const double rowExtent = 97;

  final List<SpecialityModel> specialities;

  const _Grid({required this.specialities});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = buildAllSpecialities(specialities, l10n.medicalOffers);
    return GridView.builder(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        16,
        24,
        16,
        MediaQuery.paddingOf(context).bottom,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisExtent: rowExtent,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        final tile = i == 0
            ? SpecialityItem(
                speciality: item,
                asset: AppAssets.icGift,
                title: l10n.medicalOffers,
                onTap: () => context.push(Routes.offers),
              )
            : SpecialityItem(
                speciality: item,
                onTap: () => context.push(Routes.searchDetails, extra: item),
              );
        // Android item: 4dp end margin, 16dp bottom margin.
        return Padding(
          padding: const EdgeInsetsDirectional.only(end: 4, bottom: 16),
          child: Align(alignment: Alignment.topCenter, child: tile),
        );
      },
    );
  }
}
