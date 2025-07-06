
import 'package:minimaltodo/objectbox.g.dart';

// @Entity()
import 'package:minimaltodo/helpers/consts.dart';

class QuickReminder{
  @Id()
  int id = 0;
  final String? title;
  final String? type;
  // @Property(type: PropertyType.)
  final DateTime date;
  QuickReminder({required this.date,this.title, this.type= notifReminderType});

}