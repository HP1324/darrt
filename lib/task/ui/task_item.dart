import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:minimaltodo/app/calendar_view_model.dart';
import 'package:minimaltodo/category/ui/category_chip.dart';
import 'package:minimaltodo/helpers/utils.dart';
import 'package:minimaltodo/task/logic/task_view_model.dart';
import 'package:minimaltodo/task/task.dart';
import 'package:minimaltodo/task/ui/add_task_page.dart';
import 'package:provider/provider.dart';

class TaskItem extends StatefulWidget {
  const TaskItem({super.key, required this.task});
  final Task task;
  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  @override
  Widget build(BuildContext context) {
    return Selector<TaskViewModel, Set<int>>(
      selector: (context, taskVM) => taskVM.selectedTaskIds,
      builder: (context, ids, _) {
        final isSelected = ids.contains(widget.task.id);
        final isUrgent = widget.task.priority.toLowerCase() == 'urgent';

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withAlpha(60)
                : Theme.of(context).colorScheme.surface.withAlpha(100),
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? null : Border.all(
              color: Theme.of(context).colorScheme.primary.withAlpha(80),
              width: 0.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashFactory: InkSparkle.splashFactory,
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                if (ids.isEmpty) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddTaskPage(edit: true, task: widget.task)));
                } else {
                  context.read<TaskViewModel>().toggleSelection(widget.task.id);
                }
              },
              onLongPress: () {
                context.read<TaskViewModel>().toggleSelection(widget.task.id);
              },
              child: SizedBox(
                height: 72,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Transform.scale(
                        scale: 1.09,
                        child: Consumer2<TaskViewModel, CalendarViewModel>(
                            builder: (context, taskVM, calVM, _) {
                              final repeat = widget.task.isRepeating;
                              final stc = taskVM.singleTaskCompletions, rtc = taskVM.recurringTaskCompletions;
                              final date = DateUtils.dateOnly(calVM.selectedDate).millisecondsSinceEpoch;
                              return Checkbox(
                                key: ValueKey('selection_${widget.task.id}'),
                                shape: CircleBorder(),
                                value: repeat ? rtc[widget.task.id]?.contains(date) ?? false : stc[widget.task.id] ?? false,
                                onChanged: (value) {
                                  debugPrint('TaskVM hashcode: ${taskVM.hashCode}');
                                  debugPrint('GetIt TaskVM hashcode: ${getIt<TaskViewModel>().hashCode}');
                                  // debugPrint('GetIt TaskVM hashcode: ${getIt<TaskViewModel>().hashCode}');
                                  // taskVM.toggleStatus(widget.task, value ?? false, calVM.selectedDate);
                                  getIt<TaskViewModel>().toggleStatus(widget.task, value ?? false, calVM.selectedDate);
                                },
                              );
                            }
                        ),
                      ),
                    ),

                    // Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 12, 10, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Consumer2<CalendarViewModel, TaskViewModel>(
                                      builder: (context, calVM, taskVM, _) {
                                        final date = DateUtils.dateOnly(calVM.selectedDate).millisecondsSinceEpoch;
                                        final repeat = widget.task.isRepeating;
                                        final stc = taskVM.singleTaskCompletions, rtc = taskVM.recurringTaskCompletions;
                                        final isCompleted = repeat ? rtc[widget.task.id]?.contains(date) ?? false : stc[widget.task.id] ?? false;

                                        return Text(
                                          widget.task.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: Theme.of(context).textTheme.titleSmall!.fontSize,
                                            fontWeight: FontWeight.w500,
                                            decorationColor: Theme.of(context).colorScheme.outline,
                                            decorationThickness: 2,
                                            color: isCompleted
                                                ? Theme.of(context).colorScheme.outline
                                                : Theme.of(context).colorScheme.onSurface,
                                          ),
                                        );
                                      }
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.flag_outlined,
                                      size: 14,
                                      color: isUrgent ? Colors.red.shade400 : null,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.task.priority,
                                      style: TextStyle(
                                        fontSize: Theme.of(context)
                                            .textTheme
                                            .labelSmall!
                                            .fontSize,
                                        color:
                                        isUrgent ? Colors.red.shade400 : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Spacer(),
                            // Info row
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 20,
                                    child: ShaderMask(
                                      shaderCallback: (bounds) {
                                        return LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black,
                                            Colors.black,
                                            Colors.transparent
                                          ],
                                          stops: [0.0, 0.05, 0.95, 1.0],
                                        ).createShader(bounds);
                                      },
                                      blendMode: BlendMode.dstIn,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        physics: BouncingScrollPhysics(),
                                        separatorBuilder: (context, index) => const SizedBox(width: 2),
                                        itemCount: widget.task.categories.length,
                                        itemBuilder: (context, index) {
                                          final category = widget.task.categories[index];
                                          return CategoryChip(category:category);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                if (!widget.task.isRepeating) ...[
                                  Text(
                                    DateFormat('MMM d').format(widget.task.dueDate),
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                if (widget.task.isRepeating) ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    FontAwesomeIcons.repeat,
                                    size: 13,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withAlpha(200),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
