import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
part 'target_completion.freezed.dart';

@freezed
abstract class TargetCompletion with _$TargetCompletion {
  const factory TargetCompletion({
    required DateTime date,
    @Default(0) int daily,
  }) = _TargetCompletion;
  const TargetCompletion._();

  String toJsonString() {
    return jsonEncode({'date': date.millisecondsSinceEpoch, 'daily': daily});
  }

  static TargetCompletion? fromJsonString(String? jsonString) {
    if (jsonString == null) return null;
    final map = jsonDecode(jsonString);
    return TargetCompletion(
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      daily: map['daily'],
    );
  }

  // New functions for List<TargetCompletion>
  static String? toJsonStringList(List<TargetCompletion>? completionsList) {
    if (completionsList == null) return null;

    final List<Map<String, dynamic>> jsonList = completionsList
        .map(
          (completion) => {
            'date': completion.date.millisecondsSinceEpoch,
            'daily': completion.daily,
          },
        )
        .toList();

    return jsonEncode(jsonList);
  }

  static List<TargetCompletion>? fromJsonStringList(String? jsonString) {
    if (jsonString == null) return null;

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map(
            (json) => TargetCompletion(
              date: DateTime.fromMillisecondsSinceEpoch(json['date']),
              daily: json['daily'],
            ),
          )
          .toList();
    } catch (e) {
      return null;
    }
  }
}
