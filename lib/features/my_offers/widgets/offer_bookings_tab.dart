import 'package:go_router/go_router.dart';
import 'package:lavender/core/widgets/spacers.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_svg.dart';
import '../../../data/models/responses/offer.dart';
import '../../../app/router/routes.dart';
import 'offer_session_card.dart';

/// "Bookings" tab of My offer details (`MyOfferBookingsFragment`): the offer's
/// appointments, or the empty view. A tap opens the session details.
class OfferBookingsTab extends StatelessWidget {
  final OfferModel offer;

  const OfferBookingsTab({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final appointments = offer.appointments;
    if (appointments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppSvg(AppAssets.icNoReviews, width: 70, height: 70),
            const VerticalSpacer(16),
            Text(
              context.l10n.noReservations,
              textAlign: TextAlign.center,
              style: AppTextStyles.bold(12, AppColors.c251836),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          for (var i = 0; i < appointments.length; i++)
            OfferSessionCard(
              item: appointments[i],
              position: i,
              onTap: () => context.push(
                Routes.sessionDetailsOf(appointments[i].id ?? 0),
              ),
            ),
        ],
      ),
    );
  }
}
