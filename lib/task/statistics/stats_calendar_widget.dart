import 'package:darrt/app/services/toast_service.dart';
import 'package:darrt/helpers/consts.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/utils.dart';
import 'package:darrt/task/models/task.dart';
import 'package:flutter/material.dart';

class StatsCalendarWidget extends StatefulWidget {
  final Task task;

  const StatsCalendarWidget({super.key, required this.task});

  @override
  State<StatsCalendarWidget> createState() => _StatsCalendarWidgetState();
}

class _StatsCalendarWidgetState extends State<StatsCalendarWidget> {
  late PageController _pageController;
  late DateTime _currentMonth;
  late int _initialPage;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _initialPage = _getMonthDifference(mInitialDate, _currentMonth);
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _getMonthDifference(DateTime start, DateTime end) {
    return (end.year - start.year) * 12 + end.month - start.month;
  }

  DateTime _getMonthFromPage(int page) {
    final totalMonths = mInitialDate.month + page;
    final year = mInitialDate.year + (totalMonths - 1) ~/ 12;
    final month = ((totalMonths - 1) % 12) + 1;
    return DateTime(year, month);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CalendarHeader(
            currentMonth: _currentMonth,
            textTheme: textTheme,
            scheme: scheme,
            onPreviousMonth: () {
              if (_pageController.hasClients) {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            onNextMonth: () {
              if (_pageController.hasClients) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
          ),
          const SizedBox(height: 24),
          _WeekdayHeader(),
          const SizedBox(height: 16),
          SizedBox(
            height: 320,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _currentMonth = _getMonthFromPage(page);
                });
              },
              itemBuilder: (context, page) {
                final month = _getMonthFromPage(page);
                return _MonthView(month: month, task: widget.task);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  final DateTime currentMonth;
  final TextTheme textTheme;
  final ColorScheme scheme;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const _CalendarHeader({
    required this.currentMonth,
    required this.textTheme,
    required this.scheme,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: onPreviousMonth,
            icon: Icon(
              Icons.chevron_left_rounded,
              color: scheme.onSurface,
              size: 24,
            ),
          ),
        ),
        Text(
          _getMonthYearString(currentMonth),
          style: textTheme.headlineSmall?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: onNextMonth,
            icon: Icon(
              Icons.chevron_right_rounded,
              color: scheme.onSurface,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  String _getMonthYearString(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _WeekdayHeader extends StatelessWidget {


  const _WeekdayHeader();

  @override
  Widget build(BuildContext context) {
    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final scheme = ColorScheme.of(context);
    final textTheme = TextTheme.of(context);
    return Row(
      children: weekdays
          .map(
            (day) => Expanded(
              child: Center(
                child: Text(
                  day,
                  style: textTheme.labelMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _MonthView extends StatelessWidget {
  final DateTime month;
  final Task task;

  const _MonthView({required this.month, required this.task});

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    final maxDate = getMaxDate();

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 42,
      itemBuilder: (context, index) {
        final dayNumber = index - firstWeekday + 1;

        if (dayNumber <= 0 || dayNumber > daysInMonth) {
          return const SizedBox();
        }

        final date = DateTime(month.year, month.month, dayNumber);
        final isBeforeMinDate = date.isBefore(mInitialDate);
        final isAfterMaxDate = date.isAfter(maxDate);

        if (isBeforeMinDate || isAfterMaxDate) {
          return const SizedBox();
        }

        return ListenableBuilder(
          listenable: g.taskVm,
          builder: (context, child) {
            final dateMs = DateUtils.dateOnly(date).millisecondsSinceEpoch;

            final rtc = g.taskVm.repeatingTaskCompletions;
            final isFinished = rtc[task.id]?.contains(dateMs) ?? false;
            return _DateItem(
              date: date,
              task: task,
              value: isFinished,
              onChanged: (newValue) {
                if (task.isActiveOn(date)) {
                  g.taskVm.toggleStatus(task, newValue ?? false, date);
                } else {
                  showWarningToast(context, 'Task not active on this date');
                }
              },
            );
          },
        );
      },
    );
  }
}

class _DateItem extends StatelessWidget {
  final DateTime date;
  final Task task;
  final bool? value;
  final ValueChanged<bool?>? onChanged;

  const _DateItem({
    required this.date,
    required this.task,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    final today = DateTime.now();
    final isToday = date.year == today.year && date.month == today.month && date.day == today.day;

    final isFinished = value ?? false;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onChanged != null ? () => onChanged?.call(!isFinished) : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: isFinished
                ? const Color(0xFF10B981).withValues(alpha: 0.15)
                : scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isToday
                  ? scheme.primary.withValues(alpha: 0.5)
                  : isFinished
                  ? const Color(0xFF10B981).withValues(alpha: 0.4)
                  : scheme.outline.withValues(alpha: 0.3),
              width: isToday ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              date.day.toString(),
              style: textTheme.bodyMedium?.copyWith(
                color: isFinished ? const Color(0xFF10B981) : scheme.onSurface,
                fontWeight: isToday
                    ? FontWeight.w700
                    : isFinished
                    ? FontWeight.w600
                    : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
