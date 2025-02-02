// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ThemeClassAdapter extends TypeAdapter<ThemeClass> {
  @override
  final int typeId = 3;

  @override
  ThemeClass read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ThemeClass(
      seedColor: fields[1] as String?,
      varient: fields[2] as String?,
      isMaterial: fields[3] as bool?,
      isDarkMode: fields[4] as bool?,
      isLightMode: fields[5] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, ThemeClass obj) {
    writer
      ..writeByte(5)
      ..writeByte(1)
      ..write(obj.seedColor)
      ..writeByte(2)
      ..write(obj.varient)
      ..writeByte(3)
      ..write(obj.isMaterial)
      ..writeByte(4)
      ..write(obj.isDarkMode)
      ..writeByte(5)
      ..write(obj.isLightMode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeClassAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
