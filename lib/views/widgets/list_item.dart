import 'package:flutter/material.dart';
import 'package:minimaltodo/data_models/list_model.dart';
import 'package:minimaltodo/services/list_service.dart';
import 'package:minimaltodo/theme/app_theme.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';
import 'package:minimaltodo/views/pages/new_list_page.dart';
import 'package:minimaltodo/views/pages/tasks_for_list_page.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class ListItem extends StatelessWidget {
  const ListItem({
    super.key,
    required this.list,
  });

  final ListModel list;

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskViewModel>(builder: (context, taskVM, _) {
      // Get tasks for this list
      final tasksInList = taskVM.tasks.where((task) => task.list?.id == list.id).toList();
      final completedTasks = tasksInList.where((task) => task.isDone == true).length;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.background100,
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  PageTransition(
                      type: PageTransitionType.fade, child: TasksForListPage(list: list)));
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with icon and actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withAlpha(50),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          ListService.getIcon(list.iconCode),
                          color: AppTheme.primary,
                        ),
                      ),
                      // PopupMenuButton for actions
                      if (list.id != -1) // Don't show for General list
                        PopupMenuButton(
                          icon: Icon(
                            Icons.more_vert,
                            color: AppTheme.primary.withAlpha(200),
                            size: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType.fade,
                                        child: NewListPage(editMode: true,listToEdit: list,)));
                              },
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit,
                                    color: AppTheme.primary.withAlpha(200),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Edit'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    color: Colors.red.withAlpha(200),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // List name
                  Text(
                    list.name ?? 'Unnamed List',
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Task count
                  Text(
                    '${tasksInList.length} tasks',
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.labelLarge!.fontSize,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Progress indicator
                  if (tasksInList.isNotEmpty)
                    LinearProgressIndicator(
                      value: completedTasks / tasksInList.length,
                      backgroundColor: AppTheme.background100,
                      valueColor: AlwaysStoppedAnimation(
                        AppTheme.primary,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
