import 'package:hive_flutter/hive_flutter.dart';
part 'theme_data.g.dart';

@HiveType(typeId: 3)
class ThemeClass {
  @HiveField(1)
  String? seedColor;

  @HiveField(2)
  String? varient;

  @HiveField(3)
  bool? isMaterial;

  @HiveField(4)
  bool? isDarkMode;

  @HiveField(5)
  bool? isLightMode;

  ThemeClass(
      {this.seedColor = "Purple",
       this.varient = "TonalSpot",
       this.isMaterial = true,
       this.isDarkMode = true,
       this.isLightMode = false});
}
