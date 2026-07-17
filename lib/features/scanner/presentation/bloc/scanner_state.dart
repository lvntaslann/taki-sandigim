part of 'scanner_bloc.dart';

enum ScannerStatus { initial, processing, success, failure }

class ScannerState extends Equatable {
  const ScannerState({
    this.status = ScannerStatus.initial,
    this.imagePath,
    this.lines = const [],
    this.errorMessage,
  });

  final ScannerStatus status;
  final String? imagePath;
  final List<NotebookLine> lines;
  final String? errorMessage;

  ScannerState copyWith({
    ScannerStatus? status,
    String? imagePath,
    List<NotebookLine>? lines,
    String? errorMessage,
  }) {
    return ScannerState(
      status: status ?? this.status,
      imagePath: imagePath ?? this.imagePath,
      lines: lines ?? this.lines,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, imagePath, lines, errorMessage];
}
