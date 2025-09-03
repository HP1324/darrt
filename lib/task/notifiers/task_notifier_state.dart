import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_notifier_state.freezed.dart';
@freezed
abstract class TaskNotifierState with _$TaskNotifierState{
  const factory TaskNotifierState({
    required Map<int, bool> oneTimeTaskCompletions,
    required Map<int, Set<int>> repeatingTaskCompletions,
}) = _TaskNotifierState;
  const TaskNotifierState._();
}