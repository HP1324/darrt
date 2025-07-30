import 'package:freezed_annotation/freezed_annotation.dart';
part 'quit_habit_state.freezed.dart';
@freezed
abstract class QuitHabitState with _$QuitHabitState{
  const factory QuitHabitState({required String name,}) = _QuitHabitState;

  const QuitHabitState._();
}