class WishList {
  int? id;
  String title;
  bool isFulfilled;
  DateTime? createdAt;

  WishList({
    this.id,
    required this.title,
    this.isFulfilled = false,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isFulfilled': isFulfilled ? 1 : 0,
      'createdAt':
          createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory WishList.fromJson(Map<String, dynamic> json) {
    return WishList(
      id: json['id'] as int?,
      title: json['title'] as String,
      isFulfilled: (json['isFulfilled'] as int) == 1,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}
