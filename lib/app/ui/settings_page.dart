import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:minimaltodo/app/setting/settings_service.dart';
import 'package:minimaltodo/app/state/value_notifiers.dart';
import 'package:minimaltodo/task/ui/add_task_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DefaultReminderTypeSection(),
            SnoozeSection(),
          ],
        ),
      ),
    );
  }
}

class SnoozeSection extends StatelessWidget {
  const SnoozeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StructuredRow(
      leadingIcon: Icons.snooze,
      expanded: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Snooze for (in minutes)',style: theme.textTheme.titleMedium,),
            ],
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [1,5, 10, 15, 20, 25, 30, 45,50,60].map((minutes) {
              return ValueListenableBuilder(
                valueListenable: snoozeMinutes,
                builder: (context, value, child) {
                  return ChoiceChip(
                    showCheckmark: false,
                    shape: StadiumBorder(),
                    label: Text('$minutes'),
                    selected: value == minutes,
                    onSelected: (selected) {
                      if (selected) {
                        updateSnoozeMinutes(minutes);
                      }
                    },
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class DefaultReminderTypeSection extends StatelessWidget {
  const DefaultReminderTypeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StructuredRow(
      leadingIcon: Icons.event_note,
      expanded: Column(
        children: [
          Row(
            children: [
              Text('Default reminder type', style: theme.textTheme.titleMedium),
            ],
          ),
          ValueListenableBuilder(
            valueListenable: defaultReminderType,
            builder: (context, value, child) {
              return SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'notif',
                    label: Text('Notification'),
                    icon: Icon(Icons.notifications),
                  ),
                  ButtonSegment(
                    value: 'alarm',
                    label: Text('Alarm'),
                    icon: Icon(Icons.alarm),
                  ),
                ],
                selected: {value},
                onSelectionChanged: (Set<String> selection) {
                  updateDefaultReminder(selection.first);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class SettingsItem extends StatelessWidget {
  const SettingsItem({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    this.trailing,
  });
  final Widget leading;

  final Widget title;

  final Widget subtitle;

  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    return ListTile(leading: leading, title: title, subtitle: subtitle, trailing: trailing);
  }
}
