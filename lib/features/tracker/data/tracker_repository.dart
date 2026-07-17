import 'package:uuid/uuid.dart';

import '../../dashboard/data/models/gift_enums.dart';
import '../../dashboard/data/models/gift_model.dart';
import '../../dashboard/data/repositories/gift_repository.dart';

class TrackerRepository {
  TrackerRepository({GiftRepository? giftRepository})
      : _giftRepository = giftRepository ?? GiftRepository();

  final GiftRepository _giftRepository;
  final Uuid _uuid = const Uuid();

  List<GiftModel> getAll() => _giftRepository.getAll();

  Future<GiftModel> addGift({
    required String personName,
    required GiftType giftType,
    required double amount,
    required double estimatedValueTl,
    required GiftDirection direction,
    required DateTime date,
    String? weddingId,
    String? note,
    double? goldRateTl,
    RelationType relationType = RelationType.friend,
  }) async {
    final gift = GiftModel(
      id: _uuid.v4(),
      personName: personName,
      giftType: giftType,
      amount: amount,
      estimatedValueTl: estimatedValueTl,
      direction: direction,
      date: date,
      weddingId: weddingId,
      note: note,
      goldRateTl: goldRateTl,
      relationType: relationType,
    );
    await _giftRepository.save(gift);
    return gift;
  }

  Future<void> delete(String id) => _giftRepository.delete(id);
}
