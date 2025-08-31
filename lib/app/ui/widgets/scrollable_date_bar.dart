import 'package:darrt/app/extensions/extensions.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScrollableDateBar extends StatelessWidget {
  const ScrollableDateBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: g.calMan,
      builder: (context, child) {
        return ListView.builder(
          controller: g.calMan.dateScrollController,
          scrollDirection: Axis.horizontal,
          itemExtent: g.calMan.dateItemWidth,
          physics: const BouncingScrollPhysics(),
          itemCount: g.calMan.dates.length,
          itemBuilder: (context, index) => _DateItem(date: g.calMan.dates[index]),
        );
      },
    );
  }
}


class _DateItem extends StatelessWidget {
  const _DateItem({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.0),
      child: ListenableBuilder(
        listenable: g.calMan,
        builder: (context, child) {
          final bool isSelected = g.calMan.selectedDate == date;
          final bool isToday = DateUtils.isSameDay(date, DateTime.now());
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
            dateBackgroundColor = scheme.secondaryContainer.withValues(alpha: 0.5);
            dateTextColor = scheme.onSecondaryContainer;
          } else {
            dayTextColor = scheme.onSurface.withValues(alpha: 0.8);
            dateBackgroundColor = Colors.transparent;
            dateTextColor = scheme.onSurface;
          }

          return InkWell(
            onTap: () => g.calMan.updateSelectedDate(date),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: isToday
                    ? Border.all(color: scheme.secondary.withValues(alpha: 0.5), width: 1.5)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(date),
                    style: textTheme.labelSmall?.copyWith(
                      color: dayTextColor,
                      fontWeight: isSelected || isToday ? FontWeight.w600 : FontWeight.normal,
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
                        style:textTheme.labelMedium?.copyWith(
                          color: dateTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}