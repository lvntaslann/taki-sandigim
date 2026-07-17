import 'package:hive/hive.dart';

part 'wedding_model.g.dart';

@HiveType(typeId: 0)
class WeddingModel extends HiveObject {
  WeddingModel({
    required this.id,
    required this.title,
    required this.date,
    this.location,
    this.note,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String? location;

  @HiveField(4)
  String? note;
}
