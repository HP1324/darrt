import 'package:darrt/app/services/object_box.dart';
import 'package:darrt/task/repository/task_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'task_repository_provider.g.dart';

@riverpod
TaskRepository taskRepository(Ref ref){
  final taskBox = ObjectBox().taskBox;
  final completionBox = ObjectBox().completionBox;

  return TaskRepository(taskBox, completionBox);
}