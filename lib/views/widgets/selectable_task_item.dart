import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:minimaltodo/data_models/category_model.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/helpers/mini_utils.dart';
import 'package:minimaltodo/services/category_service.dart';
import 'package:minimaltodo/services/task_service.dart';
import 'package:minimaltodo/view_models/calendar_view_model.dart';
import 'package:minimaltodo/view_models/category_view_model.dart';
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
                      scale: 1.09,
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
                      padding: const EdgeInsets.fromLTRB(0, 12, 10, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Consumer2<CalendarViewModel, TaskViewModel>(
                                    builder: (context, calVM, taskVM, _) {
                                      final date = DateTime(calVM.selectedDate.year, calVM.selectedDate.month, calVM.selectedDate.day).millisecondsSinceEpoch;
                                      final isCompleted = widget.task.isRepeating!
                                          ? taskVM.recurringTaskCompletion[widget.task.id]?.contains(date) ?? false
                                          : taskVM.singleTaskCompletion[widget.task.id] ?? false;

                                      return Text(
                                        widget.task.title!,
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
                          Selector<CategoryViewModel,List<CategoryModel>>(
                          selector: (context, categoryVM)=>categoryVM.categories,
                            builder: (context,categories,_) {
                              return FutureBuilder<List<CategoryModel>>(
                                future: TaskService.getTaskCategories(widget.task.id!),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                    return SizedBox.shrink();
                                  }
                                  return SizedBox(
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
                                        itemCount: snapshot.data!.length,
                                        itemBuilder: (context, index) {
                                          final category = snapshot.data![index];
                                          return Container(
                                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: category.color != null
                                                  ? CategoryService.getColorFromString(context, category.color!).withAlpha(30)
                                                  : Theme.of(context).colorScheme.primary.withAlpha(20),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  CategoryService.getIcon(category.iconCode),
                                                  size: 12,
                                                  color: category.color != null
                                                      ? CategoryService.getColorFromString(context, category.color!)
                                                      : Theme.of(context).colorScheme.primary,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  category.name ?? '',
                                                  style: Theme.of(context).textTheme.labelSmall,
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );

                                },
                              );
                            }
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
