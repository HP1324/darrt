// import 'package:minimaltodo/objectbox.g.dart';
import 'package:objectbox/objectbox.dart';
import 'package:minimaltodo/helpers/consts.dart';

@Entity()
class QuickReminder {
  @Id()
  int id = 0;
  String? title;
  String? type;

  int durationMinutes;
  QuickReminder({required this.durationMinutes, this.title, this.type = notifReminderType});
}
