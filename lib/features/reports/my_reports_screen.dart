import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/di/injection.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../core/network/api_result.dart';
import '../../core/theme/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/file_downloader.dart';
import '../../core/widgets/failure_toast.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/state_view.dart';
import '../../core/widgets/system_ui.dart';
import '../../core/widgets/toggle_header.dart';
import '../../core/enums/enums.dart';
import '../../data/models/responses/report.dart';
import 'domain/repositories/reports_repository.dart';
import 'my_reports_cubit.dart';
import 'widgets/report_day_group.dart';

/// Port of `MyReportsFragment` (`fragment_my_reports.xml`). Also the target of
/// `report` notifications (T39).
class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyReportsCubit(sl<ReportsRepository>())..load(),
      // Transparent status bar over the purple header, light icons.
      child: const SystemUi(statusBarIconsDark: false, child: _MyReportsView()),
    );
  }
}

class _MyReportsView extends StatelessWidget {
  const _MyReportsView();

  Widget _body(BuildContext context, MyReportsState state) {
    final cubit = context.read<MyReportsCubit>();
    switch (state.status) {
      case ViewStatus.initial:
      case ViewStatus.loading:
        return const LoadingView();
      case ViewStatus.failure:
        // Unknown failures are only toasted (Android `else` branch).
        return switch (state.failure) {
          NetworkFailure() => StateView.connectionLost(onRetry: cubit.load),
          ServerFailure() => const StateView.serverError(),
          _ => const SizedBox.expand(),
        };
      case ViewStatus.success:
        if (state.isEmpty) {
          return StateView.empty(
            icon: AppAssets.icEmptyReports,
            title: context.l10n.noReportsTitle,
            body: context.l10n.noReportsBody,
          );
        }
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          itemCount: state.days.length,
          itemBuilder: (context, i) => ReportDayGroup(
            day: state.days[i],
            onDownload: (report) => _download(context, report),
          ),
        );
    }
  }

  void _download(BuildContext context, ReportModel report) {
    final url = report.file;
    if (url == null || url.isEmpty) return;
    downloadFile(context, url: url, title: report.title ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocConsumer<MyReportsCubit, MyReportsState>(
        listenWhen: (prev, curr) =>
            curr.failure is UnknownFailure && prev.failure != curr.failure,
        listener: (context, state) => showFailureToast(context, state.failure!),
        builder: (context, state) {
          final cubit = context.read<MyReportsCubit>();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ToggleHeader(
                title: l10n.myReports,
                labels: [l10n.radiology, l10n.laboratory],
                selected: state.type.index,
                onChanged: (i) => cubit.select(ReportType.values[i]),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: cubit.refresh,
                  child: _body(context, state),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
