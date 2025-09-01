import 'package:darrt/app/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScrollableDateBar extends StatefulWidget {
  const ScrollableDateBar({
    super.key,
    this.dates,
    required this.selectedDate,
    required this.controller,
    required this.onDateChanged,
    this.dateItemWidth = 43.0,
    this.firstDate,
    this.lastDate,
    this.barHeight,
  }) : assert(dates != null || (firstDate != null && lastDate != null));

  final List<DateTime>? dates;

  final DateTime selectedDate;

  final DateTime? firstDate;

  final DateTime? lastDate;

  final ScrollController controller;

  final double dateItemWidth;

  final double? barHeight;

  final void Function(DateTime date) onDateChanged;

  @override
  State<ScrollableDateBar> createState() => _ScrollableDateBarState();
}

class _ScrollableDateBarState extends State<ScrollableDateBar> {
  late final List<DateTime> dates;

  @override
  void initState() {
    super.initState();

    final firstDate = widget.firstDate;
    final lastDate = widget.lastDate;

    dates =
        widget.dates ??
        List.generate(lastDate!.difference(firstDate!).inDays + 1, (index) {
          return firstDate.add(Duration(days: index));
        });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.animateTo(
        dates.indexOf(widget.selectedDate.dateOnly) * widget.dateItemWidth,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.barHeight ?? MediaQuery.sizeOf(context).height * 0.085,
      child: ListView.builder(
        controller: widget.controller,
        scrollDirection: Axis.horizontal,
        itemExtent: widget.dateItemWidth,
        physics: const BouncingScrollPhysics(),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = date == widget.selectedDate;
          final isToday = DateUtils.isSameDay(date, DateTime.now());
          return _DateItem(
            date: date,
            isSelected: isSelected,
            isToday: isToday,
            onDateChanged: (date) {
              widget.onDateChanged(date);
            },
          );
        },
      ),
    );
  }
}

class _DateItem extends StatelessWidget {
  const _DateItem({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.onDateChanged,
  });

  final DateTime date;

  final bool isSelected;

  final bool isToday;

  final void Function(DateTime date) onDateChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final textTheme = context.textTheme;

    // Determine text and background colors based on states
    Color dayTextColor;
    Color dateBackgroundColor;
    Color dateTextColor;

    if (isSelected) {
      dayTextColor = scheme.primary;
      dateBackgroundColor = scheme.primary;
      dateTextColor = scheme.onPrimary;
    } else if (isToday) {
      dayTextColor = scheme.secondary;
      dateBackgroundColor = scheme.secondaryContainer.withValues(
        alpha: 0.5,
      );
      dateTextColor = scheme.onSecondaryContainer;
    } else {
      dayTextColor = scheme.onSurface.withValues(alpha: 0.8);
      dateBackgroundColor = Colors.transparent;
      dateTextColor = scheme.onSurface;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.0),
      child: InkWell(
        onTap: () => onDateChanged(date),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isToday
                ? Border.all(
                    color: scheme.secondary.withValues(alpha: 0.5),
                    width: 1.5,
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('EEE').format(date),
                style: textTheme.labelSmall?.copyWith(
                  color: dayTextColor,
                  fontWeight: isSelected || isToday
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dateBackgroundColor,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: scheme.primary.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '${date.day}',
                    style: textTheme.labelMedium?.copyWith(
                      color: dateTextColor,
                      fontWeight: FontWeight.bold,
                    ),
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
