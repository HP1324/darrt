import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';
part 'build_habit_state.freezed.dart';

@freezed
abstract class BuildHabitState with _$BuildHabitState {
  const factory BuildHabitState({
    required String name,
    required DateTime startDate,
    required Color color,
    String? description,
    DateTime? endDate,
  }) = _BuildHabitState;

  const BuildHabitState._();
}
