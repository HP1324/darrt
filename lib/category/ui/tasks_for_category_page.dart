import 'package:flutter/material.dart';
import 'package:minimaltodo/category/category_model.dart';
import 'package:minimaltodo/helpers/icon_color_storage.dart';
import 'package:minimaltodo/task/logic/task_view_model.dart';
import 'package:minimaltodo/task/ui/task_item.dart';
import 'package:provider/provider.dart';


class TasksForCategoryPage extends StatefulWidget {
  const TasksForCategoryPage({super.key, required this.category});
  final CategoryModel category;
  @override
  State<TasksForCategoryPage> createState() => _TasksForCategoryPageState();
}

class _TasksForCategoryPageState extends State<TasksForCategoryPage> {

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskViewModel>(
      builder: (context, taskVM, _) {
        final tasks = taskVM.tasks.where((t) => t.categories.contains(widget.category)).toList();
        final color = IconColorStorage.colors[widget.category.color] ?? Theme.of(context).colorScheme.primary;
        final icon = IconColorStorage.flattenedIcons[widget.category.icon];
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Scaffold(
          backgroundColor: isDark
              ? Color.lerp(Theme.of(context).colorScheme.surface, color, 0.14)
              : Color.lerp(Colors.white, color, 0.05),
          appBar: AppBar(title: Text(widget.category.name),backgroundColor: color.withAlpha(25),),
          body: tasks.isEmpty
              ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 70),
                ],
              ))
              : Column(
            children: [
              const SizedBox(height: 15),
              if (taskVM.selectedTaskIds.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        context.read<TaskViewModel>().clearSelection();
                      },
                      icon: Icon(Icons.cancel),
                    ),
                    IconButton(
                      onPressed: () {
                        context.read<TaskViewModel>().deleteMultipleItems();
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
          ),
        );
      },
    );
  }
}
