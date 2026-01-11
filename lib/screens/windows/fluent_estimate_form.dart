import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/invoice.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../mixins/estimate_form_mixin.dart';
import '../../widgets/adaptive_widgets.dart';

class FluentEstimateForm extends ConsumerStatefulWidget {
  final String? estimateId;

  const FluentEstimateForm({super.key, this.estimateId});

  @override
  ConsumerState<FluentEstimateForm> createState() => _FluentEstimateFormState();
}

class _FluentEstimateFormState extends ConsumerState<FluentEstimateForm>
    with EstimateFormMixin {
  // For state autocomplete logic (specific to Fluent UI widget)
  // We will sync this with the mixin's receiverStateCtrl

  @override
  void initState() {
    super.initState();
    initEstimateControllers();

    // Sync mixin controller changes to local state if needed
    // But AutoSuggestBox can just use the mixin's controller directly!
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isInit) {
      initializeEstimateData(estimateId: widget.estimateId);
      isInit = false;
    }
  }

  @override
  void dispose() {
    disposeEstimateControllers();
    super.dispose();
  }

  Future<void> _saveEstimateUI() async {
    try {
      await saveEstimate(context);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        displayInfoBar(context, builder: (context, close) {
          return InfoBar(
            title: const Text("Error"),
            content: Text(e.toString()),
            severity: InfoBarSeverity.error,
            onClose: close,
          );
        });
      }
    }
  }

  void _convertToInvoiceUI() async {
    try {
      final invoiceNo = await convertToInvoice();
      if (mounted) {
        displayInfoBar(context, builder: (context, close) {
          return InfoBar(
            title: const Text("Success"),
            content: Text('Converted to Invoice $invoiceNo'),
            severity: InfoBarSeverity.success,
            onClose: close,
          );
        });
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        displayInfoBar(context, builder: (context, close) {
          return InfoBar(
            title: const Text("Error"),
            content: Text(e.toString()),
            severity: InfoBarSeverity.error,
            onClose: close,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: PageHeader(
        title:
            Text(widget.estimateId == null ? "New Estimate" : "Edit Estimate"),
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: IconButton(
            icon: const Icon(FluentIcons.back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        commandBar: CommandBar(
          primaryItems: [
            if (existingEstimate != null &&
                existingEstimate!.status != 'Converted')
              CommandBarButton(
                icon: const Icon(FluentIcons.switch_widget),
                label: const Text("Convert to Invoice"),
                onPressed: _convertToInvoiceUI,
              ),
            CommandBarButton(
              icon: const Icon(FluentIcons.save),
              label: const Text("Save"),
              onPressed: _saveEstimateUI,
            ),
          ],
        ),
      ),
      children: [
        Expander(
          header: const Text("Details",
              style: TextStyle(fontWeight: FontWeight.bold)),
          initiallyExpanded: true,
          content: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: AppTextInput(
                      label: "Estimate No",
                      controller: estimateNoCtrl,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InfoLabel(
                      label: "Date",
                      child: DatePicker(
                        selected: date,
                        onChanged: (d) => setState(() => date = d),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              AppTextInput(
                label: "Client Name",
                controller: receiverNameCtrl,
              ),
              const SizedBox(height: 10),
              AppTextInput(
                label: "Address",
                controller: receiverAddressCtrl,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: AppTextInput(
                      label: "GSTIN",
                      controller: receiverGstinCtrl,
                      validator: Validators.gstin,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InfoLabel(
                      label: "State",
                      child: AutoSuggestBox<String>(
                        controller: receiverStateCtrl,
                        items: IndianStates.states
                            .map((e) =>
                                AutoSuggestBoxItem<String>(value: e, label: e))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expander(
          header: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Items",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Button(
                onPressed: _addItem,
                child: const Text("+ Add"),
              )
            ],
          ),
          initiallyExpanded: true,
          content: Column(
            children: [
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("No items added"),
                ),
              ...items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Card(
                    child: ListTile(
                      title: Text(item.description.isEmpty
                          ? "Item ${index + 1}"
                          : item.description),
                      subtitle: Text(
                          "${item.quantity} x ${item.amount} = ${item.netAmount}"),
                      trailing: IconButton(
                        icon: Icon(FluentIcons.delete, color: Colors.red),
                        onPressed: () => _removeItem(index),
                      ),
                      onPressed: () => _editItem(index),
                    ),
                  ),
                );
              }),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                        "Total: ₹${items.fold(0.0, (sum, i) => sum + i.totalAmount).toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expander(
          header: const Text("Additional Info",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            children: [
              AppTextInput(label: "Notes", controller: notesCtrl, maxLines: 3),
              const SizedBox(height: 10),
              AppTextInput(label: "Terms", controller: termsCtrl, maxLines: 3),
            ],
          ),
        )
      ],
    );
  }

  void _addItem() async {
    final newItem = await showDialog<InvoiceItem>(
      context: context,
      builder: (context) => const _FluentItemEditDialog(),
    );
    if (newItem != null) {
      setState(() => items.add(newItem));
    }
  }

  void _editItem(int index) async {
    final newItem = await showDialog<InvoiceItem>(
      context: context,
      builder: (context) => _FluentItemEditDialog(item: items[index]),
    );
    if (newItem != null) {
      setState(() => items[index] = newItem);
    }
  }

  void _removeItem(int index) {
    setState(() => items.removeAt(index));
  }
}

class _FluentItemEditDialog extends StatefulWidget {
  final InvoiceItem? item;
  const _FluentItemEditDialog({this.item});

  @override
  State<_FluentItemEditDialog> createState() => _FluentItemEditDialogState();
}

class _FluentItemEditDialogState extends State<_FluentItemEditDialog> {
  final _descCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _gstCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _descCtrl.text = widget.item!.description;
      _qtyCtrl.text = widget.item!.quantity.toString();
      _rateCtrl.text = widget.item!.amount.toString();
      _gstCtrl.text = widget.item!.gstRate.toString();
    } else {
      _qtyCtrl.text = '1';
      _gstCtrl.text = '18';
    }
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _qtyCtrl.dispose();
    _rateCtrl.dispose();
    _gstCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text("Edit Item"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextInput(label: "Description", controller: _descCtrl),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: AppTextInput(label: "Qty", controller: _qtyCtrl)),
              const SizedBox(width: 8),
              Expanded(
                  child: AppTextInput(label: "Rate", controller: _rateCtrl)),
              const SizedBox(width: 8),
              Expanded(
                  child: AppTextInput(label: "GST %", controller: _gstCtrl)),
            ],
          )
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
            final item = InvoiceItem(
              description: _descCtrl.text,
              quantity: double.tryParse(_qtyCtrl.text) ?? 1,
              amount: double.tryParse(_rateCtrl.text) ?? 0,
              gstRate: double.tryParse(_gstCtrl.text) ?? 0,
            );
            Navigator.pop(context, item);
          },
        ),
      ],
    );
  }
}
