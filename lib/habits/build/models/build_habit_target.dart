import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
part 'build_habit_target.freezed.dart';
@freezed
abstract class BuildHabitTarget with _$BuildHabitTarget {
  const factory BuildHabitTarget({
    @Default(0) int daily,
    @Default(0) int weekly,
    @Default(0) int monthly,
    @Default(0) int yearly,
  }) = _BuildHabitTarget;

const BuildHabitTarget._();

  int get total => daily + weekly + monthly + yearly;

  String toJsonString() {
    final map =  {
      'daily': daily,
      'weekly': weekly,
      'monthly': monthly,
      'yearly': yearly,
    };

    return jsonEncode(map);
  }

  static BuildHabitTarget fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString);
    return BuildHabitTarget(
      daily: json['daily'],
      weekly: json['weekly'],
      monthly: json['monthly'],
      yearly: json['yearly'],
    );
  }
}
