import 'package:flutter/material.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/helpers/mini_router.dart';
import 'package:minimaltodo/services/task_service.dart';
import 'package:minimaltodo/views/pages/single_task_view.dart';
import 'package:minimaltodo/views/widgets/selectable_task_item.dart';
class TaskItem extends StatelessWidget {
  const TaskItem({
    required this.task,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.onLongPress,
    this.onSelect,
    super.key,
  });

  final Task task;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback? onLongPress;
  final Function(bool)? onSelect;
  void _navigateToTaskDetails(BuildContext context) async {
    Task? taskWithId = await TaskService.getTaskById(task.id!);
    if (context.mounted) {
      MiniRouter.to(context,
          child: TaskView(
            task: taskWithId!,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    MiniLogger.debug('Task repeat settings: ${task.repeatConfig ?? 'No repeat config'}');
    return GestureDetector(
      onLongPress: onLongPress,
      child: SelectableTaskItem(
        key: task.getTaskItemKey(),
        task: task,
        isSelected: isSelected,
        onSelectionChanged: (selected) {
          if (isSelectionMode) {
            onSelect?.call(selected);
          }
        },
        onTap: () {
          if (isSelectionMode) {
            onSelect?.call(!isSelected);
          } else {
            _navigateToTaskDetails(context);
          }
        },
      ),
    );
  }
}
