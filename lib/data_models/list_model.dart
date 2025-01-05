class ListModel {
  int? id;
  String? name;
  String? iconCode;
  String? listColor;

  ListModel({
    this.id,
    this.name,
    this.iconCode = 'folder',
    this.listColor,
  });

  ListModel copyWith({
    int? id,
    String? name,
    String? iconCode,
    String? listColor,
  }) =>
      ListModel(
        id: id ?? this.id,
        name: name ?? this.name,
        iconCode: iconCode ?? this.iconCode,
        listColor: listColor ?? this.listColor,
      );

  bool isValid() {
    return name != null &&
        name!.trim().isNotEmpty &&
        name!.toLowerCase() != 'general';
  }

  @override
  bool operator ==(Object other) {
    return other is ListModel &&
        id == other.id &&
        name == other.name &&
        iconCode == other.iconCode &&
        listColor == other.listColor;
  }

  factory ListModel.fromJson(Map<String, dynamic> json) => ListModel(
        id: json["id"],
        name: json["name"],
        iconCode: json["icon_code"] ?? 'folder',
        listColor: json["list_color"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "icon_code": iconCode,
        "list_color": listColor,
      };

  @override
  int get hashCode => Object.hash(id, name, iconCode, listColor);
}
