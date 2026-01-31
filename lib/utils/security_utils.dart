import 'package:path/path.dart' as p;

class SecurityUtils {
  /// Sanitizes a string to be used as a safe filename.
  /// Removes illegal characters like / \ : * ? " < > |
  static String sanitizeFilename(String input) {
    return input.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_').trim();
  }

  /// Validates if a path is within the expected directory to prevent path traversal.
  static bool isValidPath(String path, String expectedDir) {
    final normalizedPath = p.normalize(p.absolute(path));
    final normalizedExpected = p.normalize(p.absolute(expectedDir));
    return normalizedPath.startsWith(normalizedExpected);
  }

  /// Safely resolves a path, ensuring it doesn't escape the expected directory.
  static String? safeResolve(String? path, String expectedDir) {
    if (path == null) return null;
    if (isValidPath(path, expectedDir)) return path;
    return null;
  }
}
