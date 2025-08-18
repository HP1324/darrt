import 'package:darrt/app/services/boxpref.dart';
import 'package:darrt/app/services/mini_box.dart';
import 'package:darrt/app/services/object_box.dart';
import 'package:darrt/app/workmanger/tasks/dialy_quote_notif.dart';
import 'package:darrt/helpers/consts.dart';
import 'package:darrt/objectbox.g.dart';
import 'package:flutter/material.dart';

class ReminderSettingsSection extends StatelessWidget {
  const ReminderSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text('Reminders & Notifications'),
      children: [
        DefaultReminderTypeSection(),
        SizedBox(height: 8),
        SnoozeSection(),
        DailyQuoteNotificationSection(),
        //TODO: Implement the following latter in the future
        // CancelRemindersWithTaskFinishTile(),
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
          'Snooze reminder (in minutes)',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<BoxPref>>(
          stream: ObjectBox().prefsBox
              .query(BoxPref_.key.equals(mSnoozeMinutes))
              .watch(triggerImmediately: true)
              .map((q) => q.find()),
          builder: (context, snapshot) {
            int snoozeMinutes = 5; // Default fallback
            final value = snapshot.data?.firstOrNull?.value;
            if (value != null) {
              snoozeMinutes = int.tryParse(value) ?? 5;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$snoozeMinutes minutes',
                  style: theme.textTheme.bodyMedium,
                ),
                Slider(
                  value: snoozeMinutes.toDouble(),
                  min: 1,
                  max: 120,
                  divisions: 119,
                  label: '$snoozeMinutes',
                  onChanged: (newValue) {
                    MiniBox().write(mSnoozeMinutes, newValue.round());
                  },
                ),
              ],
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Default reminder type', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        StreamBuilder<List<BoxPref>>(
          stream: ObjectBox().prefsBox
              .query(BoxPref_.key.equals(mDefaultReminderType))
              .watch(triggerImmediately: true)
              .map((q) => q.find()),
          builder: (context, snapshot) {
            String selectedType = notifReminderType; // default
            final value = snapshot.data?.firstOrNull?.value;
            if (value != null) selectedType = value;

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
              selected: {selectedType},
              onSelectionChanged: (Set<String> selection) {
                MiniBox().write(mDefaultReminderType, selection.first);
              },
            );
          },
        ),
      ],
    );
  }
}

class DailyQuoteNotificationSection extends StatefulWidget {
  const DailyQuoteNotificationSection({super.key});

  @override
  State<DailyQuoteNotificationSection> createState() =>
      _DailyQuoteNotificationSectionState();
}

class _DailyQuoteNotificationSectionState
    extends State<DailyQuoteNotificationSection> {
  bool isEnabled = MiniBox().read(mDailyQuoteNotif) ?? true;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('Get Daily quote notification'),
      value: isEnabled,
      onChanged: (value) async{
        if (value != null) {
          isEnabled = value;
          MiniBox().write(mDailyQuoteNotif, value);
          setState(() {});
          await _handleDailyQuoteTask(value);
        }
      },
    );
  }

  Future<void> _handleDailyQuoteTask(bool value)async{
    if(!value) {
      await cancelDailyQuoteNotification();
    }else{
      await scheduleDailyQuoteNotification();
    }
  }
}

class CancelRemindersWithTaskFinishTile extends StatelessWidget {
  const CancelRemindersWithTaskFinishTile({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BoxPref>>(
      stream: ObjectBox().prefsBox
          .query(BoxPref_.key.equals(mCancelNotificationsWithTaskFinish))
          .watch(triggerImmediately: true)
          .map((query) => query.find()),
      builder: (context, snapshot) {
        final prefs = snapshot.data;
        final isEnabled =
            prefs?.isNotEmpty == true && prefs!.first.value == 'true';
        return CheckboxListTile(
          key: const ValueKey(mCancelNotificationsWithTaskFinish),
          title: const Text('Cancel reminders when task is finished'),
          value: isEnabled,
          onChanged: (value) {
            MiniBox().write(mCancelNotificationsWithTaskFinish, value ?? false);
          },
        );
      },
    );
  }
}
