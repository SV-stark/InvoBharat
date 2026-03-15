import 'dart:isolate';
import 'dart:typed_data';

class ImageProcessingResult {
  final Uint8List bytes;
  final String? error;

  ImageProcessingResult({required this.bytes, this.error});
}

Future<ImageProcessingResult> processImageBackground(final Uint8List imageBytes) async {
  // Background removal removed to reduce dependency bloat.
  // Returning original bytes.
  return ImageProcessingResult(bytes: imageBytes);
}

Future<ImageProcessingResult> processImageBackgroundInIsolate(final Uint8List imageBytes) async {
  return await Isolate.run(() => processImageBackground(imageBytes));
}
