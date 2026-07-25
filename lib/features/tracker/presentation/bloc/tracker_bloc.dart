import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import '../../../../core/database/box_names.dart';
import '../../../../core/network/gold_rate_service.dart';
import '../../../dashboard/data/models/gift_enums.dart';
import '../../../dashboard/data/models/gift_model.dart';
import '../../data/tracker_repository.dart';
import '../../domain/balance_analyzer.dart';
import '../../domain/balance_status.dart';
import '../../domain/person_ledger.dart';
import '../../domain/person_ledger_builder.dart';

part 'tracker_event.dart';
part 'tracker_state.dart';

class TrackerBloc extends Bloc<TrackerEvent, TrackerState> {
  TrackerBloc({
    required TrackerRepository trackerRepository,
    GoldRateService? goldRateService,
  }) : _trackerRepository = trackerRepository,
       _goldRateService = goldRateService ?? GoldRateService(),
       super(const TrackerState()) {
    on<TrackerStarted>(_onStarted);
    on<TrackerGiftAdded>(_onGiftAdded);
    on<TrackerEntryDeleted>(_onEntryDeleted);

    _giftSub = Hive.box<GiftModel>(
      BoxNames.gifts,
    ).watch().listen((_) => add(const TrackerStarted()));
  }

  final TrackerRepository _trackerRepository;
  final GoldRateService _goldRateService;
  late final StreamSubscription<BoxEvent> _giftSub;

  @override
  Future<void> close() {
    _giftSub.cancel();
    return super.close();
  }

  Future<void> _onStarted(
    TrackerEvent event,
    Emitter<TrackerState> emit,
  ) async {
    emit(state.copyWith(status: TrackerStatus.loading));
    try {
      final allEntries = _trackerRepository.getAll();
      final balances = BalanceAnalyzer.calculate(allEntries);
      final personLedgers = PersonLedgerBuilder.build(allEntries);
      final currentGoldRateTl = await _goldRateService.getGoldRateTl();
      emit(
        state.copyWith(
          status: TrackerStatus.success,
          balances: balances,
          allEntries: allEntries,
          personLedgers: personLedgers,
          currentGoldRateTl: currentGoldRateTl,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TrackerStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onGiftAdded(
    TrackerGiftAdded event,
    Emitter<TrackerState> emit,
  ) async {
    emit(state.copyWith(status: TrackerStatus.submitting));
    try {
      await _trackerRepository.addGift(
        personName: event.personName,
        giftType: event.giftType,
        amount: event.amount,
        estimatedValueTl: event.estimatedValueTl,
        direction: event.direction,
        date: event.date,
        note: event.note,
        goldRateTl: event.goldRateTl,
        relationType: event.relationType,
        eventType: event.eventType,
      );
      await _onStarted(const TrackerStarted(), emit);
    } catch (e) {
      emit(
        state.copyWith(
          status: TrackerStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onEntryDeleted(
    TrackerEntryDeleted event,
    Emitter<TrackerState> emit,
  ) async {
    try {
      await _trackerRepository.delete(event.id);
      await _onStarted(const TrackerStarted(), emit);
    } catch (e) {
      emit(
        state.copyWith(
          status: TrackerStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
