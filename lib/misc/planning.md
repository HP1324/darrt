Add a good filter icon after search text field
Improve filter logic:
    Show tasks only by date in view
    Add search mechanism
    in search, show date of the task to get a references

Add SearchAnchor in AppBar action property.
Open search view in different page.
Create a separate page for viewing the task, this page will not be able to edit it.
Add and alarm page.


///TODO: Today's first and foremost priority is to set the state of alarm play button

create the map and manage states accordingly:

Feature: Enable and disable notifications for tasks
1)Use get_storage to save preferences
2)Add isNotifyEnabled field in Task model
    i.  Change toJson() and fromJson() accordingly
3)Add isNotifyEnabled in DatabaseService, in table migration query
    i.  Change insertion and updation queries accordingly



-> Task marked as finished -> task.isDone = true ->
    if (task.isDone) ->->
        if(wasNotifyEnabled)
            task.isNotifyEnabled = false;
            removeTaskNotification();
            showToast('Task marked finished, notification disabled for the task')
        else
            showToast('Task marked finished')

-> Task marked pending -> task.isDone = false ->
    else if(task is not done)
        if(wasNotifyEnabled)
            if(task.dueDate is not null and a valid date)
                task.isNotifyEnable = true;
                createTaskNotification(task);
                showToast('Task marked pending, notifications enabled again');
            else
                showToast('Please reschedule the notification with new valid date and time');
                task.isNotifyEnabled = false;
         else
            showToast('Task marked pending');
            
            
### **Notification Handling**

1. Enable notification on NotificationSwitch
2. When user selects a date check if the notification is on or off, if on, check whether the time is valid for notification or not, if not valid, disable notification, if valid keep the notification enabled and check whether the selected minutes are valid or not, if valid keep them, if not reset to 0.



TODO: 1)Timeline - PENDING
TODO: 2)Repeating task - PENDING
TODO: 3)Settings - PENDING
TODO: 4)Notes - PENDING
TODO: 6)Add notification button in appbar to show notifications


import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/helpers/mini_utils.dart';
import 'package:minimaltodo/services/database_service.dart';
import 'package:minimaltodo/services/task_service.dart';
import 'package:minimaltodo/views/widgets/empty_list_placeholder.dart';
import 'package:minimaltodo/views/widgets/empty_tasks_indicator.dart';
import 'package:provider/provider.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';
import 'package:minimaltodo/view_models/calendar_view_model.dart';
import 'package:minimaltodo/views/widgets/task_item.dart';
void _deleteSelectedTasks(BuildContext context, TaskViewModel taskVM, CalendarViewModel calendarVM) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tasks'),
        content: Text('Delete ${calendarVM.selectedTaskIds.length} tasks?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              for (var id in calendarVM.selectedTaskIds) {
                final task = taskVM.tasks.firstWhere((t) => t.id == id);
                taskVM.deleteTask(task);
              }
              calendarVM.clearSelection();
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }


///PREFERRED COLORS
Color(0xff15616D)
Color(0xff78290F)

//Notification feature

1) Remove isNotifyEnabled 
2) [Done] Change setDueDate function in TaskViewModel to adopt new notification settings
3) [Done] Remove setTime function altogether, time is now handled by reminder times bottom sheet
4) [Done] Show reminder times in single task view
5) [Done] Store notification id in reminders json string itself

# Features
### Task - Add, Delete, Update, Mark as finished or unfinished
## Add Task
1. Add to the database using sqflite
2. Associate Categories Selected using foreign key relationships
3. Create notifications if reminders are not null
4. Update the state of the app where the list of tasks is shown

## Notification - Create, Remove
1. Create - single or repeating based on isRepeating flag

## Categories 
1. Create
   1. Store it to the database with correct icon code and correct color
   2. Update the state of the UI where this list of categories is shown
2. Update
3. Delete
   1. If task has only that category, update that task's category to general
      
   
