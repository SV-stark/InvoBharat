import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image_background_remover/image_background_remover.dart';

class ImageProcessingResult {
  final Uint8List bytes;
  final String? error;

  ImageProcessingResult({required this.bytes, this.error});
}

Future<ImageProcessingResult> processImageBackground(final Uint8List imageBytes) async {
  try {
    final processedImage = await BackgroundRemover.instance.removeBg(imageBytes);
    final byteData = await processedImage.toByteData(format: ui.ImageByteFormat.png);
    final processedBytes = byteData!.buffer.asUint8List();
    return ImageProcessingResult(bytes: processedBytes);
  } catch (e) {
    return ImageProcessingResult(bytes: Uint8List(0), error: e.toString());
  }
}

Future<ImageProcessingResult> processImageBackgroundInIsolate(final Uint8List imageBytes) async {
  return await Isolate.run(() => processImageBackground(imageBytes));
}
