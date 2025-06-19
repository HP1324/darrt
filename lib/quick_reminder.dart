
// import 'package:minimaltodo/objectbox.g.dart';

// @Entity()
class QuickReminder{
  // @Id()
  int id = 0;
  final String? title;

  // @Property(type: PropertyType.date)
  final DateTime date;
  QuickReminder({required this.date,this.title});

}