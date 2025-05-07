import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:minimaltodo/app/calendar_view_model.dart';
import 'package:minimaltodo/app/widgets/empty_tasks_indicator.dart';
import 'package:minimaltodo/helpers/consts.dart';
import 'package:minimaltodo/helpers/mini_box.dart';
import 'package:minimaltodo/helpers/utils.dart';
import 'package:minimaltodo/task/logic/task_view_model.dart';
import 'package:minimaltodo/task/task.dart';
import 'package:minimaltodo/task/ui/task_item.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TaskViewModel, CalendarManager>(builder: (context, taskVM, calVM, _) {
      final tasks = taskVM.items.where((t) => t.isActiveOn(calVM.selectedDate)).toList();
      final firstDate = DateTime.fromMillisecondsSinceEpoch(MiniBox.read(mFirstInstallDate));
      return Column(
        children: [
          SizedBox(
            height: 60,
            child: ScrollableDateBar(),
          )
          ,
          TabBar(
            controller: _tabController,
            splashBorderRadius: BorderRadius.circular(10),
            dividerHeight: 0,
            labelStyle:Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold),
            unselectedLabelStyle:Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w500),
            tabs: [Tab(text: 'All'), Tab(text: 'Single'), Tab(text: 'Recurring')],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                TaskList(tasks: tasks),
                TaskList(tasks: tasks, isRepeating: false),
                TaskList(tasks: tasks, isRepeating: true),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class DateItem extends StatelessWidget {
  const DateItem({
    super.key,
    required this.date,
  });

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.0),
      child: Consumer<CalendarManager>(
        builder: (context, calVM, _) {
          final bool isSelected = calVM.selectedDate == date;
          final bool isToday = DateUtils.isSameDay(date, DateTime.now());
          final ColorScheme scheme = Theme.of(context).colorScheme;

          // Determine text and background colors based on states
          Color dayTextColor;
          Color dateBackgroundColor;
          Color dateTextColor;

          if (isSelected) {
            // Selected state styling
            dayTextColor = scheme.primary;
            dateBackgroundColor = scheme.primary;
            dateTextColor = scheme.onPrimary;
          } else if (isToday) {
            // Today but not selected styling
            dayTextColor = scheme.secondary;
            dateBackgroundColor = scheme.secondaryContainer.withValues(alpha:0.5);
            dateTextColor = scheme.onSecondaryContainer;
          } else {
            // Default state styling
            dayTextColor = scheme.onSurface.withValues(alpha:0.8);
            dateBackgroundColor = Colors.transparent;
            dateTextColor = scheme.onSurface;
          }

          return InkWell(
            onTap: () {
              context.read<CalendarManager>().updateSelectedDate(date);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: isToday  ?
                Border.all(color: scheme.secondary.withValues(alpha:0.5), width: 1.5) : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(date),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: dayTextColor,
                      fontWeight: isSelected || isToday ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dateBackgroundColor,
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: scheme.primary.withValues(alpha:0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        )
                      ] : null,
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: dateTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class TaskList extends StatefulWidget {
  const TaskList({super.key, required this.tasks, this.isRepeating});
  final List<Task> tasks;

  final bool? isRepeating;

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> with AutomaticKeepAliveClientMixin{
  @override
  bool get wantKeepAlive => true;
  Widget getEmptyIndicator() {
    if (widget.isRepeating == true) {
      return const EmptyTasksIndicator(
        icon: Icons.repeat_on_outlined,
        message: 'No repeating tasks found.\nSet one up for daily routines!',
      );
    } else if (widget.isRepeating == false) {
      return const EmptyTasksIndicator(
        icon: Icons.task_alt_outlined,
        message: 'You have no one-time tasks.\nCreate one to get started!',
      );
    } else {
      return const EmptyTasksIndicator(
        icon: Icons.inbox_outlined,
        message: 'No tasks yet.\nStart by adding your first one!',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final list = widget.isRepeating == null ? widget.tasks : widget.tasks.where((t) => t.isRepeating == widget.isRepeating).toList();
    return Column(
      children: [
        if (context.select((TaskViewModel taskVM) => taskVM.selectedTaskIds).isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  context.read<TaskViewModel>().clearSelection();
                },
                icon: Icon(Icons.cancel),
              ),
              IconButton(
                onPressed: () {
                  final message = context.read<TaskViewModel>().deleteMultipleItems();
                  showToast(context, type: ToastificationType.success, description: message);
                },
                icon: Icon(Icons.delete),
              ),
            ],
          ),
        Expanded(
          child: list.isEmpty ? getEmptyIndicator() : ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              return TaskItem(task: list[index]);
            },
          ),
        ),
      ],
    );
  }
}

class ScrollableDateBar extends StatelessWidget {
  const ScrollableDateBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarManager>(
      builder: (context, calVM, _) {
        return ListView.builder(
          controller: calVM.dateScrollController,
          scrollDirection: Axis.horizontal,
          itemExtent: calVM.dateItemWidth,
          physics: const BouncingScrollPhysics(),
          itemCount: calVM.dates.length,
          itemBuilder: (context, index) => DateItem(
            date: calVM.dates[index],
          ),
        );
      },
    );
  }
}