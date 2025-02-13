import 'package:flutter/material.dart';
import 'package:minimaltodo/data_models/category_model.dart';
import 'package:minimaltodo/helpers/mini_router.dart';
import 'package:minimaltodo/helpers/mini_utils.dart';
import 'package:minimaltodo/services/category_service.dart';
import 'package:minimaltodo/services/task_service.dart';
import 'package:minimaltodo/view_models/category_view_model.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';
import 'package:minimaltodo/views/pages/new_category_page.dart';
import 'package:minimaltodo/views/pages/tasks_for_category_page.dart';
import 'package:provider/provider.dart';

class CategoryItem extends StatefulWidget {
  const CategoryItem({
    super.key,
    required this.category,
  });

  final CategoryModel category;

  @override
  State<CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem> {
  final GlobalKey _popupKey = GlobalKey();
  @override
  Widget build(BuildContext context) {



      return FutureBuilder(
        future: TaskService.getCategoryTasks(widget.category.id!),

        builder: (context,snapshot) {
          final tasksInCategory = snapshot.data ?? [];
          final completedTasks = tasksInCategory.where((task) => task.isDone == true).length;
          final listColor = widget.category.color != null ? CategoryService.getColorFromString(context, widget.category.color) : Theme.of(context).colorScheme.primary;
          return Card(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            shape: RoundedRectangleBorder(side: BorderSide(width: 0.1), borderRadius: BorderRadius.circular(10)),
            child: InkWell(
              onTap: () => MiniRouter.to(context, child: TasksForCategoryPage(category: widget.category)),
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
                          child: Icon(CategoryService.getIcon(widget.category.iconCode), color: listColor, size: 13),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.category.name ?? 'Unnamed List',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (widget.category.id != 1)
                          InkWell(
                            key: _popupKey,
                            onTap: () {
                              final (position, size) = getPositionAndSize(_popupKey);
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
                                    onTap: () => MiniRouter.to(context, child: NewCategoryPage(editMode: true, category: widget.category)),
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
                                                final deleted = await context.read<CategoryViewModel>().deleteCategory(widget.category);
                                                if (deleted) {
                                                  // showToast(title: 'List Deleted');
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
                    if (tasksInCategory.isNotEmpty)
                      SizedBox(
                        height: 4,
                        child: LinearProgressIndicator(
                          value: completedTasks / tasksInCategory.length,
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          valueColor: AlwaysStoppedAnimation(listColor),
                        ),
                      ),

                    // Third Row: Task Count
                    const SizedBox(height: 4),
                    Text(
                      '$completedTasks/${tasksInCategory.length}',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      );
  }
}
