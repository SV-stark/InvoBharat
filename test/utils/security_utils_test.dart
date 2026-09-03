import 'package:flutter_test/flutter_test.dart';
import 'package:invobharat/utils/security_utils.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

void main() {
  group('SecurityUtils', () {
    test('sanitizeFilename should remove illegal characters and guard traversal/reserved names', () {
      expect(SecurityUtils.sanitizeFilename('test/file.txt'), 'test_file.txt');
      expect(
        SecurityUtils.sanitizeFilename('a<b>c:d"e/f\\g|h?i*j'),
        'a_b_c_d_e_f_g_h_i_j',
      );
      expect(SecurityUtils.sanitizeFilename('  spaces  '), 'spaces');
      expect(SecurityUtils.sanitizeFilename('../../etc/passwd'), '____etc_passwd');
      expect(SecurityUtils.sanitizeFilename('report...   '), 'report');
      expect(SecurityUtils.sanitizeFilename('CON.txt'), 'safe_CON.txt');
      expect(SecurityUtils.sanitizeFilename('nul'), 'safe_nul');
      expect(SecurityUtils.sanitizeFilename('aux.json'), 'safe_aux.json');
    });

    test('isValidPath should detect path traversal and prefix bypass', () {
      final baseDir = p.join(Directory.systemTemp.path, 'invo_test');
      final expectedDir = p.join(baseDir, 'uploads');

      final safePath = p.join(expectedDir, 'file.txt');
      final unsafePath = p.join(expectedDir, '..', 'unsafe.txt');

      expect(SecurityUtils.isValidPath(safePath, expectedDir), true);
      expect(SecurityUtils.isValidPath(unsafePath, expectedDir), false);

      final deepUnsafe = p.join(expectedDir, '..', '..', 'etc', 'passwd');
      expect(SecurityUtils.isValidPath(deepUnsafe, expectedDir), false);

      // Prefix bypass test: e.g. /invo_test/uploads2 should NOT pass for /invo_test/uploads
      final prefixBypass = '${expectedDir}2';
      expect(SecurityUtils.isValidPath(prefixBypass, expectedDir), false);
    });

    test('safeResolve should resolve paths within expected dir', () {
      final baseDir = Directory.systemTemp.path;
      final safePath = p.join(baseDir, 'data.json');

      expect(SecurityUtils.safeResolve(safePath, baseDir), p.canonicalize(safePath));
      expect(SecurityUtils.safeResolve(null, baseDir), null);

      final outsidePath = '/outside/path';
      expect(SecurityUtils.safeResolve(outsidePath, baseDir), null);
    });
  });
}
