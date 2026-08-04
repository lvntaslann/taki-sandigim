import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../data/image_cropper.dart';

const double _frameMarginH = 32;
const double _frameMarginV = 90;

Future<String?> showCameraScanSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _CameraScanSheet(),
  );
}

class _CameraScanSheet extends StatefulWidget {
  const _CameraScanSheet();

  @override
  State<_CameraScanSheet> createState() => _CameraScanSheetState();
}

class _CameraScanSheetState extends State<_CameraScanSheet> {
  CameraController? _controller;
  Future<void>? _initFuture;
  String? _errorMessage;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _startCamera();
  }

  Future<void> _startCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _errorMessage = 'Kamera bulunamadı.');
        return;
      }
      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      _controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      _initFuture = _controller!.initialize();
      await _initFuture;
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Kamera açılamadı: $e');
    }
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _isCapturing) {
      return;
    }
    setState(() => _isCapturing = true);
    final containerWidth = MediaQuery.sizeOf(context).width;
    final containerHeight = MediaQuery.sizeOf(context).height * 0.75;
    final navigator = Navigator.of(context);
    try {
      final file = await controller.takePicture();

      final croppedPath = await ImageCropper.cropToFrame(
        sourcePath: file.path,
        containerWidth: containerWidth,
        containerHeight: containerHeight,
        leftFrac: _frameMarginH / containerWidth,
        rightFrac: _frameMarginH / containerWidth,
        topFrac: _frameMarginV / containerHeight,
        bottomFrac: _frameMarginV / containerHeight,
      );

      if (mounted) navigator.pop(croppedPath);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Fotoğraf çekilemedi: $e';
          _isCapturing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return SafeArea(
      top: false,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: screenHeight * 0.75,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.35),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(child: _cameraView()),
                _handleAndClose(),
                if (_controller?.value.isInitialized ?? false) _scanFrame(),
                Positioned(
                  bottom: 24,
                  child: _shutterButton(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cameraView() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    if (_controller == null || _initFuture == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        return ClipRect(
          child: OverflowBox(
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.previewSize?.height ?? 1,
                height: _controller!.value.previewSize?.width ?? 1,
                child: CameraPreview(_controller!),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _handleAndClose() {
    return Positioned(
      top: 10,
      left: 0,
      right: 0,
      child: Column(
        children: [
          _GlassChip(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8, top: 4),
              child: _GlassChip(
                shape: BoxShape.circle,
                padding: EdgeInsets.zero,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scanFrame() {
    return IgnorePointer(
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: _frameMarginH,
          vertical: _frameMarginV,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.55),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _shutterButton() {
    return GestureDetector(
      onTap: _capture,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.22),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.8),
                width: 3,
              ),
            ),
            child: _isCapturing
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
          ),
        ),
      ),
    );
  }
}

class _GlassChip extends StatelessWidget {
  const _GlassChip({
    required this.child,
    this.shape = BoxShape.rectangle,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  });

  final Widget child;
  final BoxShape shape;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: shape == BoxShape.circle
          ? BorderRadius.circular(999)
          : BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            shape: shape,
            borderRadius: shape == BoxShape.circle
                ? null
                : BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: child,
        ),
      ),
    );
  }
}
