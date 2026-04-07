// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'harvest_queue.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HarvestQueueAdapter extends TypeAdapter<HarvestQueue> {
  @override
  final int typeId = 2;

  @override
  HarvestQueue read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HarvestQueue(
      localId: fields[0] as String,
      blockId: fields[1] as String,
      quantity: fields[2] as double,
      unit: fields[3] as String,
      fieldCode: fields[4] as String,
      timestamp: fields[5] as DateTime,
      synced: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, HarvestQueue obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.localId)
      ..writeByte(1)
      ..write(obj.blockId)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.unit)
      ..writeByte(4)
      ..write(obj.fieldCode)
      ..writeByte(5)
      ..write(obj.timestamp)
      ..writeByte(6)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HarvestQueueAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
