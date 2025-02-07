import 'package:flutter/material.dart';
import 'package:minimaltodo/data_models/task.dart';
import 'package:minimaltodo/helpers/mini_consts.dart';
import 'package:minimaltodo/helpers/mini_logger.dart';
import 'package:minimaltodo/helpers/mini_storage.dart';
import 'dart:convert';

enum TaskFilterType { all, single, recurring }

class CalendarViewModel extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now();
  final Set<int> _selectedTaskIds = {};
  bool _isSelectionMode = false;
  bool _isFabVisible = true;
  
  // Task filter state
  TaskFilterType _taskFilter;
  
  final ScrollController dateScrollController = ScrollController();
  final ScrollController listScrollController = ScrollController();
  final double dateItemWidth = 48.0;
  double? _savedScrollPosition;
  DateTime get selectedDate => _selectedDate;
  Set<int> get selectedTaskIds => _selectedTaskIds;
  bool get isSelectionMode => _isSelectionMode;
  bool get isFabVisible => _isFabVisible;
  TaskFilterType get taskFilter => _taskFilter;
  Map<String,dynamic> taskFinishDates = {};
  // void loadFinishDates (Task task)async{
  //     if(task.isRepeating!){
  //       taskFinishDates = task.getDecompressedFinishDates();
  //     }
  // }

  // Initialize dates range
  final DateTime initialDate = DateTime.parse(MiniBox.read(mFirstInstallDate))
      .subtract(const Duration(days: 365));
  final DateTime maxExtentDate =
      DateTime.now().add(const Duration(days: 18263));

  late List<DateTime> dates = List.generate(
    maxExtentDate.difference(initialDate).inDays + 1,
    (index) => initialDate.add(Duration(days: index)),
  );
  bool _isInitialized = false;
  CalendarViewModel() : _taskFilter = TaskFilterType.values[MiniBox.read(mTaskFilterPreference) ?? 0] {
    MiniLogger.debug('Is scroll controller initialized: $_isInitialized');
    // Initialize scroll position to today's date after frame is rendered
    if (!_isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (dateScrollController.hasClients) {
          scrollToDate(DateTime.now(), animate: false);
        }
      });
      _isInitialized = true;
      
      // Add scroll listener for FAB visibility
      // listScrollController.addListener(_handleScroll);
    }
  }

  double? _lastScrollPosition;
  void _handleScroll() {
    final currentPosition = listScrollController.position.pixels;
    if (_lastScrollPosition != null) {
      // Show FAB when scrolling up, hide when scrolling down
      final isScrollingUp = currentPosition < _lastScrollPosition!;
      if (isScrollingUp != _isFabVisible) {
        _isFabVisible = isScrollingUp;
        notifyListeners();
      }
    }
    _lastScrollPosition = currentPosition;
  }

  void cycleTaskFilter() {
    final values = TaskFilterType.values;
    final nextIndex = (values.indexOf(_taskFilter) + 1) % values.length;
    _taskFilter = values[nextIndex];
    MiniBox.write(mTaskFilterPreference, nextIndex);
    notifyListeners();
  }

  String getTaskFilterLabel() {
    switch (_taskFilter) {
      case TaskFilterType.all:
        return 'All Tasks';
      case TaskFilterType.single:
        return 'Single';
      case TaskFilterType.recurring:
        return 'Recurring';
    }
  }

  IconData getTaskFilterIcon() {
    switch (_taskFilter) {
      case TaskFilterType.all:
        return Icons.list;
      case TaskFilterType.single:
        return Icons.event;
      case TaskFilterType.recurring:
        return Icons.repeat;
    }
  }

  List<Task> filterTasks(List<Task> tasks) {
    if (_taskFilter == TaskFilterType.all) {
      return tasks;
    }
    return tasks.where((task) => 
      task.isRepeating == (_taskFilter == TaskFilterType.recurring)
    ).toList();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void toggleTaskSelection(Task task) {
    if (_selectedTaskIds.contains(task.id)) {
      _selectedTaskIds.remove(task.id);
      if (_selectedTaskIds.isEmpty) {
        _isSelectionMode = false;
      }
    } else {
      _selectedTaskIds.add(task.id!);
      _isSelectionMode = true;
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedTaskIds.clear();
    _isSelectionMode = false;
    notifyListeners();
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Updated scrollToDate with animation option
  void scrollToDate(DateTime date, {bool animate = true}) {
    final index = dates.indexWhere((d) => isSameDay(d, date));
    if (index != -1) {
      if (animate) {
        dateScrollController.animateTo(
          index * dateItemWidth,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        dateScrollController.jumpTo(index * dateItemWidth);
      }
      setSelectedDate(date);
    }
  }

  void saveScrollPosition() {
    if (dateScrollController.hasClients) {
      _savedScrollPosition = dateScrollController.position.pixels;
    }
  }

  void restoreScrollPosition() {
    if (_savedScrollPosition != null && dateScrollController.hasClients) {
      dateScrollController.jumpTo(_savedScrollPosition!);
    }
  }

  List<Task> getTasksForDate(DateTime date, List<Task> allTasks) {
    final List<Task> tasksForDate = [];

    for (var task in allTasks) {
      if (task.isRepeating ?? false) {
        if (_isTaskOccurringOnDate(task, date)) {
          tasksForDate.add(task.copyWith(dueDate: date));
        }
      } else if (task.dueDate != null && isSameDay(task.dueDate!, date)) {
        tasksForDate.add(task);
      }
    }

    return tasksForDate;
  }

  bool _isTaskOccurringOnDate(Task task, DateTime date) {
    // Include start and end dates in the range check
    if (date.isBefore(task.startDate.subtract(const Duration(days: 1))) ||
        (task.endDate != null &&
            date.isAfter(task.endDate!.add(const Duration(days: 1))))) {
      return false;
    }

    try {
      final config = jsonDecode(task.repeatConfig ?? '{}');
      final repeatType = config['repeatType'] as String?;

      switch (repeatType) {
        case 'weekly':
          final selectedDays = List.from(config['selectedDays'] ?? []);
          return selectedDays.contains(date.weekday);
        case 'monthly':
          return date.day == task.startDate.day;
        case 'yearly':
          return date.day == task.startDate.day &&
              date.month == task.startDate.month;
        default:
          return false;
      }
    } catch (e) {
      MiniLogger.error('Error checking task occurrence: $e');
      return false;
    }
  }

  // Update the dates list to include a wider range for repeating tasks
  void generateDates() {
    final now = DateTime.now();
    dates = List.generate(365, (index) {
      return DateTime(now.year, now.month, now.day).add(Duration(days: index));
    });
    notifyListeners();
  }

  @override
  void dispose() {
    dateScrollController.dispose();
    // listScrollController.removeListener(_handleScroll);
    listScrollController.dispose();
    super.dispose();
  }
}
