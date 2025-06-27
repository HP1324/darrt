// Content comparison utilities
class ContentComparator {
  static String taskContentHash(Map<String, dynamic> json) {
    final basicFields = '${json['title']}|${json['priority']}|${json['isDone']}|${json['isRepeating']}';

    final dateFields =
        '${_ms(json['createdAt'])}|${_ms(json['dueDate'])}|${_ms(json['startDate'])}|${_ms(json['endDate'])}';

    final reminders = json['reminders'] ?? 'null';
    final repeatConfig = json['repeatConfig'] ?? 'null';
    final stringFields = '$reminders|$repeatConfig';

    final categories = (json['categories'] ?? []) as List;
    final sortedCatNames = categories.map((e) => e['name']).toList()..sort();
    final categoriesStr = sortedCatNames.join(',');

    final completions = (json['completions'] ?? []) as List;
    final sortedCompletions = completions
        .map((e) => _ms(e['date']))
        .toList()
      ..sort();
    final completionsStr = sortedCompletions.join(',');

    return '$basicFields|$dateFields|$stringFields|$categoriesStr|$completionsStr';
  }

  static String noteContentHash(Map<String, dynamic> json) {
    final content = json['content'] ?? '';
    final created = _ms(json['createdAt']);
    final updated = _ms(json['updatedAt']);

    final folders = (json['folders'] ?? []) as List;
    final folderNames = folders.map((f) => f['name']).toList()..sort();
    final foldersStr = folderNames.join(',');

    return '$content|$created|$updated|$foldersStr';
  }

  static String folderContentHash(Map<String, dynamic> json) {
    return '${json['name']}';
  }

  static String categoryContentHash(Map<String, dynamic> json) {
    return '${json['name']}|${json['icon']}|${json['color']}';
  }

  static String completionContentHash(Map<String, dynamic> json) {
    return '${_ms(json['date'])}|${json['isDone']}';
  }

  static String _ms(dynamic dt) {
    if (dt == null) return 'null';
    if (dt is int) return dt.toString();
    if (dt is String) return dt;
    return dt.toString();
  }
}

// Entity type resolver
class EntityTypeResolver {
  static final _hashGenerators = <String, String Function(Map<String, dynamic>)>{
    'tasks': ContentComparator.taskContentHash,
    'notes': ContentComparator.noteContentHash,
    'folders': ContentComparator.folderContentHash,
    'categories': ContentComparator.categoryContentHash,
    'completions': ContentComparator.completionContentHash,
  };

  static bool areItemsEqual(String entityType, Map<String, dynamic> item1, Map<String, dynamic> item2) {
    final hashFn = _hashGenerators[entityType];
    if (hashFn == null) {
      throw ArgumentError('Unknown entity type: $entityType');
    }
    return hashFn(item1) == hashFn(item2);
  }
}


