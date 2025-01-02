// To parse this JSON data, do
//
//     final categoryModel = categoryModelFromJson(jsonString);

class CategoryModel {
   int? categoryId;
  String? categoryName;

  CategoryModel({
    this.categoryId,
    this.categoryName,
  });

  CategoryModel copyWith({
    int? categoryId,
    String? categoryName,
  }) =>
      CategoryModel(
        categoryId: categoryId ?? this.categoryId,
        categoryName: categoryName ?? this.categoryName,
      );

  bool isValid(){
    return categoryName!.trim().isNotEmpty && categoryName!.toLowerCase() != 'general';
  }

  @override bool operator ==(Object other) {
    return other is CategoryModel && categoryId == other.categoryId && categoryName == other.categoryName;
  }
  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        categoryId: json["categoryId"],
        categoryName: json["categoryName"],
      );

  Map<String, dynamic> toJson() => {
        "categoryId": categoryId,
        "categoryName": categoryName,
      };

  @override
  // TODO: implement hashCode
  int get hashCode => Object.hash(categoryId, categoryName);

}
