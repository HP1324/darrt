
class ListModel {
   int? id;
  String? name;

  ListModel({
    this.id,
    this.name,
  });

  ListModel copyWith({
    int? id,
    String? name,
  }) =>
      ListModel(
        id: id ?? this.id,
        name: name ?? this.name,
      );

  bool isValid(){
    return name!.trim().isNotEmpty && name!.toLowerCase() != 'general';
  }

  @override bool operator ==(Object other) {
    return other is ListModel && id == other.id && name == other.name;
  }
  factory ListModel.fromJson(Map<String, dynamic> json) => ListModel(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };

  @override
  // TODO: implement hashCode
  int get hashCode => Object.hash(id, name);

}
