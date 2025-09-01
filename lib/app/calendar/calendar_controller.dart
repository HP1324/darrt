import 'package:darrt/app/calendar/calendar_state.dart';
import 'package:darrt/app/extensions/extensions.dart';
import 'package:darrt/helpers/utils.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'calendar_controller.g.dart';

@riverpod
class CalendarController extends _$CalendarController {
  late final List<DateTime> dates;

  final firstDate = getFirstDate();
  final lastDate = getLastDate();

  late ScrollController dateScrollController;

  @override
  CalendarState build() {
    dateScrollController = ScrollController();

    dates = List.generate(
      lastDate.difference(firstDate).inDays + 1,
      (index) => firstDate.add(Duration(days: index)),
    );

    return CalendarState(
      selectedDate: DateTime.now(),
      previousSelectedDate: DateTime.now(),
    );
  }

  void setSelectedDate(DateTime date) {
    state = state.copyWith(previousSelectedDate: state.selectedDate);
    state = state.copyWith(selectedDate: date.dateOnly);
  }
}
