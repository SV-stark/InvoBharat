import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../models/estimate.dart';
import '../providers/business_profile_provider.dart';

// --- Repository ---

class EstimateRepository {
  final String profileId;

  EstimateRepository({required this.profileId});

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/InvoBharat/profiles/$profileId/estimates';
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return path;
  }

  Future<void> saveEstimate(Estimate estimate) async {
    final path = await _localPath;
    final file = File('$path/${estimate.id}.json');
    await file.writeAsString(jsonEncode(estimate.toJson()));
  }

  Future<void> deleteEstimate(String id) async {
    final path = await _localPath;
    final file = File('$path/$id.json');
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<List<Estimate>> getAllEstimates() async {
    try {
      final path = await _localPath;
      final dir = Directory(path);
      if (!await dir.exists()) return [];

      final files = dir.listSync();
      List<Estimate> estimates = [];

      for (var file in files) {
        if (file is File && file.path.endsWith('.json')) {
          try {
            final content = await file.readAsString();
            final json = jsonDecode(content);
            estimates.add(Estimate.fromJson(json));
          } catch (e) {
            debugPrint("Error reading estimate file: ${file.path} - $e");
          }
        }
      }
      // Sort by date descending
      estimates.sort((a, b) => b.date.compareTo(a.date));
      return estimates;
    } catch (e) {
      debugPrint("Error fetching estimates: $e");
      return [];
    }
  }
}

// --- Providers ---

final estimateRepositoryProvider = Provider<EstimateRepository>((ref) {
  final activeId = ref.watch(activeProfileIdProvider);
  return EstimateRepository(profileId: activeId);
});

final estimateListProvider =
    AsyncNotifierProvider<EstimateListNotifier, List<Estimate>>(
        EstimateListNotifier.new);

class EstimateListNotifier extends AsyncNotifier<List<Estimate>> {
  @override
  Future<List<Estimate>> build() async {
    return _loadEstimates();
  }

  Future<List<Estimate>> _loadEstimates() async {
    final repo = ref.read(estimateRepositoryProvider);
    return await repo.getAllEstimates();
  }

  Future<void> saveEstimate(Estimate estimate) async {
    final repo = ref.read(estimateRepositoryProvider);
    await repo.saveEstimate(estimate);
    // Reload
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadEstimates());
  }

  Future<void> deleteEstimate(String id) async {
    final repo = ref.read(estimateRepositoryProvider);
    await repo.deleteEstimate(id);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadEstimates());
  }
}
