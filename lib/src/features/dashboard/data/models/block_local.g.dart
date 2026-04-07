// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block_local.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BlockLocalAdapter extends TypeAdapter<BlockLocal> {
  @override
  final int typeId = 1;

  @override
  BlockLocal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BlockLocal(
      id: fields[0] as String,
      estateId: fields[1] as String,
      code: fields[2] as String,
      area: fields[3] as double,
      palmCount: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, BlockLocal obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.estateId)
      ..writeByte(2)
      ..write(obj.code)
      ..writeByte(3)
      ..write(obj.area)
      ..writeByte(4)
      ..write(obj.palmCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlockLocalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
