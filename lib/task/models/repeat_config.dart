import 'dart:convert';

import 'package:flutter/foundation.dart' show listEquals;

class RepeatConfig {
  final String? type;
  List<int> days;

  RepeatConfig({this.type = 'weekly', List<int>? days}) : days = days ?? [1, 2, 3, 4, 5, 6];

  RepeatConfig copyWith({String? type, List<int>? days}) {
    return RepeatConfig(
      type: type ?? this.type,
      days: days ?? this.days,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RepeatConfig && other.type == type && listEquals(other.days, days);
  }

  @override
  int get hashCode => Object.hash(type, Object.hashAll(days));
  // set days(List<int> days) {this.days = days;}
  String toJsonString() {
    return jsonEncode({'type': type, 'days': days});
  }

  factory RepeatConfig.fromJsonString(String json) {
    final Map<String, dynamic> data = jsonDecode(json) ?? {};

    return RepeatConfig(
      type: data['type'] ?? 'weekly',
      days: List.from(data['days'] ?? [1, 2, 3, 4, 5, 6]),
    );
  }
}
