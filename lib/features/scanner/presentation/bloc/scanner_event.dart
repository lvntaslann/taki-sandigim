part of 'scanner_bloc.dart';

abstract class ScannerEvent extends Equatable {
  const ScannerEvent();

  @override
  List<Object?> get props => [];
}

class ScannerImageCaptured extends ScannerEvent {
  const ScannerImageCaptured(this.imagePath);

  final String imagePath;

  @override
  List<Object?> get props => [imagePath];
}

class ScannerLineUpdated extends ScannerEvent {
  const ScannerLineUpdated(this.index, this.line);

  final int index;
  final NotebookLine line;

  @override
  List<Object?> get props => [index, line];
}

class ScannerReset extends ScannerEvent {
  const ScannerReset();
}
