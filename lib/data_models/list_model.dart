class ListModel {
  int? id;
  String? name;
  String? iconCode;

  ListModel({
    this.id,
    this.name,
    this.iconCode = 'folder',
  });

  ListModel copyWith({
    int? id,
    String? name,
    String? iconCode,
  }) =>
      ListModel(
        id: id ?? this.id,
        name: name ?? this.name,
        iconCode: iconCode ?? this.iconCode,
      );

  bool isValid() {
    return name != null &&  name!.trim().isNotEmpty && name!.toLowerCase() != 'general';
  }

  @override
  bool operator ==(Object other) {
    return other is ListModel &&
        id == other.id &&
        name == other.name &&
        iconCode == other.iconCode;
  }

  factory ListModel.fromJson(Map<String, dynamic> json) => ListModel(
        id: json["id"],
        name: json["name"],
        iconCode: json["icon_code"] ?? 'folder',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "icon_code": iconCode,
      };

  @override
  // TODO: implement hashCode
  int get hashCode => Object.hash(id, name, iconCode);
}
