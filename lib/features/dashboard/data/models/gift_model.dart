import 'package:hive/hive.dart';

import 'gift_enums.dart';

part 'gift_model.g.dart';

@HiveType(typeId: 1)
class GiftModel extends HiveObject {
  GiftModel({
    required this.id,
    required this.personName,
    required this.giftType,
    required this.amount,
    required this.estimatedValueTl,
    required this.direction,
    required this.date,
    this.weddingId,
    this.note,
    this.goldRateTl,
    this.relationType = RelationType.friend,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String? weddingId;

  @HiveField(2)
  String personName;

  @HiveField(3)
  GiftType giftType;

  @HiveField(4)
  double amount;

  @HiveField(5)
  double estimatedValueTl;

  @HiveField(6)
  GiftDirection direction;

  @HiveField(7)
  DateTime date;

  @HiveField(8)
  String? note;

  @HiveField(9)
  double? goldRateTl;

  @HiveField(10)
  RelationType relationType;
}
