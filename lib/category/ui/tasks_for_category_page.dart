import 'package:flutter/material.dart';
import 'package:minimaltodo/category/category_model.dart';
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
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category.name)),
      body: Consumer<TaskViewModel>(
        builder: (context,taskVM,_) {
          final tasks = taskVM.tasks.where((t) => t.categories.contains(widget.category)).toList();
          return Column(
            children: [
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
                        context.read<TaskViewModel>().deleteSelectedTasks();
                      },
                      icon: Icon(Icons.delete),
                    ),
                  ],
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return TaskItem(task: tasks[index]);
                  },
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}
