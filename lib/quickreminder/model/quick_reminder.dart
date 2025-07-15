// import 'package:darrt/objectbox.g.dart';
import 'package:objectbox/objectbox.dart';
import 'package:darrt/helpers/consts.dart';

@Entity()
class QuickReminder {
  @Id()
  int id;
  String? title;
  String? type;
  int notifId;
  int durationMinutes;
  QuickReminder({this.id = 0,required this.durationMinutes, this.title, this.type = notifReminderType,required this.notifId});
}
