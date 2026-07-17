// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gift_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GiftModelAdapter extends TypeAdapter<GiftModel> {
  @override
  final int typeId = 1;

  @override
  GiftModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GiftModel(
      id: fields[0] as String,
      personName: fields[2] as String,
      giftType: fields[3] as GiftType,
      amount: fields[4] as double,
      estimatedValueTl: fields[5] as double,
      direction: fields[6] as GiftDirection,
      date: fields[7] as DateTime,
      weddingId: fields[1] as String?,
      note: fields[8] as String?,
      goldRateTl: fields[9] as double?,
      relationType: fields[10] as RelationType,
    );
  }

  @override
  void write(BinaryWriter writer, GiftModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.weddingId)
      ..writeByte(2)
      ..write(obj.personName)
      ..writeByte(3)
      ..write(obj.giftType)
      ..writeByte(4)
      ..write(obj.amount)
      ..writeByte(5)
      ..write(obj.estimatedValueTl)
      ..writeByte(6)
      ..write(obj.direction)
      ..writeByte(7)
      ..write(obj.date)
      ..writeByte(8)
      ..write(obj.note)
      ..writeByte(9)
      ..write(obj.goldRateTl)
      ..writeByte(10)
      ..write(obj.relationType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GiftModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
