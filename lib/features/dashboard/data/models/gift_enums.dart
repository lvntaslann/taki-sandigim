import 'package:hive/hive.dart';

import '../../../../l10n/app_localizations.dart';

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
  @HiveField(8)
  gramGold,
}

extension GiftTypeLabel on GiftType {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case GiftType.quarterGold:
        return l10n.giftTypeQuarterGold;
      case GiftType.halfGold:
        return l10n.giftTypeHalfGold;
      case GiftType.fullGold:
        return l10n.giftTypeFullGold;
      case GiftType.gremseGold:
        return l10n.giftTypeGremseGold;
      case GiftType.gramGold:
        return l10n.giftTypeGramGold;
      case GiftType.bracelet:
        return l10n.giftTypeBracelet;
      case GiftType.necklace:
        return l10n.giftTypeNecklace;
      case GiftType.cash:
        return l10n.giftTypeCash;
      case GiftType.other:
        return l10n.giftTypeOther;
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
      case GiftType.gramGold:
        return 1.0;
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
  String localizedLabel(AppLocalizations l10n) => this == GiftDirection.received
      ? l10n.giftDirectionReceived
      : l10n.giftDirectionGiven;
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
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case RelationType.family:
        return l10n.relationFamily;
      case RelationType.relative:
        return l10n.relationRelative;
      case RelationType.friend:
        return l10n.relationFriend;
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
  @HiveField(3)
  nikah,
}

extension EventTypeLabel on EventType {
  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case EventType.wedding:
        return l10n.eventWedding;
      case EventType.engagement:
        return l10n.eventEngagement;
      case EventType.henna:
        return l10n.eventHenna;
      case EventType.nikah:
        return l10n.eventNikah;
    }
  }

  String localizedLocationLabel(AppLocalizations l10n) {
    switch (this) {
      case EventType.wedding:
        return l10n.eventWeddingLocation;
      case EventType.engagement:
        return l10n.eventEngagementLocation;
      case EventType.henna:
        return l10n.eventHennaLocation;
      case EventType.nikah:
        return l10n.eventNikahLocation;
    }
  }
}
