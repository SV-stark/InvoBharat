import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/item_template.dart';
import '../../providers/item_template_provider.dart';

class FluentItemTemplatesScreen extends ConsumerWidget {
  const FluentItemTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(itemTemplateListProvider);
    final theme = FluentTheme.of(context);

    return ScaffoldPage(
      header: PageHeader(
        title: const Text('Item Templates'),
        commandBar: CommandBar(
          primaryItems: [
            CommandBarButton(
              icon: const Icon(FluentIcons.add),
              label: const Text('New Template'),
              onPressed: () => _showEditDialog(context, ref, null),
            ),
          ],
        ),
      ),
      content: templates.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(FluentIcons.page_list,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text("No templates yet.",
                      style:
                          theme.typography.title?.copyWith(color: Colors.grey)),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => _showEditDialog(context, ref, null),
                    child: const Text("Create Template"),
                  )
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Card(
                    child: ListTile(
                      leading: const Icon(FluentIcons.page_list),
                      title: Text(template.description,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          "Price: ₹${template.amount} / ${template.unit} (GST: ${template.gstRate}%) • Default Qty: ${template.quantity}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(FluentIcons.edit),
                            onPressed: () =>
                                _showEditDialog(context, ref, template),
                          ),
                          IconButton(
                            icon: Icon(FluentIcons.delete, color: Colors.red),
                            onPressed: () => _deleteTemplate(context, ref,
                                template.id, template.description),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _deleteTemplate(
      BuildContext context, WidgetRef ref, String id, String name) async {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text("Delete Template"),
        content: Text("Are you sure you want to delete '$name'?"),
        actions: [
          Button(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            style: ButtonStyle(
                backgroundColor: ButtonState.all(Colors.red),
                foregroundColor: ButtonState.all(Colors.white)),
            child: const Text("Delete"),
            onPressed: () {
              ref.read(itemTemplateListProvider.notifier).deleteTemplate(id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, WidgetRef ref, ItemTemplate? template) {
    // Controllers
    final descCtrl = TextEditingController(text: template?.description ?? '');
    final amountCtrl =
        TextEditingController(text: template?.amount.toString() ?? '0');
    final unitCtrl = TextEditingController(text: template?.unit ?? 'Nos');
    final gstCtrl =
        TextEditingController(text: template?.gstRate.toString() ?? '18');
    final sacCtrl = TextEditingController(text: template?.sacCode ?? '');
    final qtyCtrl =
        TextEditingController(text: template?.quantity.toString() ?? '1');

    String codeType = template?.codeType ?? 'SAC';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => ContentDialog(
          title: Text(template == null ? "New Template" : "Edit Template"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoLabel(
                label: "Description *",
                child: TextFormBox(
                  controller: descCtrl,
                  placeholder: "Item Name / Description",
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: InfoLabel(
                      label: "Rate",
                      child: TextFormBox(
                        controller: amountCtrl,
                        placeholder: "0.00",
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InfoLabel(
                      label: "Unit",
                      child: TextFormBox(
                        controller: unitCtrl,
                        placeholder: "e.g. Nos",
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: InfoLabel(
                      label: "Default Quantity",
                      child: TextFormBox(
                        controller: qtyCtrl,
                        placeholder: "1",
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InfoLabel(
                      label: "GST %",
                      child: TextFormBox(
                        controller: gstCtrl,
                        placeholder: "18",
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: InfoLabel(
                      label: "HSN/SAC Type",
                      child: ComboBox<String>(
                        value: codeType,
                        items: ['SAC', 'HSN']
                            .map((e) => ComboBoxItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => codeType = val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InfoLabel(
                      label: "Code",
                      child: TextFormBox(
                        controller: sacCtrl,
                        placeholder: "Code Value",
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            Button(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            FilledButton(
              child: const Text("Save"),
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
                  quantity: double.tryParse(qtyCtrl.text) ?? 1,
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
            ),
          ],
        ),
      ),
    );
  }
}
