import 'package:collection/collection.dart';
import 'package:darrt/app/services/toast_service.dart';
import 'package:darrt/category/models/entity_category.dart';
import 'package:darrt/category/ui/category_chip.dart';
import 'package:darrt/habits/build/models/build_habit.dart';
import 'package:darrt/habits/build/models/build_habit_target.dart';
import 'package:darrt/habits/build/models/target_completion.dart';
import 'package:darrt/habits/build/ui/build_habit_stats_page.dart';
import 'package:darrt/habits/build/ui/editor/editor.dart';
import 'package:darrt/helpers/mini_logger.dart';
import 'package:darrt/helpers/mini_router.dart';
import 'package:darrt/helpers/utils.dart';
import 'package:flutter/material.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BuildHabitItem extends StatefulWidget {
  const BuildHabitItem({super.key, required this.habit});
  final BuildHabit habit;
  @override
  State<BuildHabitItem> createState() => _BuildHabitItemState();
}

class _BuildHabitItemState extends State<BuildHabitItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          MiniRouter.to(context, BuildHabitEditor(edit: true, habit: widget.habit));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(child: HabitTitle(habit: widget.habit)),
                  HabitActions(habit: widget.habit),
                ],
              ),
              if (widget.habit.description != null && widget.habit.description!.isNotEmpty) ...[
                SizedBox(height: 4),
                HabitDescription(habit: widget.habit),
              ],
              SizedBox(height: 8),
              HabitCategoriesSection(habit: widget.habit),
              if (widget.habit.getMeasurementType() == MeasurementType.count) ...[
                SizedBox(height: 8),
                HabitProgressIndicator(habit: widget.habit),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class HabitTitle extends StatelessWidget {
  const HabitTitle({super.key, required this.habit});
  final BuildHabit habit;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListenableBuilder(
      listenable: g.buildHabitVm,
      builder: (context, child) {
        return Text(
          habit.name,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        );
      },
    );
  }
}

class HabitActions extends StatelessWidget {
  const HabitActions({super.key, required this.habit});
  final BuildHabit habit;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Icons.insights_rounded,
            size: 18,
            color: getColorFromString(habit.color ?? '') ?? Theme.of(context).primaryColor,
          ),
          padding: EdgeInsets.all(4),
          constraints: BoxConstraints(minWidth: 32, minHeight: 32),
          onPressed: () {
            MiniRouter.to(context, StatsPage(habit: habit));
          },
        ),
        HabitCheckbox(habit: habit),
      ],
    );
  }
}

class HabitCheckbox extends StatelessWidget {
  const HabitCheckbox({super.key, required this.habit});
  final BuildHabit habit;
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([g.buildHabitVm, g.habitCalMan]),
      builder: (context, child) {
        final date = g.habitCalMan.selectedDate.dateOnly.millisecondsSinceEpoch;
        final isCompleted = g.buildHabitVm.habitCompletions[habit.id]?.contains(date) ?? false;
        return Transform.scale(
          scale: 0.9,
          child: Checkbox(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return getColorFromString(habit.color ?? '');
              }
              return null;
            }),
            value: isCompleted,
            onChanged: (value) {
              if (value != null && habit.getMeasurementType() == MeasurementType.boolean) {
                g.buildHabitVm.toggleStatus(habit, value, g.habitCalMan.selectedDate, context);
              } else {
                showWarningToast(
                  context,
                  'Habit will be automatically finished when daily target is completed',
                );
              }
            },
          ),
        );
      },
    );
  }
}

class HabitDescription extends StatelessWidget {
  const HabitDescription({super.key, required this.habit});
  final BuildHabit habit;
  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Text(
      habit.description!,
      style: textTheme.bodySmall?.copyWith(
        color: scheme.onSurface.withValues(alpha: 0.7),
        height: 1.3,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
    );
  }
}

class HabitProgressIndicator extends StatelessWidget {
  const HabitProgressIndicator({super.key, required this.habit});
  final BuildHabit habit;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: g.buildHabitVm,
      builder: (context, child) {
        final scheme = ColorScheme.of(context);
        final textTheme = Theme.of(context).textTheme;
        final target = BuildHabitTarget.fromJsonString(habit.target);
        final completedTarget =
            TargetCompletion.fromJsonStringList(
              habit.targetCompletions,
            )?.firstWhereOrNull((c) => c.date.dateOnly == g.habitCalMan.selectedDate.dateOnly) ??
                TargetCompletion(date: DateTime.now());
        final progress = target.daily > 0
            ? (completedTarget.daily / target.daily).clamp(0.0, 1.0)
            : 0.0;
        final habitColor = getColorFromString(habit.color ?? '') ?? scheme.primary;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: scheme.surfaceContainer.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Decrement button
              _ProgressButton(
                icon: Icons.remove,
                color: habitColor,
                isEnabled: completedTarget.daily > 0,
                onTap: completedTarget.daily > 0
                    ? () => g.buildHabitVm.decrementDailyTargetCompletion(habit, context)
                    : null,
              ),
              SizedBox(width: 12),
              // Progress section
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Progress text
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${completedTarget.daily.toInt()}',
                            style: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: habitColor,
                              height: 1,
                            ),
                          ),
                          TextSpan(
                            text: '/${target.daily.toInt()}',
                            style: textTheme.labelMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                              height: 1,
                            ),
                          ),
                          if (habit.unit != null && habit.unit!.isNotEmpty)
                            TextSpan(
                              text: ' ${habit.unit}',
                              style: textTheme.labelSmall?.copyWith(
                                color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                                height: 1,
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 4),
                    // Progress bar
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation(habitColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              // Increment button
              _ProgressButton(
                icon: Icons.add,
                color: habitColor,
                isEnabled: true,
                onTap: () => g.buildHabitVm.incrementDailyTargetCompletion(habit, context),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProgressButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isEnabled;
  final VoidCallback? onTap;

  const _ProgressButton({
    required this.icon,
    required this.color,
    required this.isEnabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isEnabled
                ? color.withValues(alpha: 0.12)
                : scheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 14,
            color: isEnabled
                ? color
                : scheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}

class HabitCategoriesSection extends StatelessWidget {
  const HabitCategoriesSection({
    super.key,
    required this.habit,
  });

  final BuildHabit habit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18,
      child: HabitCategoriesList(habit: habit),
    );
  }
}

class HabitCategoriesList extends StatelessWidget {
  const HabitCategoriesList({
    super.key,
    required this.habit,
  });

  final BuildHabit habit;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: g.catVm,
      builder: (context, child) {
        var categories = g.catVm.categories;
        habit.categories.removeWhere((c) => !categories.contains(c));
        if (habit.categories.isEmpty) {
          MiniLogger.dp('This condition called');
          habit.categories.add(EntityCategory(id: 1, name: 'General'));
          habit.categories.applyToDb();
        }
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          separatorBuilder: (context, index) => const SizedBox(width: 4),
          itemCount: habit.categories.length,
          itemBuilder: (context, index) {
            final category = habit.categories[index];
            return CategoryChip(category: category);
          },
        );
      },
    );
  }
}
