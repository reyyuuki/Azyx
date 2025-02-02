import 'package:hive_flutter/hive_flutter.dart';
part 'ui_setting_class.g.dart';

@HiveType(typeId: 4)
class UiSettingClass {
  @HiveField(0)
  double? glowMultiplier;
  @HiveField(1)
  double? blurMultiplier;
  @HiveField(2)
  double? radiusMultiplier;
  @HiveField(3)
  double? spreadMultiplier;

  UiSettingClass(
      {this.blurMultiplier = 1.0,
      this.glowMultiplier = 0.6,
      this.radiusMultiplier = 1.0,
      this.spreadMultiplier = 1.0});
}
