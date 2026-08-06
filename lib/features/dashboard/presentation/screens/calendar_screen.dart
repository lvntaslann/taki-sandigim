import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/box_names.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../data/models/wedding_model.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedMonth;
  DateTime? _selectedDay;

  static const _weekdayLabels = ['Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct', 'Pz'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
  }

  void _changeMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta);
      _selectedDay = null;
    });
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Takvim')),
      body: ValueListenableBuilder<Box<WeddingModel>>(
        valueListenable: Hive.box<WeddingModel>(BoxNames.weddings).listenable(),
        builder: (context, box, _) {
          final weddings = box.values.toList()
            ..sort((a, b) => a.date.compareTo(b.date));

          final weddingsByDay = <DateTime, List<WeddingModel>>{};
          for (final wedding in weddings) {
            final key = DateTime(wedding.date.year, wedding.date.month, wedding.date.day);
            weddingsByDay.putIfAbsent(key, () => []).add(wedding);
          }

          final visibleWeddings = _selectedDay == null
              ? weddings
              : weddingsByDay[DateTime(
                    _selectedDay!.year,
                    _selectedDay!.month,
                    _selectedDay!.day,
                  )] ??
                  const <WeddingModel>[];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CustomCard(
                child: Column(
                  children: [
                    _monthHeader(),
                    const SizedBox(height: 12),
                    _weekdayRow(),
                    const SizedBox(height: 4),
                    _monthGrid(weddingsByDay),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _selectedDay == null
                    ? 'Tüm Düğünler'
                    : DateFormatter.dayMonthYear(_selectedDay!),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              if (visibleWeddings.isEmpty)
                CustomCard(
                  child: Center(
                    child: Text(
                      _selectedDay == null
                          ? 'Henüz kayıtlı bir düğün yok.'
                          : 'Bu tarihte bir düğün yok.',
                      style: TextStyle(
                        color: AppColors.muted(context),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              else
                for (final wedding in visibleWeddings)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _weddingCard(wedding),
                  ),
            ],
          );
        },
      ),
    );
  }

  Widget _monthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => _changeMonth(-1),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Text(
          DateFormat('MMMM yyyy', 'tr_TR').format(_focusedMonth),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16.5),
        ),
        IconButton(
          onPressed: () => _changeMonth(1),
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }

  Widget _weekdayRow() {
    return Row(
      children: [
        for (final label in _weekdayLabels)
          Expanded(
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: AppColors.muted(context),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _monthGrid(Map<DateTime, List<WeddingModel>> weddingsByDay) {
    final firstOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month);
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    // DateTime.weekday: Monday=1..Sunday=7 — matches _weekdayLabels order.
    final leadingBlanks = firstOfMonth.weekday - 1;
    final totalCells = leadingBlanks + daysInMonth;
    final rows = (totalCells / 7).ceil();
    final today = DateTime.now();

    return Column(
      children: [
        for (var row = 0; row < rows; row++)
          Row(
            children: [
              for (var col = 0; col < 7; col++)
                Expanded(child: _dayCell(row, col, leadingBlanks, daysInMonth, weddingsByDay, today)),
            ],
          ),
      ],
    );
  }

  Widget _dayCell(
    int row,
    int col,
    int leadingBlanks,
    int daysInMonth,
    Map<DateTime, List<WeddingModel>> weddingsByDay,
    DateTime today,
  ) {
    final cellIndex = row * 7 + col;
    final day = cellIndex - leadingBlanks + 1;
    if (day < 1 || day > daysInMonth) {
      return const SizedBox(height: 44);
    }

    final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
    final hasWedding = weddingsByDay.containsKey(date);
    final isSelected = _selectedDay != null && _isSameDay(_selectedDay!, date);
    final isToday = _isSameDay(today, date);

    return GestureDetector(
      onTap: () => setState(() => _selectedDay = isSelected ? null : date),
      child: Container(
        height: 44,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : isToday
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                color: isSelected ? Colors.white : null,
                fontWeight: isToday || isSelected ? FontWeight.w800 : FontWeight.w500,
                fontSize: 13.5,
              ),
            ),
            if (hasWedding)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _weddingCard(WeddingModel wedding) {
    return CustomCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.favorite_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wedding.title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormatter.dayMonthYear(wedding.date),
                  style: TextStyle(
                    color: AppColors.muted(context),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (wedding.location != null && wedding.location!.isNotEmpty)
                  Text(
                    wedding.location!,
                    style: TextStyle(
                      color: AppColors.muted(context),
                      fontSize: 13,
                    ),
                  ),
                if (wedding.note != null && wedding.note!.isNotEmpty)
                  Text(
                    wedding.note!,
                    style: TextStyle(
                      color: AppColors.muted(context),
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
