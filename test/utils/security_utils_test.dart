import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/utils/security_utils.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

void main() {
  group('SecurityUtils', () {
    test('sanitizeFilename should remove illegal characters', () {
      expect(SecurityUtils.sanitizeFilename('test/file.txt'), 'test_file.txt');
      expect(
        SecurityUtils.sanitizeFilename('a<b>c:d"e/f\\g|h?i*j'),
        'a_b_c_d_e_f_g_h_i_j',
      );
      expect(SecurityUtils.sanitizeFilename('  spaces  '), 'spaces');
    });

    test('isValidPath should detect path traversal', () {
      final baseDir = p.join(Directory.systemTemp.path, 'invo_test');
      final expectedDir = p.join(baseDir, 'uploads');

      final safePath = p.join(expectedDir, 'file.txt');
      final unsafePath = p.join(expectedDir, '..', 'unsafe.txt');

      expect(SecurityUtils.isValidPath(safePath, expectedDir), true);
      expect(SecurityUtils.isValidPath(unsafePath, expectedDir), false);

      final deepUnsafe = p.join(expectedDir, '..', '..', 'etc', 'passwd');
      expect(SecurityUtils.isValidPath(deepUnsafe, expectedDir), false);
    });

    test('safeResolve should resolve paths within expected dir', () {
      final baseDir = Directory.systemTemp.path;
      final safePath = p.join(baseDir, 'data.json');

      expect(SecurityUtils.safeResolve(safePath, baseDir), safePath);
      expect(SecurityUtils.safeResolve(null, baseDir), null);

      final outsidePath = '/outside/path';
      expect(SecurityUtils.safeResolve(outsidePath, baseDir), null);
    });
  });
}
