import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:minimaltodo/app_router.dart';
import 'package:minimaltodo/services/category_service.dart';
import 'package:minimaltodo/global_utils.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/view_models/category_view_model.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';
import 'package:minimaltodo/views/pages/task_editor_page.dart';
import 'package:provider/provider.dart';

class TaskView extends StatelessWidget {
  const TaskView({super.key, required this.task});
  final Task task;
  @override
  Widget build(BuildContext context) {
    task.printTask();
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(30), title: Text('${task.title}')),
      floatingActionButton: TaskViewButton(
        label: 'Edit',
        onTap: () {
          AppRouter.to(context, child: TaskEditorPage(editMode: true, taskToEdit: task));
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Consumer2<TaskViewModel, CategoryViewModel>(builder: (_, tvm, cvm, __) {
          debugPrint('Finished At: ${tvm.currentTask.finishedAt}');

          task.printTask();
          return ListView(
            children: [
              DetailItem(
                icon: Icons.assignment_outlined,
                title: 'Task',
                subtitle: '${task.title}',
              ),
              DetailItem(
                icon: CategoryService.getIcon(task.category!.iconCode),
                title: 'Category',
                subtitle: task.category!.name ?? 'General',
              ),
              DetailItem(
                icon: Icons.flag_outlined,
                title: 'Priority',
                subtitle: '${task.priority}',
              ),
              DetailItem(
                icon: Icons.calendar_today,
                title: 'Created',
                subtitle: formatDateTime(task.createdAt!),
              ),
              DetailItem(
                icon: Icons.event_outlined,
                title: 'Due Date',
                subtitle: task.dueDate == null
                    ? 'Not scheduled'
                    : "${formatDateTime(task.dueDate!)}\n${task.isDone! ? 'Task Finished' : (task.dueDate!.isBefore(DateTime.now()) ? 'Task Overdue' : (task.isNotifyEnabled! ? 'Notify on ${formatDateTime(task.notifyTime!)}' : 'Notification Disabled'))}",
              ),
              DetailItem(
                icon: Icons.task_alt,
                title: 'Finished',
                subtitle: task.finishedAt != null ? formatDateTime(task.finishedAt!) : 'Not finished yet',
              ),
            ],
          );
        }),
      ),
    );
  }
}

class DetailItem extends StatelessWidget {
  const DetailItem({super.key, required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
        fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurfaceVariant);
    final subtitleStyle = TextStyle(
        fontSize: Theme.of(context).textTheme.titleSmall!.fontSize,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurfaceVariant);
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer.withAlpha(15),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: titleStyle),
        subtitle: Text(subtitle, style: subtitleStyle),
      ),
    );
  }
}

class TaskViewButton extends StatelessWidget {
  const TaskViewButton({super.key, required this.label, required this.onTap});
  final Function() onTap;
  final String label;
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onTap,
      child: Icon(Iconsax.edit),
    );
  }
}
