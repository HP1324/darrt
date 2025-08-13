import 'package:darrt/app/notification/notification_service.dart';
import 'package:darrt/app/services/boxpref.dart';
import 'package:darrt/app/services/mini_box.dart';
import 'package:darrt/app/services/object_box.dart';
import 'package:darrt/helpers/consts.dart';
import 'package:darrt/objectbox.g.dart';
import 'package:flutter/material.dart';

class TimerSettingsSection extends StatelessWidget {
  const TimerSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text('Timer settings'),
      children: const [
        AutoSwitchToBreakTile(),
        AutoSwitchToFocusTile(),
        //TODO: Temporarily exclude "mark tasks as finished after timer finish" setting, think thoroughly about it to implement in future
        // MarkTasksFinishedTile(),
        ShowTimerNotificationTile(),
        PauseResumeSoundTile(),
      ],
    );
  }
}

class AutoSwitchToBreakTile extends StatelessWidget {
  const AutoSwitchToBreakTile({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BoxPref>>(
      stream: ObjectBox()
          .prefsBox
          .query(BoxPref_.key.equals(mAutoSwitchToBreak))
          .watch(triggerImmediately: true)
          .map((query) => query.find()),
      builder: (context, snapshot) {
        final prefs = snapshot.data;
        final isEnabled = prefs?.isNotEmpty == true && prefs!.first.value == 'true';

        return CheckboxListTile(
          key: const ValueKey(mAutoSwitchToBreak),
          title: const Text('Automatically switch to break after focus timer ends'),
          value: isEnabled,
          onChanged: (value) {
            MiniBox().write(mAutoSwitchToBreak, value ?? false);
          },
        );
      },
    );
  }
}

class AutoSwitchToFocusTile extends StatelessWidget {
  const AutoSwitchToFocusTile({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BoxPref>>(
      stream: ObjectBox()
          .prefsBox
          .query(BoxPref_.key.equals(mAutoSwitchToFocus))
          .watch(triggerImmediately: true)
          .map((query) => query.find()),
      builder: (context, snapshot) {
        final prefs = snapshot.data;
        final isEnabled = prefs?.isNotEmpty == true && prefs!.first.value == 'true';

        return CheckboxListTile(
          key: const ValueKey(mAutoSwitchToFocus),
          title: const Text('Automatically switch to focus timer after break ends'),
          value: isEnabled,
          onChanged: (value) {
            MiniBox().write(mAutoSwitchToFocus, value ?? false);
          },
        );
      },
    );
  }
}

class MarkTasksFinishedTile extends StatelessWidget {
  const MarkTasksFinishedTile({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BoxPref>>(
      stream: ObjectBox()
          .prefsBox
          .query(BoxPref_.key.equals(mMarkTasksFinished))
          .watch(triggerImmediately: true)
          .map((query) => query.find()),
      builder: (context, snapshot) {
        final prefs = snapshot.data;
        final isEnabled = prefs?.isNotEmpty == true && prefs!.first.value == 'true';

        return CheckboxListTile(
          key: const ValueKey(mMarkTasksFinished),
          title: const Text('Mark all selected tasks as finished after timer end'),
          value: isEnabled,
          onChanged: (value) {
            MiniBox().write(mMarkTasksFinished, value ?? false);
          },
        );
      },
    );
  }
}

class ShowTimerNotificationTile extends StatelessWidget {
  const ShowTimerNotificationTile({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BoxPref>>(
      stream: ObjectBox()
          .prefsBox
          .query(BoxPref_.key.equals(mShowTimerNotification))
          .watch(triggerImmediately: true)
          .map((query) => query.find()),
      builder: (context, snapshot) {
        final prefs = snapshot.data;
        final isEnabled = prefs?.isNotEmpty == true && prefs!.first.value == 'true';

        return CheckboxListTile(
          key: const ValueKey(mShowTimerNotification),
          title: const Text('Show timer as notification in notification bar until it ends'),
          value: isEnabled,
          onChanged: (value) async{
            if(value != null && value == true){
              final allowed = await NotificationService.showNotificationRationale(context);
              if (allowed == null || !allowed) return;
            }
            MiniBox().write(mShowTimerNotification, value ?? false);
          },
        );
      },
    );
  }
}

class PauseResumeSoundTile extends StatelessWidget {
  const PauseResumeSoundTile({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BoxPref>>(
      stream: ObjectBox()
          .prefsBox
          .query(BoxPref_.key.equals(mPauseResumeSoundWithTimer))
          .watch(triggerImmediately: true)
          .map((query) => query.find()),
      builder: (context, snapshot) {
        final prefs = snapshot.data;
        final isEnabled = prefs?.isNotEmpty == true && prefs!.first.value == 'true';

        return CheckboxListTile(
          key: const ValueKey(mPauseResumeSoundWithTimer),
          title: const Text('Pause and resume sound with timer'),
          value: isEnabled,
          onChanged: (value) {
            MiniBox().write(mPauseResumeSoundWithTimer, value ?? false);
          },
        );
      },
    );
  }
}
