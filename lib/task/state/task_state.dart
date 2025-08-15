import 'package:darrt/category/models/task_category.dart';
import 'package:darrt/note/models/note.dart';
import 'package:darrt/task/models/reminder.dart';
import 'package:darrt/task/models/repeat_config.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_state.freezed.dart';

///Immutable data-class to store the temporary state of the task add page
@freezed
abstract class TaskState with _$TaskState {
  const factory TaskState({
    required Map<TaskCategory, bool> categorySelection,
    required DateTime dueDate,
    required bool isRepeating,
    required DateTime startDate,
    DateTime? endDate,
    DateTime? startTime,
    DateTime? endTime,
    required RepeatConfig repeatConfig,
    required List<Reminder> reminders,
    List<Note>? notes,
    required String priority,
    required int currentPriority,
  }) = _TaskState;
  const TaskState._();
}