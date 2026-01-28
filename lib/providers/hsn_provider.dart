import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/hsn_repository.dart';

final hsnRepositoryProvider = Provider<HsnRepository>((ref) {
  return HsnRepository();
});
