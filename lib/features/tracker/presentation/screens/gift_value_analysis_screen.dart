import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/currency_rate_service.dart';
import '../../../../core/network/gold_rate_service.dart';
import '../../../../core/utils/currency_converter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/basis_badge.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../dashboard/data/models/gift_enums.dart';
import '../../../dashboard/data/models/gift_model.dart';
import '../../domain/gift_value_projection.dart';

class GiftValueAnalysisScreen extends StatefulWidget {
  const GiftValueAnalysisScreen({super.key, required this.gift});

  final GiftModel gift;

  @override
  State<GiftValueAnalysisScreen> createState() =>
      _GiftValueAnalysisScreenState();
}

enum _RateBasis { gold, currency, none }

class _GiftValueAnalysisScreenState extends State<GiftValueAnalysisScreen> {
  final _goldRateService = GoldRateService();
  final _currencyRateService = CurrencyRateService();
  GiftValueProjection? _projection;
  bool _isLoading = true;
  double? _currentRateTl;
  ValueProjectionRange _range = ValueProjectionRange.year;

  _RateBasis get _rateBasis {
    if (widget.gift.currencyCode != null) return _RateBasis.currency;
    if (widget.gift.goldRateTl != null) return _RateBasis.gold;
    return _RateBasis.none;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final gift = widget.gift;
    double currentValueTl;

    switch (_rateBasis) {
      case _RateBasis.currency:
        final rate = await _currencyRateService.getRateTl(gift.currencyCode!);
        _currentRateTl = rate;
        currentValueTl = gift.amount * rate;
      case _RateBasis.gold:
        final rate = await _goldRateService.getGoldRateTl();
        _currentRateTl = rate;
        currentValueTl = CurrencyConverter.giftValueTl(
          giftType: gift.giftType,
          amount: gift.amount,
          goldRateTl: rate,
        );
      case _RateBasis.none:
        currentValueTl = gift.estimatedValueTl;
    }

    if (!mounted) return;
    setState(() {
      _projection = GiftValueProjection.build(
        gift: gift,
        currentValueTl: currentValueTl,
      );
      _isLoading = false;
    });
  }

  void _showInfo() {
    final basisText = switch (_rateBasis) {
      _RateBasis.currency =>
        'O günkü değer, kaydı eklediğin andaki ${widget.gift.currencyCode} '
            'kuruna göredir. Bugünkü değer ise güncel döviz kuruyla yeniden '
            'hesaplanır.',
      _RateBasis.gold =>
        'O günkü değer, kaydı eklediğin andaki altın kuruna göredir. '
            'Bugünkü değer ise güncel gram altın kuruyla yeniden hesaplanır.',
      _RateBasis.none =>
        'Bu kayıt bir kur bilgisiyle eklenmediği için değeri zamanla '
            'değişmez; o günkü ve bugünkü değer aynıdır.',
    };

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bu grafik nasıl hesaplanıyor?'),
        content: Text(
          '$basisText Aradaki noktalar gerçek piyasa verisi değildir; '
          'sadece iki değer arasındaki değişimi görselleştirmek için '
          'doğrusal olarak tahmin edilmiştir. Üstteki dönem seçici sadece '
          'aynı doğrunun hangi zaman penceresini gösterdiğini değiştirir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Anladım'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gift = widget.gift;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Değer Analizi'),
        actions: [
          IconButton(
            onPressed: _showInfo,
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: _isLoading || _projection == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                CustomCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _rateBasis == _RateBasis.currency
                              ? Icons.currency_exchange
                              : Icons.redeem_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${_formatAmount(gift.amount)} ${gift.giftType.label}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                BasisBadge(label: _basisLabel),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Takıldığı Tarih: ${DateFormatter.shortDate(gift.date)}',
                              style: TextStyle(
                                color: AppColors.muted(context),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (_currentRateTl != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                _rateBasis == _RateBasis.currency
                                    ? 'Güncel kur: 1 ${gift.currencyCode} = '
                                          '${CurrencyConverter.formatTl(_currentRateTl!)}'
                                    : 'Güncel gram altın kuru: '
                                          '${CurrencyConverter.formatTl(_currentRateTl!)}',
                                style: TextStyle(
                                  color: AppColors.muted(context),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _valueComparisonRow(),
                const SizedBox(height: 16),
                _changeCard(),
                const SizedBox(height: 16),
                _chartCard(),
                const SizedBox(height: 16),
                _statsRow(),
              ],
            ),
    );
  }

  String get _basisLabel => switch (_rateBasis) {
    _RateBasis.currency => widget.gift.currencyCode ?? 'Döviz',
    _RateBasis.gold => 'Altın',
    _RateBasis.none => 'Sabit',
  };

  String _formatAmount(double amount) =>
      amount % 1 == 0 ? amount.toStringAsFixed(0) : amount.toStringAsFixed(2);

  Widget _valueComparisonRow() {
    final projection = _projection!;
    return CustomCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'O günkü değeri',
                  style: TextStyle(
                    color: AppColors.muted(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyConverter.formatTl(projection.entryValueTl),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 19,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: AppColors.muted(context).withValues(alpha: 0.2),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bugünkü değeri',
                    style: TextStyle(
                      color: AppColors.muted(context),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyConverter.formatTl(projection.currentValueTl),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 19,
                      color: projection.isIncrease
                          ? AppColors.success
                          : AppColors.error,
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

  Widget _changeCard() {
    final projection = _projection!;
    final color = projection.isIncrease ? AppColors.success : AppColors.error;
    final sign = projection.isIncrease ? '+' : '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Değer Artışı',
                style: TextStyle(
                  color: AppColors.muted(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$sign${projection.changePercent.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 21,
                ),
              ),
            ],
          ),
          Icon(
            projection.isIncrease ? Icons.trending_up : Icons.trending_down,
            color: color,
            size: 30,
          ),
        ],
      ),
    );
  }

  Widget _chartCard() {
    final projection = _projection!;
    final series = projection.seriesFor(_range);
    final minY = series.map((p) => p.valueTl).reduce((a, b) => a < b ? a : b);
    final maxY = series.map((p) => p.valueTl).reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.15 + 1;
    final chartMinY = minY - padding;
    final chartMaxY = maxY + padding;
    final yInterval = (chartMaxY - chartMinY) / 4;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Değer Değişimi Grafiği',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Uç noktalar gerçek, aradaki çizgi tahminidir.',
            style: TextStyle(
              color: AppColors.muted(context),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          _rangeSelector(),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: chartMinY,
                maxY: chartMaxY,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      interval: yInterval,
                      getTitlesWidget: (value, meta) {
                        if (value <= chartMinY + yInterval * 0.4) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          value.toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.muted(context),
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 26,
                      getTitlesWidget: (value, meta) {
                        final index = value.round();
                        if (value != value.roundToDouble() ||
                            (index != 0 && index != series.length - 1)) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            DateFormat(
                              _range == ValueProjectionRange.day ||
                                      _range == ValueProjectionRange.week
                                  ? 'dd.MM'
                                  : (_range == ValueProjectionRange.month
                                        ? 'MM.yyyy'
                                        : 'yyyy'),
                            ).format(series[index].date),
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.muted(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (var i = 0; i < series.length; i++)
                        FlSpot(i.toDouble(), series[i].valueTl),
                    ],
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withValues(alpha: 0.15),
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

  Widget _rangeSelector() {
    return SegmentedButton<ValueProjectionRange>(
      segments: ValueProjectionRange.values
          .map(
            (r) => ButtonSegment(
              value: r,
              label: Text(
                r.label,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          )
          .toList(),
      selected: {_range},
      showSelectedIcon: false,
      onSelectionChanged: (s) => setState(() => _range = s.first),
      style: const ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _statsRow() {
    final series = _projection!.seriesFor(_range);
    final lowest = series.reduce((a, b) => a.valueTl <= b.valueTl ? a : b);
    final highest = series.reduce((a, b) => a.valueTl >= b.valueTl ? a : b);
    final average =
        series.fold<double>(0, (sum, p) => sum + p.valueTl) / series.length;

    return Row(
      children: [
        Expanded(
          child: _statBox('En Düşük', lowest.valueTl, lowest.date),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statBox('En Yüksek', highest.valueTl, highest.date),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statBox('Ortalama', average, null),
        ),
      ],
    );
  }

  Widget _statBox(String label, double value, DateTime? date) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.muted(context),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyConverter.formatTl(value),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          if (date != null) ...[
            const SizedBox(height: 2),
            Text(
              DateFormat('dd.MM.yyyy').format(date),
              style: TextStyle(
                color: AppColors.muted(context),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
