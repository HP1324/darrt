import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/global_utils.dart';
import 'package:minimaltodo/services/list_service.dart';
import 'package:minimaltodo/theme/app_theme.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';
import 'package:provider/provider.dart';

class SelectableTaskItem extends StatefulWidget {
  const SelectableTaskItem({
    super.key,
    required this.task,
    required this.isSelected,
    required this.onSelectionChanged,
    this.onTap,
    this.onStatusChanged,
  });

  final Task task;
  final bool isSelected;
  final Function(bool) onSelectionChanged;
  final Function()? onTap;
  final Function(bool)? onStatusChanged;

  @override
  State<SelectableTaskItem> createState() => _SelectableTaskItemState();
}

class _SelectableTaskItemState extends State<SelectableTaskItem> {
  late bool _isChecked;
  @override
  void initState() {
    super.initState();
    _isChecked = widget.task.isDone!;
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<TaskViewModel>(builder: (context, tvm, __) {
      final isUrgent = widget.task.priority?.toLowerCase() == 'urgent';
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: widget.isSelected ? Theme.of(context).colorScheme.primary.withAlpha(60) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.isSelected
                ? Theme.of(context).colorScheme.primary
                : isUrgent && !widget.task.isDone!
                    ? Colors.red.shade200
                    : Theme.of(context).colorScheme.surface,
            width: widget.isSelected ? 2 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.onTap ?? () => widget.onSelectionChanged(!widget.isSelected),
            child: SizedBox(
              height: 72,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Transform.scale(
                      scale: 1.1,
                      child: Checkbox(
                        key: ValueKey('selection_${widget.task.id}'),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        activeColor: Theme.of(context).colorScheme.primary,
                        checkColor: Colors.white,
                        value: _isChecked,
                        onChanged: (value) {
                          if (widget.onStatusChanged != null) {
                            setState(() {
                              _isChecked = value!;
                            });
                            widget.onStatusChanged!(value ?? false);
                            showToast(title: value ?? false ? 'Task finished' : 'Task marked pending');
                          }
                        },
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
                                    fontSize: Theme.of(context).textTheme.titleSmall!.fontSize,
                                    fontWeight: FontWeight.w500,
                                    decoration: widget.task.isDone!
                                        ? TextDecoration.lineThrough
                                        : null,
                                    decorationColor: Colors.grey,
                                    decorationThickness: 2,
                                    color: widget.task.isDone!
                                        ? Colors.grey
                                        : Colors.black87,
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
                                    color: isUrgent ? Colors.red.shade400 : Theme.of(context).colorScheme.primary.withAlpha(135),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.task.priority!,
                                    style: TextStyle(
                                      fontSize: Theme.of(context).textTheme.labelSmall!.fontSize,
                                      color: isUrgent ? Colors.red.shade400 : Theme.of(context).colorScheme.primary.withAlpha(135),
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
                              if (widget.task.dueDate != null) ...[
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 14,
                                  color: isUrgent ? Colors.red.shade400 : Theme.of(context).colorScheme.primary.withAlpha(170),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  formatTime(widget.task.dueDate!),
                                  style: TextStyle(
                                    fontSize: Theme.of(context).textTheme.labelSmall!.fontSize,
                                    color: isUrgent ? Colors.red.shade400 : Theme.of(context).colorScheme.primary.withAlpha(160),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                              Icon(
                                widget.task.list?.iconCode != null
                                    ? ListService.getIcon(widget.task.list!.iconCode)
                                    : Iconsax.folder_2,
                                size: 14,
                                color: widget.task.list?.listColor != null
                                    ? ListService.getColorFromString(widget.task.list?.listColor) :Theme.of(context).colorScheme.primary.withAlpha(160),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.task.list?.name ?? 'General',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: Theme.of(context).textTheme.labelSmall!.fontSize,
                                    color: Theme.of(context).colorScheme.primary.withAlpha(160),
                                  ),
                                ),
                              ),
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
    });
  }
}

String formatDateTime(DateTime dateTime) {
  return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
}
