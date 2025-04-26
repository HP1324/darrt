import 'package:flutter/material.dart';
import 'package:minimaltodo/helpers/consts.dart';
import 'package:minimaltodo/helpers/mini_box.dart';

class CalendarViewModel extends ChangeNotifier {
  DateTime selectedDate = DateTime.now();

  void updateSelectedDate(DateTime date) {
    selectedDate = DateTime(date.year, date.month,date.day);
    notifyListeners();
  }

  ScrollController dateScrollController = ScrollController();

  void scrollToDate(DateTime date) {
    final index = date.difference(DateTime.fromMillisecondsSinceEpoch(MiniBox.read(mFirstInstallDate))).inDays;
    dateScrollController.animateTo(index  * 43.0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    updateSelectedDate(date);
  }


  CalendarViewModel(){
    WidgetsBinding.instance.addPostFrameCallback((_){
      if(dateScrollController.hasClients){
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
