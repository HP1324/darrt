import 'package:flutter/cupertino.dart' show CupertinoNavigationBarBackButton;
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:minimaltodo/data_models/list_model.dart';
import 'package:minimaltodo/services/list_service.dart';
import 'package:page_transition/page_transition.dart';
import 'package:minimaltodo/global_utils.dart';
import 'package:minimaltodo/theme/app_theme.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/view_models/list_view_model.dart';
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
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.surfaceBright,title: Text('${task.title}')),
      floatingActionButton: TaskViewButton(
          label: 'Edit',
          onTap: () {
            Navigator.push(
                context,
                PageTransition(
                    child: TaskEditorPage(
                      editMode: true,
                      taskToEdit: task,
                    ),
                    type: PageTransitionType.fade));
          },),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Consumer2<TaskViewModel, ListViewModel>(builder: (_, tvm, cvm, __) {
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
                icon: ListService.getIcon(task.list!.iconCode),
                list: task.list,
                title: 'List',
                subtitle: task.list!.name ?? 'General (not added to a list)',
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
                    : "${formatDateTime(task.dueDate!)}\n${task.isDone! ? 'Task Finished' : (task.dueDate!.isBefore(DateTime.now()) ? 'Task Overdue' : (task.isNotifyEnabled! ? 'Notify on ${formatDateTime(task.notifyTime!.add(const Duration(seconds: 35)))}' : 'Notification Disabled'))}",
              ),
              DetailItem(
                icon: Icons.task_alt,
                title: 'Finished',
                subtitle:
                    task.finishedAt != null ? formatDateTime(task.finishedAt!) : 'Not finished yet',
              ),
            ],
          );
        }),
      ),
    );
  }
}

class DetailItem extends StatelessWidget {
  const DetailItem(
      {super.key, required this.icon, required this.title, required this.subtitle, this.list});
  final IconData icon;
  final String title;
  final String subtitle;
  final ListModel? list;

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
        fontSize: Theme.of(context).textTheme.titleMedium!.fontSize, fontWeight: FontWeight.bold);
    final subtitleStyle = TextStyle(
        fontSize: Theme.of(context).textTheme.titleSmall!.fontSize, fontWeight: FontWeight.w500);
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: ListTile(
        leading: Icon(
          icon,
          color: list != null ? ListService.getColorFromString(context,list!.listColor) : null,
        ),
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
