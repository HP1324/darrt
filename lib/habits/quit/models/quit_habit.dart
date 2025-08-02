import 'dart:convert';

import 'package:darrt/habits/quit/models/relapse_entry.dart';
import 'package:darrt/helpers/globals.dart' as g;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class QuitHabit {
  @Id()
  int id;
  String name;
  /// Relapse list stored as json string using [RelapseEntry.toJsonString]
  String? relapses;
  final String uuid;

  QuitHabit({
    this.id = 0,
    required this.name,
    this.relapses,
    String? uuid,
  }) : uuid = uuid ?? g.uuid.v4();

  DateTime get oldestRelapse {
    final relapseEntries = RelapseEntry.fromJsonString(relapses ?? '');
    
    final dateTimes = relapseEntries.map((relapse) => relapse.dateTime).toList();
    
    return dateTimes.reduce((d1, d2) => d1.isBefore(d2) ? d1 : d2);
    
  }

  DateTime get latestRelapse{
    final relapseEntries = RelapseEntry.fromJsonString(relapses ?? '');

    final dateTimes = relapseEntries.map((relapse) => relapse.dateTime).toList();

    return dateTimes.reduce((d1, d2) => d1.isAfter(d2) ? d1 : d2);
  }
}



