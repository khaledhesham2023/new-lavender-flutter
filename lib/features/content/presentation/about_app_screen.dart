import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/di/injection.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/network/api_result.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/launchers.dart';
import '../../../core/widgets/app_link.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_svg.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/failure_toast.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/spacers.dart';
import '../../../core/widgets/system_ui.dart';
import '../../../data/models/responses/about.dart';
import '../domain/repositories/content_repository.dart';
import '../../../app/router/routes.dart';
import 'content_cubit.dart';
import '../../../core/widgets/app_top_bar.dart';
import 'widgets/html_content.dart';
import 'content_kind.dart';
import 'content_state.dart';

/// Port of `AboutFragment` (`fragment_about.xml`).
class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ContentCubit(sl<ContentRepository>(), ContentKind.aboutApp)..load(),
      child: const _AboutAppView(),
    );
  }
}

class _AboutAppView extends StatelessWidget {
  const _AboutAppView();

  /// Only these keys show an icon (the Android adapter hides any other).
  static const _socialKeys = [
    'facebook',
    'twitter',
    'x',
    'youtube',
    'instagram',
    'link',
  ];

  static String? _iconOf(String? key) => switch (key) {
    'facebook' => AppAssets.icFacebook,
    // The API may send the legacy key "twitter" or "x"; both show the X logo.
    'twitter' || 'x' => AppAssets.icXIcon,
    'youtube' => AppAssets.icYoutube,
    'instagram' => AppAssets.icInstagram,
    'link' => AppAssets.icShare,
    _ => null,
  };

  /// Android `openLink`: empty value → warning; no app to open it → warning.
  Future<void> _openLink(BuildContext context, String? url) async {
    final l10n = context.l10n;
    if (url == null || url.isEmpty) {
      AppToast.show(context, l10n.theLinkIsInvalidOrEmpty, ToastType.warning);
      return;
    }
    final opened = await openUrl(url);
    if (!opened && context.mounted) {
      AppToast.show(
        context,
        l10n.noSuitableAppFoundToOpenTheLink,
        ToastType.warning,
      );
    }
  }

  Widget _header(AboutModel? model) {
    final media = model?.image?.media;
    return SizedBox(
      height: 150,
      width: double.infinity,
      child: media == null
          ? const AppSvg(
              AppAssets.icAboutHeader,
              width: double.infinity,
              height: 150,
              fit: BoxFit.fill,
            )
          : AppNetworkImage(url: media, height: 150, fit: BoxFit.fill),
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
              final links = (model?.links ?? const <SocialLink>[])
                  .where((l) => _socialKeys.contains(l.key))
                  .toList();
              return Column(
                children: [
                  AppTopBar(title: l10n.aboutApp),
                  Expanded(
                    child: Stack(
                      children: [
                        // Hidden while loading or after an error.
                        Visibility(
                          visible: state.status == ViewStatus.success,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _header(model),
                                const VerticalSpacer(30),
                                Text(
                                  l10n.whatDoesTibiAppPresents,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.semiBold(
                                    16,
                                    AppColors.black,
                                  ),
                                ),
                                const VerticalSpacer(12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: HtmlContent(
                                    html: model?.name ?? '',
                                    center: true,
                                    style: AppTextStyles.regular(
                                      14,
                                      AppColors.c546881,
                                    ),
                                  ),
                                ),
                                const VerticalSpacer(163),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    for (final link in links)
                                      _SocialIcon(
                                        asset: _iconOf(link.key)!,
                                        onTap: () =>
                                            _openLink(context, link.value),
                                      ),
                                  ],
                                ),
                                const VerticalSpacer(22),
                                Text(
                                  l10n.allRightsReserved,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.semiBold(
                                    14,
                                    AppColors.c1A1A1E,
                                  ),
                                ),
                                const VerticalSpacer(12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    l10n.appProvides,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.regular(
                                      12,
                                      AppColors.black,
                                    ),
                                  ),
                                ),
                                const VerticalSpacer(40),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AppLink(
                                      text: l10n.termsOfUse,
                                      onTap: () => context.push(Routes.terms),
                                    ),
                                    const HorizontalSpacer(11),
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.cAAACAE,
                                      ),
                                    ),
                                    const HorizontalSpacer(11),
                                    AppLink(
                                      text: l10n.privacyPolicy,
                                      onTap: () => context.push(Routes.privacy),
                                    ),
                                  ],
                                ),
                                const VerticalSpacer(16),
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

/// `recycler_social_item.xml`: 40x41 icon with 12dp side margins.
class _SocialIcon extends StatelessWidget {
  final String asset;
  final VoidCallback onTap;
  const _SocialIcon({required this.asset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: AppSvg(asset, width: 40, height: 41),
      ),
    );
  }
}
