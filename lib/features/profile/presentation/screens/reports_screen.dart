import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/user_settings_repository.dart';
import '../../../../core/services/purchase_service.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../dashboard/data/models/gift_model.dart';
import '../../../dashboard/data/repositories/gift_repository.dart';
import '../../data/gift_export_service.dart';
import '../../data/gift_import_service.dart';
import '../../domain/import_source.dart';
import '../widgets/import_source_sheet.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _giftRepository = GiftRepository();
  final _settingsRepository = UserSettingsRepository();
  final _exportService = GiftExportService();
  late final _importService = GiftImportService(_giftRepository);

  // Which row is currently busy: 'pdf', 'excel', 'share', 'import', or null when idle.
  String? _processingKey;

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  List<GiftModel>? _giftsOrWarn() {
    final gifts = _giftRepository.getAll();
    if (gifts.isEmpty) {
      _showMessage(AppLocalizations.of(context).noGiftRecordsYet);
      return null;
    }
    return gifts;
  }

  String _buildFileName() {
    final rawName = _settingsRepository.getName()?.trim();
    final safeName = (rawName == null || rawName.isEmpty)
        ? 'TakiListem'
        : rawName.replaceAll(RegExp(r'\s+'), '_').replaceAll(
              RegExp(r'[^\w]'),
              '',
            );
    final dateSuffix = DateFormat('ddMMyyyy').format(DateTime.now());
    return '${safeName}_$dateSuffix';
  }

  Future<void> _exportPdf() => _export(key: 'pdf', asPdf: true);

  Future<void> _exportExcel() => _export(key: 'excel', asPdf: false);

  Future<void> _export({required String key, required bool asPdf}) async {
    final gifts = _giftsOrWarn();
    if (gifts == null || _processingKey != null) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _processingKey = key);
    try {
      await _exportService.exportAndShare(
        gifts,
        asPdf: asPdf,
        fileName: _buildFileName(),
        l10n: l10n,
      );
    } catch (e) {
      _showMessage(l10n.reportFailed('$e'));
    } finally {
      if (mounted) setState(() => _processingKey = null);
    }
  }

  Future<void> _import() async {
    if (_processingKey != null) return;
    final source = await showImportSourceSheet(context);
    if (source == null || !mounted) return;
    final l10n = AppLocalizations.of(context);

    if (source == ImportSource.pdf) {
      _showMessage(l10n.pdfImportComingSoon);
      return;
    }

    setState(() => _processingKey = 'import');
    try {
      final result = await _importService.pickAndImport(l10n);
      if (result == null) return; // user cancelled the picker
      _showMessage(
        l10n.importResult(result.addedCount, result.addedWeddingCount),
      );
    } on GiftImportFormatException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      _showMessage(l10n.importFailed('$e'));
    } finally {
      if (mounted) setState(() => _processingKey = null);
    }
  }

  Future<void> _share() async {
    final gifts = _giftsOrWarn();
    if (gifts == null || _processingKey != null) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _processingKey = 'share');
    try {
      await _exportService.shareSummary(gifts, l10n);
    } catch (e) {
      _showMessage(l10n.shareFailed('$e'));
    } finally {
      if (mounted) setState(() => _processingKey = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CustomCard(
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.giftListReport,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.giftListReportHint,
                        style: TextStyle(
                          color: AppColors.muted(context),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<bool>(
            valueListenable: PurchaseService.instance.isPremium,
            builder: (context, isPremium, _) => CustomCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _reportRow(
                    rowKey: 'pdf',
                    icon: Icons.picture_as_pdf_outlined,
                    title: l10n.pdfReport,
                    subtitle: l10n.pdfReportHint,
                    onTap: _exportPdf,
                    locked: !isPremium,
                  ),
                  const Divider(height: 1),
                  _reportRow(
                    rowKey: 'excel',
                    icon: Icons.table_chart_outlined,
                    title: 'Excel (CSV)',
                    subtitle: l10n.excelReportHint,
                    onTap: _exportExcel,
                    locked: !isPremium,
                  ),
                  const Divider(height: 1),
                  _reportRow(
                    rowKey: 'share',
                    icon: Icons.ios_share,
                    title: l10n.share,
                    subtitle: l10n.shareHint,
                    onTap: _share,
                  ),
                  const Divider(height: 1),
                  _reportRow(
                    rowKey: 'import',
                    icon: Icons.upload_file_outlined,
                    title: l10n.importData,
                    subtitle: l10n.importDataHint,
                    onTap: _import,
                    locked: !isPremium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportRow({
    required String rowKey,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool locked = false,
  }) {
    final isBusy = _processingKey == rowKey;
    final isDisabled = _processingKey != null && !isBusy;
    final effectiveOnTap = locked ? () => context.push(AppRoutes.premium) : onTap;

    return InkWell(
      onTap: _processingKey == null ? effectiveOnTap : null,
      child: Opacity(
        opacity: (isDisabled || locked) ? 0.5 : 1,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      locked ? AppLocalizations.of(context).premiumRequired : subtitle,
                      style: TextStyle(
                        color: AppColors.muted(context),
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (isBusy)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (locked)
                Icon(Icons.lock_outline, color: AppColors.muted(context))
              else
                Icon(Icons.chevron_right, color: AppColors.muted(context)),
            ],
          ),
        ),
      ),
    );
  }
}
