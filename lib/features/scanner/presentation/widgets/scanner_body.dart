import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/scan_usage_repository.dart';
import '../../../../core/services/purchase_service.dart';
import '../../../../core/widgets/banner_ad_widget.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/widgets/interstitial_ad_manager.dart';
import '../../../dashboard/data/models/gift_enums.dart';
import '../../../dashboard/data/models/wedding_model.dart';
import '../../../dashboard/data/repositories/wedding_repository.dart';
import '../../../tracker/data/tracker_repository.dart';
import '../../data/ai_evaluation_service.dart';
import '../../data/ocr_service.dart';
import '../../domain/scan_source.dart';
import '../bloc/scanner_bloc.dart';
import 'camera_scan_sheet.dart';
import 'image_preview_sheet.dart';
import 'invitation_confirmation_card.dart';
import 'line_confirmation_card.dart';
import 'scan_limit_sheet.dart';
import 'scan_source_sheet.dart';

class ScannerBody extends StatelessWidget {
  const ScannerBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScannerBloc(
        ocrService: OcrService(),
        aiEvaluationService: AiEvaluationService(),
      ),
      child: const _ScannerBodyView(),
    );
  }
}

class _ScannerBodyView extends StatefulWidget {
  const _ScannerBodyView();

  @override
  State<_ScannerBodyView> createState() => _ScannerBodyViewState();
}

class _ScannerBodyViewState extends State<_ScannerBodyView> {
  final TrackerRepository _trackerRepository = TrackerRepository();
  final WeddingRepository _weddingRepository = WeddingRepository();
  final Uuid _uuid = const Uuid();
  final PageController _pageController = PageController();
  final Set<int> _addedLines = {};
  final InterstitialAdManager _interstitialAdManager = InterstitialAdManager();
  final ScanUsageRepository _scanUsageRepository = ScanUsageRepository();
  int _activePage = 0;
  bool _invitationSaved = false;
  bool _adShownForThisScan = false;
  Timer? _quotaTicker;

  @override
  void initState() {
    super.initState();
    _interstitialAdManager.preload();
    _quotaTicker = Timer.periodic(const Duration(minutes: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _interstitialAdManager.dispose();
    _quotaTicker?.cancel();
    super.dispose();
  }

  bool _checkQuotaOrUpsell(BuildContext context) {
    if (PurchaseService.instance.isPremium.value) return true;
    if (_scanUsageRepository.canScan) return true;
    showScanLimitSheet(context, resetIn: _scanUsageRepository.timeUntilReset());
    return false;
  }

  void _maybeShowInterstitial() {
    if (_adShownForThisScan) return;
    _adShownForThisScan = true;
    _interstitialAdManager.showIfReady();
  }

  String _formatResetIn(Duration? duration, AppLocalizations l10n) {
    if (duration == null || duration <= Duration.zero) return l10n.resetSoon;
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours <= 0) return l10n.durationMinutes(minutes);
    return l10n.durationHoursMinutes(hours, minutes);
  }

  String _errorText(Object? error, AppLocalizations l10n) {
    if (error is! AiEvaluationException) return l10n.textReadFailed('$error');
    return switch (error.kind) {
      AiEvaluationError.rateLimited => l10n.aiRateLimited,
      AiEvaluationError.server => l10n.textReadFailed(error.detail ?? ''),
      AiEvaluationError.unexpectedResponse => l10n.textReadFailed(l10n.aiUnexpectedResponse),
      AiEvaluationError.noUserId => l10n.textReadFailed(l10n.aiNoUserId),
      AiEvaluationError.appCheckFailed => l10n.textReadFailed(l10n.aiAppCheckFailed),
      AiEvaluationError.requestFailed =>
        l10n.textReadFailed(l10n.aiRequestFailed(error.detail ?? '')),
    };
  }

  Widget _quotaBanner() {
    return ValueListenableBuilder<bool>(
      valueListenable: PurchaseService.instance.isPremium,
      builder: (context, isPremium, _) {
        if (isPremium) return const SizedBox.shrink();
        final l10n = AppLocalizations.of(context);
        final remaining = _scanUsageRepository.remainingScans();
        final hasQuota = remaining > 0;
        final text = hasQuota
            ? l10n.scansRemaining(remaining, ScanUsageRepository.freeScanLimit)
            : l10n.scansExhausted(
                _formatResetIn(_scanUsageRepository.timeUntilReset(), l10n),
              );
        final color = hasQuota ? AppColors.primary : AppColors.error;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  hasQuota ? Icons.document_scanner_outlined : Icons.lock_clock_outlined,
                  color: color,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12.5),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openCamera(BuildContext context) async {
    if (!_checkQuotaOrUpsell(context)) return;
    final source = await showScanSourceSheet(context);
    if (source == null || !context.mounted) return;
    final imagePath = await showCameraScanSheet(context);
    if (imagePath == null || !context.mounted) return;
    final confirmed = await showImagePreviewSheet(context, imagePath);
    if (!confirmed || !context.mounted) return;
    await _scanUsageRepository.recordScan();
    if (!context.mounted) return;
    _startNewScan();
    context.read<ScannerBloc>().add(ScannerImageCaptured(imagePath, source));
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    if (!_checkQuotaOrUpsell(context)) return;
    final source = await showScanSourceSheet(context);
    if (source == null || !context.mounted) return;
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (file == null || !context.mounted) return;
    final confirmed = await showImagePreviewSheet(context, file.path);
    if (!confirmed || !context.mounted) return;
    await _scanUsageRepository.recordScan();
    if (!context.mounted) return;
    _startNewScan();
    context.read<ScannerBloc>().add(ScannerImageCaptured(file.path, source));
  }

  void _startNewScan() {
    setState(() {
      _addedLines.clear();
      _activePage = 0;
      _invitationSaved = false;
      _adShownForThisScan = false;
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  Future<void> _addLine({
    required int index,
    required int totalLines,
    required String personName,
    required GiftType giftType,
    required double amount,
    required double estimatedValueTl,
    required GiftDirection direction,
    double? goldRateTl,
    RelationType relationType = RelationType.friend,
    String? currencyCode,
    double? currencyRateTl,
  }) async {
    await _trackerRepository.addGift(
      personName: personName,
      giftType: giftType,
      amount: amount,
      estimatedValueTl: estimatedValueTl,
      direction: direction,
      date: DateTime.now(),
      goldRateTl: goldRateTl,
      relationType: relationType,
      currencyCode: currencyCode,
      currencyRateTl: currencyRateTl,
    );
    if (!mounted) return;
    setState(() => _addedLines.add(index));
    _maybeShowInterstitial();
    if (index < totalLines - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _saveInvitation({
    required String title,
    required DateTime date,
    String? time,
    String? location,
  }) async {
    await _weddingRepository.save(
      WeddingModel(
        id: _uuid.v4(),
        title: title,
        date: date,
        location: location,
        note: time != null ? AppLocalizations.of(context).invitationTimeNote(time) : null,
      ),
    );
    if (!mounted) return;
    setState(() => _invitationSaved = true);
    _maybeShowInterstitial();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        _quotaBanner(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: l10n.scanWithCamera,
                  icon: Icons.camera_alt_outlined,
                  onPressed: () => _openCamera(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  label: l10n.pickFromGallery,
                  variant: CustomButtonVariant.outline,
                  icon: Icons.photo_library_outlined,
                  onPressed: () => _pickFromGallery(context),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<ScannerBloc, ScannerState>(
            builder: (context, state) {
              if (state.status == ScannerStatus.processing) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == ScannerStatus.failure) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _errorText(state.error, l10n),
                          style: const TextStyle(color: AppColors.error),
                          textAlign: TextAlign.center,
                        ),
                        if (state.imagePath != null && state.source != null) ...[
                          const SizedBox(height: 16),
                          CustomButton(
                            label: l10n.tryAgain,
                            icon: Icons.refresh,
                            onPressed: () => context.read<ScannerBloc>().add(
                                  ScannerImageCaptured(
                                    state.imagePath!,
                                    state.source!,
                                  ),
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }
              if (state.status != ScannerStatus.success) {
                return _idleState(context);
              }
              if (state.source == ScanSource.invitation) {
                return _invitationArea(state);
              }
              return _reviewArea(state);
            },
          ),
        ),
        const SizedBox(height: 8),
        const Center(child: BannerAdWidget()),
      ],
    );
  }

  Widget _idleState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.document_scanner_outlined,
              size: 40,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context).scanIdleTitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5),
            ),
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context).scanIdleHint,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.muted(context),
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _sourceHint(Icons.menu_book_outlined, AppLocalizations.of(context).sourceNotebookShort),
                const SizedBox(width: 10),
                _sourceHint(Icons.mail_outline, AppLocalizations.of(context).sourceInvitation),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sourceHint(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _invitationArea(ScannerState state) {
    final info = state.invitationInfo;
    if (info == null) {
      return Center(
        child: Text(
          AppLocalizations.of(context).invitationReadFailed,
          style: TextStyle(
            color: AppColors.muted(context),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    if (_invitationSaved) {
      return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _addedCard(AppLocalizations.of(context).itemSaved(info.title)),
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: InvitationConfirmationCard(
        info: info,
        onSave: ({required title, required date, time, location}) => _saveInvitation(
          title: title,
          date: date,
          time: time,
          location: location,
        ),
      ),
    );
  }

  Widget _reviewArea(ScannerState state) {
    if (state.lines.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context).noReadableLines,
          style: TextStyle(
            color: AppColors.muted(context),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).recordPosition(_activePage + 1, state.lines.length),
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                AppLocalizations.of(context).addedCount(_addedLines.length),
                style: const TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        _pageIndicator(state.lines.length),
        const SizedBox(height: 8),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: state.lines.length,
            onPageChanged: (i) => setState(() => _activePage = i),
            itemBuilder: (context, index) {
              final line = state.lines[index];
              final added = _addedLines.contains(index);
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: added
                    ? _addedCard(
                        AppLocalizations.of(context).lineAdded(line.personName),
                      )
                    : LineConfirmationCard(
                        key: ValueKey(index),
                        line: line,
                        onAdd: ({
                          required personName,
                          required giftType,
                          required amount,
                          required estimatedValueTl,
                          required direction,
                          goldRateTl,
                          required relationType,
                          currencyCode,
                          currencyRateTl,
                        }) =>
                            _addLine(
                          index: index,
                          totalLines: state.lines.length,
                          personName: personName,
                          giftType: giftType,
                          amount: amount,
                          estimatedValueTl: estimatedValueTl,
                          direction: direction,
                          goldRateTl: goldRateTl,
                          relationType: relationType,
                          currencyCode: currencyCode,
                          currencyRateTl: currencyRateTl,
                        ),
                        onSkip: () {
                          if (index < state.lines.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                            );
                          }
                        },
                      ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _pageIndicator(int count) {
    return SizedBox(
      height: 8,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: count,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final active = i == _activePage;
          final added = _addedLines.contains(i);
          return Container(
            width: active ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: added
                  ? AppColors.success
                  : active
                      ? AppColors.primary
                      : AppColors.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        },
      ),
    );
  }

  Widget _addedCard(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
