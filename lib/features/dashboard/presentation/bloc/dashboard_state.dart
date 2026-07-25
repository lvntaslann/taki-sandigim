part of 'dashboard_bloc.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.upcomingWeddings = const [],
    this.recentEntries = const [],
    this.summary = BudgetSummary.empty,
    this.giftTypeBreakdown = const {},
    this.receivedBreakdown = const {},
    this.givenBreakdown = const {},
    this.receivedByPerson = const [],
    this.givenByPerson = const [],
    this.errorMessage,
  });

  final DashboardStatus status;
  final List<WeddingModel> upcomingWeddings;
  final List<GiftModel> recentEntries;
  final BudgetSummary summary;
  final Map<GiftType, double> giftTypeBreakdown;
  final Map<GiftType, double> receivedBreakdown;
  final Map<GiftType, double> givenBreakdown;
  final List<PersonTotal> receivedByPerson;
  final List<PersonTotal> givenByPerson;
  final String? errorMessage;

  DashboardState copyWith({
    DashboardStatus? status,
    List<WeddingModel>? upcomingWeddings,
    List<GiftModel>? recentEntries,
    BudgetSummary? summary,
    Map<GiftType, double>? giftTypeBreakdown,
    Map<GiftType, double>? receivedBreakdown,
    Map<GiftType, double>? givenBreakdown,
    List<PersonTotal>? receivedByPerson,
    List<PersonTotal>? givenByPerson,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      upcomingWeddings: upcomingWeddings ?? this.upcomingWeddings,
      recentEntries: recentEntries ?? this.recentEntries,
      summary: summary ?? this.summary,
      giftTypeBreakdown: giftTypeBreakdown ?? this.giftTypeBreakdown,
      receivedBreakdown: receivedBreakdown ?? this.receivedBreakdown,
      givenBreakdown: givenBreakdown ?? this.givenBreakdown,
      receivedByPerson: receivedByPerson ?? this.receivedByPerson,
      givenByPerson: givenByPerson ?? this.givenByPerson,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    upcomingWeddings,
    recentEntries,
    summary,
    giftTypeBreakdown,
    receivedBreakdown,
    givenBreakdown,
    receivedByPerson,
    givenByPerson,
    errorMessage,
  ];
}
