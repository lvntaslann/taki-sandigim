import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageCropper {
  ImageCropper._();

  static Future<String> cropToFrame({
    required String sourcePath,
    required double containerWidth,
    required double containerHeight,
    required double leftFrac,
    required double topFrac,
    required double rightFrac,
    required double bottomFrac,
  }) async {
    final bytes = await File(sourcePath).readAsBytes();
    var image = img.decodeImage(bytes);
    if (image == null) return sourcePath;

    image = img.bakeOrientation(image);

    final containerAspect = containerWidth / containerHeight;
    final imageAspect = image.width / image.height;

    double visibleX = 0, visibleY = 0;
    double visibleW = image.width.toDouble();
    double visibleH = image.height.toDouble();

    if (imageAspect > containerAspect) {
      visibleW = image.height * containerAspect;
      visibleX = (image.width - visibleW) / 2;
    } else if (imageAspect < containerAspect) {
      visibleH = image.width / containerAspect;
      visibleY = (image.height - visibleH) / 2;
    }

    final cropX = visibleX + visibleW * leftFrac;
    final cropY = visibleY + visibleH * topFrac;
    final cropWidth = visibleW * (1 - leftFrac - rightFrac);
    final cropHeight = visibleH * (1 - topFrac - bottomFrac);

    if (cropWidth <= 0 || cropHeight <= 0) return sourcePath;

    final x = cropX.round().clamp(0, image.width - 1);
    final y = cropY.round().clamp(0, image.height - 1);
    final w = cropWidth.round().clamp(1, image.width - x);
    final h = cropHeight.round().clamp(1, image.height - y);

    final cropped = img.copyCrop(image, x: x, y: y, width: w, height: h);

    final tempDir = await getTemporaryDirectory();
    final outputPath =
        '${tempDir.path}/notebook_crop_${DateTime.now().microsecondsSinceEpoch}.jpg';
    await File(outputPath).writeAsBytes(img.encodeJpg(cropped, quality: 92));
    return outputPath;
  }
}
