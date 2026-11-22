import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/number_utils.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_svg.dart';
import '../../../../core/widgets/icon_info_box.dart';
import '../../../../core/widgets/spacers.dart';
import '../../../../core/widgets/star_rating.dart';
import '../../../../data/models/responses/doctor.dart';

/// Top bar of `fragment_doctor_details.xml`: back, title, heart (logged in only,
/// once the doctor is loaded) and share.
class DoctorTopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback? onShare;
  final VoidCallback? onHeart;
  final bool isFav;

  const DoctorTopBar({
    super.key,
    required this.onBack,
    this.onShare,
    this.onHeart,
    this.isFav = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              const HorizontalSpacer(16),
              InkResponse(onTap: onBack, child: AppSvg(AppAssets.icBack)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    context.l10n.doctorDetails,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bold(16, AppColors.c0F0102),
                  ),
                ),
              ),
              if (onHeart != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 16, end: 10),
                  child: HeartButton(isFav: isFav, onTap: onHeart!),
                ),
              if (onShare != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 16),
                  child: InkResponse(
                    onTap: onShare,
                    child: AppSvg(AppAssets.icBtnShare),
                  ),
                ),
              const HorizontalSpacer(16),
            ],
          ),
        ),
        const VerticalSpacer(10),
        const Divider(height: 1, thickness: 1, color: AppColors.cE6E6E6),
      ],
    );
  }
}

/// Heart (`ic_heart_btn_*`) with the Android bounce: 1 -> 1.4 -> 1, 180 ms each
/// way, overshoot. It plays whenever [isFav] changes, i.e. after the request
/// succeeded.
class HeartButton extends StatefulWidget {
  final bool isFav;
  final VoidCallback onTap;

  const HeartButton({super.key, required this.isFav, required this.onTap});

  @override
  State<HeartButton> createState() => _HeartButtonState();
}

class _HeartButtonState extends State<HeartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
  );

  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 1.4,
      ).chain(CurveTween(curve: Curves.easeOutBack)),
      weight: 1,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.4,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeOutBack)),
      weight: 1,
    ),
  ]).animate(_controller);

  @override
  void didUpdateWidget(HeartButton old) {
    super.didUpdateWidget(old);
    if (old.isFav != widget.isFav) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: AppSvg(
          widget.isFav
              ? AppAssets.icHeartBtnActive
              : AppAssets.icHeartBtnInactive,
        ),
      ),
    );
  }
}

/// Image, name, brief, read-only rating and the duration / price / experience
/// boxes.
class DoctorHeader extends StatelessWidget {
  final DoctorModel doctor;

  const DoctorHeader({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rate = doctor.rate;
    final price = double.tryParse(doctor.price ?? '');
    return Column(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(
            start: 16,
            end: 16,
            top: 12,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppNetworkImage(
                url: doctor.image,
                width: 79,
                height: 79,
                radius: 10,
                fit: BoxFit.fill,
              ),
              const HorizontalSpacer(10),
              Expanded(
                child: SizedBox(
                  height: 79,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.semiBold(16, AppColors.c251836),
                      ),
                      const VerticalSpacer(10),
                      Text(
                        doctor.subSpecialty ?? doctor.specialty ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.semiBold(13, AppColors.c666666),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          StarRating(score: rate ?? 0, size: 11.6),
                          const HorizontalSpacer(2),
                          Flexible(
                            child: Text(
                              l10n.rateNumberOfReviewsWithValues(
                                '${truncateToDecimal(rate ?? 0, 1)}',
                                l10n.reviewsWithNumber(
                                  '${doctor.reviewsCount ?? 0}',
                                ),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.semiBold(
                                12,
                                AppColors.c7E94B0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: IconInfoBox(
                    valueTop: 14,
                    endPadding: 4,
                    centerValue: true,
                    valueMaxLines: 1,
                    icon: AppAssets.icTimer,
                    value: l10n.minValues('${doctor.duration}'),
                    label: l10n.examinationDurationNoColon,
                  ),
                ),
                const HorizontalSpacer(8),
                Expanded(
                  child: IconInfoBox(
                    valueTop: 14,
                    endPadding: 4,
                    centerValue: true,
                    valueMaxLines: 1,
                    icon: AppAssets.icCard,
                    value: l10n.priceWithValue(formatDecimal(price)),
                    label: l10n.examinationPriceNoColon,
                  ),
                ),
                const HorizontalSpacer(8),
                Expanded(
                  child: IconInfoBox(
                    valueTop: 14,
                    endPadding: 4,
                    centerValue: true,
                    valueMaxLines: 1,
                    icon: AppAssets.icMedal,
                    value: '${formatDecimalString(doctor.experience)}+',
                    label: l10n.yearsOfExperience,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
