import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/item_template.dart';
import '../providers/item_template_provider.dart';

class ItemTemplatesScreen extends ConsumerWidget {
  const ItemTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(itemTemplateListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Item Templates"),
      ),
      body: templates.isEmpty
          ? const Center(
              child: Text("No templates yet.\nTap + to add one.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];
                return Card(
                  child: ListTile(
                    title: Text(template.description),
                    subtitle: Text(
                        "₹${template.amount} / ${template.unit} (GST: ${template.gstRate}%)"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () =>
                              _showEditDialog(context, ref, template),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => ref
                              .read(itemTemplateListProvider.notifier)
                              .deleteTemplate(template.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(context, ref, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, WidgetRef ref, ItemTemplate? template) {
    final descCtrl = TextEditingController(text: template?.description ?? '');
    final amountCtrl =
        TextEditingController(text: template?.amount.toString() ?? '0');
    final unitCtrl = TextEditingController(text: template?.unit ?? 'Nos');
    final gstCtrl =
        TextEditingController(text: template?.gstRate.toString() ?? '18');
    final sacCtrl = TextEditingController(text: template?.sacCode ?? '');
    String codeType = template?.codeType ?? 'SAC';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(template == null ? "New Template" : "Edit Template"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: descCtrl,
                    decoration:
                        const InputDecoration(labelText: "Description")),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                        child: TextField(
                            controller: amountCtrl,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: "Rate"))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: TextField(
                            controller: unitCtrl,
                            decoration:
                                const InputDecoration(labelText: "Unit"))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                        child: TextField(
                            controller: gstCtrl,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: "GST %"))),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: codeType,
                      items: const [
                        DropdownMenuItem(value: 'SAC', child: Text('SAC')),
                        DropdownMenuItem(value: 'HSN', child: Text('HSN')),
                      ],
                      onChanged: (val) => setState(() => codeType = val!),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                    controller: sacCtrl,
                    decoration:
                        const InputDecoration(labelText: "HSN/SAC Code")),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            FilledButton(
                onPressed: () {
                  if (descCtrl.text.isEmpty) return;
                  final newTemplate = ItemTemplate(
                    id: template?.id ?? const Uuid().v4(),
                    description: descCtrl.text,
                    amount: double.tryParse(amountCtrl.text) ?? 0,
                    unit: unitCtrl.text,
                    gstRate: double.tryParse(gstCtrl.text) ?? 18,
                    codeType: codeType,
                    sacCode: sacCtrl.text,
                  );

                  if (template == null) {
                    ref
                        .read(itemTemplateListProvider.notifier)
                        .addTemplate(newTemplate);
                  } else {
                    ref
                        .read(itemTemplateListProvider.notifier)
                        .updateTemplate(newTemplate);
                  }
                  Navigator.pop(context);
                },
                child: const Text("Save")),
          ],
        ),
      ),
    );
  }
}
