import 'package:flutter/material.dart';
import 'package:minimaltodo/app_router.dart';
import 'package:minimaltodo/data_models/category_model.dart';
import 'package:minimaltodo/global_utils.dart';
import 'package:minimaltodo/services/category_service.dart';
import 'package:minimaltodo/view_models/category_view_model.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';
import 'package:minimaltodo/views/pages/new_list_page.dart';
import 'package:minimaltodo/views/pages/tasks_for_category_page.dart';
import 'package:provider/provider.dart';

class CategoryItem extends StatefulWidget {
  const CategoryItem({
    super.key,
    required this.list,
  });

  final CategoryModel list;

  @override
  State<CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem> {
  final GlobalKey _popupKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Consumer2<TaskViewModel, CategoryViewModel>(builder: (context, taskVM, categoryVM, _) {
      final tasksInList = taskVM.tasks.where((task) => task.category?.id == widget.list.id).toList();
      final completedTasks = tasksInList.where((task) => task.isDone == true).length;

      final listColor = widget.list.color != null ? CategoryService.getColorFromString(context, widget.list.color) : Theme.of(context).colorScheme.primary;

      return Card(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        shape: RoundedRectangleBorder(side: BorderSide(width: 0.1), borderRadius: BorderRadius.circular(10)),
        child: InkWell(
          onTap: () => AppRouter.to(context, child: TasksForCategoryPage(list: widget.list)),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: listColor.withAlpha(50),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(CategoryService.getIcon(widget.list.iconCode), color: listColor, size: 13),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.list.name ?? 'Unnamed List',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (widget.list.id != 1)
                      InkWell(
                        key: _popupKey,
                        onTap: () {
                          //Had to calculate the InkWell's position because showMenu does not give direct control for placing the popup menu under the button directly. So I calculated the InkWell's position on the screen and passed it as arguments to RelativeRect.9fromLTRB().
                          final RenderBox renderBox = _popupKey.currentContext!.findRenderObject() as RenderBox;
                          final position = renderBox.localToGlobal(Offset.zero);
                          final size = renderBox.size;
                          showMenu(
                            context: context,
                            position: RelativeRect.fromLTRB(
                              position.dx,
                              position.dy + size.height,
                              position.dx + size.width,
                              position.dy,
                            ),
                            items: [
                              PopupMenuItem(
                                onTap: () => AppRouter.to(context, child: NewListPage(editMode: true, listToEdit: widget.list)),
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, color: listColor, size: 20),
                                    const SizedBox(width: 8),
                                    const Text('Edit'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      content: const Text(
                                          'Are you sure you want to delete the list? All tasks in this list will be moved to the General list.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: const Text('Cancel'),
                                        ),
                                        FilledButton(
                                          onPressed: () async {
                                            final nav = Navigator.of(context);
                                            final deleted = await categoryVM.deleteCategory(widget.list, taskVM);
                                            if (deleted) {
                                              showToast(title: 'List Deleted');
                                              nav.pop();
                                            }
                                          },
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red, size: 20),
                                    const SizedBox(width: 8),
                                    const Text('Delete', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                        child: Icon(Icons.more_horiz, size: 19),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (tasksInList.isNotEmpty)
                  SizedBox(
                    height: 4,
                    child: LinearProgressIndicator(
                      value: completedTasks / tasksInList.length,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      valueColor: AlwaysStoppedAnimation(listColor),
                    ),
                  ),

                // Third Row: Task Count
                const SizedBox(height: 4),
                Text(
                  '$completedTasks/${tasksInList.length}',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
