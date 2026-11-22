import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/enums/enums.dart';

/// Colors of the status pill (`tvStatus` in `AppointmentDetailsFragment`):
/// background, text. Shared by the appointment / session details screens.
(Color, Color) statusPillColors(BookingStatus? status) => switch (status) {
  BookingStatus.pending => (AppColors.cF8F6FA, AppColors.primary),
  BookingStatus.confirmed => (AppColors.cE6E6E6, AppColors.c251836),
  BookingStatus.completed => (AppColors.c1950C878, AppColors.c50C878),
  BookingStatus.canceled ||
  BookingStatus.rejected => (AppColors.c19ED1C24, AppColors.cED1C24),
  BookingStatus.processing => (AppColors.cF8FAFB, AppColors.c006F98),
  null => (AppColors.white, AppColors.primary),
};

/// Rounded 10dp pill with the translated status (`status_trans`).
class StatusPill extends StatelessWidget {
  final String? status;
  final String? text;

  const StatusPill({super.key, required this.status, required this.text});

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = statusPillColors(
      BookingStatus.fromValue(status),
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text ?? '',
        textAlign: TextAlign.center,
        style: AppTextStyles.bold(12, foreground),
      ),
    );
  }
}
