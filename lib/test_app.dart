import 'dart:math';
import 'package:sqflite/sqflite.dart';
class TestApp{

  static Future<void> insertTestTasks(Database db) async {
    final random = Random();

    // Sample task titles
    final taskTitles = [
      "Complete Flutter UI design",
      "Grocery shopping",
      "Call mom",
      "Read a book",
      "Prepare presentation",
      "Fix app bug",
      "Plan weekend trip",
      "Water the plants",
      "Workout session",
      "Update resume",
      "Attend online course",
      "Write blog post",
      "Team meeting",
      "Buy a birthday gift",
      "Go for a walk",
      "Organize workspace",
      "Meditate for 10 mins",
      "Backup important files",
      "Learn a new recipe",
      "Watch a tutorial",
    ];

    for (int i = 0; i < 100; i++) {
      // Random title
      String title = taskTitles[random.nextInt(taskTitles.length)];

      // Is it a repeating task?
      bool isRepeating = random.nextBool();

      // Generate start date (somewhere in the last 2 months)
      DateTime startDate = DateTime.now().subtract(Duration(days: random.nextInt(60)));

      // Generate dueDate (for non-repeating tasks)
      DateTime? dueDate = isRepeating ? null : startDate.add(Duration(days: random.nextInt(30)));

      // Generate endDate (for repeating tasks, some null, some within 2 years)
      DateTime? endDate;
      if (isRepeating) {
        bool hasEndDate = random.nextBool();
        endDate = hasEndDate ? startDate.add(Duration(days: random.nextInt(730))) : null;
      }

      // Random priority
      List<String> priorities = ["Low", "Medium", "High", "Urgent"];
      String priority = priorities[random.nextInt(priorities.length)];

      // Insert into database
      await db.insert('tasks', {
        'title': title,
        'isDone': 0,
        'createdAt': startDate.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'isRepeating': isRepeating ? 1 : 0,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'repeatConfig': isRepeating ? '{"repeatType": "weekly","selectedDays":[1,2,3,4,5,6,7]}' : null,
        'priority': priority,
      });
    }
  }

}