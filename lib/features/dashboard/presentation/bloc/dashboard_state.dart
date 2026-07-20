part of 'dashboard_bloc.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.upcomingWeddings = const [],
    this.recentEntries = const [],
    this.summary = BudgetSummary.empty,
    this.giftTypeBreakdown = const {},
    this.errorMessage,
  });

  final DashboardStatus status;
  final List<WeddingModel> upcomingWeddings;
  final List<GiftModel> recentEntries;
  final BudgetSummary summary;
  final Map<GiftType, double> giftTypeBreakdown;
  final String? errorMessage;

  DashboardState copyWith({
    DashboardStatus? status,
    List<WeddingModel>? upcomingWeddings,
    List<GiftModel>? recentEntries,
    BudgetSummary? summary,
    Map<GiftType, double>? giftTypeBreakdown,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      upcomingWeddings: upcomingWeddings ?? this.upcomingWeddings,
      recentEntries: recentEntries ?? this.recentEntries,
      summary: summary ?? this.summary,
      giftTypeBreakdown: giftTypeBreakdown ?? this.giftTypeBreakdown,
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
        errorMessage,
      ];
}
