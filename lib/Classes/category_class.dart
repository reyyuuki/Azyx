class CategoryClass {
  String? name;
  List<int> anilistIds;
  CategoryClass({required this.anilistIds, this.name});

  Map<String, dynamic> toJson() {
    return {'name': name, 'anilistIds': anilistIds};
  }

  factory CategoryClass.fromJson(Map<dynamic, dynamic> data) {
    return CategoryClass(
        name: data['name'],
        anilistIds: List<int>.from(data['anilistIds'] ?? []));
  }
}
