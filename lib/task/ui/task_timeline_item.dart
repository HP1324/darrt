  import 'package:darrt/task/statistics/stats_page.dart';
  import 'package:flutter/material.dart';
  import 'package:intl/intl.dart';
  import 'package:font_awesome_flutter/font_awesome_flutter.dart';
  import 'package:darrt/category/ui/category_chip.dart';
  import 'package:darrt/helpers/globals.dart' as g;
  import 'package:darrt/helpers/mini_router.dart';
  import 'package:darrt/task/models/task.dart';
  import 'package:darrt/task/ui/add_task_page.dart';

  class TaskTimelineItem extends StatefulWidget {
    const TaskTimelineItem({
      super.key,
      required this.task,
      required this.isLast,
    });

    final Task task;
    final bool isLast;

    @override
    State<TaskTimelineItem> createState() => _TaskTimelineItemState();
  }

  class _TaskTimelineItemState extends State<TaskTimelineItem> {
    @override
    Widget build(BuildContext context) {
      // MiniLogger.dp('Timeline Task: title: ${widget.task.title}, id: ${widget.task.id}');
      return ListenableBuilder(
        listenable: g.taskVm,
        builder: (context, child) {
          final ids = g.taskVm.selectedTaskIds;
          final isSelected = ids.contains(widget.task.id);
          return TimelineTaskContainer(
            task: widget.task,
            isSelected: isSelected,
            isLast: widget.isLast,
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

  class TimelineTaskContainer extends StatelessWidget {
    const TimelineTaskContainer({
      super.key,
      required this.task,
      required this.isSelected,
      required this.isLast,
      required this.onTap,
      required this.onLongPress,
    });

    final Task task;
    final bool isSelected;
    final bool isLast;
    final VoidCallback onTap;
    final VoidCallback onLongPress;

    @override
    Widget build(BuildContext context) {
      final scheme = Theme.of(context).colorScheme;
      final hasTime = task.startTime != null;

      return Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: 2,
                        // margin: const EdgeInsets.only(top: 1),
                        decoration: BoxDecoration(
                          color: hasTime
                              ? scheme.outline.withValues(alpha: 0.8)
                              : scheme.outline.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                    // Timeline checkpoint (checkbox)
                    TimelineCheckbox(task: task),
                    // Timeline line
                    // if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        // margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: hasTime
                              ? scheme.outline.withValues(alpha: 0.8)
                              : scheme.outline.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Task content
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onTap,
                  onLongPress: onLongPress,
                  child: Container(
                    // margin: const EdgeInsets.only(left: 12, top: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? scheme.outline.withValues(alpha: 0.7)
                          : scheme.surface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: scheme.outline.withValues(alpha: 0.25),
                        width: 0.5,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: TimelineTaskContent(task: task),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  class TimelineTaskContent extends StatelessWidget {
    const TimelineTaskContent({
      super.key,
      required this.task,
    });

    final Task task;

    @override
    Widget build(BuildContext context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TimelineTaskTime(task: task),
          const SizedBox(height: 8),
          TimelineTaskTitle(task: task),
          const SizedBox(height: 8),
          TimelineTaskInfo(task: task),
        ],
      );
    }
  }

  class TimelineTaskTitle extends StatelessWidget {
    const TimelineTaskTitle({super.key, required this.task});

    final Task task;

    @override
    Widget build(BuildContext context) {
      return ListenableBuilder(
        listenable: Listenable.merge([g.calMan, g.taskVm]),
        builder: (context, child) {
          final textTheme = Theme.of(context).textTheme;
          final scheme = Theme.of(context).colorScheme;
          final date = DateUtils.dateOnly(g.calMan.selectedDate).millisecondsSinceEpoch;
          final repeat = task.isRepeating;
          final stc = g.taskVm.onetimeTaskCompletions;
          final rtc = g.taskVm.repeatingTaskCompletions;
          final isFinished = repeat ? rtc[task.id]?.contains(date) ?? false : stc[task.id] ?? false;
          return Row(
            children: [
              Expanded(
                child: Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: textTheme.titleSmall!.fontSize,
                    fontWeight: FontWeight.w600,
                    decorationColor: scheme.outline,
                    decorationThickness: 2,
                    decoration: isFinished ? TextDecoration.lineThrough : null,
                    color: isFinished ? scheme.outline : scheme.onSurface,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  class TimelineTaskInfo extends StatelessWidget {
    const TimelineTaskInfo({
      super.key,
      required this.task,
    });

    final Task task;

    @override
    Widget build(BuildContext context) {
      final scheme = Theme.of(context).colorScheme;
      return Row(
        children: [
          // Categories
          Expanded(
            child: TimelineTaskCategories(task: task),
          ),
          if (task.isRepeating && (task.startTime == null && task.endTime == null)) ...[
            Icon(
              FontAwesomeIcons.repeat,
              size: 13,
              color: scheme.primary.withAlpha(200),
            ),
            const SizedBox(width: 8),
            // InkWell(
            //   borderRadius: BorderRadius.circular(8),
            //   onTap: () => MiniRouter.to(context, StatsPage(habit: task)),
            //   child: Icon(
            //     Icons.calendar_month_outlined,
            //     size: 21,
            //     color: scheme.secondary,
            //   ),
            // ),
          ],
        ],
      );
    }
  }

  class TimelineTaskCategories extends StatelessWidget {
    const TimelineTaskCategories({
      super.key,
      required this.task,
    });

    final Task task;

    @override
    Widget build(BuildContext context) {
      return SizedBox(
        height: 20,
        child: ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
              stops: [0.0, 0.05, 0.95, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            separatorBuilder: (context, index) => const SizedBox(width: 5),
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

  class TimelineTaskTime extends StatelessWidget {
    const TimelineTaskTime({
      super.key,
      required this.task,
    });

    final Task task;

    @override
    Widget build(BuildContext context) {
      final start = task.startTime;
      final end = task.endTime;

      if (start == null) return const SizedBox.shrink();

      final timeFormat = DateFormat.jm(); // 12/24 hr format by locale
      final startStr = timeFormat.format(start);
      final endStr = end != null ? timeFormat.format(end) : null;
      final timeDisplay = endStr != null ? "$startStr - $endStr" : startStr;

      final theme = Theme.of(context);

      return Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4,vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: theme.colorScheme.primary.withValues(alpha:0.5))
            ),
            child: Text(
              timeDisplay,
              style: TextStyle(
                fontSize: theme.textTheme.labelSmall!.fontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Spacer(),
          if (task.isRepeating) ...[
            Icon(
              FontAwesomeIcons.repeat,
              size: 13,
              color: theme.colorScheme.primary.withAlpha(200),
            ),
            const SizedBox(width: 8),
            // InkWell(
            //   borderRadius: BorderRadius.circular(8),
            //   onTap: () => MiniRouter.to(context, StatsPage(habit: task)),
            //   child: Icon(Icons.calendar_month_outlined, size: 21, color: theme.colorScheme.secondary),
            // ),
          ],
        ],
      );
    }
  }


  class TimelineCheckbox extends StatelessWidget {
    const TimelineCheckbox({super.key, required this.task});

    final Task task;

    @override
    Widget build(BuildContext context) {
      return SizedBox(
        width: 24,
        height: 24,
        child: ListenableBuilder(
          listenable: Listenable.merge([g.taskVm, g.calMan]),
          builder: (context, child) {
            final repeat = task.isRepeating;
            final oneTimeCompletions = g.taskVm.onetimeTaskCompletions;
            final repeatingCompletions = g.taskVm.repeatingTaskCompletions;
            final date = DateUtils.dateOnly(g.calMan.selectedDate).millisecondsSinceEpoch;
            final isCompleted = repeat
                ? repeatingCompletions[task.id]?.contains(date) ?? false
                : oneTimeCompletions[task.id] ?? false;

            return CheckboxTheme(
              data: _buildTimelineCheckboxTheme(context, isCompleted),
              child: Checkbox(
                value: isCompleted,
                onChanged: (value) {
                  g.taskVm.toggleStatus(task, value ?? false, g.calMan.selectedDate, context);
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            );
          },
        ),
      );
    }

    CheckboxThemeData _buildTimelineCheckboxTheme(BuildContext context, bool isCompleted) {
      final colorScheme = Theme.of(context).colorScheme;
      final hasTime = task.startTime != null;

      return CheckboxThemeData(
        shape: const CircleBorder(),
        side: WidgetStateBorderSide.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return BorderSide(
              color: hasTime ? colorScheme.primary : colorScheme.outline,
              width: 2,
            );
          }
          return BorderSide(
            color: hasTime
                ? colorScheme.primary.withValues(alpha: 0.6)
                : colorScheme.outline.withValues(alpha: 0.4),
            width: 2,
          );
        }),
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return hasTime ? colorScheme.primary : colorScheme.outline;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return hasTime ? colorScheme.onPrimary : colorScheme.surface;
          }
          return colorScheme.onSurface;
        }),
        overlayColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.pressed)) {
            return (hasTime ? colorScheme.primary : colorScheme.outline).withValues(alpha: 0.1);
          }
          return Colors.transparent;
        }),
      );
    }
  }
