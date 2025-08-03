import 'package:darrt/app/state/managers/calendar_manager.dart';
import 'package:darrt/helpers/utils.dart';
import 'package:flutter/material.dart';

class DateSelector extends StatelessWidget {
  const DateSelector({super.key, required this.controller});
  final CalendarManager controller;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashFactory: NoSplash.splashFactory,
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return CalendarDatePicker(
              initialDate: DateTime.now(),
              firstDate: getFirstDate(),
              lastDate: getMaxDate(),
              onDateChanged: (selectedDate) {
                final date = DateUtils.dateOnly(selectedDate);
                controller.scrollToDate(date);
              },
            );
          },
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListenableBuilder(
            listenable: controller,
            builder: (context, child) {
              final selectedDate = controller.selectedDate;
              final isBefore = selectedDate.isBefore(controller.previousSelectedDate);
              final title = DateUtils.isSameDay(selectedDate, DateTime.now())
                  ? 'Today'
                  : formatDateNoJm(selectedDate, 'EEE, d MMM, yyyy');
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  final inAnimation = Tween<Offset>(
                    begin: const Offset(-1.0, 0.0),
                    end: Offset.zero,
                  ).animate(animation);

                  final outAnimation = Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(animation);

                  if (child.key == ValueKey<DateTime>(selectedDate)) {
                    // This is the new date coming in
                    return ClipRect(
                      child: SlideTransition(
                        position: isBefore ? inAnimation : outAnimation,
                        child: child,
                      ),
                    );
                  } else {
                    // This is the old date going out
                    return ClipRect(
                      child: SlideTransition(
                        position: isBefore ? outAnimation : inAnimation,
                        child: child,
                      ),
                    );
                  }
                },
                child: Text(
                  title,
                  key: ValueKey<DateTime>(selectedDate),
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
          Icon(Icons.arrow_drop_down_rounded),
        ],
      ),
    );
  }
}
