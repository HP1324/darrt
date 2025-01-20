import 'package:flutter/material.dart';
import 'package:minimaltodo/global_utils.dart';
import 'package:minimaltodo/services/notification_service.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';
import 'package:provider/provider.dart';

class TaskNotificationSettingsPage extends StatefulWidget {
  const TaskNotificationSettingsPage({super.key});
  @override
  State<TaskNotificationSettingsPage> createState() => _TaskNotificationSettingsPageState();
}

class _TaskNotificationSettingsPageState extends State<TaskNotificationSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TaskViewModel>(builder: (context, tvm, _) {
      logger.d('Selected notif time: ${tvm.selectedMinutes}');
      return PopScope(
        onPopInvokedWithResult: (_, __) {},
        child: Scaffold(
          appBar: AppBar(
              leading: BackButton(),
              title: const Text('Notification Settings', style: TextStyle(fontSize: 20))),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SwitchListTile(
                  title: const Text(
                    "Enable notification",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  value: tvm.currentTask.isNotifyEnabled!,
                  onChanged: (value) async {
                    if (await NotificationService.managePermission(context)) {
                      tvm.toggleNotifSwitch(value);
                      logger.d('isNotifyEnabled: ${tvm.currentTask.isNotifyEnabled}');
                      logger.d(
                          'Notification Time at the time of toggling: ${tvm.currentTask.notifyTime}');
                    }
                  },
                ),
              ),
              if (tvm.currentTask.isNotifyEnabled!) ...[
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).primaryColor.withAlpha(100)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notify me before',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        runAlignment: WrapAlignment.start,
                        children: [
                          _TimeOption(minutes: 0, label: 'On time'),
                          _TimeOption(minutes: 5, label: '5 min'),
                          _TimeOption(minutes: 10, label: '10 min'),
                          _TimeOption(minutes: 15, label: '15 min'),
                          _TimeOption(minutes: 30, label: '30 min'),
                          _TimeOption(minutes: 45, label: '45 min'),
                          _TimeOption(minutes: 60, label: '1 hour'),
                          _TimeOption(minutes: 120, label: '2 hour'),
                          _TimeOption(minutes: 180, label: '3 hour'),
                          _TimeOption(minutes: 240, label: '4 hour'),
                        ],
                      ),
                    ],
                  ),
                )
              ]
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pop(context);
              tvm.currentTask.printTask();
            },
            shape: const CircleBorder(),
            child: const Icon(Icons.done),
          ),
        ),
      );
    });
  }
}

class _TimeOption extends StatelessWidget {
  const _TimeOption({
    required this.minutes,
    required this.label,
  });

  final int minutes;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskViewModel>(
      builder: (context, tvm, _) {
        final isSelected = tvm.selectedMinutes == minutes;
        return Material(
          color: isSelected ? Theme.of(context).primaryColor : null,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              tvm.updateNotifyTime(minutes);
              logger.d('notify time after selecting it from chips: ${tvm.currentTask.notifyTime}');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(label),
            ),
          ),
        );
      },
    );
  }
}
