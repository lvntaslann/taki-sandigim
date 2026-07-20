import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import '../../../../core/database/box_names.dart';
import '../../data/models/gift_enums.dart';
import '../../data/models/gift_model.dart';
import '../../data/models/wedding_model.dart';
import '../../data/repositories/gift_repository.dart';
import '../../data/repositories/wedding_repository.dart';
import '../../domain/budget_calculator.dart';
import '../../domain/budget_summary.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc({
    required WeddingRepository weddingRepository,
    required GiftRepository giftRepository,
  })  : _weddingRepository = weddingRepository,
        _giftRepository = giftRepository,
        super(const DashboardState()) {
    on<DashboardStarted>(_onStarted);
    on<DashboardRefreshed>(_onStarted);

    _giftSub = Hive.box<GiftModel>(BoxNames.gifts).watch().listen(
          (_) => add(const DashboardRefreshed()),
        );
    _weddingSub = Hive.box<WeddingModel>(BoxNames.weddings).watch().listen(
          (_) => add(const DashboardRefreshed()),
        );
  }

  final WeddingRepository _weddingRepository;
  final GiftRepository _giftRepository;
  late final StreamSubscription<BoxEvent> _giftSub;
  late final StreamSubscription<BoxEvent> _weddingSub;

  @override
  Future<void> close() {
    _giftSub.cancel();
    _weddingSub.cancel();
    return super.close();
  }

  Future<void> _onStarted(
    DashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final upcomingWeddings = _weddingRepository.getUpcoming();
      final allGifts = _giftRepository.getAll();
      final summary = BudgetCalculator.calculate(allGifts);
      final giftTypeBreakdown = BudgetCalculator.breakdownByType(allGifts);
      emit(
        state.copyWith(
          status: DashboardStatus.success,
          upcomingWeddings: upcomingWeddings,
          recentEntries: allGifts.take(5).toList(),
          summary: summary,
          giftTypeBreakdown: giftTypeBreakdown,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DashboardStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
