import 'package:darrt/app/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:darrt/category/models/task_category.dart';
import 'package:darrt/category/ui/add_category_page.dart';
import 'package:darrt/category/ui/tasks_for_category_page.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/icon_color_storage.dart';
import 'package:darrt/helpers/mini_router.dart';
import 'package:darrt/helpers/utils.dart';

class CategoryItem extends StatefulWidget {
  const CategoryItem({super.key, required this.category});

  final TaskCategory category;

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
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color.withAlpha(50)),
        ),
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

  final TaskCategory category;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Text(
      category.uuid == 'general' ?  '${category.name} (Default)':category.name,
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

  final TaskCategory category;
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
  final TaskCategory category;
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
              builder: (context) => _DeleteCategoryDialog(categoryId: category.id),
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

class _DeleteCategoryDialog extends StatefulWidget {
  const _DeleteCategoryDialog({required this.categoryId});

  final int categoryId;

  @override
  State<_DeleteCategoryDialog> createState() => _DeleteCategoryDialogState();
}

class _DeleteCategoryDialogState extends State<_DeleteCategoryDialog> {
  bool deleteTasks = false;
  @override
  void dispose() {
    deleteTasks = false;
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Are you sure you want to delete the category?'),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: deleteTasks,
            title: FittedBox(child: Text('Delete tasks in this category?')),
            onChanged: (newValue) {
              setState(() {
                deleteTasks = newValue ?? false;
              });
            },
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () async {
            final message = g.catVm.deleteItem(widget.categoryId, deleteTasks: deleteTasks);
            showSuccessToast(context,  message);
            Navigator.pop(context);
          },
          child: const Text('Delete'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
