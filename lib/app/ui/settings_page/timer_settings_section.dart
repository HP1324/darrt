
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
      title:    Text('Timer settings'),
      children: [
        AutoSwitchToBreakTile(),
        AutoSwitchToFocusTile(),
        MarkTasksFinishedTile(),
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
    return StreamBuilder<Query<BoxPref>>(
      stream: ObjectBox().prefsBox.query(BoxPref_.key.equals(mAutoSwitchToBreak)).watch(),
      builder: (context, snapshot) {
        bool isEnabled = false;
        if (snapshot.hasData) {
          final result = snapshot.data!.find();
          if (result.isNotEmpty) {
            isEnabled = result.first.value == 'true';
          }
        }

        return CheckboxListTile(
          title: Text('Automatically switch to break after focus timer ends'),
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
    return StreamBuilder<Query<BoxPref>>(
      stream: ObjectBox().prefsBox.query(BoxPref_.key.equals(mAutoSwitchToFocus)).watch(),
      builder: (context, snapshot) {
        bool isEnabled = false;
        if (snapshot.hasData) {
          final result = snapshot.data!.find();
          if (result.isNotEmpty) {
            isEnabled = result.first.value == 'true';
          }
        }

        return CheckboxListTile(
          title: Text('Automatically switch to focus timer after break ends'),
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
    return StreamBuilder<Query<BoxPref>>(
      stream: ObjectBox().prefsBox.query(BoxPref_.key.equals(mMarkTasksFinished)).watch(),
      builder: (context, snapshot) {
        bool isEnabled = false;
        if (snapshot.hasData) {
          final result = snapshot.data!.find();
          if (result.isNotEmpty) {
            isEnabled = result.first.value == 'true';
          }
        }

        return CheckboxListTile(
          title: Text('Mark all selected tasks as finished after timer end'),
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
    return StreamBuilder<Query<BoxPref>>(
      stream: ObjectBox().prefsBox.query(BoxPref_.key.equals(mShowTimerNotification)).watch(),
      builder: (context, snapshot) {
        bool isEnabled = false;
        if (snapshot.hasData) {
          final result = snapshot.data!.find();
          if (result.isNotEmpty) {
            isEnabled = result.first.value == 'true';
          }
        }

        return CheckboxListTile(
          title: Text('Show timer as notification in notification bar until it ends'),
          value: isEnabled,
          onChanged: (value) {
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
    return StreamBuilder<Query<BoxPref>>(
      stream: ObjectBox().prefsBox.query(BoxPref_.key.equals(mPauseResumeSound)).watch(),
      builder: (context, snapshot) {
        bool isEnabled = false;
        if (snapshot.hasData) {
          final result = snapshot.data!.find();
          if (result.isNotEmpty) {
            isEnabled = result.first.value == 'true';
          }
        }

        return CheckboxListTile(
          title: Text('Pause and resume sound with timer'),
          value: isEnabled,
          onChanged: (value) {
            MiniBox().write(mPauseResumeSound, value ?? false);
          },
        );
      },
    );
  }
}