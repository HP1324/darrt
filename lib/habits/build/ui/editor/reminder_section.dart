import 'package:app_settings/app_settings.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:darrt/app/notification/notification_service.dart';
import 'package:darrt/app/services/mini_box.dart';
import 'package:darrt/app/services/toast_service.dart';
import 'package:darrt/habits/build/state/build_habit_state_controller.dart';
import 'package:darrt/helpers/consts.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/messages.dart';
import 'package:darrt/helpers/mini_logger.dart';
import 'package:darrt/task/models/reminder.dart';
import 'package:flutter/material.dart';

class ReminderSection extends StatelessWidget {
  const ReminderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () async {
        g.buildHabitSc.textFieldNode.unfocus();
        final allowed = await AwesomeNotifications().isNotificationAllowed();
        if (context.mounted) {
          if ((allowed || await NotificationService.showNotificationRationale(context)) &&
              context.mounted) {
            _showRemindersBottomSheet(context);
          }
        }
      },
      child: Row(
        children:[
        Icon( Icons.notification_add_outlined),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reminders',
                style: theme.textTheme.titleSmall,
              ),
              Expanded(
                child: ListenableBuilder(
                  listenable: g.buildHabitSc,
                  builder: (context, child) {
                    final reminders = g.buildHabitSc.reminders;
                    return Text(
                      reminders.isEmpty
                          ? 'Tap here to add reminders per day'
                          : reminders.map((r) => r.time.format(context)).join(', '),
                      style: theme.textTheme.bodySmall,
                    );
                  },
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              g.buildHabitSc.textFieldNode.unfocus();
              _showBatteryOptimizationDialog(context, theme);
            },
            icon: Icon(Icons.info_outline),
          ),
        ]


      ),
    );
  }

  void _showBatteryOptimizationDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          content: Text(
            Messages.mBatteryOptimizationMessage,
            style: TextStyle(fontSize: theme.textTheme.bodyMedium!.fontSize),
          ),
          actions: [
            FilledButton(
              onPressed: () async {
                await AppSettings.openAppSettings(
                  type: AppSettingsType.batteryOptimization,
                );
                // await SettingsService.openBatterySettings();
              },
              child: Text('Go to settings'),
            ),
          ],
        );
      },
    );
  }

  void _showRemindersBottomSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 24),
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
          child: ListenableBuilder(
            listenable: g.buildHabitSc,
            builder: (context, child) {
              final textTheme = Theme.of(context).textTheme;
              final scheme = Theme.of(context).colorScheme;
              final reminders = List.from(g.buildHabitSc.reminders);
              reminders.sort((a, b) => a.time.compareTo(b.time));
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reminders',
                        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (g.buildHabitSc.startTime != null) Flexible(child: EasyReminderActions()),
                  Flexible(
                    child: reminders.isEmpty
                        ? Center(
                      child: Text(
                        'No reminders set',
                        style: textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    )
                        : ListView.builder(
                      itemCount: reminders.length,
                      itemBuilder: (context, index) {
                        MiniLogger.dp(
                          'Reminder ${index + 1} time in list: ${reminders[index].time.hour}:${reminders[index].time.minute}',
                        );
                        return HabitReminderItem(
                          reminder: reminders[index],
                          onTap: () async {
                            await _showReminderDialog(
                              context,
                              edit: true,
                              reminder: reminders[index],
                            );
                          },
                          onRemove: () {
                            g.buildHabitSc.removeReminder(reminders[index]);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _showReminderDialog(context),
                      icon: const Icon(Icons.add),
                      label: Text(
                        g.buildHabitSc.startTime == null ? 'Add Reminder' : 'Add Custom Reminder',
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
Future<void> _showReminderDialog(
    BuildContext context, {
      bool edit = false,
      Reminder? reminder,
    }) async {
  MiniLogger.dp('Reminder time: ${reminder?.time.hour}:${reminder?.time.minute}');
  await showAdaptiveDialog(
    context: context,
    builder: (context) => HabitReminderDialog(
      edit: edit,
      reminder: reminder,
      onSaved: (newReminder) {
        final message = g.buildHabitSc.putReminder(
          edit: edit,
          reminder: newReminder,
          oldReminder: reminder,
        );
        if (message == Messages.mReminderAdded) {
          showSuccessToast(context, message);
        } else
          showErrorToast(context, message);
      },
    ),
  );
}
class EasyReminderActions extends StatelessWidget {
  const EasyReminderActions({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: GridView(
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2.2,
        ),
        children: [
          _buildTimeChip(context, minutes: null),
          _buildTimeChip(context, minutes: 5),
          _buildTimeChip(context, minutes: 10),
          _buildTimeChip(context, minutes: 15),
          _buildTimeChip(context, minutes: 30),
          _buildTimeChip(context, minutes: 45),
        ],
      ),
    );
  }

  Widget _buildTimeChip(BuildContext context, {required int? minutes}) {
    return Tooltip(
      message: minutes == null ? 'On time reminder' : 'Before $minutes min',
      child: Center(
        child: FilledButton(
          onPressed: () {
            final reminder = buildReminder(minutes: minutes);
            final message = g.buildHabitSc.putReminder(
              edit: false,
              reminder: reminder,
            );
            if (message == Messages.mReminderAdded) {
              showSuccessToast(context, message);
            } else {
              showErrorToast(context, message);
            }
          },
          child: Text(minutes != null ? '- $minutes min' : 'On time'),
        ),
      ),
    );
  }

  Reminder buildReminder({required int? minutes}) {
    Reminder? reminder;
    TimeOfDay reminderTime = TimeOfDay.now();
    if (minutes == null) {
      reminderTime = TimeOfDay.fromDateTime(g.buildHabitSc.startTime!);
    } else {
      reminderTime = TimeOfDay.fromDateTime(
        g.buildHabitSc.startTime!.subtract(Duration(minutes: minutes)),
      );
    }
    reminder = Reminder(time: reminderTime);
    return reminder;
  }
}

class HabitReminderItem extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const HabitReminderItem({
    super.key,
    required this.reminder,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Text(
                reminder.time.format(context),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    reminder.type == 'alarm' ? Icons.alarm : Icons.notifications,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    reminder.type == 'alarm' ? 'Alarm' : 'Notification',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.close, color: Theme.of(context).colorScheme.error),
                onPressed: onRemove,
                tooltip: 'Remove reminder',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HabitReminderDialog extends StatefulWidget {
  final bool edit;
  final Reminder? reminder;
  final Function(Reminder) onSaved;

  const HabitReminderDialog({
    super.key,
    required this.edit,
    this.reminder,
    required this.onSaved,
  }) : assert(!edit || reminder != null, 'Reminder must be provided when editing');

  @override
  State<HabitReminderDialog> createState() => _HabitReminderDialogState();
}

class _HabitReminderDialogState extends State<HabitReminderDialog> {
  late String _selectedType;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    // Initialize from existing reminder if editing, else defaults
    _selectedType = widget.edit ? widget.reminder!.type : MiniBox().read(mDefaultReminderType);
    _selectedTime = widget.edit ? widget.reminder!.time : TimeOfDay.now();
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && mounted) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.edit ? 'Edit reminder' : 'Add a reminder',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 3,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Reminder type',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton(
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            segments: [
              ButtonSegment(
                value: 'notif',
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      size: 18,
                      color: _selectedType == 'notif'
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: 6),
                    FittedBox(child: const Text('Notification')),
                  ],
                ),
              ),
              ButtonSegment(
                value: 'alarm',
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.alarm_outlined,
                      size: 18,
                      color: _selectedType == 'alarm'
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: 6),
                    FittedBox(child: const Text('Alarm')),
                  ],
                ),
              ),
            ],
            selected: {_selectedType},
            onSelectionChanged: (val) => setState(() => _selectedType = val.first),
          ),
          const SizedBox(height: 24),
          Text(
            'Time',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _selectTime,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedTime.format(context),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Icon(
                      Icons.access_time_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
        FilledButton(
          onPressed: () {
            final newReminder = Reminder(
              id: DateTime.now().millisecondsSinceEpoch.remainder(10000),
              type: _selectedType,
              time: _selectedTime,
            );
            widget.onSaved(newReminder);
            Navigator.of(context).pop();
          },
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          child: const Text('Save'),
        ),
      ],
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}