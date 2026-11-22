import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/di/injection.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/failure_toast.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/spacers.dart';
import '../../../core/widgets/system_ui.dart';
import '../../../data/models/responses/about.dart';
import '../domain/repositories/content_repository.dart';
import 'content_cubit.dart';
import '../../../core/widgets/app_top_bar.dart';
import 'widgets/html_content.dart';
import 'content_kind.dart';
import 'content_state.dart';

/// Port of `AboutUsFragment` (`fragment_about_us.xml`).
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ContentCubit(sl<ContentRepository>(), ContentKind.aboutUs)..load(),
      child: const _AboutUsView(),
    );
  }
}

class _AboutUsView extends StatelessWidget {
  const _AboutUsView();

  Widget _card(AboutImage image, {double? width, required double height}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AppNetworkImage(
        url: image.media,
        width: width,
        height: height,
        fit: BoxFit.fill,
      ),
    );
  }

  /// Up to 3 images: the first is the big card at the end, the next two are the small
  /// cards stacked at the start. Unused slots are hidden (a lone image fills the row).
  Widget _images(List<AboutImage> all) {
    final images = all.take(3).toList();
    if (images.isEmpty) return const SizedBox.shrink();
    final big = _card(images[0], height: 163);
    if (images.length == 1) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: SizedBox(width: double.infinity, child: big),
      );
    }
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _card(images[1], width: 113, height: 77),
              if (images.length > 2) ...[
                const VerticalSpacer(9),
                _card(images[2], width: 113, height: 77),
              ],
            ],
          ),
          const HorizontalSpacer(9),
          Expanded(child: big),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SystemUi(
      statusBarColor: AppColors.white,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: BlocConsumer<ContentCubit, ContentState>(
            listener: (context, state) {
              if (state.failure != null) {
                showFailureToast(context, state.failure!);
                context.read<ContentCubit>().consumeFailure();
              }
            },
            builder: (context, state) {
              final model = state.model;
              final hasImages = model?.images.isNotEmpty ?? false;
              return Column(
                children: [
                  AppTopBar(title: l10n.whoWeAre),
                  Expanded(
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _images(model?.images ?? const []),
                              VerticalSpacer(hasImages ? 12 : 20),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                child: HtmlContent(
                                  html: model?.name ?? '',
                                  style: AppTextStyles.regular(
                                    14,
                                    AppColors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (state.isLoading) const LoadingView(),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
