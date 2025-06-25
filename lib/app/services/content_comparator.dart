// Content comparison utilities
class ContentComparator {
  static bool areTasksEqual(Map<String, dynamic> task1, Map<String, dynamic> task2) {
    return task1['title'] == task2['title'] &&
        task1['priority'] == task2['priority'] &&
        task1['isDone'] == task2['isDone'] &&
        task1['isRepeating'] == task2['isRepeating'] &&
        task1['reminders'] == task2['reminders'] &&
        task1['repeatConfig'] == task2['repeatConfig'] &&
        _areDateTimesEqual(task1['createdAt'], task2['createdAt']) &&
        _areDateTimesEqual(task1['endDate'], task2['endDate']) &&
        _areDateTimesEqual(task1['dueDate'], task2['dueDate']) &&
        _areDateTimesEqual(task1['startDate'], task2['startDate']);
  }

  static bool areCategoriesEqual(Map<String, dynamic> cat1, Map<String, dynamic> cat2) {
    return cat1['name'] == cat2['name'] &&
        cat1['icon'] == cat2['icon'] &&
        cat1['color'] == cat2['color'];
  }

  static bool areNotesEqual(Map<String, dynamic> note1, Map<String, dynamic> note2) {
    return note1['content'] == note2['content'] &&
        _areDateTimesEqual(note1['createdAt'], note2['createdAt']) &&
        _areDateTimesEqual(note1['updatedAt'], note2['updatedAt']);
  }

  static bool areFoldersEqual(Map<String, dynamic> folder1, Map<String, dynamic> folder2) {
    return folder1['name'] == folder2['name'];
  }

  static bool areCompletionsEqual(Map<String, dynamic> comp1, Map<String, dynamic> comp2) {
    return _areDateTimesEqual(comp1['date'], comp2['date']) &&
        comp1['isDone'] == comp2['isDone'];
  }

  static bool _areDateTimesEqual(dynamic date1, dynamic date2) {
    if (date1 == null && date2 == null) return true;
    if (date1 == null || date2 == null) return false;

    // Handle both string and DateTime formats
    if (date1 is String && date2 is String) {
      return date1 == date2;
    }

    if (date1 is int && date2 is int) {
      return date1 == date2; // millisecondsSinceEpoch
    }

    return date1.toString() == date2.toString();
  }
}

// Entity type resolver
class EntityTypeResolver {
  static const Map<String, bool Function(Map<String, dynamic>, Map<String, dynamic>)> _comparators = {
    'tasks': ContentComparator.areTasksEqual,
    'categories': ContentComparator.areCategoriesEqual,
    'notes': ContentComparator.areNotesEqual,
    'folders': ContentComparator.areFoldersEqual,
    'completions': ContentComparator.areCompletionsEqual,
  };

  static bool areItemsEqual(String entityType, Map<String, dynamic> item1, Map<String, dynamic> item2) {
    final comparator = _comparators[entityType];
    if (comparator == null) {
      throw ArgumentError('Unknown entity type: $entityType');
    }
    return comparator(item1, item2);
  }
}

