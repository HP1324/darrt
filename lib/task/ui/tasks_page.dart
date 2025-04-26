import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:minimaltodo/app/calendar_view_model.dart';
import 'package:minimaltodo/app/widgets/empty_tasks_indicator.dart';
import 'package:minimaltodo/helpers/consts.dart';
import 'package:minimaltodo/helpers/mini_box.dart';
import 'package:minimaltodo/task/logic/task_view_model.dart';
import 'package:minimaltodo/task/task.dart';
import 'package:minimaltodo/task/ui/task_item.dart';
import 'package:provider/provider.dart';

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
    return Consumer2<TaskViewModel, CalendarViewModel>(builder: (context, taskVM, calVM, _) {
      final tasks = taskVM.tasks.where((t) => t.isActiveOn(calVM.selectedDate)).toList();
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
    return Consumer<CalendarViewModel>(
      builder: (context, calVM, _) {
        bool isSelected = calVM.selectedDate == date;
        bool isToday = DateUtils.isSameDay(date, DateTime.now());
        final scheme = Theme.of(context).colorScheme;
        return InkWell(
          onTap: () {
            context.read<CalendarViewModel>().updateSelectedDate(date);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 60,
            width: 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? scheme.primary
                  : isToday
                  ? scheme.primaryContainer
                  : scheme.primary.withAlpha(14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  DateFormat('EEE').format(date),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isSelected
                        ? scheme.onPrimary
                        : isToday
                        ? scheme.onPrimaryContainer
                        : scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                CircleAvatar(
                  backgroundColor: isSelected ? scheme.primaryContainer.withAlpha(150) : scheme.primary.withAlpha(30),
                  radius: 11,
                  child: Text(
                    '${date.day}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? scheme.onPrimary
                          : isToday
                          ? scheme.onPrimaryContainer
                          : scheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
                  context.read<TaskViewModel>().deleteSelectedTasks();
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
    return Consumer<CalendarViewModel>(
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