import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/user_settings_repository.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../dashboard/data/models/gift_model.dart';
import '../../../dashboard/data/repositories/gift_repository.dart';
import '../../data/gift_export_service.dart';
import '../../data/gift_import_service.dart';

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
      _showMessage('Henüz bir takı kaydı yok.');
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
    setState(() => _processingKey = key);
    try {
      await _exportService.exportAndShare(
        gifts,
        asPdf: asPdf,
        fileName: _buildFileName(),
      );
    } catch (e) {
      _showMessage('Rapor oluşturulamadı: $e');
    } finally {
      if (mounted) setState(() => _processingKey = null);
    }
  }

  Future<void> _import() async {
    if (_processingKey != null) return;
    setState(() => _processingKey = 'import');
    try {
      final result = await _importService.pickAndImport();
      if (result == null) return; // user cancelled the picker
      _showMessage('${result.addedCount} kayıt eklendi.');
    } on GiftImportFormatException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      _showMessage('Veriler içe aktarılamadı: $e');
    } finally {
      if (mounted) setState(() => _processingKey = null);
    }
  }

  Future<void> _share() async {
    final gifts = _giftsOrWarn();
    if (gifts == null || _processingKey != null) return;
    setState(() => _processingKey = 'share');
    try {
      await _exportService.shareSummary(gifts);
    } catch (e) {
      _showMessage('Paylaşılamadı: $e');
    } finally {
      if (mounted) setState(() => _processingKey = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Raporlar')),
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
                      const Text(
                        'Takı Listesi Raporu',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Verilerinizi PDF veya Excel formatında dışa aktarın.',
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
          CustomCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _reportRow(
                  rowKey: 'pdf',
                  icon: Icons.picture_as_pdf_outlined,
                  title: 'PDF Raporu (A4)',
                  subtitle: 'Detaylı takı listesi',
                  onTap: _exportPdf,
                ),
                const Divider(height: 1),
                _reportRow(
                  rowKey: 'excel',
                  icon: Icons.table_chart_outlined,
                  title: 'Excel (CSV)',
                  subtitle: 'Düzenlenebilir tablo',
                  onTap: _exportExcel,
                ),
                const Divider(height: 1),
                _reportRow(
                  rowKey: 'share',
                  icon: Icons.ios_share,
                  title: 'Paylaş',
                  subtitle: 'Aile bireyleriyle bilgi paylaşın',
                  onTap: _share,
                ),
                const Divider(height: 1),
                _reportRow(
                  rowKey: 'import',
                  icon: Icons.upload_file_outlined,
                  title: 'Verileri Yükle',
                  subtitle: 'Daha önce dışa aktarılan Excel dosyasını içe aktarın',
                  onTap: _import,
                ),
              ],
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
  }) {
    final isBusy = _processingKey == rowKey;
    final isDisabled = _processingKey != null && !isBusy;

    return InkWell(
      onTap: _processingKey == null ? onTap : null,
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1,
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
                      subtitle,
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
              else
                Icon(Icons.chevron_right, color: AppColors.muted(context)),
            ],
          ),
        ),
      ),
    );
  }
}
