import 'package:flutter/material.dart';
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
        child: SingleChildScrollView(
          child: Column(
            spacing: 18,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefaultReminderTypeSection(),
              Divider(),
              SnoozeSection(),
              Divider(),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  spacing: -1,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Backup & Restore', style: Theme.of(context).textTheme.titleMedium),
                    Divider(height: 0),
                    ListTile(
                      visualDensity: VisualDensity.compact,
                      onTap: (){},
                      contentPadding: EdgeInsets.zero,
                      title: Text('Google Account'),
                      subtitle: Text('No account set'),
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      value: true,
                      onChanged: (value) {},
                      title: Text('Auto backup'),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      title: Text('Restore data'),
                    )
                  ],
                ),
              ),
            ],
          ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Snooze for (in minutes)',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [1, 5, 10, 15, 20, 25, 30, 45, 50, 60].map((minutes) {
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
    );
  }
}

class DefaultReminderTypeSection extends StatelessWidget {
  const DefaultReminderTypeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Default reminder type', style: theme.textTheme.titleMedium),
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
    );
  }
}
