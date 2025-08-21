import 'package:darrt/app/extensions/extensions.dart';
import 'package:darrt/app/ui/empty_tasks_indicator.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/messages.dart';
import 'package:darrt/helpers/utils.dart';
import 'package:darrt/task/models/task.dart';
import 'package:darrt/task/ui/task_delete_confirmation_dialog.dart';
import 'package:darrt/task/ui/task_item.dart';
import 'package:darrt/task/ui/task_timeline_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _tabController.addListener(() {
      g.navMan.currentTab.value = _tabController.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([g.taskVm, g.calMan]),
      builder: (context, child) {
        final tasks = g.taskVm.tasks.where((t) => t.isActiveOn(g.calMan.selectedDate)).toList();
        final textTheme = TextTheme.of(context);
        return NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.085,
                child: ScrollableDateBar(),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  controller: _tabController,
                  splashBorderRadius: BorderRadius.circular(10),
                  dividerHeight: 0,
                  labelStyle: textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold),
                  unselectedLabelStyle: textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w500),
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'One-time'),
                    Tab(text: 'Repeating'),
                  ],
                ),
              ),
            ),
            Builder(
              builder: (context) {
                if (g.taskVm.selectedTaskIds.isNotEmpty) {
                  return TasksSelectedActions();
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              TaskList(tasks: tasks),
              TaskList(tasks: tasks, isRepeating: false),
              TaskList(tasks: tasks, isRepeating: true),
            ],
          ),
        );
      },
    );
  }
}

class DateItem extends StatelessWidget {
  const DateItem({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.0),
      child: ListenableBuilder(
        listenable: g.calMan,
        builder: (context, child) {
          final bool isSelected = g.calMan.selectedDate == date;
          final bool isToday = DateUtils.isSameDay(date, DateTime.now());
          final scheme = Theme.of(context).colorScheme;

          // Determine text and background colors based on states
          Color dayTextColor;
          Color dateBackgroundColor;
          Color dateTextColor;

          if (isSelected) {
            dayTextColor = scheme.primary;
            dateBackgroundColor = scheme.primary;
            dateTextColor = scheme.onPrimary;
          } else if (isToday) {
            dayTextColor = scheme.secondary;
            dateBackgroundColor = scheme.secondaryContainer.withValues(alpha: 0.5);
            dateTextColor = scheme.onSecondaryContainer;
          } else {
            dayTextColor = scheme.onSurface.withValues(alpha: 0.8);
            dateBackgroundColor = Colors.transparent;
            dateTextColor = scheme.onSurface;
          }

          return InkWell(
            onTap: () => g.calMan.updateSelectedDate(date),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: isToday
                    ? Border.all(color: scheme.secondary.withValues(alpha: 0.5), width: 1.5)
                    : null,
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
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: scheme.primary.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : null,
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

class _TaskListState extends State<TaskList> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Widget _getEmptyIndicator() {
    if (widget.isRepeating == true) {
      return EmptyTasksIndicator(
        icon: Icons.repeat_on_outlined,
        message: Messages.mNoRepeatingTasksYet,
      );
    } else if (widget.isRepeating == false) {
      return EmptyTasksIndicator(
        icon: Icons.task_alt_outlined,
        message: Messages.mNoOneTimeTasksYet,
      );
    } else {
      return EmptyTasksIndicator(
        icon: Icons.inbox_outlined,
        message: Messages.mNoTasksYet,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListenableBuilder(
      listenable: g.taskVm,
      builder: (context, child) {
        // Filter tasks based on repeating status
        final filteredTasks = widget.isRepeating == null
            ? widget.tasks
            : widget.tasks.where((t) => t.isRepeating == widget.isRepeating).toList();

        if (filteredTasks.isEmpty) {
          return _getEmptyIndicator();
        }

        final sortedTasks = g.taskVm.tasks.sortByTime();

        return CustomScrollView(
          slivers: [
            SliverList.builder(
              itemCount: sortedTasks.length,
              itemBuilder: (context, index) {
                final task = sortedTasks[index];
                final isLast = index == sortedTasks.length - 1;

                // Use timeline item if timeline view is enabled, otherwise use regular item
                if (g.taskVm.isTimelineView) {
                  return TaskTimelineItem(
                    task: task,
                    isLast: isLast,
                  );
                } else {
                  return TaskItem(task: task);
                }
              },
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 85)),
          ],
        );
      },
    );
  }
}

class TasksSelectedActions extends StatelessWidget {
  const TasksSelectedActions({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TasksSelectedActionsDelegate(
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (g.taskVm.selectedTaskIds.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text('${g.taskVm.selectedTaskIds.length}'),
              ),
            Spacer(),
            IconButton(
              tooltip: 'Clear selection',
              onPressed: () => g.taskVm.clearSelection(),
              icon: CloseButtonIcon(),
            ),
            IconButton(
              onPressed: () async => await _showTaskDeleteConfirmationDialog(context),
              icon: Icon(Icons.delete),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showTaskDeleteConfirmationDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return TaskDeleteConfirmationDialog();
      },
    );
  }
}



class ScrollableDateBar extends StatelessWidget {
  const ScrollableDateBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: g.calMan,
      builder: (context, child) {
        return ListView.builder(
          controller: g.calMan.dateScrollController,
          scrollDirection: Axis.horizontal,
          itemExtent: g.calMan.dateItemWidth,
          physics: const BouncingScrollPhysics(),
          itemCount: g.calMan.dates.length,
          itemBuilder: (context, index) => DateItem(date: g.calMan.dates[index]),
        );
      },
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _TabBarDelegate(this._tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(color: getSurfaceColor(context), child: _tabBar);
  }

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) {
    //This function was previously returning false, but that was creating an issue, where the tab bar was not updating when the theme changed.
    return true;
  }
}

class _TasksSelectedActionsDelegate extends SliverPersistentHeaderDelegate {
  final Widget _child;
  _TasksSelectedActionsDelegate(this._child);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      height: kToolbarHeight,
      child: _child,
    );
  }

  @override
  double get maxExtent => kToolbarHeight;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
