class CategoryModel {
  int? id;
  String? name;
  String? iconCode;
  String? color;

  CategoryModel({
    this.id,
    this.name,
    this.iconCode = 'folder',
    this.color,
  });

  CategoryModel copyWith({
    int? id,
    String? name,
    String? iconCode,
    String? color,
  }) =>
      CategoryModel(
        id: id ?? this.id,
        name: name ?? this.name,
        iconCode: iconCode ?? this.iconCode,
        color: color ?? this.color,
      );

  bool isValid() {
    return name != null &&
        name!.trim().isNotEmpty &&
        name!.toLowerCase() != 'general';
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryModel &&
        id == other.id &&
        name == other.name &&
        iconCode == other.iconCode &&
        color == other.color;
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json["id"],
        name: json["name"],
        iconCode: json["icon_code"] ?? 'folder',
        color: json["color"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "icon_code": iconCode,
        "color": color,
      };

  @override
  int get hashCode => Object.hash(id, name, iconCode, color);
}
