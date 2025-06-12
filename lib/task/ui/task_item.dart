import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:minimaltodo/category/models/category_model.dart';
import 'package:minimaltodo/category/ui/category_chip.dart';
import 'package:minimaltodo/helpers/globals.dart' as g;
import 'package:minimaltodo/helpers/mini_router.dart';
import 'package:minimaltodo/task/models/task.dart';
import 'package:minimaltodo/task/ui/add_task_page.dart';

class TaskItem extends StatefulWidget {
  const TaskItem({super.key, required this.task});
  final Task task;
  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: g.taskVm,
      builder: (context, child) {
        final ids = g.taskVm.selectedTaskIds;
        final isSelected = ids.contains(widget.task.id);
        final isUrgent = widget.task.priority.toLowerCase() == 'urgent';

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
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashFactory: NoSplash.splashFactory,
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                if (ids.isEmpty) {
                  MiniRouter.to(context, AddTaskPage(edit: true, task: widget.task));
                } else {
                  g.taskVm.toggleSelection(widget.task.id);
                }
              },
              onLongPress: () {
                g.taskVm.toggleSelection(widget.task.id);
              },
              child: SizedBox(
                height: 72,
                child: Row(
                  children: [
                    _buildCheckbox(),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 12, 10, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              spacing: 8.0,
                              children: [
                                _buildTitle(),
                                _buildPriority(isUrgent, context),
                              ],
                            ),
                            const Spacer(),
                            // Info row
                            Row(
                              children: [
                                _buildCategories(),
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
                                    color: Theme.of(context).colorScheme.primary.withAlpha(200),
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

  Padding _buildCheckbox() {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Transform.scale(
        scale: 1.0,
        child: ListenableBuilder(
          listenable: Listenable.merge([g.taskVm, g.calMan]),
          builder: (context, child) {
            final repeat = widget.task.isRepeating;
            final stc = g.taskVm.singleTaskCompletions, rtc = g.taskVm.recurringTaskCompletions;
            final date = DateUtils.dateOnly(g.calMan.selectedDate).millisecondsSinceEpoch;
            final colorScheme = Theme.of(context).colorScheme;
            return CheckboxTheme(
              data: CheckboxThemeData(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
                side: WidgetStateBorderSide.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return BorderSide(
                      color: colorScheme.secondary,
                      width: 2.5,
                    );
                  }
                  if (states.contains(WidgetState.hovered)) {
                    return BorderSide(
                      color: colorScheme.secondary.withAlpha(160),
                      width: 2.5,
                    );
                  }
                  return BorderSide(
                    color: colorScheme.outline,
                    width: 2.0,
                  );
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
              ),
              child: Checkbox(
                key: ValueKey('selection_${widget.task.id}'),
                // shape: CircleBorder(),
                value: repeat
                    ? rtc[widget.task.id]?.contains(date) ?? false
                    : stc[widget.task.id] ?? false,
                onChanged: (value) {
                  g.taskVm.toggleStatus(widget.task, value ?? false, g.calMan.selectedDate);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Expanded _buildCategories() {
    return Expanded(
      child: SizedBox(
        height: 20,
        child: ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
              stops: [0.0, 0.05, 0.95, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: ListenableBuilder(
            listenable: g.catVm,
            builder: (context, child) {
              var categories = g.catVm.categories;
              widget.task.categories.removeWhere((c) => !categories.contains(c));
              if (widget.task.categories.isEmpty) {
                debugPrint('This condition called');
                widget.task.categories.add(CategoryModel(id: 1, name: 'General'));
                widget.task.categories.applyToDb();
              }
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                separatorBuilder: (context, index) => const SizedBox(width: 2),
                itemCount: widget.task.categories.length,
                itemBuilder: (context, index) {
                  final category = widget.task.categories[index];
                  return CategoryChip(category: category);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Row _buildPriority(bool isUrgent, BuildContext context) {
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
          widget.task.priority,
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.labelSmall!.fontSize,
            color: isUrgent ? Colors.red.shade400 : null,
          ),
        ),
      ],
    );
  }

  Expanded _buildTitle() {
    return Expanded(
      child: ListenableBuilder(
          listenable: Listenable.merge([g.calMan, g.taskVm]),
          builder: (context, child) {
            final date = DateUtils.dateOnly(g.calMan.selectedDate).millisecondsSinceEpoch;
            final repeat = widget.task.isRepeating;
            final stc = g.taskVm.singleTaskCompletions, rtc = g.taskVm.recurringTaskCompletions;
            final isFinished = repeat
                ? rtc[widget.task.id]?.contains(date) ?? false
                : stc[widget.task.id] ?? false;

            return Text(
              widget.task.title,
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
          }),
    );
  }
}
