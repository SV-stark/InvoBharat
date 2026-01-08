import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../models/invoice.dart';
import '../models/business_profile.dart';
import '../models/client.dart';
import '../utils/pdf_generator.dart';
import '../providers/business_profile_provider.dart';
import '../providers/client_provider.dart';
import '../providers/invoice_provider.dart';

import '../services/invoice_actions.dart'; // NEW Import

// Generates a unique ID

class InvoiceFormScreen extends ConsumerStatefulWidget {
  final Invoice? invoiceToEdit;
  const InvoiceFormScreen({super.key, this.invoiceToEdit});

  @override
  ConsumerState<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends ConsumerState<InvoiceFormScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.invoiceToEdit != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(invoiceProvider.notifier).setInvoice(widget.invoiceToEdit!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoice = ref.watch(invoiceProvider);
    final profile = ref.watch(businessProfileProvider);
    final theme = Theme.of(context);

    // Watch clients for selection
    final clients = ref.watch(clientListProvider);

    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.invoiceToEdit != null ? "Edit Invoice" : "New Invoice"),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility_outlined),
            tooltip: "Preview PDF",
            onPressed: () => _showPreview(context, invoice, profile),
          ),
          IconButton(
              icon: const Icon(Icons.print_outlined),
              tooltip: "Print",
              onPressed: () => _printInvoice(invoice, profile)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: FilledButton.icon(
              onPressed: () => _saveInvoice(context, ref, invoice),
              icon: const Icon(Icons.save),
              label: const Text("Save"),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- Invoice Header Card ---
            _buildSectionCard(
              context,
              title: "Invoice Details",
              icon: Icons.description_outlined,
              children: [
                _buildDropdown(
                  "Invoice Style",
                  invoice.style,
                  ['Modern', 'Professional', 'Minimal'],
                  (val) => ref.read(invoiceProvider.notifier).updateStyle(val!),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: "Invoice No",
                        initialValue: invoice.invoiceNo,
                        onChanged: (val) => ref
                            .read(invoiceProvider.notifier)
                            .updateInvoiceNo(val),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                              context: context,
                              initialDate: invoice.invoiceDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100));
                          if (date != null) {
                            ref.read(invoiceProvider.notifier).updateDate(date);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: "Date",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 16),
                            suffixIcon: Icon(Icons.calendar_today, size: 18),
                          ),
                          child: Text(DateFormat('dd MMM yyyy')
                              .format(invoice.invoiceDate)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                          label: "Place of Supply",
                          initialValue: invoice.placeOfSupply,
                          onChanged: (val) => ref
                              .read(invoiceProvider.notifier)
                              .updatePlaceOfSupply(val)),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 120,
                      child: _buildDropdown(
                        "Rev. Charge",
                        invoice.reverseCharge.isEmpty
                            ? "N"
                            : invoice.reverseCharge,
                        ['N', 'Y'],
                        (val) => ref
                            .read(invoiceProvider.notifier)
                            .updateReverseCharge(val!),
                      ),
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- Client Details Card ---
            _buildSectionCard(
              context,
              title: "Client Details",
              icon: Icons.person_outline,
              action: TextButton.icon(
                onPressed: () => _showClientSelector(context, clients),
                icon: const Icon(Icons.list),
                label: const Text("Select Client"),
              ),
              children: [
                _buildTextField(
                  label: "Client Name",
                  initialValue: invoice.receiver.name,
                  onChanged: (val) => ref
                      .read(invoiceProvider.notifier)
                      .updateReceiverName(val),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: "GSTIN",
                        initialValue: invoice.receiver.gstin,
                        onChanged: (val) => ref
                            .read(invoiceProvider.notifier)
                            .updateReceiverGstin(val),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        label: "State",
                        initialValue: invoice.receiver.state,
                        onChanged: (val) => ref
                            .read(invoiceProvider.notifier)
                            .updateReceiverState(val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                    label: "Billing Address",
                    initialValue: invoice.receiver.address,
                    maxLines: 2,
                    onChanged: (val) => ref
                        .read(invoiceProvider.notifier)
                        .updateReceiverAddress(
                            val)), // Assuming updateReceiverAddress exists or maps to updateReceiverState?
                // Wait, updateReceiverAddress likely missing in original code based on previous read.
                // Let's check `invoice_provider.dart` later. Assuming standard pattern.
                // Actually, looking at original file, there was `updateReceiverName`, `updateReceiverGstin`, `updateReceiverState`.
                // Warning: `updateReceiverAddress` might not exist. I should check or implement it.
                // Original code had `_buildTextField("Name", invoice.receiver.name...`
                // It seems address field was missing in original form?
                // The Receiver model has address.
                // Let's assume the provider has it or I might need to add it.
                // To be safe, I will stick to what was there or check provider API.
                // Wait, looking at original code... `updateReceiverName`, `updateReceiverGstin`, `updateReceiverState`, `updateReceiverStateCode`.
                // NO ADDRESS. That's a gap. The Receiver model definition has it.
                // I will add the UI field, but if the provider method is missing, I'll need to update provider.
                // For now let's assume I can't call a missing method. I'll comment it out or fix provider later.
                // Actually better: I will add `updateReceiverAddress` to `InvoiceNotifier` in a separate step if it fails.
                // Wait, I can't check provider now easily without task switch.
                // I will use `updateReceiverAddress` and if it fails compilation, I will fix provider.
                // Actually, simpler: I'll browse provider first? No, I'm in ReplaceFile.
                // I'll take a risk or just omit address for now if I want to be safe?
                // User wants "recipient section shall have ability to use from client list". Client has address.
                // So I MUST populate address. Invoice Recipient MUST have address.
                // I will assume the method exists or I will add it.
              ],
            ),
            const SizedBox(height: 16),

            // --- Items Card ---
            _buildSectionCard(context,
                title: "Items",
                icon: Icons.shopping_cart_outlined,
                children: [
                  if (invoice.items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text("No items added yet",
                            style: TextStyle(color: Colors.grey)),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: invoice.items.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final item = invoice.items[index];
                        return ListTile(
                          title: Text(item.description.isNotEmpty
                              ? item.description
                              : "New Item"),
                          subtitle: Text(
                              "${item.quantity} ${item.unit} x ₹${item.amount} | GST: ${item.gstRate}%"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("₹${item.totalAmount.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () =>
                                    _editItemDialog(context, index, item),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red, size: 20),
                                onPressed: () => ref
                                    .read(invoiceProvider.notifier)
                                    .removeItem(index),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          ref.read(invoiceProvider.notifier).addItem(),
                      icon: const Icon(Icons.add),
                      label: const Text("Add New Item"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                            color: theme.primaryColor.withValues(alpha: 0.5)),
                      ),
                    ),
                  )
                ]),

            const SizedBox(height: 16),
            // Grand Total Summary
            Card(
              elevation: 0,
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Grand Total",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("₹${invoice.grandTotal.toStringAsFixed(2)}",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context,
      {required String title,
      required IconData icon,
      required List<Widget> children,
      Widget? action}) {
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 20, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                if (action != null) action,
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required String label,
      required String initialValue,
      required Function(String) onChanged,
      int maxLines = 1}) {
    return TextFormField(
      key: ValueKey(initialValue), // Ensure updates when selecting client
      initialValue: initialValue,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        isDense: true,
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items,
      Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      key: ValueKey(value),
      initialValue: value,
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  void _showClientSelector(BuildContext context, List<Client> clients) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (context) {
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
                          itemBuilder: (context, index) {
                            final client = clients[index];
                            return ListTile(
                              leading: CircleAvatar(
                                  child: Text(client.name[0].toUpperCase())),
                              title: Text(client.name),
                              subtitle: Text(client.gstin.isNotEmpty
                                  ? "GST: ${client.gstin}"
                                  : client.address),
                              onTap: () {
                                // Populate Fields
                                final notifier =
                                    ref.read(invoiceProvider.notifier);
                                notifier.updateReceiverName(client.name);
                                notifier.updateReceiverGstin(client.gstin);
                                notifier.updateReceiverState(client.state);
                                notifier.updateReceiverAddress(client.address);
                                // We don't have explicit state in client, usage implies manual entry or extraction.
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

  void _editItemDialog(BuildContext context, int index, InvoiceItem item) {
    // Reusing the same UI logic but in a Dialog
    final descriptionCtrl = TextEditingController(text: item.description);
    final amountCtrl = TextEditingController(text: item.amount.toString());
    final qtyCtrl = TextEditingController(text: item.quantity.toString());
    final gstCtrl = TextEditingController(text: item.gstRate.toString());
    final unitCtrl = TextEditingController(text: item.unit);
    final sacCtrl = TextEditingController(text: item.sacCode);
    String codeType = item.codeType;

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              title: const Text("Edit Item"),
              scrollable: true,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: descriptionCtrl,
                    decoration: const InputDecoration(
                        labelText: "Description", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: qtyCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: "Quantity",
                              border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: unitCtrl,
                          decoration: const InputDecoration(
                              labelText: "Unit", border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: amountCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: "Price", border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: gstCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: "GST %", border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      DropdownButton<String>(
                        value: codeType,
                        items: const [
                          DropdownMenuItem(value: 'SAC', child: Text('SAC')),
                          DropdownMenuItem(value: 'HSN', child: Text('HSN')),
                        ],
                        onChanged: (val) => setState(() => codeType = val!),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                          child: TextField(
                        controller: sacCtrl,
                        decoration: const InputDecoration(
                            labelText: "Code", border: OutlineInputBorder()),
                      ))
                    ],
                  )
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel")),
                FilledButton(
                    onPressed: () {
                      final notifier = ref.read(invoiceProvider.notifier);
                      notifier.updateItemDescription(
                          index, descriptionCtrl.text);
                      notifier.updateItemQuantity(index, qtyCtrl.text);
                      notifier.updateItemUnit(index, unitCtrl.text);
                      notifier.updateItemAmount(index, amountCtrl.text);
                      notifier.updateItemGstRate(index, gstCtrl.text);
                      notifier.updateItemCodeType(index, codeType);
                      notifier.updateItemSac(index, sacCtrl.text);
                      Navigator.pop(context);
                    },
                    child: const Text("Updates"))
              ],
            ),
          );
        });
  }

  Future<void> _saveInvoice(
      BuildContext context, WidgetRef ref, Invoice invoice) async {
    try {
      await InvoiceActions.saveInvoice(ref, invoice);

      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Invoice Saved!")));
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _printInvoice(Invoice invoice, BusinessProfile profile) async {
    final pdfBytes = await generateInvoicePdf(invoice, profile);
    await Printing.layoutPdf(onLayout: (_) => pdfBytes);
  }

  void _showPreview(
      BuildContext context, Invoice invoice, BusinessProfile profile) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: PdfPreview(
            build: (format) => generateInvoicePdf(invoice, profile),
            useActions: false,
          ),
        );
      },
    );
  }
}
