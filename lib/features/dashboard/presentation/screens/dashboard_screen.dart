import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/box_names.dart';
import '../../../../core/database/user_settings_repository.dart';
import '../../data/models/gift_enums.dart';
import '../../data/repositories/gift_repository.dart';
import '../../data/repositories/wedding_repository.dart';
import '../bloc/dashboard_bloc.dart';
import '../widgets/balance_breakdown_card.dart';
import '../widgets/direction_toggle.dart';
import '../widgets/person_totals_list.dart';
import '../widgets/upcoming_weddings_list.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardBloc(
        weddingRepository: WeddingRepository(),
        giftRepository: GiftRepository(),
      )..add(const DashboardStarted()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  GiftDirection _direction = GiftDirection.received;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state.status == DashboardStatus.loading ||
                state.status == DashboardStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }

            final isReceived = _direction == GiftDirection.received;
            final breakdown =
                isReceived ? state.receivedBreakdown : state.givenBreakdown;
            final people =
                isReceived ? state.receivedByPerson : state.givenByPerson;
            final peopleTotal =
                people.fold<double>(0, (sum, p) => sum + p.totalTl);
            final listTitle =
                isReceived ? 'Sana takılanlar' : 'Senin taktıkların';

            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(const DashboardRefreshed());
              },
              child: ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  _header(context),
                  SizedBox(height: 20.h),
                  DirectionToggle(
                    selected: _direction,
                    onChanged: (direction) =>
                        setState(() => _direction = direction),
                  ),
                  SizedBox(height: 20.h),
                  BalanceBreakdownCard(breakdown: breakdown),
                  SizedBox(height: 20.h),
                  if (state.upcomingWeddings.isNotEmpty) ...[
                    Text(
                      'Yaklaşan Düğünler',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    SizedBox(height: 12.h),
                    UpcomingWeddingsList(weddings: state.upcomingWeddings),
                    SizedBox(height: 20.h),
                  ],
                  PersonTotalsList(
                    title: listTitle,
                    total: peopleTotal,
                    people: people,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return _titleAndGreeting(context);
  }

  Widget _titleAndGreeting(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.card_giftcard_outlined,
          color: AppColors.primary,
          size: 36.sp,
        ),
        SizedBox(width: 10.w),
        Expanded(child: _titleAndName(context)),
      ],
    );
  }

  Widget _titleAndName(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Takı Sandığım',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                fontSize: 20.sp,
              ),
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 2.h),
        ValueListenableBuilder<Box>(
          valueListenable: Hive.box(BoxNames.settings).listenable(),
          builder: (context, box, _) {
            final name = UserSettingsRepository().getName();
            final greeting = (name == null || name.isEmpty)
                ? 'Merhaba! 👋'
                : 'Merhaba, $name 👋';

            return Text(
              greeting,
              style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp),
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
      ],
    );
  }
}
