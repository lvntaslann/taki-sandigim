part of 'scanner_bloc.dart';

enum ScannerStatus { initial, processing, success, failure }

class ScannerState extends Equatable {
  const ScannerState({
    this.status = ScannerStatus.initial,
    this.imagePath,
    this.source,
    this.lines = const [],
    this.invitationInfo,
    this.error,
  });

  final ScannerStatus status;
  final String? imagePath;
  final ScanSource? source;
  final List<NotebookLine> lines;
  final InvitationInfo? invitationInfo;
  final Object? error;

  ScannerState copyWith({
    ScannerStatus? status,
    String? imagePath,
    ScanSource? source,
    List<NotebookLine>? lines,
    InvitationInfo? invitationInfo,
    Object? error,
  }) {
    return ScannerState(
      status: status ?? this.status,
      imagePath: imagePath ?? this.imagePath,
      source: source ?? this.source,
      lines: lines ?? this.lines,
      invitationInfo: invitationInfo ?? this.invitationInfo,
      error: error,
    );
  }

  @override
  List<Object?> get props =>
      [status, imagePath, source, lines, invitationInfo, error];
}
