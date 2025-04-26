import 'package:flutter/material.dart';
import 'package:minimaltodo/helpers/consts.dart';
import 'package:minimaltodo/helpers/mini_box.dart';

class CalendarViewModel extends ChangeNotifier {
  DateTime selectedDate = DateTime.now();
  final maxDate = DateTime.now().add(Duration(days: maxExtentDateDays));
  final initialDate = DateTime.fromMillisecondsSinceEpoch(MiniBox.read(mFirstInstallDate))
      .subtract(const Duration(days: 365));
  late List<DateTime> dates = List.generate(
    maxDate.difference(initialDate).inDays + 1,
        (index) => initialDate.add(Duration(days: index)),
  );
  final dateItemWidth = 43.0;
  void updateSelectedDate(DateTime date) {
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

  CalendarViewModel() {
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