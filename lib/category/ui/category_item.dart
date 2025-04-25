import 'package:flutter/material.dart';
import 'package:minimaltodo/category/category_model.dart';
import 'package:minimaltodo/category/logic/category_view_model.dart';
import 'package:minimaltodo/category/ui/add_category_page.dart';
import 'package:minimaltodo/category/ui/tasks_for_category_page.dart';
import 'package:minimaltodo/helpers/icon_color_storage.dart';
import 'package:minimaltodo/helpers/mini_router.dart';
import 'package:minimaltodo/helpers/utils.dart';
import 'package:minimaltodo/task/logic/task_view_model.dart';
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
    final color = IconColorStorage.colors[widget.category.color] ?? Theme.of(context).colorScheme.primary;
    final icon = IconColorStorage.flattenedIcons[widget.category.icon];

    return Card(
      color: color.withAlpha(10),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      shape: RoundedRectangleBorder(
          side: BorderSide(width: 0.1,color: color), borderRadius: BorderRadius.circular(10),),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TasksForCategoryPage(category: widget.category)));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with icon, title and menu
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: color.withAlpha(50),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 13),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        widget.category.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
                              onTap: () {
                                MiniRouter.to(context,
                                    AddCategoryPage(edit: true, category: widget.category));
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: color, size: 20),
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
                                    content:
                                        const Text('Are you sure you want to delete the category?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('Cancel'),
                                      ),
                                      FilledButton(
                                        onPressed: () async {
                                          context
                                              .read<CategoryViewModel>()
                                              .deleteCategory(widget.category.id);
                                          Navigator.pop(context);
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
              // Additional content with proper constraint handling
              const SizedBox(height: 4),
              Flexible(
                child: Container(
                  alignment: Alignment.bottomRight,
                  child: Builder(builder: (context) {
                    return Consumer<TaskViewModel>(builder: (context, taskVM, _) {
                      final tasks = taskVM.tasks;
                      final count = tasks
                          .where((t) => t.categories.contains(widget.category))
                          .toList()
                          .length;
                      return Text(
                        '$count tasks',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: 12),
                      );
                    });
                  }),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
