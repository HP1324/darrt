import 'package:flutter/material.dart';
import 'package:minimaltodo/category/models/category_model.dart';
import 'package:minimaltodo/category/ui/add_category_page.dart';
import 'package:minimaltodo/category/ui/tasks_for_category_page.dart';
import 'package:minimaltodo/helpers/globals.dart' as g;
import 'package:minimaltodo/helpers/icon_color_storage.dart';
import 'package:minimaltodo/helpers/mini_router.dart';
import 'package:minimaltodo/helpers/utils.dart';
import 'package:toastification/toastification.dart';

class CategoryItem extends StatefulWidget {
  const CategoryItem({super.key, required this.category});

  final CategoryModel category;

  @override
  State<CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem> {
  final GlobalKey _popupKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final color =IconColorStorage.colors[widget.category.color] ?? Theme.of(context).colorScheme.primary;
    final icon = IconColorStorage.flattenedIcons[widget.category.icon];
    final textTheme = Theme.of(context).textTheme;
    return Card(
      color: color.withAlpha(10),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color.withValues(alpha: 0.20)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () {
          MiniRouter.to(context, TasksForCategoryPage(category: widget.category));
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
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
                        style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (widget.category.id != 1)
                    InkWell(
                      key: _popupKey,
                      onTap: () {
                        final (offset, size) = getOffsetAndSize(_popupKey);
                        _showCategoryMenu(context, offset, size, color);
                      },
                      child: Icon(Icons.more_horiz, size: 19),
                    ),
                ],
              ),
              // Additional content with proper constraint handling
              Flexible(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: ListenableBuilder(
                    listenable: g.taskVm,
                    builder: (context, child) {
                      final tasks = g.taskVm.tasks;
                      final count = tasks
                          .where((t) => t.categories.contains(widget.category))
                          .toList()
                          .length;
                      return Text(
                        '$count ${count != 1 ? 'tasks' : 'task'}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: textTheme.labelSmall?.copyWith(),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryMenu(BuildContext context, Offset offset, Size size, Color color) {
    showMenu(
      context: context,
      position: getRelativeRectFromOffsetAndSize(offset, size),
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
                      final message = g.catVm
                          .deleteItem(widget.category.id);
                      showToast(context,
                          type: ToastificationType.success,
                          description: message);
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
  }
}
