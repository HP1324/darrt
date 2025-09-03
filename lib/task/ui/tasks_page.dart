import 'package:darrt/app/calendar/date_bar_controller.dart';
import 'package:darrt/app/calendar/date_providers.dart';
import 'package:darrt/app/extensions/extensions.dart';
import 'package:darrt/app/ui/empty_tasks_indicator.dart';
import 'package:darrt/app/ui/widgets/scrollable_date_bar.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:darrt/helpers/messages.dart';
import 'package:darrt/helpers/utils.dart';
import 'package:darrt/task/state/task_providers.dart';
import 'package:darrt/task/ui/task_delete_confirmation_dialog.dart';
import 'package:darrt/task/ui/task_timeline_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TasksPage extends ConsumerStatefulWidget {
  const TasksPage({super.key});

  @override
  ConsumerState<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends ConsumerState<TasksPage>
    with SingleTickerProviderStateMixin {
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
    final selectedDate = ref.watch(
      selectedDateNotifierProvider.select((calendar) => calendar.selectedDate),
    );
    final textTheme = context.textTheme;

    final dates = ref.read(datesProvider);

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverToBoxAdapter(
          child: ScrollableDateBar(
            controller: ref.read(dateBarControllerProvider),
            selectedDate: selectedDate,
            onDateChanged: (date) {
              ref.read(selectedDateNotifierProvider.notifier).setSelectedDate(date);
            },
            dates: dates,
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _TabBarDelegate(
            TabBar(
              controller: _tabController,
              splashBorderRadius: BorderRadius.circular(10),
              dividerHeight: 0,
              labelStyle: textTheme.titleSmall!.copyWith(
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: textTheme.titleSmall!.copyWith(
                fontWeight: FontWeight.w500,
              ),
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
          TaskList(),
          TaskList(isRepeating: false),
          TaskList(isRepeating: true),
        ],
      ),
    );
  }
}

class TaskList extends ConsumerStatefulWidget {
  const TaskList({super.key, this.isRepeating});

  final bool? isRepeating;

  @override
  ConsumerState<TaskList> createState() => _TaskListState();
}

class _TaskListState extends ConsumerState<TaskList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final taskStream = ref.watch(taskStreamProvider);
    return taskStream.when(
      data: (tasks) {
        tasks = widget.isRepeating == null
            ? tasks
            : tasks.where((t) => t.isRepeating == widget.isRepeating).toList();
        if (tasks.isEmpty) {
          return _getEmptyIndicator();
        }
        return CustomScrollView(
          slivers: [
            SliverList.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final isLast = index == tasks.length - 1;

                // Use timeline item if timeline view is enabled, otherwise use regular item
                // if (g.taskVm.isTimelineView) {
                return TaskTimelineItem(
                  task: task,
                  isLast: isLast,
                );
                // } else {
                //   return TaskItem(task: task);
                // }
              },
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 85)),
          ],
        );
      },
      error: (context, child) {
        return Text('Error loading tasks..');
      },
      loading: () {
        return CircularProgressIndicator();
      },
    );
  }

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
              onPressed: () async =>
                  await _showTaskDeleteConfirmationDialog(context),
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

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _TabBarDelegate(this._tabBar);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
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
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
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
