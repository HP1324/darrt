import 'dart:convert';

class RepeatConfig{
  final String? type;
  List<int> days;

  RepeatConfig({ this.type = 'weekly', List<int>? days}): days = days ?? [1,2,3,4,5,6];

  // set days(List<int> days) {this.days = days;}
  String toJsonString(){
    return jsonEncode({'type' : type, 'days': days});
  }
  factory RepeatConfig.fromJsonString(String json) {
    final Map<String, dynamic> data = jsonDecode(json) ?? {};

    return RepeatConfig(
      type: data['type'] ?? 'weekly',
      days: List.from(data['days'] ?? [1,2,3,4,5,6]),
    );
  }
}