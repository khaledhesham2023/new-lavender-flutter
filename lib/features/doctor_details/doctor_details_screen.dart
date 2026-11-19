import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/config/env.dart';
import '../../core/di/injection.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../core/network/api_result.dart';
import '../../core/session/session_cubit.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/failure_toast.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/must_login_sheet.dart';
import '../../core/widgets/state_view.dart';
import '../../core/widgets/system_ui.dart';
import '../../data/repositories/doctor_repository.dart';
import '../../router/routes.dart';
import '../booking/widgets/day_time_picker.dart';
import 'doctor_details_cubit.dart';
import 'widgets/detail_tabs.dart';
import 'widgets/doctor_header.dart';
import 'widgets/info_tab.dart';
import 'widgets/reviews_tab.dart';

/// Port of `DoctorDetailsFragment`: header, three custom tabs (Booking time /
/// Info / Reviews, no swipe) and the "Book an appointment" button.
class DoctorDetailsScreen extends StatelessWidget {
  final int doctorId;

  const DoctorDetailsScreen({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          DoctorDetailsCubit(sl<DoctorRepository>(), doctorId)..load(),
      child: const SystemUi(child: _DoctorDetailsView()),
    );
  }
}

class _DoctorDetailsView extends StatefulWidget {
  const _DoctorDetailsView();

  @override
  State<_DoctorDetailsView> createState() => _DoctorDetailsViewState();
}

class _DoctorDetailsViewState extends State<_DoctorDetailsView> {
  int _tab = 0;

  void _book(BuildContext context) {
    final cubit = context.read<DoctorDetailsCubit>();
    if (!context.read<SessionCubit>().state.isLoggedIn) {
      showMustLoginSheet(context);
      return;
    }
    final state = cubit.state;
    final l10n = context.l10n;
    if (state.selectedDay == null) {
      AppToast.show(context, l10n.pleaseSelectDay, ToastType.failed);
    } else if (state.selectedTime == null) {
      AppToast.show(context, l10n.pleaseSelectTime, ToastType.failed);
    } else if (state.doctor?.userOffers.isNotEmpty ?? false) {
      // T25: appointment type sheet (for now go straight to book appointment).
      context.push(Routes.bookAppointment, extra: cubit.buildDraft());
    } else {
      context.push(Routes.bookAppointment, extra: cubit.buildDraft());
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DoctorDetailsCubit>();
    final isLoggedIn = context.watch<SessionCubit>().state.isLoggedIn;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<DoctorDetailsCubit, DoctorDetailsState>(
          listenWhen: (prev, curr) =>
              curr.favoriteFailure != null &&
              prev.favoriteFailure != curr.favoriteFailure,
          listener: (context, state) {
            showFailureToast(context, state.favoriteFailure!);
            cubit.consumeFavoriteFailure();
          },
          builder: (context, state) {
            final doctor = state.doctor;
            final loaded = state.status == ViewStatus.success && doctor != null;
            return Column(
              children: [
                DoctorTopBar(
                  onBack: () => context.pop(),
                  onShare: loaded
                      ? () => SharePlus.instance.share(
                          ShareParams(
                            text: '${Env.hostUrl}/doctor/${doctor.id ?? 0}',
                          ),
                        )
                      : null,
                  onHeart: loaded && isLoggedIn ? cubit.toggleFavorite : null,
                  isFav: state.isFav,
                ),
                Expanded(
                  child: switch (state.status) {
                    ViewStatus.initial ||
                    ViewStatus.loading => const LoadingView(),
                    ViewStatus.failure => Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: state.failure is NetworkFailure
                          ? StateView.connectionLost(onRetry: cubit.load)
                          : const StateView.serverError(),
                    ),
                    ViewStatus.success => Column(
                      children: [
                        DoctorHeader(doctor: doctor!),
                        DetailTabs(
                          index: _tab,
                          onChanged: (i) => setState(() => _tab = i),
                        ),
                        Expanded(
                          child: IndexedStack(
                            index: _tab,
                            children: [
                              DayTimePicker(
                                days: doctor.workTimes,
                                selectedDay: state.selectedDay,
                                selectedTime: state.selectedTime,
                                onDayChanged: cubit.selectDay,
                                onTimeChanged: cubit.selectTime,
                              ),
                              InfoTab(doctor: doctor),
                              ReviewsTab(doctor: doctor),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            border: Border.fromBorderSide(
                              BorderSide(color: AppColors.cE6E6E6),
                            ),
                          ),
                          child: SafeArea(
                            top: false,
                            child: AppButton(
                              text: context.l10n.bookAnAppointment,
                              onPressed: () => _book(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
