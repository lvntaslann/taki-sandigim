part of 'tracker_bloc.dart';

enum TrackerStatus { initial, loading, success, failure, submitting }

class TrackerState extends Equatable {
  const TrackerState({
    this.status = TrackerStatus.initial,
    this.balances = const [],
    this.allEntries = const [],
    this.personLedgers = const [],
    this.currentGoldRateTl = 0,
    this.errorMessage,
  });

  final TrackerStatus status;
  final List<BalanceStatus> balances;
  final List<GiftModel> allEntries;
  final List<PersonLedger> personLedgers;
  final double currentGoldRateTl;
  final String? errorMessage;

  TrackerState copyWith({
    TrackerStatus? status,
    List<BalanceStatus>? balances,
    List<GiftModel>? allEntries,
    List<PersonLedger>? personLedgers,
    double? currentGoldRateTl,
    String? errorMessage,
  }) {
    return TrackerState(
      status: status ?? this.status,
      balances: balances ?? this.balances,
      allEntries: allEntries ?? this.allEntries,
      personLedgers: personLedgers ?? this.personLedgers,
      currentGoldRateTl: currentGoldRateTl ?? this.currentGoldRateTl,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        balances,
        allEntries,
        personLedgers,
        currentGoldRateTl,
        errorMessage,
      ];
}
