import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/helpers/mini_utils.dart';
import 'package:minimaltodo/services/category_service.dart';
import 'package:minimaltodo/view_models/calendar_view_model.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';
import 'package:provider/provider.dart';

class SelectableTaskItem extends StatefulWidget {
  const SelectableTaskItem({
    super.key,
    required this.task,
    required this.isSelected,
    required this.onSelectionChanged,
    this.onTap,
  });

  final Task task;
  final bool isSelected;
  final Function(bool) onSelectionChanged;
  final VoidCallback? onTap;

  @override
  State<SelectableTaskItem> createState() => SelectableTaskItemState();
}

class SelectableTaskItemState extends State<SelectableTaskItem> {

  @override
  Widget build(BuildContext context) {
      debugPrint("widget context: ${context.hashCode}");
      final isUrgent = widget.task.priority?.toLowerCase() == 'urgent';
      return Container(

        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? Theme.of(context).colorScheme.primary.withAlpha(60)
              : Theme.of(context).colorScheme.surface.withAlpha(100),
          borderRadius: BorderRadius.circular(12),
          border:widget.isSelected ? null : Border.all(
            color: Theme.of(context).colorScheme.primary.withAlpha(80),
            width: 0.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.onTap ??() {
                  widget.onSelectionChanged(!widget.isSelected);
                },
            child: SizedBox(
              height: 72,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: Transform.scale(
                      scale: 1.05,
                      child: Consumer2<CalendarViewModel,TaskViewModel>(
                        builder: (context,calVM,taskVM, _) {
                          final date = DateTime(calVM.selectedDate.year,calVM.selectedDate.month,calVM.selectedDate.day).millisecondsSinceEpoch;
                          return Checkbox(
                            key: ValueKey('selection_${widget.task.id}'),
                            shape: CircleBorder(),
                            value: widget.task.isRepeating! ? taskVM.recurringTaskCompletion[widget.task.id]?.contains(date) ??false: taskVM.singleTaskCompletion[widget.task.id] ?? false,
                            onChanged: (checked) {
                              if(checked != null ) {
                                taskVM.toggleStatus(widget.task, checked, calVM);
                              }
                            },
                          );
                        }
                      ),
                    ),
                  ),

                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 12, 4, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.task.title!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .fontSize,
                                    fontWeight: FontWeight.w500,
                                    decorationColor:
                                        Theme.of(context).colorScheme.outline,
                                    decorationThickness: 2,
                                    color: widget.task.isDone!
                                        ? Theme.of(context).colorScheme.outline
                                        : null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.flag_outlined,
                                    size: 14,
                                    color:
                                        isUrgent ? Colors.red.shade400 : null,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.task.priority!,
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
                              if (widget.task.dueDate != null && !widget.task.isRepeating!) ...[
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 14,
                                  color: isUrgent ? Colors.red.shade400 : null,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  formatTime(widget.task.dueDate!),
                                  style: TextStyle(
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .labelSmall!
                                        .fontSize,
                                    color:
                                        isUrgent ? Colors.red.shade400 : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                              Icon(
                                widget.task.category?.iconCode != null
                                    ? CategoryService.getIcon(
                                        widget.task.category!.iconCode)
                                    : Iconsax.folder_2,
                                size: 14,
                                color: widget.task.category?.color != null
                                    ? CategoryService.getColorFromString(
                                        context, widget.task.category?.color)
                                    : null,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.task.category?.name ?? 'General',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .labelSmall!
                                        .fontSize,
                                  ),
                                ),
                              ),
                              if (widget.task.isRepeating ?? false) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  FontAwesomeIcons.repeat,
                                  size: 14,
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
  }
}
