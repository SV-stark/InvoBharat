import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/item_template.dart';

final itemTemplateListProvider =
    NotifierProvider<ItemTemplateNotifier, List<ItemTemplate>>(
        ItemTemplateNotifier.new);

class ItemTemplateNotifier extends Notifier<List<ItemTemplate>> {
  @override
  List<ItemTemplate> build() {
    _loadTemplates();
    return [];
  }

  static const _key = 'item_templates';

  Future<void> _loadTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key);
    if (jsonList != null) {
      state =
          jsonList.map((e) => ItemTemplate.fromJson(jsonDecode(e))).toList();
    }
  }

  Future<void> addTemplate(ItemTemplate template) async {
    state = [...state, template];
    await _saveTemplates();
  }

  Future<void> updateTemplate(ItemTemplate template) async {
    state = [
      for (final t in state)
        if (t.id == template.id) template else t
    ];
    await _saveTemplates();
  }

  Future<void> deleteTemplate(String id) async {
    state = state.where((t) => t.id != id).toList();
    await _saveTemplates();
  }

  Future<void> _saveTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = state.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
  }
}
