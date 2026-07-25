// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gift_enums.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GiftTypeAdapter extends TypeAdapter<GiftType> {
  @override
  final int typeId = 2;

  @override
  GiftType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GiftType.quarterGold;
      case 1:
        return GiftType.halfGold;
      case 2:
        return GiftType.fullGold;
      case 3:
        return GiftType.gremseGold;
      case 4:
        return GiftType.bracelet;
      case 5:
        return GiftType.necklace;
      case 6:
        return GiftType.cash;
      case 7:
        return GiftType.other;
      default:
        return GiftType.quarterGold;
    }
  }

  @override
  void write(BinaryWriter writer, GiftType obj) {
    switch (obj) {
      case GiftType.quarterGold:
        writer.writeByte(0);
        break;
      case GiftType.halfGold:
        writer.writeByte(1);
        break;
      case GiftType.fullGold:
        writer.writeByte(2);
        break;
      case GiftType.gremseGold:
        writer.writeByte(3);
        break;
      case GiftType.bracelet:
        writer.writeByte(4);
        break;
      case GiftType.necklace:
        writer.writeByte(5);
        break;
      case GiftType.cash:
        writer.writeByte(6);
        break;
      case GiftType.other:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GiftTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GiftDirectionAdapter extends TypeAdapter<GiftDirection> {
  @override
  final int typeId = 3;

  @override
  GiftDirection read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GiftDirection.received;
      case 1:
        return GiftDirection.given;
      default:
        return GiftDirection.received;
    }
  }

  @override
  void write(BinaryWriter writer, GiftDirection obj) {
    switch (obj) {
      case GiftDirection.received:
        writer.writeByte(0);
        break;
      case GiftDirection.given:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GiftDirectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RelationTypeAdapter extends TypeAdapter<RelationType> {
  @override
  final int typeId = 4;

  @override
  RelationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RelationType.family;
      case 1:
        return RelationType.relative;
      case 2:
        return RelationType.friend;
      default:
        return RelationType.family;
    }
  }

  @override
  void write(BinaryWriter writer, RelationType obj) {
    switch (obj) {
      case RelationType.family:
        writer.writeByte(0);
        break;
      case RelationType.relative:
        writer.writeByte(1);
        break;
      case RelationType.friend:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RelationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EventTypeAdapter extends TypeAdapter<EventType> {
  @override
  final int typeId = 5;

  @override
  EventType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EventType.wedding;
      case 1:
        return EventType.engagement;
      case 2:
        return EventType.henna;
      default:
        return EventType.wedding;
    }
  }

  @override
  void write(BinaryWriter writer, EventType obj) {
    switch (obj) {
      case EventType.wedding:
        writer.writeByte(0);
        break;
      case EventType.engagement:
        writer.writeByte(1);
        break;
      case EventType.henna:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
