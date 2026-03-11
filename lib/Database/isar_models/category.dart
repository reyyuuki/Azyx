import 'package:isar_community/isar.dart';

part 'category.g.dart';

@collection
class Category {
  Id id = Isar.autoIncrement;
  @Index()
  String? name;
  List<String>? anilistIds;
  bool isManga;

  Category({this.name, this.anilistIds, this.isManga = false});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'],
      anilistIds: List<String>.from(json['anilistIds'] ?? []),
      isManga: json['isManga'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'anilistIds': anilistIds, 'isManga': isManga};
  }
}
