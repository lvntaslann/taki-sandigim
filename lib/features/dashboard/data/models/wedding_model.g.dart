// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wedding_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeddingModelAdapter extends TypeAdapter<WeddingModel> {
  @override
  final int typeId = 0;

  @override
  WeddingModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeddingModel(
      id: fields[0] as String,
      title: fields[1] as String,
      date: fields[2] as DateTime,
      location: fields[3] as String?,
      note: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WeddingModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeddingModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
