import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_link.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/state_view.dart';
import '../../../data/models/responses/doctor.dart';
import '../day_time_logic.dart';
import 'day_chip.dart';
import 'time_chip.dart';

/// Port of `BookingAppointmentsFragment`: horizontal days, a 3-column grid of
/// times, and "Open calendar" limited to the active dates. The selection is owned
/// by the parent ([selectedDay] / [selectedTime]); on first build (and when
/// [days] changes) the picker selects [initialDay] and clears the time.
class DayTimePicker extends StatefulWidget {
  final List<WorkTimeModel> days;
  final WorkTimeModel? selectedDay;
  final TimeModel? selectedTime;
  final ValueChanged<WorkTimeModel?> onDayChanged;
  final ValueChanged<TimeModel?> onTimeChanged;
  final bool showCalendarButton;

  /// Heading above the days; defaults to `pickUpBookingAppointment`.
  final String? title;

  const DayTimePicker({
    super.key,
    required this.days,
    required this.selectedDay,
    required this.selectedTime,
    required this.onDayChanged,
    required this.onTimeChanged,
    this.showCalendarButton = true,
    this.title,
  });

  @override
  State<DayTimePicker> createState() => _DayTimePickerState();
}

class _DayTimePickerState extends State<DayTimePicker> {
  late List<GlobalKey> _dayKeys;

  @override
  void initState() {
    super.initState();
    _dayKeys = _newKeys();
    WidgetsBinding.instance.addPostFrameCallback((_) => _selectInitial());
  }

  @override
  void didUpdateWidget(covariant DayTimePicker old) {
    super.didUpdateWidget(old);
    if (old.days != widget.days) {
      _dayKeys = _newKeys();
      WidgetsBinding.instance.addPostFrameCallback((_) => _selectInitial());
    }
  }

  List<GlobalKey> _newKeys() => [for (final _ in widget.days) GlobalKey()];

  void _selectInitial() {
    if (!mounted) return;
    widget.onDayChanged(initialDay(widget.days));
    widget.onTimeChanged(null);
  }

  void _selectDay(WorkTimeModel day) {
    widget.onDayChanged(day);
    widget.onTimeChanged(null);
  }

  void _scrollTo(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || index < 0 || index >= _dayKeys.length) return;
      final ctx = _dayKeys[index].currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 250),
        alignment: 0.5,
      );
    });
  }

  Future<void> _openCalendar() async {
    final dates = activeDates(widget.days)..sort();
    final now = DateTime.now();
    DateTime local(DateTime d) => DateTime(d.year, d.month, d.day);
    final initial = dates.isNotEmpty ? local(dates.first) : local(now);
    final last = dates.isNotEmpty ? local(dates.last) : initial;
    final available = dates.toSet();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: initial,
      lastDate: last,
      helpText: context.l10n.calender,
      selectableDayPredicate: (d) =>
          available.contains(DateTime.utc(d.year, d.month, d.day)),
    );
    if (picked == null || !mounted) return;
    final day = findDayForDate(widget.days, picked);
    if (day == null) {
      AppToast.show(
        context,
        context.l10n.selectedDayNotAvailableYet,
        ToastType.failed,
      );
      return;
    }
    _selectDay(day);
    _scrollTo(widget.days.indexOf(day));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final days = widget.days;
    final day = widget.selectedDay ?? initialDay(days);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (days.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title ?? l10n.pickUpBookingAppointment,
                    style: AppTextStyles.bold(14, AppColors.c3D4C5E),
                  ),
                  if (widget.showCalendarButton)
                    AppLink(
                      text: l10n.openCalender,
                      size: 12,
                      weight: FontWeight.w600,
                      onTap: _openCalendar,
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsetsDirectional.only(start: 16),
                child: Row(
                  children: [
                    for (var i = 0; i < days.length; i++)
                      KeyedSubtree(
                        key: _dayKeys[i],
                        child: DayChip(
                          day: days[i],
                          selected: days[i] == day,
                          onTap: () => _selectDay(days[i]),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              height: 1,
              margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              color: AppColors.cE6E6E6,
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: Text(
              l10n.appointmentsAvailable,
              style: AppTextStyles.bold(14, AppColors.c3D4C5E),
            ),
          ),
          if (!dayHasTimes(day))
            SizedBox(
              height: 240,
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: StateView.empty(
                  icon: AppAssets.icNoAvailableBookings,
                  title: l10n.noAvailableTimesToday,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: day!.times.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisExtent: 53,
                ),
                itemBuilder: (context, i) {
                  final time = day.times[i];
                  final selected = widget.selectedTime == time;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TimeChip(
                      time: time,
                      selected: selected,
                      onTap: () => widget.onTimeChanged(selected ? null : time),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
