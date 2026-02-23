import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:invobharat/models/client.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/providers/client_provider.dart';
import 'package:invobharat/mixins/estimate_form_mixin.dart';
import 'package:invobharat/widgets/adaptive_widgets.dart';

class EstimateForm extends ConsumerStatefulWidget {
  final String? estimateId;

  const EstimateForm({super.key, this.estimateId});

  @override
  ConsumerState<EstimateForm> createState() => _EstimateFormState();
}

class _EstimateFormState extends ConsumerState<EstimateForm>
    with EstimateFormMixin {
  @override
  void initState() {
    super.initState();
    initEstimateControllers();
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
    if (!formKey.currentState!.validate()) return;
    try {
      await saveEstimate(context);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  void _confirmConvertToInvoice() async {
    final confirm = await AppDialog.show(
      context,
      title: "Convert to Invoice?",
      content: "This will create a new Invoice from this Estimate. Continue?",
      confirmText: "Convert",
    );

    if (confirm == true) {
      try {
        final invoiceNo = await convertToInvoice();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Converted to Invoice $invoiceNo')));
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.estimateId == null ? "New Estimate" : "Edit Estimate"),
        actions: [
          if (existingEstimate != null)
            IconButton(
              icon: const Icon(Icons.print),
              onPressed: printEstimate,
              tooltip: "Print Estimate",
            ),
          if (existingEstimate != null &&
              existingEstimate!.status != 'Converted')
            TextButton.icon(
              onPressed: _confirmConvertToInvoice,
              icon: const Icon(Icons.transform, color: Colors.white),
              label: const Text("Convert to Invoice",
                  style: TextStyle(color: Colors.white)),
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveEstimateUI,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header info
              Row(
                children: [
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: AppTextInput(
                      label: "Estimate No",
                      controller: estimateNoCtrl,
                      validator: (final val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                    ),
                  )),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildDatePicker(
                          "Date", date, (final d) => setState(() => date = d))),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Client Details",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: () => _showClientSelector(
                        context, ref.read(clientListProvider)),
                    icon: const Icon(Icons.list),
                    label: const Text("Select Client"),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: AppTextInput(
                  label: "Client Name",
                  controller: receiverNameCtrl,
                  validator: (final val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: AppTextInput(
                  label: "Address",
                  controller: receiverAddressCtrl,
                  validator: (final val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
              ),
              Row(
                children: [
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: AppTextInput(
                      label: "GSTIN",
                      controller: receiverGstinCtrl,
                      validator: (final val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                    ),
                  )),
                  const SizedBox(width: 16),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: AppTextInput(
                      label: "State",
                      controller: receiverStateCtrl,
                      validator: (final val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                    ),
                  )),
                ],
              ),
              const SizedBox(height: 16),

              // Items
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Items",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                      onPressed: _addItem, icon: const Icon(Icons.add_circle)),
                ],
              ),
              ...items.asMap().entries.map((final entry) {
                final index = entry.key;
                final item = entry.value;
                return Card(
                  child: ListTile(
                    title: Text(item.description.isEmpty
                        ? "Item ${index + 1}"
                        : item.description),
                    subtitle: Text(
                        "${item.quantity} x ₹${item.amount} = ₹${item.netAmount}"),
                    trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeItem(index)),
                    onTap: () => _editItem(index),
                  ),
                );
              }),

              const SizedBox(height: 16),
              const Divider(),
              _buildSummary(),

              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: AppTextInput(
                  label: "Notes",
                  controller: notesCtrl,
                  maxLines: 2,
                  validator: (final val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: AppTextInput(
                  label: "Terms",
                  controller: termsCtrl,
                  maxLines: 2,
                  validator: (final val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(
      final String label, final DateTime date, final Function(DateTime) onSelect) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100));
        if (picked != null) onSelect(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
            labelText: label, border: const OutlineInputBorder()),
        child: Text(DateFormat('dd/MM/yyyy').format(date)),
      ),
    );
  }

  void _addItem() async {
    final newItem = await showDialog<InvoiceItem>(
      context: context,
      builder: (final ctx) => const _ItemEditDialog(),
    );
    if (newItem != null) {
      setState(() => items.add(newItem));
    }
  }

  void _editItem(final int index) async {
    final newItem = await showDialog<InvoiceItem>(
      context: context,
      builder: (final ctx) => _ItemEditDialog(item: items[index]),
    );
    if (newItem != null) {
      setState(() => items[index] = newItem);
    }
  }

  void _showClientSelector(final BuildContext context, final List<Client> clients) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (final context) {
          return Container(
            padding: const EdgeInsets.all(16),
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Select Client",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Expanded(
                  child: clients.isEmpty
                      ? const Center(child: Text("No clients found."))
                      : ListView.builder(
                          itemCount: clients.length,
                          itemBuilder: (final context, final index) {
                            final client = clients[index];
                            final initial = client.name.isNotEmpty
                                ? client.name[0].toUpperCase()
                                : "?";
                            return ListTile(
                              leading: CircleAvatar(child: Text(initial)),
                              title: Text(client.name),
                              subtitle: Text(client.gstin.isNotEmpty
                                  ? "GST: ${client.gstin}"
                                  : client.address),
                              onTap: () {
                                onClientSelected(client);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                )
              ],
            ),
          );
        });
  }

  void _removeItem(final int index) {
    setState(() => items.removeAt(index));
  }

  Widget _buildSummary() {
    final double total = items.fold(0, (final sum, final item) => sum + item.totalAmount);
    return Align(
        alignment: Alignment.centerRight,
        child: Text("Total: ₹${total.toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)));
  }
}

class _ItemEditDialog extends StatefulWidget {
  final InvoiceItem? item;
  const _ItemEditDialog({this.item});
  @override
  State<_ItemEditDialog> createState() => _ItemEditDialogState();
}

class _ItemEditDialogState extends State<_ItemEditDialog> {
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
  Widget build(final BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Item"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextInput(label: "Description", controller: _descCtrl),
          const SizedBox(height: 8),
          AppTextInput(
              label: "Quantity",
              controller: _qtyCtrl,
              keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          AppTextInput(
              label: "Rate",
              controller: _rateCtrl,
              keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          AppTextInput(
              label: "GST %",
              controller: _gstCtrl,
              keyboardType: TextInputType.number),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel")),
        ElevatedButton(
            onPressed: () {
              final item = InvoiceItem(
                description: _descCtrl.text,
                quantity: double.tryParse(_qtyCtrl.text) ?? 1,
                amount: double.tryParse(_rateCtrl.text) ?? 0,
                gstRate: double.tryParse(_gstCtrl.text) ?? 0,
              );
              Navigator.pop(context, item);
            },
            child: const Text("Save")),
      ],
    );
  }
}
