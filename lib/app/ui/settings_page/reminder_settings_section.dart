import 'package:darrt/app/services/boxpref.dart';
import 'package:darrt/app/services/mini_box.dart';
import 'package:darrt/app/services/object_box.dart';
import 'package:darrt/helpers/consts.dart';
import 'package:darrt/objectbox.g.dart';
import 'package:flutter/material.dart';

class ReminderSettingsSection extends StatelessWidget {
  const ReminderSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title:Text('Reminder settings'),
      children: [
        DefaultReminderTypeSection(),
        SizedBox(height: 8),
        SnoozeSection(),
      ],
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
        Text(
          'Snooze reminder for (in minutes)',
          style: theme.textTheme.titleSmall,
        ),
        SizedBox(height: 8),
        StreamBuilder<Query<BoxPref>>(
          stream: ObjectBox().prefsBox.query(BoxPref_.key.equals(mSnoozeMinutes)).watch(),
          builder: (context, snapshot) {
            int snoozeMinutes = 5; // default value
            if (snapshot.hasData) {
              final result = snapshot.data!.find();
              if (result.isNotEmpty) {
                snoozeMinutes = int.tryParse(result.first.value) ?? 5;
              }
            }

            return Wrap(
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
                      MiniBox().write(mSnoozeMinutes, minutes);
                    }
                  },
                );
              }).toList(),
            );
          },
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
        Text('Default reminder type', style: theme.textTheme.titleSmall),
        StreamBuilder<Query<BoxPref>>(
          stream: ObjectBox().prefsBox.query(BoxPref_.key.equals(mDefaultReminderType)).watch(),
          builder: (context, snapshot) {
            String defaultReminderType = notifReminderType; // default value
            if (snapshot.hasData) {
              final result = snapshot.data!.find();
              if (result.isNotEmpty) {
                defaultReminderType = result.first.value;
              }
            }

            return SegmentedButton<String>(
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
                MiniBox().write(mDefaultReminderType, selection.first);
              },
            );
          },
        ),
      ],
    );
  }
}
