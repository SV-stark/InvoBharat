import 'dart:convert';
import 'package:flutter/services.dart';

class HsnEntry {
  final String code;
  final String description;
  final String type; // 'HSN' or 'SAC'

  const HsnEntry({
    required this.code,
    required this.description,
    required this.type,
  });

  factory HsnEntry.fromJson(final Map<String, dynamic> json) {
    return HsnEntry(
      code: json['code'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? 'HSN',
    );
  }

  @override
  String toString() => '$code - $description ($type)';
}

class HsnService {
  static final HsnService instance = HsnService._();
  HsnService._();

  List<HsnEntry>? _entries;
  bool _isLoading = false;

  Future<void> init() async {
    if (_entries != null || _isLoading) return;
    _isLoading = true;
    try {
      final jsonStr = await rootBundle.loadString('assets/data/hsn_sac.json');
      final List<dynamic> raw = jsonDecode(jsonStr) as List<dynamic>;
      _entries = raw
          .map((final e) => HsnEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _entries = [];
    } finally {
      _isLoading = false;
    }
  }

  Future<List<HsnEntry>> search(final String query, {final int limit = 15}) async {
    if (_entries == null) {
      await init();
    }
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    final isNumeric = RegExp(r'^\d+$').hasMatch(q);
    final results = <HsnEntry>[];

    for (final entry in _entries!) {
      if (isNumeric) {
        if (entry.code.startsWith(q)) {
          results.add(entry);
        }
      } else {
        if (entry.description.toLowerCase().contains(q) || entry.code.toLowerCase().contains(q)) {
          results.add(entry);
        }
      }
      if (results.length >= limit) break;
    }

    // Fallback if startsWith didn't find enough results for numeric query
    if (isNumeric && results.length < limit) {
      for (final entry in _entries!) {
        if (!entry.code.startsWith(q) && entry.code.contains(q)) {
          results.add(entry);
          if (results.length >= limit) break;
        }
      }
    }

    return results;
  }
}
