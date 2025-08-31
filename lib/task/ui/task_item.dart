import 'package:darrt/category/ui/category_chip.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/mini_logger.dart';
import 'package:darrt/helpers/mini_router.dart';
import 'package:darrt/task/models/task.dart';
import 'package:darrt/task/statistics/stats_page.dart';
import 'package:darrt/task/ui/add_task_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class TaskItem extends StatefulWidget {
  const TaskItem({super.key, required this.task});
  final Task task;
  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  @override
  Widget build(BuildContext context) {
    MiniLogger.dp('Task: title: ${widget.task.title}, id: ${widget.task.id}');
    return ListenableBuilder(
      listenable: g.taskVm,
      builder: (context, child) {
        final ids = g.taskVm.selectedTaskIds;
        final isSelected = ids.contains(widget.task.id);
        return TaskItemContainer(
          task: widget.task,
          isSelected: isSelected,
          onTap: () => _handleTap(ids),
          onLongPress: () => g.taskVm.toggleSelection(widget.task.id),
        );
      },
    );
  }

  void _handleTap(Set<int> selectedIds) {
    if (selectedIds.isEmpty) {
      MiniRouter.to(context, AddTaskPage(edit: true, task: widget.task));
    } else {
      g.taskVm.toggleSelection(widget.task.id);
    }
  }
}

class TaskItemContainer extends StatelessWidget {
  const TaskItemContainer({
    super.key,
    required this.task,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  final Task task;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? scheme.outline.withAlpha(130) : scheme.surface.withAlpha(100),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scheme.outline.withAlpha(60),
          width: 0.5,
        ),
      ),
      child: TaskItemInkWell(
        task: task,
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}

class TaskItemInkWell extends StatelessWidget {
  const TaskItemInkWell({
    super.key,
    required this.task,
    required this.onTap,
    required this.onLongPress,
  });

  final Task task;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashFactory: NoSplash.splashFactory,
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        onLongPress: onLongPress,
        child: TaskItemContent(task: task),
      ),
    );
  }
}

class TaskItemContent extends StatelessWidget {
  const TaskItemContent({
    super.key,
    required this.task,
  });

  final Task task;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Row(
        children: [
          TaskFinishCheckbox(task: task),
          Expanded(
            child: TaskItemDetails(task: task),
          ),
        ],
      ),
    );
  }
}

class TaskItemDetails extends StatelessWidget {
  const TaskItemDetails({
    super.key,
    required this.task,
  });

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 10, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TaskTitleRow(task: task),
          const Spacer(),
          TaskInfoRow(task: task),
        ],
      ),
    );
  }
}

class TaskTitleRow extends StatelessWidget {
  const TaskTitleRow({
    super.key,
    required this.task,
  });

  final Task task;

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    return Row(
      spacing: 8.0,
      children: [
        TaskTitle(task: task),
        if (task.isRepeating) ...[
          const SizedBox(width: 4),
          Icon(
            FontAwesomeIcons.repeat,
            size: 13,
            color: scheme.primary.withAlpha(200),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => MiniRouter.to(context, StatsPage(task: task)),
            child: Icon(Icons.calendar_month_outlined, size: 21, color: scheme.secondary),
          ),
        ],
        // TaskPrioritySection(task: task, isUrgent: isUrgent, context: context),
      ],
    );
  }
}

class TaskInfoRow extends StatelessWidget {
  const TaskInfoRow({
    super.key,
    required this.task,
  });

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TaskCategoriesSection(task: task),
        TaskTime(task: task),
      ],
    );
  }
}

class TaskTime extends StatelessWidget {
  const TaskTime({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final start = task.startTime;
    final end = task.endTime;

    if (start == null) return const SizedBox.shrink();

    final timeFormat = DateFormat.jm(); // Locale-aware time formatting
    final startStr = timeFormat.format(start);
    final endStr = end != null ? timeFormat.format(end) : null;
    final timeDisplay = endStr != null ? "$startStr - $endStr" : startStr;

    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Text(
        timeDisplay,
        style: TextStyle(
          fontSize: theme.textTheme.labelSmall?.fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class TaskTitle extends StatelessWidget {
  const TaskTitle({
    super.key,
    required this.task,
  });

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListenableBuilder(
        listenable: Listenable.merge([g.calMan, g.taskVm]),
        builder: (context, child) {
          final date = DateUtils.dateOnly(g.calMan.selectedDate).millisecondsSinceEpoch;
          final repeat = task.isRepeating;
          final stc = g.taskVm.onetimeTaskCompletions, rtc = g.taskVm.repeatingTaskCompletions;
          final isFinished = repeat ? rtc[task.id]?.contains(date) ?? false : stc[task.id] ?? false;

          return Text(
            task.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.titleSmall!.fontSize,
              fontWeight: FontWeight.w500,
              decorationColor: Theme.of(context).colorScheme.outline,
              decorationThickness: 2,
              color: isFinished
                  ? Theme.of(context).colorScheme.outline
                  : Theme.of(context).colorScheme.onSurface,
            ),
          );
        },
      ),
    );
  }
}

class TaskPrioritySection extends StatelessWidget {
  const TaskPrioritySection({
    super.key,
    required this.task,
    required this.isUrgent,
  });

  final Task task;
  final bool isUrgent;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.flag_outlined,
          size: 14,
          color: isUrgent ? Colors.red.shade400 : null,
        ),
        const SizedBox(width: 4),
        Text(
          task.priority,
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.labelSmall!.fontSize,
            color: isUrgent ? Colors.red.shade400 : null,
          ),
        ),
      ],
    );
  }
}

class TaskCategoriesSection extends StatelessWidget {
  const TaskCategoriesSection({
    super.key,
    required this.task,
  });

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 20,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          separatorBuilder: (context, index) => const SizedBox(width: 2),
          itemCount: task.categories.length,
          itemBuilder: (context, index) {
            final category = task.categories[index];
            return CategoryChip(category: category);
          },
        ),
      ),
    );
  }
}


class TaskFinishCheckbox extends StatelessWidget {
  const TaskFinishCheckbox({
    super.key,
    required this.task,
  });

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Transform.scale(
        scale: 1.0,
        child: ListenableBuilder(
          listenable: Listenable.merge([g.taskVm, g.calMan]),
          builder: (context, child) {
            final repeat = task.isRepeating;
            final oneTimeCompletions = g.taskVm.onetimeTaskCompletions;
            final repeatingCompletions = g.taskVm.repeatingTaskCompletions;
            final date = DateUtils.dateOnly(g.calMan.selectedDate).millisecondsSinceEpoch;

            return CheckboxTheme(
              data: _buildCheckboxTheme(context),
              child: Checkbox(
                key: ValueKey('selection_${task.id}'),
                value: repeat
                    ? repeatingCompletions[task.id]?.contains(date) ?? false
                    : oneTimeCompletions[task.id] ?? false,
                onChanged: (value) {
                  g.taskVm.toggleStatus(task, value ?? false, g.calMan.selectedDate, context);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  CheckboxThemeData _buildCheckboxTheme(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CheckboxThemeData(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      ),
      side: WidgetStateBorderSide.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return BorderSide(color: colorScheme.secondary, width: 2.5);
        }
        if (states.contains(WidgetState.hovered)) {
          return BorderSide(color: colorScheme.secondary.withAlpha(160), width: 2.5);
        }
        return BorderSide(color: colorScheme.outline, width: 2.0);
      }),
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.secondary;
        }
        if (states.contains(WidgetState.hovered)) {
          return colorScheme.secondary.withAlpha(40);
        }
        return colorScheme.surface;
      }),
      overlayColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.pressed)) {
          return colorScheme.secondary.withAlpha(100);
        }
        if (states.contains(WidgetState.hovered)) {
          return colorScheme.secondary.withAlpha(50);
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.onSecondary;
        }
        return colorScheme.onSurface;
      }),
      splashRadius: 22,
    );
  }
}
