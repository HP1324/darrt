import 'package:flutter/material.dart';
import 'package:darrt/helpers/consts.dart';

class CalendarManager extends ChangeNotifier {
  DateTime selectedDate = DateTime.now();
  DateTime previousSelectedDate = DateTime.now();
  final maxDate = DateTime.now().add(Duration(days: maxExtentDateDays));
  final initialDate = mInitialDate;
  late List<DateTime> dates = List.generate(
    maxDate.difference(initialDate).inDays + 1,
        (index) => initialDate.add(Duration(days: index)),
  );
  final dateItemWidth = 43.0;
  void updateSelectedDate(DateTime date) {
    previousSelectedDate = selectedDate;
    selectedDate = DateTime(date.year, date.month, date.day);
    notifyListeners();
  }

  ScrollController dateScrollController = ScrollController();

  void scrollToDate(DateTime date) {
    final index = dates.indexWhere((d) => DateUtils.isSameDay(d, date));
    if(index != -1) {
      dateScrollController.animateTo(index * dateItemWidth,
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      updateSelectedDate(date);
    }
  }

  CalendarManager() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (dateScrollController.hasClients) {
        scrollToDate(DateTime.now());
      }
    });
  }
  @override
  void dispose() {
    dateScrollController.dispose();
    super.dispose();
  }
}