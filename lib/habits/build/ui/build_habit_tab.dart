import 'package:darrt/habits/build/ui/build_habit_item.dart';
import 'package:flutter/material.dart';

class BuildHabitTab extends StatelessWidget {
  const BuildHabitTab({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: AddBuildHabitCard(),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                return BuildHabitItem(
                  habitName: 'Sample Habit ${index + 1}',
                  description: 'This is a sample habit for demonstration',
                  progress: (index + 1) * 0.2,
                  targetValue: '8 glasses',
                  currentValue: '${(index + 1) * 2} glasses',
                  isCompleted: (index + 1) * 0.2 >= 1.0,
                );
              },
              childCount: 5, // Sample data
            ),
          ),
        ),
      ],
    );
  }
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
        color: colorScheme.primaryContainer,
        child: InkWell(
          onTap: () {
            // Add habit logic will go here
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
                  color: colorScheme.onPrimaryContainer.withOpacity(0.5),
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




