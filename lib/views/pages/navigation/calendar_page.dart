import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:minimaltodo/helpers/mini_consts.dart';
import 'package:minimaltodo/helpers/mini_storage.dart';
import 'package:provider/provider.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';
import 'package:minimaltodo/views/widgets/task_item.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _selectedDate;
  final Set<int> _selectedTaskIds = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  void _toggleTaskSelection(Task task) {
    setState(() {
      if (_selectedTaskIds.contains(task.id)) {
        _selectedTaskIds.remove(task.id);
        if (_selectedTaskIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedTaskIds.add(task.id!);
        _isSelectionMode = true;
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedTaskIds.clear();
      _isSelectionMode = false;
    });
  }

  void _deleteSelectedTasks(TaskViewModel taskVM) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tasks'),
        content: Text('Delete ${_selectedTaskIds.length} tasks?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              for (var id in _selectedTaskIds) {
                final task = taskVM.tasks.firstWhere((t) => t.id == id);
                taskVM.deleteTask(task);
              }
              _clearSelection();
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskViewModel>(
      builder: (context, taskVM, _) {
        final scheduledTasks = taskVM.tasks.where((task) => task.dueDate != null).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isSelectionMode)
              ListTile(
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _clearSelection,
                ),
                title: Text('${_selectedTaskIds.length} selected'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteSelectedTasks(taskVM),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 2),
              child: Text(
                DateFormat('EEE, d MMM, yyyy').format(_selectedDate),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            ScrollableDateBar(
              initialDate: _selectedDate,
              onDateSelected: (date) {
                setState(() => _selectedDate = date);
              },
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 16),
                children: [
                  Builder(
                    builder: (context) {
                      final tasksForSelectedDate = scheduledTasks.where((task) {
                        final taskDate = task.dueDate!;
                        return taskDate.year == _selectedDate.year && taskDate.month == _selectedDate.month && taskDate.day == _selectedDate.day;
                      }).toList();

                      if (tasksForSelectedDate.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Iconsax.calendar_1,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No tasks scheduled for this day',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap the + button to add a new task',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: tasksForSelectedDate
                            .map((task) => TaskItem(
                                  key: ValueKey('${task.id}_${task.isDone}'),
                                  task: task,
                                  isSelected: _selectedTaskIds.contains(task.id),
                                  isSelectionMode: _isSelectionMode,
                                  onLongPress: () => _toggleTaskSelection(task),
                                  onSelect: (selected) => _toggleTaskSelection(task),
                                ))
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class ScrollableDateBar extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateSelected;
  final ScrollController? scrollController;

  const ScrollableDateBar({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
    this.scrollController,
  });

  @override
  State<ScrollableDateBar> createState() => _ScrollableDateBarState();
}

class _ScrollableDateBarState extends State<ScrollableDateBar> {
  late ScrollController _scrollController;
  late DateTime _selectedDate;
  final double _dateItemWidth = 48.0;

  DateTime initialDate = DateTime.parse(MiniBox.read(mFirstInstallDate)).subtract(Duration(days: 365));
  DateTime maxExtentDate = DateTime.now().add(Duration(days: 18263));

  late final List<DateTime> _dates = List.generate(
    maxExtentDate.difference(initialDate).inDays + 1,
    (index) => initialDate.add(Duration(days:index)),
  );

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _scrollController = widget.scrollController ?? ScrollController();

    // Scroll to initial date after layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialIndex = _dates.indexWhere(
        (date) => isSameDay(date, widget.initialDate),
      );
      if (initialIndex != -1) {
        _scrollController.jumpTo(initialIndex * _dateItemWidth);
      }
    });
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 80,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemExtent: _dateItemWidth,
        physics: const BouncingScrollPhysics(),
        itemCount: _dates.length,
        itemBuilder: (context, index) {
          final date = _dates[index];
          final isSelected = isSameDay(date, _selectedDate);
          final isToday = isSameDay(date, DateTime.now());

          return GestureDetector(
            onTap: () {
              setState(() => _selectedDate = date);
              widget.onDateSelected(date);
            },
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
              elevation: 0,
              color: isSelected
                  ? colorScheme.primary
                  : isToday
                      ? colorScheme.primaryContainer
                      : colorScheme.primary.withAlpha(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(date),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isSelected
                              ? colorScheme.onPrimary
                              : isToday
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? colorScheme.primaryContainer.withAlpha(100)
                          : isToday
                              ? colorScheme.primary.withAlpha(100)
                              : colorScheme.secondaryContainer.withAlpha(30),
                    ),
                    child: Center(
                      child: Text(
                        date.day.toString(),
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: isSelected
                                  ? colorScheme.onPrimary
                                  : isToday
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onSurface,
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

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }
}
