import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:invobharat/data/hsn_repository.dart';

final hsnRepositoryProvider = Provider<HsnRepository>((final ref) {
  return HsnRepository();
});
