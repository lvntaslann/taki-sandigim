import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../dashboard/data/models/gift_enums.dart';
import '../../../tracker/data/tracker_repository.dart';
import '../../data/ocr_service.dart';
import '../bloc/scanner_bloc.dart';
import 'camera_scan_sheet.dart';
import 'line_confirmation_card.dart';

class ScannerBody extends StatelessWidget {
  const ScannerBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScannerBloc(ocrService: OcrService()),
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
  final PageController _pageController = PageController();
  final Set<int> _addedLines = {};
  int _activePage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openCamera(BuildContext context) async {
    final imagePath = await showCameraScanSheet(context);
    if (imagePath == null || !context.mounted) return;
    _startNewScan();
    context.read<ScannerBloc>().add(ScannerImageCaptured(imagePath));
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (file == null || !context.mounted) return;
    _startNewScan();
    context.read<ScannerBloc>().add(ScannerImageCaptured(file.path));
  }

  void _startNewScan() {
    setState(() {
      _addedLines.clear();
      _activePage = 0;
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
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Metin okunamadı: ${state.errorMessage}',
                      style: const TextStyle(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              if (state.status != ScannerStatus.success) {
                return const Center(
                  child: Text(
                    'Bir defter fotoğrafı tarayın ya da galeriden seçin.',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                );
              }
              return _reviewArea(state);
            },
          ),
        ),
      ],
    );
  }

  Widget _reviewArea(ScannerState state) {
    if (state.lines.isEmpty) {
      return const Center(
        child: Text(
          'Görüntüde okunabilir bir satır bulunamadı.',
          style: TextStyle(color: AppColors.textMuted),
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
                    ? _addedCard(line.personName)
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

  Widget _addedCard(String personName) {
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
              '$personName eklendi. Diğer kayıtları görmek için kaydırın.',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
