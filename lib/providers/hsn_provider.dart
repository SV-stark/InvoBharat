import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invobharat/data/hsn_repository.dart';

final hsnRepositoryProvider = Provider<HsnRepository>((final ref) {
  return HsnRepository();
});
