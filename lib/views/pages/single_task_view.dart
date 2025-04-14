import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:minimaltodo/data_models/category_model.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/helpers/mini_router.dart';
import 'package:minimaltodo/helpers/miniutils.dart';
import 'package:minimaltodo/services/category_service.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/services/task_service.dart';
import 'package:minimaltodo/views/pages/task_editor_page.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class TaskView extends StatefulWidget {
  const TaskView({super.key, required this.task});
  final Task task;

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  String _getRepeatDescription(Task task) {
    if (!(task.isRepeating ?? false)) return 'Not repeating';

    try {
      final config = jsonDecode(task.repeatConfig ?? '{}');
      final repeatType = config['repeatType'] as String?;
      final selectedDays = List.from(config['selectedDays'] ?? []);

      switch (repeatType) {
        case 'weekly':
          final dayNames = selectedDays
              .map((day) => DateFormat('EEEE').format(
                    DateTime(2024, 1, day + 7), // Jan 7, 2024 was a Sunday
                  ))
              .join(', ');
          return 'Weekly on $dayNames';

        case 'monthly':
          final dayOfMonth = DateFormat('d').format(task.startDate);
          final suffix = _getDayOfMonthSuffix(int.parse(dayOfMonth));
          return 'Monthly on the $dayOfMonth$suffix';

        case 'yearly':
          return 'Yearly on ${DateFormat('MMMM d').format(task.startDate)}';

        default:
          return 'Not repeating';
      }
    } catch (e) {
      return 'Error reading repeat configuration';
    }
  }

  String _getDayOfMonthSuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  String _getReminderTimesDescription(Task task, BuildContext context) {
    if (!(task.isNotifyEnabled ?? false)) return 'Notifications disabled';
    if (task.reminders == null) return 'No reminders set';

    try {
      final times = jsonDecode(task.reminders!) as List;
      return times.map((timeStr) {
        final parts = timeStr.split(':');
        final time = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
        return time.format(context);
      }).join(', ');
    } catch (e) {
      return 'Error reading reminder times';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    MiniLogger.debug('Start date: ${widget.task.startDate}, End Date: ${widget.task.endDate}');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary.withAlpha(30),
        title: Text('${widget.task.title}'),
      ),
      floatingActionButton: TaskViewButton(
        label: 'Edit',
        onTap: () {
          MiniRouter.to(
            context,
            child: TaskEditorPage(editMode: true, taskToEdit: widget.task),
          );
        },
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DetailItem(
            icon: Icons.assignment_outlined,
            title: 'Task',
            subtitle: widget.task.title ?? '',
          ),
          DetailItem(
            icon: Iconsax.category,
            title: 'Categories',
            optionalWidget: FutureBuilder<List<CategoryModel>>(
              future: TaskService.getTaskCategories(widget.task.id!),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return SizedBox.shrink();
                }
                return SizedBox(
                  height: 20,
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.transparent,
                          Colors.black,
                          Colors.black,
                          Colors.transparent
                        ],
                        stops: [0.0, 0.05, 0.95, 1.0],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      separatorBuilder: (context, index) => const SizedBox(width: 2),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final category = snapshot.data![index];
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CategoryService.getIcon(category.iconCode),
                                size: 12,
                                color: category.color != null
                                    ? CategoryService.getColorFromString(context, category.color!)
                                    : Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                category.name ?? '',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          DetailItem(
            icon: Icons.flag_outlined,
            title: 'Priority',
            subtitle: widget.task.priority ?? 'Low',
          ),
          if (widget.task.isRepeating ?? false) ...[
            DetailItem(
              icon: Icons.repeat,
              title: 'Repeat',
              subtitle: _getRepeatDescription(widget.task),
            ),
            DetailItem(
              icon: Icons.date_range,
              title: 'Date Range',
              subtitle: 'From ${DateFormat.yMMMd().format(widget.task.startDate)}'
                  '${widget.task.endDate != null ? ' to ${DateFormat.yMMMd().format(widget.task.endDate!)}' : ' (No end date)'}',
            ),
          ] else ...[
            DetailItem(
              icon: Icons.calendar_today,
              title: 'Due Date',
              subtitle: widget.task.dueDate != null
                  ? DateFormat.yMMMd().format(widget.task.dueDate!)
                  : 'Not scheduled',
            ),
          ],
          DetailItem(
            icon: Icons.notifications,
            title: 'Reminders',
            optionalWidget: Builder(
              builder: (context) {
                if (widget.task.reminders == null || widget.task.reminders!.isEmpty) {
                  return Text('No reminders set');
                }
                final times = widget.task.getReminderTimeOfDaysList;
                return SizedBox(
                  height: 20,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: times.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Text(
                          times[index].format(context),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => SizedBox(width: 10),
                  ),
                );
              },
            ),
          ),
          DetailItem(
            icon: Icons.access_time_outlined,
            title: 'Created',
            subtitle: DateFormat.yMMMd().add_jm().format(widget.task.createdAt!),
          ),
          if (widget.task.isDone ?? false)
            DetailItem(
              icon: Icons.check_circle_outline,
              title: 'Finished',
              subtitle: widget.task.finishedAt != null
                  ? DateFormat.yMMMd().add_jm().format(widget.task.finishedAt!)
                  : 'Unknown',
            ),
        ],
      ),
    );
  }
}

class DetailItem extends StatelessWidget {
  const DetailItem(
      {super.key, required this.icon, required this.title, this.subtitle, this.optionalWidget});
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? optionalWidget;
  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );
    final subtitleStyle = Theme.of(context).textTheme.labelLarge!.copyWith(
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer.withAlpha(15),
      child: ListTile(
        leading: Icon(icon, size: 20),
        title: Text(title, style: titleStyle),
        subtitle: optionalWidget ?? Text(subtitle!, style: subtitleStyle),
      ),
    );
  }
}

class TaskViewButton extends StatelessWidget {
  const TaskViewButton({super.key, required this.label, required this.onTap});
  final Function() onTap;
  final String label;
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onTap,
      child: Icon(Iconsax.edit),
    );
  }
}
