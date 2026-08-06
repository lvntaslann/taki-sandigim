part of 'scanner_bloc.dart';

enum ScannerStatus { initial, processing, success, failure }

class ScannerState extends Equatable {
  const ScannerState({
    this.status = ScannerStatus.initial,
    this.imagePath,
    this.source,
    this.lines = const [],
    this.invitationInfo,
    this.errorMessage,
  });

  final ScannerStatus status;
  final String? imagePath;
  final ScanSource? source;
  final List<NotebookLine> lines;
  final InvitationInfo? invitationInfo;
  final String? errorMessage;

  ScannerState copyWith({
    ScannerStatus? status,
    String? imagePath,
    ScanSource? source,
    List<NotebookLine>? lines,
    InvitationInfo? invitationInfo,
    String? errorMessage,
  }) {
    return ScannerState(
      status: status ?? this.status,
      imagePath: imagePath ?? this.imagePath,
      source: source ?? this.source,
      lines: lines ?? this.lines,
      invitationInfo: invitationInfo ?? this.invitationInfo,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, imagePath, source, lines, invitationInfo, errorMessage];
}
