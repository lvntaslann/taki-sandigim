part of 'tracker_bloc.dart';

abstract class TrackerEvent extends Equatable {
  const TrackerEvent();

  @override
  List<Object?> get props => [];
}

class TrackerStarted extends TrackerEvent {
  const TrackerStarted();
}

class TrackerGiftAdded extends TrackerEvent {
  const TrackerGiftAdded({
    required this.personName,
    required this.giftType,
    required this.amount,
    required this.estimatedValueTl,
    required this.direction,
    required this.date,
    this.note,
    this.goldRateTl,
    this.relationType = RelationType.friend,
  });

  final String personName;
  final GiftType giftType;
  final double amount;
  final double estimatedValueTl;
  final GiftDirection direction;
  final DateTime date;
  final String? note;
  final double? goldRateTl;
  final RelationType relationType;

  @override
  List<Object?> get props => [
        personName,
        giftType,
        amount,
        estimatedValueTl,
        direction,
        date,
        note,
        goldRateTl,
        relationType,
      ];
}

class TrackerEntryDeleted extends TrackerEvent {
  const TrackerEntryDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
