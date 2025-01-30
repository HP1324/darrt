import 'package:flutter/material.dart';
import 'package:minimaltodo/mini_router.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';
import 'package:minimaltodo/views/pages/single_task_view.dart';
import 'package:minimaltodo/views/widgets/selectable_task_item.dart';
import 'package:provider/provider.dart';

class TaskItem extends StatelessWidget {
  const TaskItem({
    required this.task,
    this.isSelected = false,
    this.onLongPress,
    this.isSelectionMode = false,
    this.onSelect,
    super.key,
  });

  final Task task;
  final bool isSelected;
  final VoidCallback? onLongPress;
  final bool isSelectionMode;
  final Function(bool)? onSelect;

  void _navigateToTaskDetails(BuildContext context) {
    MiniRouter.to(context, child: TaskView(task: task));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskViewModel>(builder: (context, taskViewModel, _) {
      return GestureDetector(
        onLongPress: onLongPress,
        child: SelectableTaskItem(
          task: task,
          isSelected: isSelected,
          onSelectionChanged: (selected) {
            if (onSelect != null) {
              onSelect!(selected);
            }
          },
          onTap: isSelectionMode ? () => onSelect?.call(!isSelected) : () => _navigateToTaskDetails(context),
          onStatusChanged: (isDone) async {
            await taskViewModel.toggleStatus(task, isDone);
          },
        ),
      );
    });
  }
}
