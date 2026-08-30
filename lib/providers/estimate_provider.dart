import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invobharat/models/estimate.dart';
import 'package:invobharat/providers/invoice_repository_provider.dart';

final estimateListProvider =
    AsyncNotifierProvider<EstimateListNotifier, List<Estimate>>(
      EstimateListNotifier.new,
    );

class EstimateListNotifier extends AsyncNotifier<List<Estimate>> {
  @override
  Future<List<Estimate>> build() async {
    final repo = ref.watch(invoiceRepositoryProvider);
    return await repo.getAllEstimates();
  }

  Future<void> saveEstimate(final Estimate estimate) async {
    final repo = ref.read(invoiceRepositoryProvider);
    await repo.saveEstimate(estimate);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await repo.getAllEstimates();
    });
  }

  Future<void> deleteEstimate(final String id) async {
    final repo = ref.read(invoiceRepositoryProvider);
    await repo.deleteEstimate(id);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await repo.getAllEstimates();
    });
  }

  Future<void> markAsConverted(final String id) async {
    final repo = ref.read(invoiceRepositoryProvider);
    final estimates = await repo.getAllEstimates();
    final estimate = estimates.firstWhere(
      (final e) => e.id == id,
      orElse: () => throw Exception('Estimate not found'),
    );
    final updated = estimate.copyWith(status: 'Converted');
    await repo.saveEstimate(updated);

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await repo.getAllEstimates();
    });
  }
}
