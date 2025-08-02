import 'package:darrt/habits/build/state/build_habit_state_controller.dart';
import 'package:darrt/helpers/globals.dart' as g show buildHabitSc;
import 'package:darrt/helpers/utils.dart';
import 'package:flutter/material.dart';

class TargetSelector extends StatefulWidget {
  const TargetSelector({super.key});

  @override
  State<TargetSelector> createState() => _TargetSelectorState();
}

class _TargetSelectorState extends State<TargetSelector> {
  Icon icon = Icon(Icons.add_circle_outline_rounded);
  bool isExpanded = false;
  String unitText = '';

  @override
  void initState() {
    super.initState();
    g.buildHabitSc.unitController.addListener(() {
      setState(() {
        unitText = g.buildHabitSc.unitController.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: g.buildHabitSc,
      builder: (context, child) {
        final scheme = ColorScheme.of(context);
        final color = getColorFromString(g.buildHabitSc.color);
        return ExpansionTile(
          onExpansionChanged: (expanded) {
            setState(() {
              isExpanded = expanded;
              if (isExpanded) {
                icon = Icon(Icons.remove_circle_outline_rounded);
              } else {
                icon = Icon(Icons.add_circle_outline_rounded);
              }
            });
          },
          title: Text('Set Targets ${unitText.isEmpty ? '' : '($unitText)'}'),
          shape: RoundedRectangleBorder(),
          trailing: icon,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                DailyTarget(),
                WeeklyTarget(),
                MonthlyTarget(),
                YearlyTarget(),
              ],
            ),
          ],
        );
      },
    );
  }
}

class TargetItem extends StatelessWidget {
  const TargetItem({
    super.key,
    required this.label,
    this.targetCount = 0,
    this.onIncrement,
    this.onDecrement,
  });
  final String label;
  final int targetCount;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label),
        Row(
          children: [
            InkWell(
              onTap: onDecrement,
              child: Icon(Icons.remove,),
            ),
            Text(targetCount.toString()),
            InkWell(
              onTap: onIncrement,
              child: Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }
}

class DailyTarget extends StatelessWidget {
  const DailyTarget({super.key});

  @override
  Widget build(BuildContext context) {
    return TargetItem(
      label: 'Daily',
      targetCount: g.buildHabitSc.target.daily,
      onIncrement: () {
        final newDailyTarget = g.buildHabitSc.target.daily + 1;
        g.buildHabitSc.setTarget(
          g.buildHabitSc.target.copyWith(daily: newDailyTarget),
        );
      },
      onDecrement: () {
        final newDailyTarget = g.buildHabitSc.target.daily - 1;
        g.buildHabitSc.setTarget(
          g.buildHabitSc.target.copyWith(daily: newDailyTarget),
        );
      },
    );
  }
}

class WeeklyTarget extends StatelessWidget {
  const WeeklyTarget({super.key});
  @override
  Widget build(BuildContext context) {
    return TargetItem(
      label: 'Weekly',
      targetCount: g.buildHabitSc.target.weekly,
      onIncrement: () {
        final newWeeklyTarget = g.buildHabitSc.target.weekly + 1;
        g.buildHabitSc.setTarget(
          g.buildHabitSc.target.copyWith(weekly: newWeeklyTarget),
        );
      },
      onDecrement: () {
        final newWeeklyTarget = g.buildHabitSc.target.weekly - 1;
        g.buildHabitSc.setTarget(
          g.buildHabitSc.target.copyWith(weekly: newWeeklyTarget),
        );
      },
    );
  }
}

class MonthlyTarget extends StatelessWidget {
  const MonthlyTarget({super.key});
  @override
  Widget build(BuildContext context) {
    return TargetItem(
      label: 'Monthly',
      targetCount: g.buildHabitSc.target.monthly,
      onIncrement: () {
        final newMonthlyTarget = g.buildHabitSc.target.monthly + 1;
        g.buildHabitSc.setTarget(
          g.buildHabitSc.target.copyWith(monthly: newMonthlyTarget),
        );
      },
      onDecrement: () {
        final newMonthlyTarget = g.buildHabitSc.target.monthly - 1;
        g.buildHabitSc.setTarget(
          g.buildHabitSc.target.copyWith(monthly: newMonthlyTarget),
        );
      },
    );
  }
}

class YearlyTarget extends StatelessWidget {
  const YearlyTarget({super.key});
  @override
  Widget build(BuildContext context) {
    return TargetItem(
      label: 'Yearly',
      targetCount: g.buildHabitSc.target.yearly,
      onIncrement: () {
        final newYearlyTarget = g.buildHabitSc.target.yearly + 1;
        g.buildHabitSc.setTarget(
          g.buildHabitSc.target.copyWith(yearly: newYearlyTarget),
        );
      },
      onDecrement: () {
        final newYearlyTarget = g.buildHabitSc.target.yearly - 1;
        g.buildHabitSc.setTarget(
          g.buildHabitSc.target.copyWith(yearly: newYearlyTarget),
        );
      },
    );
  }
}
