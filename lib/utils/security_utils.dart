import 'package:path/path.dart' as p;

class SecurityUtils {
  static const _reservedNames = {
    'con',
    'prn',
    'aux',
    'nul',
    'com1',
    'com2',
    'com3',
    'com4',
    'com5',
    'com6',
    'com7',
    'com8',
    'com9',
    'lpt1',
    'lpt2',
    'lpt3',
    'lpt4',
    'lpt5',
    'lpt6',
    'lpt7',
    'lpt8',
    'lpt9',
  };

  /// Sanitizes a string to be used as a safe filename.
  /// Removes illegal characters, prevents path traversal ('..'),
  /// strips trailing dots/spaces, and guards Windows reserved device names.
  static String sanitizeFilename(final String input) {
    var cleaned = input
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '')
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .trim();

    // Strip trailing dots and spaces first to prevent Windows filesystem aliasing
    cleaned = cleaned.replaceAll(RegExp(r'[. ]+$'), '');

    // Prevent path traversal
    cleaned = cleaned.replaceAll('..', '_');

    // Clean any trailing dots/spaces
    cleaned = cleaned.replaceAll(RegExp(r'[. ]+$'), '');

    if (cleaned.isEmpty) {
      return 'unnamed_file';
    }

    // Check against Windows reserved device names
    final baseWithoutExt = p.basenameWithoutExtension(cleaned).toLowerCase();
    if (_reservedNames.contains(baseWithoutExt)) {
      cleaned = 'safe_$cleaned';
    }

    return cleaned;
  }

  /// Validates if a path is strictly inside the expected directory to prevent path traversal
  /// and prefix bypass (e.g. /app/data2 bypassing /app/data).
  static bool isValidPath(final String path, final String expectedDir) {
    if (path.isEmpty || expectedDir.isEmpty) return false;
    final canonicalPath = p.canonicalize(path);
    final canonicalExpected = p.canonicalize(expectedDir);
    return canonicalPath == canonicalExpected ||
        p.isWithin(canonicalExpected, canonicalPath);
  }

  /// Safely resolves a path, ensuring it doesn't escape the expected directory.
  static String? safeResolve(final String? path, final String expectedDir) {
    if (path == null || path.trim().isEmpty) return null;
    if (isValidPath(path, expectedDir)) {
      return p.canonicalize(path);
    }
    return null;
  }
}

