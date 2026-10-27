import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_converter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../dashboard/data/models/gift_enums.dart';
import '../../../dashboard/data/models/gift_model.dart';
import '../../data/tracker_repository.dart';
import '../../domain/balance_status.dart';
import '../../domain/person_ledger.dart';
import '../bloc/tracker_bloc.dart';

class LedgerScreen extends StatelessWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          TrackerBloc(trackerRepository: TrackerRepository())
            ..add(const TrackerStarted()),
      child: const _LedgerView(),
    );
  }
}

class _LedgerView extends StatefulWidget {
  const _LedgerView();

  @override
  State<_LedgerView> createState() => _LedgerViewState();
}

class _LedgerViewState extends State<_LedgerView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).ledgerTitle)),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
            child: TextField(
              controller: _searchController,
              onChanged: (v) =>
                  setState(() => _searchQuery = v.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).ledgerSearchHint,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<TrackerBloc, TrackerState>(
              builder: (context, state) {
                if (state.status == TrackerStatus.loading ||
                    state.status == TrackerStatus.initial) {
                  return const Center(child: CircularProgressIndicator());
                }

                final ledgers = state.personLedgers
                    .where(
                      (l) => l.personName.toLowerCase().contains(_searchQuery),
                    )
                    .toList();

                if (ledgers.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? AppLocalizations.of(context).noRecordsYetDot
                          : AppLocalizations.of(context).noResults,
                      style: TextStyle(
                        color: AppColors.muted(context),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<TrackerBloc>().add(const TrackerStarted());
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: ledgers.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _PersonLedgerCard(ledger: ledgers[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonLedgerCard extends StatefulWidget {
  const _PersonLedgerCard({required this.ledger});

  final PersonLedger ledger;

  @override
  State<_PersonLedgerCard> createState() => _PersonLedgerCardState();
}

class _PersonLedgerCardState extends State<_PersonLedgerCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final ledger = widget.ledger;
    final status = ledger.status;
    final lastEntry = ledger.entries.first;
    final l10n = AppLocalizations.of(context);

    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.18),
                    child: Text(
                      ledger.personName.isNotEmpty
                          ? ledger.personName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ledger.personName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${lastEntry.giftType.localizedLabel(l10n)} (${lastEntry.date.year})',
                          style: TextStyle(
                            color: AppColors.muted(context),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.muted(context),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) _details(context, ledger, status),
        ],
      ),
    );
  }

  Widget _details(
    BuildContext context,
    PersonLedger ledger,
    BalanceStatus status,
  ) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0x11000000))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          if (ledger.lastGiven != null)
            _summaryRow(l10n.youGave, ledger.lastGiven!, AppColors.accent),
          if (ledger.lastReceived != null) ...[
            const SizedBox(height: 8),
            _summaryRow(
              l10n.youReceived,
              ledger.lastReceived!,
              AppColors.success,
            ),
          ],
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.totalBalanceTitle,
                style: TextStyle(
                  color: AppColors.muted(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                CurrencyConverter.formatTl(status.balanceTl.abs()),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: status.isBalanced
                      ? AppColors.muted(context)
                      : status.weOwe
                      ? AppColors.error
                      : AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.allRecordsCount(ledger.entries.length),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...ledger.entries.map((e) => _entryRow(context, e)),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, GiftModel entry, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text('${entry.giftType.localizedLabel(AppLocalizations.of(context))} (${entry.date.year})'),
      ],
    );
  }

  Widget _entryRow(BuildContext context, GiftModel entry) {
    final directionColor = entry.direction == GiftDirection.received
        ? AppColors.success
        : AppColors.accent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(width: 4, height: 32, color: directionColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.giftType.localizedLabel(AppLocalizations.of(context))} · ${CurrencyConverter.formatTl(entry.estimatedValueTl)}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                Text(
                  DateFormatter.shortDate(entry.date),
                  style: TextStyle(
                    color: AppColors.muted(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () => _confirmDelete(context, entry),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, GiftModel entry) async {
    final bloc = context.read<TrackerBloc>();
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteRecordTitle),
        content: Text(
          l10n.deleteRecordConfirm(
            entry.personName,
            entry.giftType.localizedLabel(l10n),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.delete, style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      bloc.add(TrackerEntryDeleted(entry.id));
    }
  }
}
