class Category {
  String? name;
  List<int> anilistIds;
  Category({required this.anilistIds, this.name});

  Map<String, dynamic> toJson() {
    return {'name': name, 'anilistIds': anilistIds};
  }

  factory Category.fromJson(Map<dynamic, dynamic> data) {
    return Category(
        name: data['name'],
        anilistIds: List<int>.from(data['anilistIds'] ?? []));
  }
}
