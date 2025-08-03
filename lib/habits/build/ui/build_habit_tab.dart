import 'dart:ui' show lerpDouble;

import 'package:darrt/habits/build/ui/editor/editor.dart';
import 'package:darrt/habits/build/ui/build_habit_item.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/mini_router.dart';
import 'package:darrt/task/ui/tasks_page.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class BuildHabitTab extends StatefulWidget {
  const BuildHabitTab({super.key});

  @override
  State<BuildHabitTab> createState() => _BuildHabitTabState();
}

class _BuildHabitTabState extends State<BuildHabitTab> with AutomaticKeepAliveClientMixin{
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.09,
          child: ListenableBuilder(
            listenable: g.habitCalMan,
            builder: (context,child) {
              return ScrollableDateBar(controller: g.habitCalMan);
            }
          ),
        ),
        Expanded(child: DraggableBuildHabitList()),
        AddBuildHabitCard(),
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class AddBuildHabitCard extends StatelessWidget {
  const AddBuildHabitCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Material(
        elevation: 1,
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.primaryContainer.withValues(alpha: 0.8),
        child: InkWell(
          onTap: () {
            MiniRouter.to(
              context,
              BuildHabitEditor(edit: false),
              type: PageTransitionType.rightToLeft,
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add,
                    color: colorScheme.onPrimary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Build a New Habit',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  color: colorScheme.onPrimaryContainer.withValues(alpha:
                  0.5),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DraggableBuildHabitList extends StatefulWidget {
  const DraggableBuildHabitList({super.key});

  @override
  State<DraggableBuildHabitList> createState() => _DraggableBuildHabitListState();
}

class _DraggableBuildHabitListState extends State<DraggableBuildHabitList> {
  final List<Map<String, dynamic>> _habits = [
    {
      'id': '1',
      'name': 'Drink Water',
      'description': 'Stay hydrated throughout the day',
      'progress': 0.6,
      'targetValue': '8 glasses',
      'currentValue': '5 glasses',
      'isCompleted': false,
    },
    {
      'id': '2',
      'name': 'Morning Exercise',
      'description': 'Start the day with 30 minutes of exercise',
      'progress': 1.0,
      'targetValue': '30 minutes',
      'currentValue': '30 minutes',
      'isCompleted': true,
    },
    {
      'id': '3',
      'name': 'Read Books',
      'description': 'Read for at least 20 minutes daily',
      'progress': 0.4,
      'targetValue': '20 pages',
      'currentValue': '8 pages',
      'isCompleted': false,
    },
    {
      'id': '4',
      'name': 'Meditation',
      'description': 'Practice mindfulness meditation',
      'progress': 0.8,
      'targetValue': '15 minutes',
      'currentValue': '12 minutes',
      'isCompleted': false,
    },
    {
      'id': '5',
      'name': 'Learn Programming',
      'description': 'Practice coding for skill improvement',
      'progress': 0.2,
      'targetValue': '2 hours',
      'currentValue': '25 minutes',
      'isCompleted': false,
    },
  ];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      buildDefaultDragHandles: true,
      itemCount: _habits.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final item = _habits.removeAt(oldIndex);
          _habits.insert(newIndex, item);
        });
      },
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, Widget? child) {
            final double animValue = Curves.easeInOut.transform(animation.value);
            final double elevation = lerpDouble(1, 8, animValue)!;
            final double scale = lerpDouble(1, 1.02, animValue)!;

            return Transform.scale(
              scale: scale,
              child: Material(
                elevation: elevation,
                borderRadius: BorderRadius.circular(12),
                child: child,
              ),
            );
          },
          child: child,
        );
      },
      itemBuilder: (context, index) {
        final habit = _habits[index];
        return ReorderableDelayedDragStartListener(
          key: ValueKey(habit['id']),
          index: index,
          child: BuildHabitItem(
            habitName: habit['name'],
            description: habit['description'],
            progress: habit['progress'],
            targetValue: habit['targetValue'],
            currentValue: habit['currentValue'],
            isCompleted: habit['isCompleted'],
          ),
        );
      },
    );
  }
}
