import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:invobharat/models/item_template.dart';
import 'package:invobharat/providers/database_provider.dart';

final itemTemplateListProvider =
    NotifierProvider<ItemTemplateNotifier, List<ItemTemplate>>(
      ItemTemplateNotifier.new,
    );

class ItemTemplateNotifier extends Notifier<List<ItemTemplate>> {
  @override
  List<ItemTemplate> build() {
    _loadTemplates();
    return [];
  }

  static const _key = 'item_templates';

  Future<void> _loadTemplates() async {
    try {
      final settingsService = ref.read(appSettingsServiceProvider);
      final jsonStr = await settingsService.getSetting(_key);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        state = decoded
            .map((final e) => ItemTemplate.fromJson(e as Map<String, dynamic>))
            .toList();
        return;
      }

      // Fallback migration from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList(_key);
      if (jsonList != null && jsonList.isNotEmpty) {
        final list = jsonList
            .map((final e) => ItemTemplate.fromJson(jsonDecode(e)))
            .toList();
        state = list;
        await _saveTemplates();
        await prefs.remove(_key);
      }
    } catch (_) {}
  }

  Future<void> addTemplate(final ItemTemplate template) async {
    state = [...state, template];
    await _saveTemplates();
  }

  Future<void> updateTemplate(final ItemTemplate template) async {
    state = [
      for (final t in state)
        if (t.id == template.id) template else t,
    ];
    await _saveTemplates();
  }

  Future<void> deleteTemplate(final String id) async {
    state = state.where((final t) => t.id != id).toList();
    await _saveTemplates();
  }

  Future<void> _saveTemplates() async {
    try {
      final settingsService = ref.read(appSettingsServiceProvider);
      final jsonStr = jsonEncode(state.map((final e) => e.toJson()).toList());
      await settingsService.setSetting(_key, jsonStr);
    } catch (_) {}
  }
}
