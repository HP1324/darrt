import 'package:flutter/material.dart';
import 'package:minimaltodo/global_utils.dart';
import 'package:minimaltodo/theme/app_theme.dart';
import 'package:minimaltodo/view_models/list_view_model.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';
import 'package:minimaltodo/views/pages/new_list_page.dart';
import 'package:minimaltodo/views/pages/tasks_for_list_page.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:toastification/toastification.dart';

class ListsPage extends StatelessWidget {
  const ListsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ListViewModel, TaskViewModel>(
      builder: (context, listVM, taskVM, _) {
        final lists = listVM.lists;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Text(
                      'Your Lists',
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.headlineSmall!.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>  NewListPage(),
                          ),
                        );
                      },
                      icon: const Icon(Iconsax.add),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.background50,
                        foregroundColor: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.97,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final list = lists[index];
                    final tasksInList = list.id == -1
                        ? taskVM.tasks.where((task) => 
                            task.list == null ||
                            task.list?.id == null ||
                            task.list?.name == null
                          ).toList()
                        : taskVM.tasks
                            .where((task) => task.list?.id == list.id)
                            .toList();
                    final completedTasks = tasksInList
                        .where((task) => task.isDone ?? false)
                        .length;

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TasksForListPage(
                              list: list,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.background200,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withAlpha(30),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Iconsax.folder_2,
                                    color: AppTheme.primary,
                                    size: 20,
                                  ),
                                ),
                                const Spacer(),
                                if (list.id != -1) // Only show popup menu for non-General lists
                                  PopupMenuButton(
                                    icon: const Icon(
                                      Iconsax.more,
                                      size: 20,
                                      color: Colors.black54,
                                    ),
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Text(
                                          'Edit',
                                          style: TextStyle(color: Colors.black87),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Text(
                                          'Delete',
                                          style: TextStyle(color: AppTheme.error),
                                        ),
                                      ),
                                    ],
                                    onSelected: (value) {
                                      if (value == 'delete') {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text('Delete List'),
                                            content: Text(
                                              'Are you sure you want to delete "${list.name}"? All tasks in this list will be moved to General list.',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  final taskVM = Provider.of<TaskViewModel>(context, listen: false);
                                                  listVM.deleteList(list, taskVM).then((deleted){
                                                    if(deleted){
                                                      showToast(
                                                        title: 'List deleted', 
                                                        description: 'All tasks have been moved to General list'
                                                      );
                                                    } else {
                                                      showToast(
                                                        title: 'Failed to delete list',
                                                        description: 'Please try again'
                                                      );
                                                    }
                                                  });
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                    color: AppTheme.error,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else if (value == 'edit') {
                                        final textController = TextEditingController(text: list.name);
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (context) => Container(
                                            padding: EdgeInsets.only(
                                              bottom: MediaQuery.of(context).viewInsets.bottom,
                                            ),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(20),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(20),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Edit List Name',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppTheme.primary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 20),
                                                  TextField(
                                                    controller: textController,
                                                    autofocus: true,
                                                    decoration: InputDecoration(
                                                      hintText: 'Enter list name',
                                                      filled: true,
                                                      fillColor: AppTheme.background50,
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                        borderSide: BorderSide.none,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context),
                                                        child: const Text('Cancel'),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          if (textController.text.trim().isEmpty) {
                                                            showToast(
                                                              title: 'List name cannot be empty',
                                                              type: ToastificationType.error,
                                                            );
                                                            return;
                                                          }
                                                          listVM
                                                              .editList(list, textController.text)
                                                              .then((success) {
                                                            if (success) {
                                                              showToast(title: 'List name updated');
                                                              Navigator.pop(context);
                                                            } else {
                                                              showToast(
                                                                title: 'Failed to update list name',
                                                                type: ToastificationType.error,
                                                              );
                                                            }
                                                          });
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: AppTheme.primary,
                                                          foregroundColor: Colors.white,
                                                        ),
                                                        child: const Text('Save'),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              list.name ?? 'Unnamed List',
                              style:  TextStyle(
                                fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${tasksInList.length} tasks',
                              style: TextStyle(
                                fontSize: Theme.of(context).textTheme.labelLarge!.fontSize,
                                color: Colors.black54,
                              ),
                            ),
                            const Spacer(),
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
                    );
                  },
                  childCount: lists.length,
                ),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
          ],
        );
      },
    );
  }
}