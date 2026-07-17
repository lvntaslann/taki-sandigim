import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/ocr_service.dart';
import '../../domain/notebook_line.dart';
import '../../domain/notebook_parser.dart';

part 'scanner_event.dart';
part 'scanner_state.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  ScannerBloc({required OcrService ocrService})
      : _ocrService = ocrService,
        super(const ScannerState()) {
    on<ScannerImageCaptured>(_onImageCaptured);
    on<ScannerLineUpdated>(_onLineUpdated);
    on<ScannerReset>((event, emit) => emit(const ScannerState()));
  }

  final OcrService _ocrService;

  Future<void> _onImageCaptured(
    ScannerImageCaptured event,
    Emitter<ScannerState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ScannerStatus.processing,
        imagePath: event.imagePath,
      ),
    );
    try {
      final rawText = await _ocrService.recognizeText(event.imagePath);
      final lines = NotebookParser.parse(rawText);
      emit(state.copyWith(status: ScannerStatus.success, lines: lines));
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
