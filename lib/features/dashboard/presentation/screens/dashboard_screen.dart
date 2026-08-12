import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/box_names.dart';
import '../../../../core/database/user_settings_repository.dart';
import '../../../../core/utils/currency_converter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/banner_ad_widget.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../data/models/gift_enums.dart';
import '../../data/models/gift_model.dart';
import '../../data/repositories/gift_repository.dart';
import '../../data/repositories/wedding_repository.dart';
import '../bloc/dashboard_bloc.dart';
import '../widgets/direction_toggle.dart';
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
  static const Map<GiftType, Color> _giftTypeColors = {
    GiftType.quarterGold: Color(0xFFEAD3C1),
    GiftType.halfGold: Color(0xFFA67926),
    GiftType.fullGold: Color(0xFFB2C2B1),
    GiftType.gremseGold: Color(0xFF736757),
    GiftType.bracelet: Color(0xFFC2B59D),
    GiftType.necklace: Color(0xFFD89E30),
    GiftType.cash: Color(0xFF425757),
    GiftType.other: Color(0xFF8C7B6E),
    GiftType.gramGold: Color(0xFF736757),
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
                  SizedBox(height: 12.h),
                  const Center(child: BannerAdWidget()),
                  SizedBox(height: 12.h),
                  DirectionToggle(
                    selected: _direction,
                    onChanged: (direction) =>
                        setState(() => _direction = direction),
                  ),
                  SizedBox(height: 16.h),
                  _totalBalanceCard(context, state),
                  SizedBox(height: 16.h),
                  _receivedFromList(context, state),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Yaklaşan Düğünler',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      InkWell(
                        onTap: () => context.push(AppRoutes.calendar),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_month_outlined,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Takvim',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  UpcomingWeddingsList(weddings: state.upcomingWeddings),
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
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 21.sp,
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
                    color: AppColors.muted(context),
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _emptyState(
    BuildContext context, {
    required IconData icon,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Column(
        children: [
          Icon(icon, size: 24, color: AppColors.primary.withValues(alpha: 0.5)),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.muted(context),
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 10),
            CustomButton(
              label: actionLabel,
              icon: Icons.add,
              variant: CustomButtonVariant.outline,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }

  Widget _totalBalanceCard(BuildContext context, DashboardState state) {
    final typeGifts = <GiftType, List<GiftModel>>{};
    for (final gift in state.allGifts) {
      if (gift.direction != _direction) continue;
      (typeGifts[gift.giftType] ??= <GiftModel>[]).add(gift);
    }
    final typeBreakdown = <GiftType, double>{
      for (final entry in typeGifts.entries)
        entry.key: entry.value.fold<double>(0, (s, g) => s + g.estimatedValueTl),
    };
    final total = typeBreakdown.values.fold<double>(0, (sum, v) => sum + v);

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hediye Dağılımı',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 12.h),
          Center(
            child: _TotalBalanceBubbleChart(
              centerLabel: '${total.toStringAsFixed(0)} TL',
              typeBreakdown: typeBreakdown,
              typeColors: _giftTypeColors,
              onTypeTap: (type) => _showTypeDetailDialog(context, type, typeGifts[type] ?? const []),
              onCenterTap: () => _showOverallDetailDialog(context, state.allGifts),
            ),
          ),
        ],
      ),
    );
  }

  void _showTypeDetailDialog(
    BuildContext context,
    GiftType type,
    List<GiftModel> gifts,
  ) {
    const currencyTypes = {GiftType.cash, GiftType.other};
    const noAdetTypes = {GiftType.other, GiftType.necklace, GiftType.bracelet};
    const currencyLabels = {
      'USD': 'Dolar',
      'EUR': 'Euro',
      'GBP': 'Sterlin',
    };

    final recordCount = gifts.length;
    final totalAmount = gifts.fold<double>(0, (s, g) => s + g.amount);
    final totalTl = gifts.fold<double>(0, (s, g) => s + g.estimatedValueTl);
    final isCurrencyType = currencyTypes.contains(type);
    final showAdet = !noAdetTypes.contains(type) && !isCurrencyType;
    final totalGram = isCurrencyType
        ? null
        : type.gramEquivalent > 0
        ? totalAmount * type.gramEquivalent
        : totalAmount;

    final currencyTotals = <String, double>{};
    if (isCurrencyType) {
      for (final g in gifts) {
        final code = g.currencyCode ?? 'TL';
        currencyTotals[code] = (currencyTotals[code] ?? 0) + g.amount;
      }
    }

    String formatNumber(double n) =>
        n == n.roundToDouble() ? n.toStringAsFixed(0) : n.toStringAsFixed(2);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(type.label),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow(
              context,
              label: 'Kayıt Sayısı',
              value: '$recordCount adet kayıt',
            ),
            if (showAdet)
              _detailRow(
                context,
                label: 'Toplam Adet',
                value: '${formatNumber(totalAmount)} adet',
              ),
            if (totalGram != null)
              _detailRow(
                context,
                label: 'Toplam Gram',
                value: '${formatNumber(totalGram)} g',
              ),
            if (isCurrencyType)
              for (final code in ['TL', 'USD', 'EUR', 'GBP'])
                if (currencyTotals[code] != null)
                  _detailRow(
                    context,
                    label: 'Toplam ${currencyLabels[code] ?? code}',
                    value: _formatCurrencyAmount(code, currencyTotals[code]!),
                  ),
            const Divider(height: 20),
            _detailRow(
              context,
              label: 'Toplam Değer',
              value: CurrencyConverter.formatTl(totalTl),
              emphasize: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showOverallDetailDialog(BuildContext context, List<GiftModel> allGifts) {
    const goldTypes = {
      GiftType.quarterGold,
      GiftType.halfGold,
      GiftType.fullGold,
      GiftType.gremseGold,
      GiftType.gramGold,
    };
    const currencyTypes = {GiftType.cash, GiftType.other};
    const currencyLabels = {
      'USD': 'Dolar',
      'EUR': 'Euro',
      'GBP': 'Sterlin',
    };

    final gifts = allGifts.where((g) => g.direction == _direction).toList();
    final totalTl = gifts.fold<double>(0, (s, g) => s + g.estimatedValueTl);
    final totalGoldGram = gifts
        .where((g) => goldTypes.contains(g.giftType))
        .fold<double>(0, (s, g) => s + g.amount * g.giftType.gramEquivalent);

    final currencyTotals = <String, double>{};
    for (final g in gifts.where((g) => currencyTypes.contains(g.giftType))) {
      final code = g.currencyCode ?? 'TL';
      currencyTotals[code] = (currencyTotals[code] ?? 0) + g.amount;
    }

    String formatNumber(double n) =>
        n == n.roundToDouble() ? n.toStringAsFixed(0) : n.toStringAsFixed(2);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Genel Toplam'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (totalGoldGram > 0)
              _detailRow(
                context,
                label: 'Toplam Gram Altın',
                value: '${formatNumber(totalGoldGram)} g',
              ),
            for (final code in ['TL', 'USD', 'EUR', 'GBP'])
              if (currencyTotals[code] != null)
                _detailRow(
                  context,
                  label: 'Toplam ${currencyLabels[code] ?? code}',
                  value: _formatCurrencyAmount(code, currencyTotals[code]!),
                ),
            const Divider(height: 20),
            _detailRow(
              context,
              label: 'Genel Toplam Değer',
              value: CurrencyConverter.formatTl(totalTl),
              emphasize: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  String _formatCurrencyAmount(String code, double n) {
    const symbols = {'TL': '₺', 'USD': '\$', 'EUR': '€', 'GBP': '£'};
    final formatted = n == n.roundToDouble() ? n.toStringAsFixed(0) : n.toStringAsFixed(2);
    return '$formatted ${symbols[code] ?? code}';
  }

  Widget _detailRow(
    BuildContext context, {
    required String label,
    required String value,
    bool emphasize = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.muted(context),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: emphasize ? 17 : 15,
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
              color: emphasize ? AppColors.secondary : null,
            ),
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
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (people.isNotEmpty)
                Text(
                  '${total.toStringAsFixed(0)}TL',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          if (people.isEmpty)
            Center(
              child: _emptyState(
                context,
                icon: isReceived
                    ? Icons.card_giftcard_outlined
                    : Icons.volunteer_activism_outlined,
                message: isReceived
                    ? 'Henüz sana takılan bir şey yok.'
                    : 'Henüz kimseye takı vermedin.',
                actionLabel: 'Takı Ekle',
                onAction: () => context.push(AppRoutes.addGift),
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
    final personTotal = gifts.fold<double>(0, (sum, g) => sum + g.estimatedValueTl);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isExpanded ? AppColors.primary.withValues(alpha: 0.05) : null,
        borderRadius: BorderRadius.circular(16),
      ),
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
              child: _personRow(name, personTotal, isExpanded),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
              child: gifts.isEmpty
                  ? Text(
                      'Kayıt bulunamadı.',
                      style: TextStyle(
                        color: AppColors.muted(context),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : Column(
                      children: [
                        for (final gift in gifts)
                          Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: _giftDetailRow(gift, state.allGifts),
                          ),
                      ],
                    ),
            ),
        ],
      ),
    );
  }

  Widget _giftDetailRow(GiftModel gift, List<GiftModel> allGifts) {
    final dateText = DateFormatter.shortDate(gift.date);
    final locationText = gift.eventType?.locationLabel;
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
    final typeColor = _giftTypeColors[gift.giftType] ?? AppColors.primary;
    final titleText = gift.giftType == GiftType.cash && gift.currencyCode != null
        ? '${gift.giftType.label} '
              '(${gift.amount.toStringAsFixed(gift.amount % 1 == 0 ? 0 : 2)} '
              '${gift.currencyCode})'
        : gift.giftType.label;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: typeColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  titleText,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                ),
              ),
              Text(
                '${gift.estimatedValueTl.toStringAsFixed(0)}TL',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  [dateText, if (locationText != null) locationText].join(' · '),
                  style: TextStyle(
                    color: AppColors.muted(context),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: noteColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  noteText,
                  style: TextStyle(
                    color: noteColor,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _personRow(String name, double personTotal, bool isExpanded) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18.r,
          backgroundColor: AppColors.primary.withValues(alpha: 0.16),
          child: Padding(
            padding: EdgeInsets.all(4.r),
            child: FittedBox(
              child: Text(
                _initials(name),
                style: const TextStyle(
                  color: AppColors.primary,
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '${personTotal.toStringAsFixed(0)}TL',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(width: 4.w),
        AnimatedRotation(
          turns: isExpanded ? 0.5 : 0,
          duration: const Duration(milliseconds: 200),
          child: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.muted(context),
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

}

class _TotalBalanceBubbleChart extends StatelessWidget {
  const _TotalBalanceBubbleChart({
    required this.centerLabel,
    required this.typeBreakdown,
    required this.typeColors,
    required this.onTypeTap,
    required this.onCenterTap,
  });

  final String centerLabel;
  final Map<GiftType, double> typeBreakdown;
  final Map<GiftType, Color> typeColors;
  final ValueChanged<GiftType> onTypeTap;
  final VoidCallback onCenterTap;

  static const double _centerDiameter = 110;
  static const double _maxSurroundDiameter = _centerDiameter * 0.62;
  // Populated bubbles never shrink below this, so their label/percentage
  // stay legible even when their share of the total is small.
  static const double _minPopulatedDiameter = _centerDiameter * 0.5;
  static const double _emptyDiameter = _centerDiameter * 0.26;
  static const double _margin = 6;

  @override
  Widget build(BuildContext context) {
    final types = GiftType.values.where((t) => t != GiftType.other).toList();
    final total = typeBreakdown.values.fold<double>(0, (s, v) => s + v);
    final maxValue = typeBreakdown.values.isEmpty
        ? 0.0
        : typeBreakdown.values.reduce((a, b) => a > b ? a : b);

    // Ring radius must be large enough that two full-size adjacent bubbles
    // don't overlap each other, and that a full-size bubble doesn't
    // overlap the center circle.
    final angleSpacingRadius = _maxSurroundDiameter /
        (2 * math.sin(math.pi / types.length));
    final clearCenterRadius =
        _centerDiameter / 2 + _maxSurroundDiameter / 2 + _margin;
    final ringRadius = math.max(angleSpacingRadius, clearCenterRadius);
    final chartSize = 2 * (ringRadius + _maxSurroundDiameter / 2 + _margin);

    return SizedBox(
      width: chartSize.w,
      height: chartSize.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (var i = 0; i < types.length; i++)
            _positionedBubble(
              index: i,
              count: types.length,
              type: types[i],
              value: typeBreakdown[types[i]] ?? 0,
              total: total,
              maxValue: maxValue,
              ringRadius: ringRadius,
            ),
          GestureDetector(
            onTap: onCenterTap,
            child: _bubble(
              diameter: _centerDiameter.w,
              color: AppColors.secondary,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Toplam',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    centerLabel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _positionedBubble({
    required int index,
    required int count,
    required GiftType type,
    required double value,
    required double total,
    required double ringRadius,
    required double maxValue,
  }) {
    final hasValue = value > 0;
    final sizeRatio = maxValue > 0 ? value / maxValue : 0.0;
    final diameter = hasValue
        ? (_minPopulatedDiameter +
                  (_maxSurroundDiameter - _minPopulatedDiameter) * sizeRatio)
              .w
        : _emptyDiameter.w;

    final angle = (2 * math.pi * index / count) - (math.pi / 2);
    final dx = ringRadius.w * math.cos(angle);
    final dy = ringRadius.w * math.sin(angle);

    final color = typeColors[type] ?? AppColors.primary;
    final bubbleColor = hasValue ? color : color.withValues(alpha: 0.35);
    const textColor = Colors.white;

    return Transform.translate(
      offset: Offset(dx, dy),
      child: GestureDetector(
        onTap: hasValue ? () => onTypeTap(type) : null,
        child: _bubble(
          diameter: diameter,
          color: bubbleColor,
          child: hasValue
              ? Padding(
                  padding: EdgeInsets.all(4.w),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          type.label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          '%${((value / total) * 100).round()}',
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _bubble({
    required double diameter,
    required Color color,
    Widget? child,
  }) {
    return Container(
      width: diameter,
      height: diameter,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: child,
    );
  }
}
