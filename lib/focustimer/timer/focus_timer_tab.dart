import 'package:flutter/material.dart';
import 'package:minimaltodo/focustimer/timer/duration_selector.dart';
import 'package:minimaltodo/focustimer/timer/timer_controller.dart';
import 'package:minimaltodo/focustimer/timer/timer_controls.dart';
import 'package:minimaltodo/focustimer/timer/timer_display.dart';
import 'package:minimaltodo/focustimer/timer/timer_task_selection_expansion_tile.dart';
import 'package:minimaltodo/focustimer/timer/timer_type_selector.dart';

import '../../helpers/globals.dart' as g show timerController;

class FocusTimerTab extends StatelessWidget {

  const FocusTimerTab({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final availableHeight = mediaQuery.size.height * 0.6; // 60% of screen height

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            scheme.primary.withAlpha(5),
            scheme.surface,
          ],
        ),
      ),
      child: ListenableBuilder(
        listenable: g.timerController,
        builder: (context, child) {
          return SingleChildScrollView(
            child: Column(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                // Button to add tasks for this timer
                TimerTaskSelectionExpansionTile(),

                // Timer type selector
                TimerTypeSelector(),

                // Timer display
                TimerDisplay(),

                // Duration selector
                DurationSelector(),

                // Controls
                TimerControls(),
                SizedBox(height: 20),
                // // Completion actions (if completed)
                // if (controller.isCompleted)
                //   CompletionActions(controller: controller),
              ],
            ),
          );
        },
      ),
    );
  }
}

