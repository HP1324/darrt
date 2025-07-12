// task_selection_item.dart
import 'package:flutter/material.dart';
import 'package:minimaltodo/focustimer/timer/timer_controller.dart';
import 'package:minimaltodo/helpers/globals.dart' as g;

class TaskSelectionItem extends StatelessWidget {
  final dynamic task;
  final TimerController controller;
  final bool isSelected;

  const TaskSelectionItem({
    super.key,
    required this.task,
    required this.controller,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? scheme.primaryContainer.withValues(alpha: 0.3)
            : scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? scheme.primary.withValues(alpha: 0.5)
              : scheme.outline.withValues(alpha: 0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _toggleSelection(),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Selection indicator
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? scheme.primary
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? scheme.primary
                          : scheme.outline,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: isSelected
                      ? Icon(
                    Icons.check,
                    color: scheme.onPrimary,
                    size: 16,
                  )
                      : null,
                ),

                const SizedBox(width: 12),

                // Task content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Task title
                      Text(
                        task.title,
                        style: textTheme.titleSmall?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      // Task details
                      if (task.description?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          style: textTheme.bodySmall?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      // Task metadata
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          // Priority indicator
                          if (task.priority != null) ...[
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _getPriorityColor(task.priority, scheme),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],

                          // Due date for one-time tasks
                          if (!task.isRepeating && task.dueDate != null) ...[
                            Icon(
                              Icons.schedule,
                              color: scheme.onSurface.withValues(alpha: 0.5),
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDueDate(task.dueDate),
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],

                          // Repeat indicator for repeating tasks
                          if (task.isRepeating) ...[
                            Icon(
                              Icons.repeat,
                              color: scheme.primary,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Repeating',
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],

                          const Spacer(),

                          // Task completion status
                          if (task.isCompleted) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Done',
                                style: textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Selection animation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isSelected ? 4 : 0,
                  height: 40,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleSelection() {
    if (isSelected) {
      controller.removeTask(task);
    } else {
      controller.addTask(task);
    }
  }

  Color _getPriorityColor(dynamic priority, ColorScheme scheme) {
    switch (priority?.toString().toLowerCase()) {
      case 'high':
        return scheme.error;
      case 'medium':
        return scheme.primary;
      case 'low':
        return scheme.tertiary;
      default:
        return scheme.outline;
    }
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);

    final difference = taskDate.difference(today).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 1) {
      return 'In $difference days';
    } else {
      return '${difference.abs()} days ago';
    }
  }
}