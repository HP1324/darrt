import 'package:darrt/app/services/object_box.dart';
import 'package:darrt/task/completion/task_completion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'task_completion_stream_provider.g.dart';

@riverpod
Stream<List<TaskCompletion>> taskCompletionStream(Ref ref){
  final queryBuilder = ObjectBox().completionBox.query();

  final completionStream = queryBuilder.watch(triggerImmediately: true);

  return completionStream.map((query) => query.find());
}