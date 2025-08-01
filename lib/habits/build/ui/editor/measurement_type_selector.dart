import 'package:darrt/habits/build/models/build_habit.dart';
import 'package:darrt/habits/build/state/build_habit_state_controller.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/utils.dart';
import 'package:flutter/material.dart';

class MeasurementTypeSelector extends StatelessWidget {
  const MeasurementTypeSelector();

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    final scheme = ColorScheme.of(context);
    final color = getColorFromString(g.buildHabitSc.color) ?? scheme.primary;
    final type = g.buildHabitSc.measurementType;

    return Column(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Track progress with',
          style: textTheme.titleSmall?.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<MeasurementType>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment<MeasurementType>(
                value: MeasurementType.boolean,
                label: Text('Yes/No'),
              ),
              ButtonSegment<MeasurementType>(
                value: MeasurementType.count,
                label: Text('Numeric Value'),
              ),
            ],
            selected: {type},
            onSelectionChanged: (Set<MeasurementType> newSelection) {
              g.buildHabitSc.setMeasurementType(newSelection.first);
            },
            style: SegmentedButton.styleFrom(
              backgroundColor: Colors.transparent,
              selectedBackgroundColor: color.withValues(alpha: 0.2),
              selectedForegroundColor: color,
              foregroundColor: scheme.onSurface,
              side: BorderSide(color: color.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}
