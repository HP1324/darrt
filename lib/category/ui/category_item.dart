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
    final color =
        IconColorStorage.colors[widget.category.color] ?? Theme.of(context).colorScheme.primary;
    final icon = IconColorStorage.flattenedIcons[widget.category.icon];
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.1,
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3),
      child: ListTile(
        onTap: () {
          MiniRouter.to(context, TasksForCategoryPage(category: widget.category));
        },
        tileColor: scheme.surfaceContainer.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), side: BorderSide(color: color.withAlpha(50))),
        leading: CategoryIcon(color: color, icon: icon),
        title: CategoryNameLabel(category: widget.category, textTheme: textTheme),
        subtitle: TaskCountLabel(category: widget.category, textTheme: textTheme),
        trailing: widget.category.id != 1
            ? CategoryPopupMenuButton(popupKey: _popupKey, category: widget.category, color: color)
            : null,
      ),
    );
  }
}

class CategoryIcon extends StatelessWidget {
  const CategoryIcon({super.key, required this.color, required this.icon});

  final Color color;
  final dynamic icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: color.withAlpha(50),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 13),
    );
  }
}

class CategoryNameLabel extends StatelessWidget {
  const CategoryNameLabel({
    super.key,
    required this.category,
    required this.textTheme,
  });

  final CategoryModel category;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Text(
      category.name,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: textTheme.titleMedium?.copyWith(),
    );
  }
}

class TaskCountLabel extends StatelessWidget {
  const TaskCountLabel({
    super.key,
    required this.category,
    required this.textTheme,
  });

  final CategoryModel category;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: g.taskVm,
      builder: (context, child) {
        final tasks = g.taskVm.tasks;
        final count = tasks.where((t) => t.categories.contains(category)).toList().length;
        return Text(
          '$count ${count != 1 ? 'tasks' : 'task'}',
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: textTheme.labelMedium?.copyWith(),
        );
      },
    );
  }
}

class CategoryPopupMenuButton extends StatelessWidget {
  const CategoryPopupMenuButton({
    super.key,
    required GlobalKey<State<StatefulWidget>> popupKey,
    required this.category,
    required this.color,
  }) : _popupKey = popupKey;

  final GlobalKey<State<StatefulWidget>> _popupKey;
  final CategoryModel category;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: _popupKey,
      onTap: () {
        final (offset, size) = getOffsetAndSize(_popupKey);
        _showCategoryMenu(context, offset, size);
      },
      child: Icon(Icons.more_vert),
    );
  }

  Future<dynamic> _showCategoryMenu(BuildContext context, Offset offset, Size size) {
    return showMenu(
      context: context,
      position: getRelativeRectFromOffsetAndSize(offset, size),
      items: [
        PopupMenuItem(
          onTap: () {
            MiniRouter.to(context, AddCategoryPage(edit: true, category: category));
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
                content: const Text('Are you sure you want to delete the category?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () async {
                      final message = g.catVm.deleteItem(category.id);
                      showToast(context, type: ToastificationType.success, description: message);
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
