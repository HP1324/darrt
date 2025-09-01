import 'package:darrt/app/extensions/extensions.dart';
import 'package:darrt/helpers/utils.dart';
import 'package:flutter/material.dart';

class CalendarManager extends ChangeNotifier {
  DateTime selectedDate = DateTime.now();
  DateTime previousSelectedDate = DateTime.now();

  final firstDate = getFirstDate();
  final lastDate = getLastDate();

  late final List<DateTime> dates;

  final dateItemWidth = 43.0;

  void updateSelectedDate(DateTime date) {
    previousSelectedDate = selectedDate;
    selectedDate = DateTime(date.year, date.month, date.day);
    notifyListeners();
  }

  ScrollController dateScrollController = ScrollController();

  void scrollToDate(DateTime date) {
    final index = dates.indexOf(date.dateOnly);
    if (index != -1) {
      dateScrollController.animateTo(
        index * dateItemWidth,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      updateSelectedDate(date);
    }
  }

  CalendarManager() {
    dates = List.generate(
      lastDate.difference(firstDate).inDays + 1,
      (index) => firstDate.add(Duration(days: index)),
    );
  }

  @override
  void dispose() {
    dateScrollController.dispose();
    super.dispose();
  }
}
