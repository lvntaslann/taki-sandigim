import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/ai_evaluation_service.dart';
import '../../data/ocr_service.dart';
import '../../domain/invitation_info.dart';
import '../../domain/notebook_line.dart';
import '../../domain/scan_source.dart';

part 'scanner_event.dart';
part 'scanner_state.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  ScannerBloc({
    required OcrService ocrService,
    required AiEvaluationService aiEvaluationService,
  })  : _ocrService = ocrService,
        _aiEvaluationService = aiEvaluationService,
        super(const ScannerState()) {
    on<ScannerImageCaptured>(_onImageCaptured);
    on<ScannerLineUpdated>(_onLineUpdated);
    on<ScannerReset>((event, emit) => emit(const ScannerState()));
  }

  final OcrService _ocrService;
  final AiEvaluationService _aiEvaluationService;

  Future<void> _onImageCaptured(
    ScannerImageCaptured event,
    Emitter<ScannerState> emit,
  ) async {
    emit(
      ScannerState(
        status: ScannerStatus.processing,
        imagePath: event.imagePath,
        source: event.source,
      ),
    );
    try {
      final rawText = await _ocrService.recognizeText(event.imagePath);
      if (event.source == ScanSource.notebook) {
        final lines = await _aiEvaluationService.evaluateNotebook(
          imagePath: event.imagePath,
          ocrText: rawText,
        );
        emit(
          ScannerState(
            status: ScannerStatus.success,
            imagePath: event.imagePath,
            source: event.source,
            lines: lines,
          ),
        );
      } else {
        final info = await _aiEvaluationService.evaluateInvitation(
          imagePath: event.imagePath,
          ocrText: rawText,
        );
        emit(
          ScannerState(
            status: ScannerStatus.success,
            imagePath: event.imagePath,
            source: event.source,
            invitationInfo: info,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ScannerStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onLineUpdated(
    ScannerLineUpdated event,
    Emitter<ScannerState> emit,
  ) {
    final updatedLines = List<NotebookLine>.from(state.lines);
    updatedLines[event.index] = event.line;
    emit(state.copyWith(lines: updatedLines));
  }
}
