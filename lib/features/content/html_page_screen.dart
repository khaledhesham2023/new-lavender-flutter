import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/di/injection.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_network_image.dart';
import '../../core/widgets/failure_toast.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/spacers.dart';
import '../../core/widgets/system_ui.dart';
import '../../data/repositories/profile_repository.dart';
import 'content_cubit.dart';
import '../../core/widgets/app_top_bar.dart';
import 'widgets/html_content.dart';

/// Port of `TermsOfUseFragment` and `PrivacyPolicyFragment`: header and HTML body.
/// Terms are plain text under the bar; Privacy adds the 229dp image above the text.
class HtmlPageScreen extends StatelessWidget {
  final ContentKind kind;

  const HtmlPageScreen({super.key, required this.kind})
    : assert(kind == ContentKind.terms || kind == ContentKind.privacy);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ContentCubit(sl<ProfileRepository>(), kind)..load(),
      child: _HtmlPageView(kind: kind),
    );
  }
}

class _HtmlPageView extends StatelessWidget {
  final ContentKind kind;
  const _HtmlPageView({required this.kind});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isPrivacy = kind == ContentKind.privacy;
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
              return Column(
                children: [
                  AppTopBar(
                    title: isPrivacy
                        ? l10n.privacyPolicy
                        : l10n.termsOfUseTitle,
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (isPrivacy) ...[
                                  const VerticalSpacer(4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: AppNetworkImage(
                                      url: model?.image?.media,
                                      height: 229,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ],
                                const VerticalSpacer(8),
                                HtmlContent(
                                  html: model?.name ?? '',
                                  style: isPrivacy
                                      ? AppTextStyles.medium(
                                          14,
                                          AppColors.c60717F,
                                        )
                                      : AppTextStyles.regular(
                                          14,
                                          AppColors.black,
                                        ),
                                ),
                              ],
                            ),
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
