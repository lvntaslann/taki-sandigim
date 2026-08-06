import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
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
  int _activePage = 0;
  bool _invitationSaved = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openCamera(BuildContext context) async {
    final source = await showScanSourceSheet(context);
    if (source == null || !context.mounted) return;
    final imagePath = await showCameraScanSheet(context);
    if (imagePath == null || !context.mounted) return;
    final confirmed = await showImagePreviewSheet(context, imagePath);
    if (!confirmed || !context.mounted) return;
    _startNewScan();
    context.read<ScannerBloc>().add(ScannerImageCaptured(imagePath, source));
  }

  Future<void> _pickFromGallery(BuildContext context) async {
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
    _startNewScan();
    context.read<ScannerBloc>().add(ScannerImageCaptured(file.path, source));
  }

  void _startNewScan() {
    setState(() {
      _addedLines.clear();
      _activePage = 0;
      _invitationSaved = false;
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
        note: time != null ? 'Saat: $time' : null,
      ),
    );
    if (!mounted) return;
    setState(() => _invitationSaved = true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: 'Kamerayla Tara',
                  icon: Icons.camera_alt_outlined,
                  onPressed: () => _openCamera(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  label: 'Galeriden Seç',
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
                final isRateLimited =
                    state.errorMessage?.toLowerCase().contains('rate limit') ??
                        false;
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isRateLimited
                              ? 'Şu an yoğunluktan dolayı AI yanıt veremedi. Birkaç saniye sonra tekrar dene.'
                              : 'Metin okunamadı: ${state.errorMessage}',
                          style: const TextStyle(color: AppColors.error),
                          textAlign: TextAlign.center,
                        ),
                        if (state.imagePath != null && state.source != null) ...[
                          const SizedBox(height: 16),
                          CustomButton(
                            label: 'Tekrar Dene',
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
              'Bir takı defteri sayfası ya da davetiye tarat',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5),
            ),
            const SizedBox(height: 6),
            Text(
              'Kamerayla çek ya da galeriden seç, AI otomatik okusun.',
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
                _sourceHint(Icons.menu_book_outlined, 'Defter'),
                const SizedBox(width: 10),
                _sourceHint(Icons.mail_outline, 'Davetiye'),
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
          'Davetiyeden bilgi okunamadı.',
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
          child: _addedCard('${info.title} kaydedildi.'),
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
          'Görüntüde okunabilir bir satır bulunamadı.',
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
                'Kayıt ${_activePage + 1} / ${state.lines.length}',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                '${_addedLines.length} eklendi',
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
                        '${line.personName} eklendi. Diğer kayıtları görmek için kaydırın.',
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
