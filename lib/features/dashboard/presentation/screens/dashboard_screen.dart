import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/box_names.dart';
import '../../../../core/database/user_settings_repository.dart';
import '../../data/repositories/gift_repository.dart';
import '../../data/repositories/wedding_repository.dart';
import '../bloc/dashboard_bloc.dart';
import '../widgets/main_balance_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/recent_entries_list.dart';
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

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state.status == DashboardStatus.loading ||
                state.status == DashboardStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(const DashboardRefreshed());
              },
              child: ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  _header(context),
                  SizedBox(height: 20.h),
                  MainBalanceCard(summary: state.summary),
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
                  Row(
                    children: [
                      Expanded(
                        child: QuickActionButton(
                          icon: Icons.add_circle_outline,
                          label: 'Yeni Ekle',
                          onTap: () => context.push(
                            AppRoutes.addGift,
                            extra: 0,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: QuickActionButton(
                          icon: Icons.document_scanner_outlined,
                          label: 'Defter Tara',
                          onTap: () => context.push(
                            AppRoutes.addGift,
                            extra: 1,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: QuickActionButton(
                          icon: Icons.settings_outlined,
                          label: 'Ayarlar',
                          onTap: () => context.go(AppRoutes.profile),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Son Kayıtlar',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 12.h),
                  RecentEntriesList(entries: state.recentEntries),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: _greeting(context)),
        Container(
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.secondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _greeting(BuildContext context) {
    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box(BoxNames.settings).listenable(),
      builder: (context, box, _) {
        final name = UserSettingsRepository().getName();
        final greeting =
            (name == null || name.isEmpty) ? 'Merhaba! 👋' : 'Merhaba, $name 👋';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.secondary,
                    fontSize: 22.sp,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2.h),
            Text(
              'Ana Sayfa',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp),
            ),
          ],
        );
      },
    );
  }
}
