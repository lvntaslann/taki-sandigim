import 'package:hive/hive.dart';

part 'gift_enums.g.dart';

@HiveType(typeId: 2)
enum GiftType {
  @HiveField(0)
  quarterGold,
  @HiveField(1)
  halfGold,
  @HiveField(2)
  fullGold,
  @HiveField(3)
  gremseGold,
  @HiveField(4)
  bracelet,
  @HiveField(5)
  necklace,
  @HiveField(6)
  cash,
  @HiveField(7)
  other,
}

extension GiftTypeLabel on GiftType {
  String get label {
    switch (this) {
      case GiftType.quarterGold:
        return 'Çeyrek Altın';
      case GiftType.halfGold:
        return 'Yarım Altın';
      case GiftType.fullGold:
        return 'Tam Altın';
      case GiftType.gremseGold:
        return 'Gremse Altın';
      case GiftType.bracelet:
        return 'Bilezik';
      case GiftType.necklace:
        return 'Kolye';
      case GiftType.cash:
        return 'Para';
      case GiftType.other:
        return 'Diğer';
    }
  }

  double get gramEquivalent {
    switch (this) {
      case GiftType.quarterGold:
        return 1.75;
      case GiftType.halfGold:
        return 3.5;
      case GiftType.fullGold:
        return 7.0;
      case GiftType.gremseGold:
        return 3.0;
      case GiftType.bracelet:
      case GiftType.necklace:
      case GiftType.cash:
      case GiftType.other:
        return 0.0;
    }
  }
}

@HiveType(typeId: 3)
enum GiftDirection {
  @HiveField(0)
  received,
  @HiveField(1)
  given,
}

extension GiftDirectionLabel on GiftDirection {
  String get label =>
      this == GiftDirection.received ? 'Bize Takılan' : 'Bizim Taktığımız';
}

@HiveType(typeId: 4)
enum RelationType {
  @HiveField(0)
  family,
  @HiveField(1)
  relative,
  @HiveField(2)
  friend,
}

extension RelationTypeLabel on RelationType {
  String get label {
    switch (this) {
      case RelationType.family:
        return 'Aile';
      case RelationType.relative:
        return 'Akraba';
      case RelationType.friend:
        return 'Arkadaş';
    }
  }
}

@HiveType(typeId: 5)
enum EventType {
  @HiveField(0)
  wedding,
  @HiveField(1)
  engagement,
  @HiveField(2)
  henna,
}

extension EventTypeLabel on EventType {
  String get label {
    switch (this) {
      case EventType.wedding:
        return 'Düğün';
      case EventType.engagement:
        return 'Nişan';
      case EventType.henna:
        return 'Kına';
    }
  }

  String get locationLabel {
    switch (this) {
      case EventType.wedding:
        return 'Düğünde takıldı';
      case EventType.engagement:
        return 'Nişanda takıldı';
      case EventType.henna:
        return 'Kınada takıldı';
    }
  }
}
