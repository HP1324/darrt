import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
part 'relapse_entry.freezed.dart';
@freezed
abstract class RelapseEntry with _$RelapseEntry {
  const factory RelapseEntry({required DateTime dateTime, String? trigger}) = _RelpaseEntry;

  static String toJsonString(List<RelapseEntry> relapses) {
    final map = relapses.map(
      (relapse) => {"dateTime": relapse.dateTime.millisecondsSinceEpoch, "trigger": relapse.trigger},
    );
    return jsonEncode(map);
  }

  static List<RelapseEntry> fromJsonString(String json) {
    final List<dynamic> data = jsonDecode(json);
    return data.map((item) {
      return RelapseEntry(
        dateTime: DateTime.fromMillisecondsSinceEpoch(item['dateTime']),
        trigger: item['trigger'],
      );
    }).toList();
  }
}
