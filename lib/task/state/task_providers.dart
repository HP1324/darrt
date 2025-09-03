import 'package:darrt/app/calendar/date_providers.dart';
import 'package:darrt/app/services/object_box.dart';
import 'package:darrt/task/models/task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'task_providers.g.dart';

@riverpod
Stream<List<Task>> taskStream(Ref ref){
  final selectedDate = ref.watch(selectedDateNotifierProvider.select((calendar) => calendar.selectedDate));

  final queryBuilder = ObjectBox().taskBox.query();

  final queryStream = queryBuilder.watch(triggerImmediately: true);

  return queryStream.map((query) => query.find().where((t) => t.isActiveOn(selectedDate)).toList());
}