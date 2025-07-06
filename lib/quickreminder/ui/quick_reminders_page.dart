import 'package:flutter/material.dart';
import 'package:minimaltodo/helpers/consts.dart';
import 'package:minimaltodo/helpers/globals.dart' as g;

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
          return ListView.builder(
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final r = reminders[index];
              final icon = r.type == notifReminderType ? Icons.notifications_active:Icons.alarm;
              final title = r.title ?? 'No title was set';
              final time = r.durationMinutes;
              return ListTile(
                leading: Icon(icon),
                title: Text(title),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('$time'),
                    Text('min'),
                  ],
                ),
              );
            },
          );
        }
      ),
    );
  }
}
