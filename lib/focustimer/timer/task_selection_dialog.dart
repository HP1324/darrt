import 'package:flutter/material.dart';
import 'package:minimaltodo/helpers/mini_router.dart';
import 'package:minimaltodo/helpers/utils.dart';
import 'package:minimaltodo/task/models/task.dart';
import 'package:minimaltodo/task/ui/add_task_page.dart';

import '../../helpers/globals.dart' as g show taskVm, timerController;

class TaskSelectionDialog extends StatefulWidget {
  const TaskSelectionDialog({super.key});

  @override
  State<TaskSelectionDialog> createState() => _TaskSelectionDialogState();
}

class _TaskSelectionDialogState extends State<TaskSelectionDialog>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: Listenable.merge([g.taskVm, g.timerController]),
      builder: (context, child) {
        final allTasks = g.taskVm.tasks;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxHeight: 600),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: 0.15),
                  blurRadius: 32,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(scheme, textTheme),
                _buildTabBar(scheme, textTheme),
                _buildContent(allTasks, scheme, textTheme),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ColorScheme scheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [scheme.primary, scheme.primaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Select Tasks',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ColorScheme scheme, TextTheme textTheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: TabBar(
              controller: _tabController,
              labelColor: scheme.onPrimary,
              unselectedLabelColor: scheme.onSurfaceVariant,
              labelStyle: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              indicator: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(4),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'One-time'),
                Tab(text: 'Repeating'),
              ],
            ),
          ),
          IconButton.filled(
            onPressed: () {
              MiniRouter.to(context, AddTaskPage(edit: false));
            },
            icon: Icon(Icons.add_rounded),
            tooltip: 'Add new task',
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<Task> allTasks, ColorScheme scheme, TextTheme textTheme) {

    return Flexible(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildTaskTab(allTasks.where((task) => !task.isRepeating).toList()),
            _buildTaskTab(allTasks.where((task) => task.isRepeating).toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskTab(List<Task> tasks) {
    return TaskSelectionTab(tasks: tasks);
  }
}

class _EmptyStateIndicator extends StatelessWidget {
  const _EmptyStateIndicator({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.task_alt_rounded,
              size: 32,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No tasks available',
            style: textTheme.titleMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskSelectionItem extends StatefulWidget {
  const _TaskSelectionItem({required this.task});
  final Task task;
  @override
  State<_TaskSelectionItem> createState() => _TaskSelectionItemState();
}

class _TaskSelectionItemState extends State<_TaskSelectionItem> {
  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: g.timerController,
      builder: (context, child) {
        final task = widget.task;
        final isSelected = g.timerController.isTaskSelected(task);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? scheme.primaryContainer.withValues(alpha: 0.3)
                : scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? scheme.primary.withValues(alpha: 0.3)
                  : scheme.outline.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: InkWell(
            onTap: () {
              if (isSelected) {
                g.timerController.removeTask(task);
              } else {
                g.timerController.addTask(task);
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildCheckbox(isSelected, scheme),
                  const SizedBox(width: 16),
                  _buildTaskTitle(task, isSelected, scheme, textTheme),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCheckbox(bool isSelected, ColorScheme scheme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isSelected ? scheme.primary : Colors.transparent,
        border: Border.all(
          color: isSelected ? scheme.primary : scheme.outline,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: isSelected
          ? Icon(
              Icons.check_rounded,
              size: 16,
              color: scheme.onPrimary,
            )
          : null,
    );
  }

  Widget _buildTaskTitle(Task task, bool isSelected, ColorScheme scheme, TextTheme textTheme) {
    return Expanded(
      child: Text(
        task.title,
        style: textTheme.bodyLarge?.copyWith(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? scheme.onSurface : scheme.onSurface.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}

class TaskSelectionTab extends StatefulWidget {
  const TaskSelectionTab({super.key, required this.tasks});
  final List<Task> tasks;

  @override
  State<TaskSelectionTab> createState() => _TaskSelectionTabState();
}

class _TaskSelectionTabState extends State<TaskSelectionTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if(widget.tasks.isEmpty) return _EmptyStateIndicator(message: 'No tasks available');
    final scheme = ColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    final uniqueDates =
        widget.tasks.map((task) => DateUtils.dateOnly(task.dueDate)).toSet().toList()..sort();

    return ListView.builder(
      itemCount: uniqueDates.length,
      itemBuilder: (context, index) {
        final date = uniqueDates[index];
        final tasksForDate = widget.tasks
            .where((task) => DateUtils.dateOnly(task.dueDate) == date)
            .toList();
        final title = getFormattedDateTitle(date);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: scheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: ExpansionTile(
            title: Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            iconColor: scheme.primary,
            collapsedIconColor: scheme.onSurfaceVariant,
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: tasksForDate.map((task) {
              return _TaskSelectionItem(task: task);
            }).toList(),
          ),
        );
      },
    );
  }

  String getFormattedDateTitle(DateTime date) {
    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);
    final target = DateUtils.dateOnly(date);

    final diff = target.difference(today).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';

    return formatDateNoJm(date, 'dd MMM, yyyy');
  }
}
