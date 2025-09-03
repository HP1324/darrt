import 'package:darrt/category/models/task_category.dart';
import 'package:darrt/task/models/task.dart';
import 'package:darrt/task/state/task_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'task_state_notifier.g.dart';

@riverpod
class TaskStateNotifier extends _$TaskStateNotifier{
  @override
  TaskState build(bool edit, [Task? task, TaskCategory? category]) {
    // TODO: implement build
    throw UnimplementedError();
  }


}