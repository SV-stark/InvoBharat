import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invobharat/providers/business_profile_provider.dart';
import 'package:invobharat/providers/database_provider.dart';

class InvoiceSeries {
  final String prefix;
  final int sequence;

  InvoiceSeries({required this.prefix, required this.sequence});

  Map<String, dynamic> toJson() => {'prefix': prefix, 'sequence': sequence};

  factory InvoiceSeries.fromJson(final Map<String, dynamic> json) {
    return InvoiceSeries(
      prefix: json['prefix'] as String? ?? '',
      sequence: json['sequence'] as int? ?? 1,
    );
  }
}

final invoiceSeriesProvider =
    NotifierProvider<InvoiceSeriesNotifier, List<InvoiceSeries>>(
      InvoiceSeriesNotifier.new,
    );

class InvoiceSeriesNotifier extends Notifier<List<InvoiceSeries>> {
  @override
  List<InvoiceSeries> build() {
    final profile = ref.watch(businessProfileProvider);
    _loadSeries(profile.id, profile.invoiceSeries, profile.invoiceSequence);
    return [];
  }

  Future<void> _loadSeries(
    final String profileId,
    final String defaultSeries,
    final int defaultSequence,
  ) async {
    final settingsService = ref.read(appSettingsServiceProvider);
    final jsonStr = await settingsService.getSetting('series_list_$profileId');

    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        final list = decoded
            .map((final e) => InvoiceSeries.fromJson(e))
            .toList();

        // Ensure default series exists and is synchronized with profile sequence
        final hasDefault = list.any((final e) => e.prefix == defaultSeries);
        if (!hasDefault) {
          list.insert(
            0,
            InvoiceSeries(prefix: defaultSeries, sequence: defaultSequence),
          );
        } else {
          for (int i = 0; i < list.length; i++) {
            if (list[i].prefix == defaultSeries &&
                list[i].sequence < defaultSequence) {
              list[i] = InvoiceSeries(
                prefix: defaultSeries,
                sequence: defaultSequence,
              );
            }
          }
        }
        state = list;
        await _saveSeries(profileId);
        return;
      } catch (_) {}
    }

    // Default seed
    state = [InvoiceSeries(prefix: defaultSeries, sequence: defaultSequence)];
    await _saveSeries(profileId);
  }

  Future<void> _saveSeries(final String profileId) async {
    final settingsService = ref.read(appSettingsServiceProvider);
    final jsonStr = jsonEncode(state.map((final e) => e.toJson()).toList());
    await settingsService.setSetting('series_list_$profileId', jsonStr);
  }

  Future<void> addSeries(final String prefix, final int sequence) async {
    if (state.any((final e) => e.prefix == prefix)) return;

    final profile = ref.read(businessProfileProvider);
    state = [...state, InvoiceSeries(prefix: prefix, sequence: sequence)];
    await _saveSeries(profile.id);
  }

  Future<void> removeSeries(final String prefix) async {
    // Keep at least one
    if (state.length <= 1) return;

    final profile = ref.read(businessProfileProvider);
    state = state.where((final e) => e.prefix != prefix).toList();
    await _saveSeries(profile.id);
  }

  Future<void> updateSequence(final String prefix, final int sequence) async {
    final profile = ref.read(businessProfileProvider);
    state = state.map((final e) {
      if (e.prefix == prefix) {
        return InvoiceSeries(prefix: prefix, sequence: sequence);
      }
      return e;
    }).toList();
    await _saveSeries(profile.id);

    // Keep BusinessProfile in sync if updating the primary series
    if (prefix == profile.invoiceSeries &&
        profile.invoiceSequence != sequence) {
      await ref
          .read(businessProfileListProvider.notifier)
          .updateProfile(profile.copyWith(invoiceSequence: sequence));
    }
  }

  Future<void> incrementSequence(final String prefix) async {
    final profile = ref.read(businessProfileProvider);
    int newSeq = 1;
    state = state.map((final e) {
      if (e.prefix == prefix) {
        newSeq = e.sequence + 1;
        return InvoiceSeries(prefix: prefix, sequence: newSeq);
      }
      return e;
    }).toList();
    await _saveSeries(profile.id);

    // Keep BusinessProfile in sync if incrementing the primary series
    if (prefix == profile.invoiceSeries) {
      await ref
          .read(businessProfileListProvider.notifier)
          .updateProfile(profile.copyWith(invoiceSequence: newSeq));
    }
  }
}
