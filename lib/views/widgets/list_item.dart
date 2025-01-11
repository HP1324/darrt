import 'package:flutter/material.dart';
import 'package:minimaltodo/data_models/list_model.dart';
import 'package:minimaltodo/global_utils.dart';
import 'package:minimaltodo/services/list_service.dart';
import 'package:minimaltodo/theme/app_theme.dart';
import 'package:minimaltodo/view_models/list_view_model.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';
import 'package:minimaltodo/views/pages/new_list_page.dart';
import 'package:minimaltodo/views/pages/tasks_for_list_page.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class ListItem extends StatefulWidget {
  const ListItem({
    super.key,
    required this.list,
  });

  final ListModel list;

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  final GlobalKey _popupKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Consumer2<TaskViewModel, ListViewModel>(builder: (context, taskVM, listVM, _) {
      final tasksInList = taskVM.tasks.where((task) => task.list?.id == widget.list.id).toList();
      final completedTasks = tasksInList.where((task) => task.isDone == true).length;

      final listColor = widget.list.listColor != null
          ? ListService.getColorFromString(widget.list.listColor)
          : AppTheme.primary;

      return Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).primaryColor, width: 0.2),
            borderRadius: BorderRadius.circular(10)),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                child: TasksForListPage(list: widget.list),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: listColor.withAlpha(50),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        ListService.getIcon(widget.list.iconCode),
                        color: listColor,
                        size: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.list.name ?? 'Unnamed List',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if(widget.list.id != 1)
                    InkWell(
                      key: _popupKey,
                      onTap: (){
                        //Had to calculate the InkWell's position because showMenu does not give direct control for placing the popup menu under the button directly. So I calculated the InkWell's position on the screen and passed it as arguments to RelativeRect.fromLTRB().
                        final RenderBox renderBox = _popupKey.currentContext!.findRenderObject() as RenderBox;
                        final position = renderBox.localToGlobal(Offset.zero);
                        final size = renderBox.size;
                        showMenu(
                            context: context,
                            position: RelativeRect.fromLTRB( position.dx, // Left
                              position.dy + size.height, // Top (below the button)
                              position.dx + size.width, // Right
                              position.dy,),
                            items: [
                          PopupMenuItem(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.fade,
                                  child: NewListPage(
                                    editMode: true,
                                    listToEdit: widget.list,
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: listColor, size: 20),
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
                                  content: const Text(
                                      'Are you sure you want to delete the list? All tasks in this list will be moved to the General list.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Cancel'),
                                    ),
                                    FilledButton(
                                      onPressed: () async {
                                        final nav = Navigator.of(context);
                                        final deleted =
                                        await listVM.deleteList(widget.list, taskVM);
                                        if (deleted) {
                                          showToast(title: 'List Deleted');
                                          nav.pop();
                                        }
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
                      },

                      child: Icon(Icons.more_horiz),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (tasksInList.isNotEmpty)
                  SizedBox(
                    height: 4,
                    child: LinearProgressIndicator(
                      value: completedTasks / tasksInList.length,
                      backgroundColor: AppTheme.background100,
                      valueColor: AlwaysStoppedAnimation(listColor),
                    ),
                  ),

                // Third Row: Task Count
                const SizedBox(height: 4),
                Text(
                  '$completedTasks/${tasksInList.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
