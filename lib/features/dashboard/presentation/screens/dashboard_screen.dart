import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:hive_flutter/hive_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/box_names.dart';
import '../../../../core/database/user_settings_repository.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../data/models/gift_enums.dart';
import '../../data/models/gift_model.dart';
import '../../data/repositories/gift_repository.dart';
import '../../data/repositories/wedding_repository.dart';
import '../bloc/dashboard_bloc.dart';
import '../widgets/direction_toggle.dart';

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
  static const List<Color> _chartColors = [
    Color(0xFFD89E30),
    Color(0xFFA67926),
    Color(0xFF463219),
    Color(0xFF736757),
    Color(0xFFFFEBD1),
  ];

  static final Map<GiftType, Color> _giftTypeColors = {
    for (final entry in GiftType.values.indexed)
      entry.$2: _chartColors[entry.$1 % _chartColors.length],
  };

  String? _expandedPerson;
  GiftDirection _direction = GiftDirection.received;

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
                  _appHeader(context),
                  SizedBox(height: 16.h),
                  DirectionToggle(
                    selected: _direction,
                    onChanged: (direction) =>
                        setState(() => _direction = direction),
                  ),
                  SizedBox(height: 16.h),
                  _totalBalanceCard(context, state),
                  SizedBox(height: 16.h),
                  _receivedFromList(context, state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _appHeader(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.card_giftcard_outlined, color: AppColors.primary, size: 32.sp),
        SizedBox(width: 10.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Takı Sandığım',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
                fontSize: 20.sp,
              ),
            ),
            SizedBox(height: 2.h),
            ValueListenableBuilder<Box>(
              valueListenable: Hive.box(BoxNames.settings).listenable(),
              builder: (context, box, _) {
                final name = UserSettingsRepository().getName();
                final greeting = (name == null || name.isEmpty)
                    ? 'Merhaba'
                    : 'Merhaba, $name';
                return Text(
                  greeting,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13.sp,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _totalBalanceCard(BuildContext context, DashboardState state) {
    final breakdown = _direction == GiftDirection.received
        ? state.receivedBreakdown
        : state.givenBreakdown;
    final total = breakdown.values.fold<double>(0, (sum, v) => sum + v);
    final types = GiftType.values
        .where((type) => (breakdown[type] ?? 0) > 0)
        .toList();

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Toplam Bakiye',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 16.h),
          if (total <= 0)
            const Center(
              child: Text(
                'Henüz takı eklenmedi.',
                style: TextStyle(color: AppColors.textMuted),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 180.h,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 46,
                      sections: [
                        for (final type in types)
                          PieChartSectionData(
                            value: breakdown[type],
                            color: _giftTypeColors[type],
                            title:
                                '${((breakdown[type]! / total) * 100).round()}%',
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                            radius: 42,
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    for (final type in types)
                      Expanded(
                        child: _legendRow(
                          color: _giftTypeColors[type]!,
                          label: type.label,
                        ),
                      ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _receivedFromList(BuildContext context, DashboardState state) {
    final isReceived = _direction == GiftDirection.received;
    final people = isReceived ? state.receivedByPerson : state.givenByPerson;
    final total = people.fold<double>(0, (sum, p) => sum + p.totalTl);
    final title = isReceived ? 'Bize Takılanlar' : 'Bizim Taktığımız';

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              if (people.isNotEmpty)
                Text(
                  '${total.toStringAsFixed(0)}TL',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          if (people.isEmpty)
            const Center(
              child: Text(
                'Henüz takı eklenmedi.',
                style: TextStyle(color: AppColors.textMuted),
              ),
            )
          else
            for (final person in people)
              Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _personEntry(state, person.name),
              ),
        ],
      ),
    );
  }

  Widget _personEntry(DashboardState state, String name) {
    final isExpanded = _expandedPerson == name;
    final gifts = state.allGifts
        .where((g) => g.personName == name && g.direction == _direction)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedPerson = isExpanded ? null : name;
              });
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: _personRow(name),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
              child: gifts.isEmpty
                  ? const Text(
                      'Kayıt bulunamadı.',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final gift in gifts)
                          _giftDetailRow(gift, state.allGifts),
                      ],
                    ),
            ),
        ],
      ),
    );
  }

  Widget _giftDetailRow(GiftModel gift, List<GiftModel> allGifts) {
    final dateText = DateFormat('d MMMM yyyy', 'tr_TR').format(gift.date);
    final locationText = gift.eventType?.locationLabel ?? 'Belirtilmedi';
    final oppositeDirection = gift.direction == GiftDirection.received
        ? GiftDirection.given
        : GiftDirection.received;
    final isMatched = allGifts.any(
      (g) =>
          g.personName == gift.personName &&
          g.direction == oppositeDirection &&
          g.giftType == gift.giftType,
    );
    final noteText = gift.direction == GiftDirection.received
        ? (isMatched ? 'Karşılığı Verildi' : 'Karşılığı Verilecek')
        : (isMatched ? 'Karşılığı Alındı' : 'Karşılığı Bekleniyor');
    final noteColor = isMatched ? AppColors.success : AppColors.primaryDark;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${gift.giftType.label} · $dateText · $locationText · '
            '${gift.estimatedValueTl.toStringAsFixed(0)}TL',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          SizedBox(height: 2.h),
          Text(
            noteText,
            style: TextStyle(
              color: noteColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _personRow(String name) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18.r,
          backgroundColor: AppColors.primary,
          child: Padding(
            padding: EdgeInsets.all(4.r),
            child: FittedBox(
              child: Text(
                _initials(name),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  Widget _legendRow({required Color color, required String label}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }
}
