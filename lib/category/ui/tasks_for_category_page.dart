import 'package:flutter/material.dart';
import 'package:minimaltodo/category/models/task_category.dart';
import 'package:minimaltodo/helpers/icon_color_storage.dart';
import 'package:minimaltodo/helpers/mini_router.dart';
import 'package:minimaltodo/task/ui/add_task_page.dart';
import 'package:minimaltodo/task/ui/task_item.dart';
import 'package:minimaltodo/helpers/globals.dart' as g;

class TasksForCategoryPage extends StatefulWidget {
  const TasksForCategoryPage({super.key, required this.category});
  final TaskCategory category;
  @override
  State<TasksForCategoryPage> createState() => _TasksForCategoryPageState();
}

class _TasksForCategoryPageState extends State<TasksForCategoryPage> {
  @override
  void dispose() {
    g.taskVm.selectedItemIds.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: g.taskVm,
      builder: (context, child) {
        final tasks = g.taskVm.tasks.where((t) => t.categories.contains(widget.category)).toList();
        final color =
            IconColorStorage.colors[widget.category.color] ?? Theme.of(context).colorScheme.primary;
        final icon = IconColorStorage.flattenedIcons[widget.category.icon];
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Scaffold(
          backgroundColor: isDark
              ? Color.lerp(Theme.of(context).colorScheme.surface, color, 0.05)
              : Color.lerp(Colors.white, color, 0.03),
          appBar: AppBar(
            title: Text(widget.category.name),
            backgroundColor: color.withAlpha(25),
          ),
          body: Builder(
            builder: (context) {
              if (tasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: color, size: getIconSize(context)),
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  const SizedBox(height: 15),
                  if (g.taskVm.selectedTaskIds.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            g.taskVm.clearSelection();
                          },
                          icon: Icon(Icons.cancel),
                        ),
                        IconButton(
                          onPressed: () {
                            g.taskVm.deleteMultipleItems();
                          },
                          icon: Icon(Icons.delete),
                        ),
                      ],
                    ),
                  Expanded(
                    child: Scrollbar(
                      thickness: 7,
                      child: ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          return TaskItem(task: tasks[index]);
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => MiniRouter.to(context, AddTaskPage(edit: false, category: widget.category)),
            backgroundColor: IconColorStorage.colors[widget.category.color],
            tooltip: 'Add task to this category',
            label: Text('Add task'),
            icon: Icon(Icons.add),
          ),
        );
      },
    );
  }

  double getIconSize(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    double iconSize = screenWidth * 0.2;

    return iconSize.clamp(60.0, 120.0);
  }
}
