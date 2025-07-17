import 'package:darrt/app/services/boxpref.dart';
import 'package:darrt/app/services/object_box.dart';
import 'package:darrt/app/ui/settings_page/timer_settings_section.dart';
import 'package:darrt/objectbox.g.dart';
import 'package:flutter/material.dart';
import 'package:darrt/app/services/mini_box.dart';
import '../../../helpers/consts.dart';
import 'package:darrt/app/ui/settings_page/backup_restore_section.dart';

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
              TimerSettingsSection(),
              Divider(),
              BackupRestoreSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class SnoozeSection extends StatefulWidget {
  const SnoozeSection({super.key});

  @override
  State<SnoozeSection> createState() => _SnoozeSectionState();
}

class _SnoozeSectionState extends State<SnoozeSection> {
  int snoozeMinutes = MiniBox().read(mSnoozeMinutes) ?? 5;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Snooze reminder for (in minutes)',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [1, 5, 10, 15, 20, 25, 30, 45, 50, 60].map((minutes) {
            return ChoiceChip(
              showCheckmark: false,
              shape: StadiumBorder(),
              label: Text('$minutes'),
              selected: snoozeMinutes == minutes,
              onSelected: (selected) async {
                if (selected) {
                  setState(() {
                    snoozeMinutes = minutes;
                  });
                  MiniBox().write(mSnoozeMinutes, minutes);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class DefaultReminderTypeSection extends StatefulWidget {
  const DefaultReminderTypeSection({super.key});

  @override
  State<DefaultReminderTypeSection> createState() => _DefaultReminderTypeSectionState();
}

class _DefaultReminderTypeSectionState extends State<DefaultReminderTypeSection> {
  String defaultReminderType = MiniBox().read(mDefaultReminderType) ?? notifReminderType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Default reminder type', style: theme.textTheme.titleMedium),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: notifReminderType,
              label: Text('Notification'),
              icon: Icon(Icons.notifications),
            ),
            ButtonSegment(
              value: alarmReminderType,
              label: Text('Alarm'),
              icon: Icon(Icons.alarm),
            ),
          ],
          selected: {defaultReminderType},
          onSelectionChanged: (Set<String> selection) async{
            setState(() {
              defaultReminderType = selection.first;
            });
            MiniBox().write(mDefaultReminderType, selection.first);
          },
        ),
      ],
    );
  }
}
