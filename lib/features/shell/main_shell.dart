import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n/l10n_ext.dart';
import '../../core/session/session_cubit.dart';
import '../../core/theme/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_svg.dart';
import '../../router/routes.dart';

/// Scaffold around the five tabs (port of `activity_main.xml` + `MainActivity`).
/// Detail routes are top-level, so they cover this shell and hide the bar.
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  // (unselected, selected) per tab, from the *_selector.xml drawables.
  static const _icons = [
    (AppAssets.icHomeUnselected, AppAssets.icHomeActive),
    (AppAssets.icSearchInactive, AppAssets.icSearchActive),
    (AppAssets.icReserveInactive, AppAssets.icReserveActive),
    (AppAssets.icFavoritesInactive, AppAssets.icFavoritesActive),
    (AppAssets.icAccountInactive, AppAssets.icAccountActive),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final path = GoRouterState.of(context).uri.path;
    final index = Routes.tabs.indexOf(path);
    final labels = [
      l10n.home,
      l10n.search,
      l10n.bookings,
      l10n.favorites,
      l10n.account,
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (path != Routes.home) {
          context.go(Routes.home);
        } else if (context.read<SessionCubit>().state.isLoggedIn) {
          SystemNavigator.pop();
        } else {
          // Android opens Auth and finishes Main.
          context.go(Routes.authStart);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: child,
        bottomNavigationBar: _BottomBar(
          selected: index,
          labels: labels,
          icons: _icons,
          onTap: (i) {
            if (i == index) return;
            context.go(Routes.tabs[i]);
          },
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int selected;
  final List<String> labels;
  final List<(String, String)> icons;
  final ValueChanged<int> onTap;

  const _BottomBar({
    required this.selected,
    required this.labels,
    required this.icons,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.cCDFFFFFF,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border.all(color: AppColors.cF8F6FA),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              for (var i = 0; i < icons.length; i++)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppSvg(
                          i == selected ? icons[i].$2 : icons[i].$1,
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          labels[i],
                          maxLines: 1,
                          style: AppTextStyles.medium(
                            12,
                            i == selected
                                ? AppColors.primary
                                : AppColors.c7E94B0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
