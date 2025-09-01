import 'package:darrt/app/calendar/calendar_providers.dart';
import 'package:darrt/app/calendar/calendar_state.dart';
import 'package:darrt/app/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'calendar_controller.g.dart';

@riverpod
class CalendarController extends _$CalendarController {

  @override
  CalendarState build() {

    return CalendarState(
      selectedDate: DateTime.now(),
      previousSelectedDate: DateTime.now(),
    );
  }

  void setSelectedDate(DateTime date) {
    state = state.copyWith(previousSelectedDate: state.selectedDate);
    state = state.copyWith(selectedDate: date.dateOnly);
  }

  void scrollToDate(DateTime date, [ScrollController? controller]) {
    final dates = ref.read(datesProvider);
    final index = dates.indexOf(date.dateOnly);
    if (index != -1) {
      // ignore: avoid_manual_providers_as_generated_provider_dependency
      // final controller = ref.read(dateBarControllerProvider);
      controller?.animateTo(
        index * 43,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setSelectedDate(date);
    }
  }
}

