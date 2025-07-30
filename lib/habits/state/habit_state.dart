import 'package:freezed_annotation/freezed_annotation.dart';
part 'habit_state.freezed.dart';

@freezed
abstract class HabitState with _$HabitState {
  const factory HabitState({
    required String name,
    String? description,
    required DateTime startDate,
    DateTime? endDate,

  }) = _HabitState;

  const HabitState._();
}
