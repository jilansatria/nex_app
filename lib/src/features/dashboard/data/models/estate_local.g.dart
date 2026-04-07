// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'estate_local.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EstateLocalAdapter extends TypeAdapter<EstateLocal> {
  @override
  final int typeId = 0;

  @override
  EstateLocal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EstateLocal(
      id: fields[0] as String,
      name: fields[1] as String,
      location: fields[2] as String,
      totalArea: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, EstateLocal obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.location)
      ..writeByte(3)
      ..write(obj.totalArea);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EstateLocalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
