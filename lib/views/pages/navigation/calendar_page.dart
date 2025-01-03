import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/global_utils.dart';
import 'package:minimaltodo/theme/app_theme.dart';
import 'package:minimaltodo/view_models/task_view_model.dart';
import 'package:minimaltodo/views/task_item.dart';
import 'package:provider/provider.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _todayReference;
  late DateTime _selectedDate;
  late PageController _weekController;
  final int _basePageIndex = 1000;
  final int _maxWeeksOffset = 100;
  final Duration _animationDuration = const Duration(milliseconds: 300);
  final Curve _animationCurve = Curves.easeInOut;
  Set<int> _selectedTaskIds = {};
  bool _isSelectionMode = false;

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

  @override
  void initState() {
    super.initState();
    _todayReference = DateTime.now();
    _selectedDate = _todayReference;
    _weekController = PageController(initialPage: _basePageIndex);
  }

  List<DateTime> _getDaysInWeek(int weekOffset) {
    final DateTime firstDayOfWeek = _todayReference.add(
      Duration(days: -(_todayReference.weekday - 1) + (weekOffset * 7)),
    );
    return List.generate(7, (index) => firstDayOfWeek.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskViewModel>(
      builder: (context, taskVM, _) {
        final scheduledTasks = taskVM.tasks.where((task) => 
          task.dueDate != null).toList();

        return Scaffold(
          appBar: _isSelectionMode ? AppBar(
            backgroundColor: AppTheme.primary,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: _clearSelection,
            ),
            title: Text('${_selectedTaskIds.length} selected'),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
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
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ) : null,
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.background50,
                ),
                child: Text(
                  DateFormat('MMMM yyyy').format(_selectedDate),
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              SizedBox(
                height: 80,
                child: PageView.builder(
                  controller: _weekController,
                  onPageChanged: (page) {
                    debugPrint('Page changed: $page');
                    debugPrint('_basePageIndex: $_basePageIndex');
                    debugPrint('_maxWeeksOffset: $_maxWeeksOffset');
                    if (page < _basePageIndex - _maxWeeksOffset ||
                        page > _basePageIndex + _maxWeeksOffset) {
                      _weekController.jumpToPage(_basePageIndex);
                      return;
                    }
                    setState(() {
                      final weekOffset = page - _basePageIndex;
                      final newDates = _getDaysInWeek(weekOffset);
                      if (!newDates.contains(_selectedDate)) {
                        _selectedDate = newDates.first;
                      }
                    });
                  },
                  itemBuilder: (context, page) {
                    final weekOffset = page - _basePageIndex;
                    final dates = _getDaysInWeek(weekOffset);

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: dates.map((date) {
                        final isSelected = date.year == _selectedDate.year &&
                            date.month == _selectedDate.month &&
                            date.day == _selectedDate.day;
                        final isToday = date.year == DateTime.now().year &&
                            date.month == DateTime.now().month &&
                            date.day == DateTime.now().day;

                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedDate = date);
                            logger.d('Date Tapped -> _selectedDate = $_selectedDate');
                          },
                          child: AnimatedContainer(
                            duration: _animationDuration,
                            curve: _animationCurve,
                            width: 48,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primary
                                  : AppTheme.background100,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primary
                                    : isToday
                                        ? AppTheme.primary
                                        : Colors.transparent,
                                width: 1.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.primary.withAlpha(50),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              spacing: 6,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat('EEE').format(date),
                                  style: TextStyle(
                                    fontSize: Theme.of(context).textTheme.labelSmall!.fontSize,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : isToday
                                            ? AppTheme.primary
                                            : Colors.black87,
                                  ),
                                ),
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? Colors.white.withAlpha(65)
                                        : Colors.black.withAlpha(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      date.day.toString(),
                                      style: TextStyle(
                                        fontSize: Theme.of(context).textTheme.labelMedium!.fontSize,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.white
                                            : isToday
                                                ? AppTheme.primary
                                                : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 8),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Tasks for ${DateFormat('MMMM d').format(_selectedDate)}',
                        style: TextStyle(
                          fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    Builder(
                      builder: (context) {
                        final tasksForSelectedDate = scheduledTasks.where((task) {
                          final taskDate = task.dueDate!;
                          return taskDate.year == _selectedDate.year &&
                              taskDate.month == _selectedDate.month &&
                              taskDate.day == _selectedDate.day;
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
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No tasks scheduled for this day',
                                    style: TextStyle(
                                      fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap the + button to add a new task',
                                    style: TextStyle(
                                      fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: tasksForSelectedDate.map((task) => TaskItem(
                            key: ValueKey('${task.id}_${task.isDone}'),
                            task: task,
                            isSelected: _selectedTaskIds.contains(task.id),
                            isSelectionMode: _isSelectionMode,
                            onLongPress: () => _toggleTaskSelection(task),
                            onSelect: (selected) => _toggleTaskSelection(task),
                          )).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _weekController.dispose();
    super.dispose();
  }
}