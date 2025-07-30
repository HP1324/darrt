import 'dart:convert';

import 'package:darrt/helpers/globals.dart' as g;
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
    String? uuid,
  }) : uuid = uuid ?? g.uuid.v4();
}

class RelapseEntry {
  /// The date and time when this relapse happened, each relapse will be stored as a separate entry.
  DateTime date;

  /// Optional trigger for the relapse.
  String? trigger;

  RelapseEntry({required this.date, this.trigger});

  RelapseEntry copyWith({DateTime? date, String? trigger}) {
    return RelapseEntry(date: date ?? this.date, trigger: trigger ?? this.trigger);
  }

  static String toJsonString(List<RelapseEntry> relapses) {
    final map = relapses.map(
      (relapse) => {"date": relapse.date.millisecondsSinceEpoch, "trigger": relapse.trigger},
    );
    return jsonEncode(map);
  }

  static List<RelapseEntry> fromJsonString(String json) {
    final List<dynamic> data = jsonDecode(json);
    return data.map((item) {
      return RelapseEntry(
        date: DateTime.fromMillisecondsSinceEpoch(item['date']),
        trigger: item['trigger'],
      );
    }).toList();
  }
}
