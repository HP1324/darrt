import 'package:minimaltodo/services/database_service.dart';

class StatsService {
  // Insert or update stats for a specific date
  static Future<void> updateStats(String date, Map<String, dynamic> stats) async {
    final database = await DatabaseService.openDb();
    
    // Check if stats for this date already exist
    final existing = await database.query(
      'stats',
      where: 'date = ?',
      whereArgs: [date],
    );

    if (existing.isEmpty) {
      // Insert new stats
      await database.insert('stats', {
        'date': date,
        'total_tasks': stats['total'] ?? 0,
        'completed_tasks': stats['completed'] ?? 0,
        'urgent_tasks': (stats['priorities'] as Map)['Urgent'] ?? 0,
        'high_tasks': (stats['priorities'] as Map)['High'] ?? 0,
        'medium_tasks': (stats['priorities'] as Map)['Medium'] ?? 0,
        'low_tasks': (stats['priorities'] as Map)['Low'] ?? 0,
      });
    } else {
      // Update existing stats
      await database.update(
        'stats',
        {
          'total_tasks': stats['total'] ?? 0,
          'completed_tasks': stats['completed'] ?? 0,
          'urgent_tasks': (stats['priorities'] as Map)['Urgent'] ?? 0,
          'high_tasks': (stats['priorities'] as Map)['High'] ?? 0,
          'medium_tasks': (stats['priorities'] as Map)['Medium'] ?? 0,
          'low_tasks': (stats['priorities'] as Map)['Low'] ?? 0,
        },
        where: 'date = ?',
        whereArgs: [date],
      );
    }
  }

  // Get stats for a specific date
  static Future<Map<String, dynamic>> getStats(String date) async {
    final database = await DatabaseService.openDb();
    final results = await database.query(
      'stats',
      where: 'date = ?',
      whereArgs: [date],
    );

    if (results.isEmpty) {
      return {
        'total': 0,
        'completed': 0,
        'priorities': {
          'Urgent': 0,
          'High': 0,
          'Medium': 0,
          'Low': 0,
        }
      };
    }

    final row = results.first;
    return {
      'total': row['total_tasks'] as int,
      'completed': row['completed_tasks'] as int,
      'priorities': {
        'Urgent': row['urgent_tasks'] as int,
        'High': row['high_tasks'] as int,
        'Medium': row['medium_tasks'] as int,
        'Low': row['low_tasks'] as int,
      }
    };
  }

  // Get stats for a date range
  static Future<List<Map<String, dynamic>>> getStatsRange(
    DateTime startDate, 
    DateTime endDate
  ) async {
    final database = await DatabaseService.openDb();
    final results = await database.query(
      'stats',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [
        startDate.toString().split(' ')[0],
        endDate.toString().split(' ')[0],
      ],
      orderBy: 'date ASC',
    );

    return results.map((row) => {
      'date': DateTime.parse(row['date'] as String),
      'total': row['total_tasks'] as int,
      'completed': row['completed_tasks'] as int,
      'priorities': {
        'Urgent': row['urgent_tasks'] as int,
        'High': row['high_tasks'] as int,
        'Medium': row['medium_tasks'] as int,
        'Low': row['low_tasks'] as int,
      }
    }).toList();
  }
}
