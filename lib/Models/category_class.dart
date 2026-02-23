class Category {
  String? name;
  List<String> anilistIds;
  Category({required this.anilistIds, this.name});

  Map<String, dynamic> toJson() {
    return {'name': name, 'anilistIds': anilistIds};
  }

  factory Category.fromJson(Map<dynamic, dynamic> data) {
    return Category(
      name: data['name'],
      anilistIds: List<String>.from(data['anilistIds'] ?? []),
    );
  }
}
