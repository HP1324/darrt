import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:minimaltodo/helpers/consts.dart';
import 'package:minimaltodo/helpers/globals.dart' as g;
import 'package:minimaltodo/quickreminder/ui/quick_reminder_dialog.dart';

class QuickRemindersPage extends StatefulWidget {
  const QuickRemindersPage({super.key});

  @override
  State<QuickRemindersPage> createState() => _QuickRemindersPageState();
}

class _QuickRemindersPageState extends State<QuickRemindersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton(), title: Text('Quick Reminders')),
      body: ListenableBuilder(
        listenable: g.quickVm,
        builder: (context, child) {
          final reminders = g.quickVm.items;
          if (reminders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_alarm, size: 50),
                  Text('No quick reminders set'),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final r = reminders[index];
              final icon = r.type == notifReminderType ? Icons.notifications_active : Icons.alarm;
              final title = r.title == null || r.title!.isEmpty ? 'No title was set' : r.title;
              final time = r.durationMinutes;
              return ListTile(
                onTap: () async {
                  await showAdaptiveDialog(
                    context: context,
                    builder: (context) => QuickReminderDialog(edit: true, reminder: r),
                  );
                },
                leading: Icon(icon),
                title: Text(title!),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('$time'),
                        Text('min'),
                      ],
                    ),
                    InkWell(
                      onTap: () async{
                        g.quickVm.deleteItem(r.id);
                        await AwesomeNotifications().cancel(r.notifId);
                      },
                      child: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
