// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ui_setting_class.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UiSettingClassAdapter extends TypeAdapter<UiSettingClass> {
  @override
  final int typeId = 4;

  @override
  UiSettingClass read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UiSettingClass(
      blurMultiplier: fields[1] as double?,
      glowMultiplier: fields[0] as double?,
      radiusMultiplier: fields[2] as double?,
      spreadMultiplier: fields[3] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, UiSettingClass obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.glowMultiplier)
      ..writeByte(1)
      ..write(obj.blurMultiplier)
      ..writeByte(2)
      ..write(obj.radiusMultiplier)
      ..writeByte(3)
      ..write(obj.spreadMultiplier);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UiSettingClassAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
