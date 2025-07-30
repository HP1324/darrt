import 'dart:ui' show lerpDouble;

import 'package:darrt/habits/build/ui/quit_habit_item.dart';
import 'package:flutter/material.dart';

class QuitHabitTab extends StatelessWidget {
  const QuitHabitTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: DraggableQuitHabitList()),
        AddQuitHabitCard(),
      ],
    );
  }
}

class AddQuitHabitCard extends StatelessWidget {
  const AddQuitHabitCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Material(
        elevation: 1,
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.errorContainer,
        child: InkWell(
          onTap: () {
            // Add quit habit logic will go here
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.error,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add,
                    color: colorScheme.onError,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Quit a Bad Habit',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onErrorContainer,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  color: colorScheme.onErrorContainer.withOpacity(0.5),
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

class DraggableQuitHabitList extends StatefulWidget {
  const DraggableQuitHabitList({super.key});

  @override
  State<DraggableQuitHabitList> createState() => _DraggableQuitHabitListState();
}

class _DraggableQuitHabitListState extends State<DraggableQuitHabitList> {
  final List<Map<String, dynamic>> _quitHabits = [
    // ... your existing quit habits data
    {
      'id': '1',
      'name': 'Quit Smoking',
      'description': 'Breaking free from cigarette addiction',
      'daysClean': 25,
      'lastRelapse': DateTime.now().subtract(Duration(days: 25)),
    },
    {
      'id': '2',
      'name': 'Stop Social Media Scrolling',
      'description': 'Reduce mindless social media consumption',
      'daysClean': 12,
      'lastRelapse': DateTime.now().subtract(Duration(days: 12)),
    },
    {
      'id': '3',
      'name': 'Quit Junk Food',
      'description': 'Avoid processed and unhealthy foods',
      'daysClean': 8,
      'lastRelapse': DateTime.now().subtract(Duration(days: 8)),
    },
  ];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      itemCount: _quitHabits.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final item = _quitHabits.removeAt(oldIndex);
          _quitHabits.insert(newIndex, item);
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
        final habit = _quitHabits[index];
        return ReorderableDelayedDragStartListener(
          key: ValueKey(habit['id']),
          index: index,
          child: QuitHabitItem(
            habitName: habit['name'],
            description: habit['description'],
            daysClean: habit['daysClean'],
            lastRelapse: habit['lastRelapse'],
          ),
        );
      },
    );
  }
}
