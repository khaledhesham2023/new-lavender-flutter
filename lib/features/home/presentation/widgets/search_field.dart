import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:lavender/app/router/routes.dart';
import 'package:lavender/core/l10n/l10n_ext.dart';
import 'package:lavender/core/theme/app_assets.dart';
import 'package:lavender/core/theme/app_colors.dart';
import 'package:lavender/core/theme/app_text_styles.dart';
import 'package:lavender/core/widgets/app_svg.dart';
import 'package:lavender/core/widgets/spacers.dart';

/// Read-only search box: opens the Search tab.
class SearchBox extends StatelessWidget {
  const SearchBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.go(Routes.search),
        child: Container(
          height: 50,
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.cFAFAFA,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cE6E6E6),
          ),
          child: Row(
            children: [
              const AppSvg(AppAssets.icSearch, width: 20, height: 20),
              const HorizontalSpacer(10),
              Expanded(
                child: Text(
                  context.l10n.searchBySpecialityOrDoctor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.medium(12, AppColors.c666666),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}