import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../models/invoice.dart';
import '../models/business_profile.dart'; // Import for manual usage if needed
import '../utils/pdf_generator.dart';
import '../providers/business_profile_provider.dart';
import '../data/invoice_repository.dart';

// Generates a unique ID
String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();

final invoiceProvider =
    NotifierProvider<InvoiceNotifier, Invoice>(InvoiceNotifier.new);

class InvoiceNotifier extends Notifier<Invoice> {
  @override
  Invoice build() {
    final profile = ref.watch(businessProfileProvider);
    // Initialize with defaults from profile
    return Invoice(
      id: null, // New invoice
      style: 'Modern',
      supplier: Supplier(
        name: profile.companyName,
        address: profile.address,
        gstin: profile.gstin,
        pan: "", // Optional: Add to profile model if needed
        email: profile.email,
        phone: profile.phone,
      ),
      receiver: const Receiver(), // Empty
      invoiceDate: DateTime.now(),
      invoiceNo:
          "${profile.invoiceSeries}${profile.invoiceSequence.toString().padLeft(3, '0')}",
      items: [
        // One empty item to start
        const InvoiceItem(description: "", amount: 0, gstRate: 18),
      ],
    );
  }

  void setInvoice(Invoice invoice) {
    state = invoice;
  }

  void updateStyle(String val) {
    state = state.copyWith(style: val);
  }

  void updateInvoiceNo(String val) {
    state = state.copyWith(invoiceNo: val);
  }

  void updateSupplierName(String val) {
    state = state.copyWith(supplier: state.supplier.copyWith(name: val));
  }

  void updateSupplierGstin(String val) {
    state = state.copyWith(supplier: state.supplier.copyWith(gstin: val));
  }

  void updateReceiverName(String val) {
    state = state.copyWith(receiver: state.receiver.copyWith(name: val));
  }

  void updateReceiverGstin(String val) {
    state = state.copyWith(receiver: state.receiver.copyWith(gstin: val));
  }

  void updateItemDescription(int index, String val) {
    final newItems = List<InvoiceItem>.from(state.items);
    newItems[index] = newItems[index].copyWith(description: val);
    state = state.copyWith(items: newItems);
  }

  void updateItemAmount(int index, String val) {
    final newItems = List<InvoiceItem>.from(state.items);
    newItems[index] =
        newItems[index].copyWith(amount: double.tryParse(val) ?? 0.0);
    state = state.copyWith(items: newItems);
  }

  void updateItemGstRate(int index, String val) {
    final newItems = List<InvoiceItem>.from(state.items);
    newItems[index] =
        newItems[index].copyWith(gstRate: double.tryParse(val) ?? 0.0);
    state = state.copyWith(items: newItems);
  }

  void addItem() {
    state = state.copyWith(items: [
      ...state.items,
      const InvoiceItem(description: "", amount: 0, gstRate: 18)
    ]);
  }

  void removeItem(int index) {
    if (state.items.length > 1) {
      final newItems = List<InvoiceItem>.from(state.items);
      newItems.removeAt(index);
      state = state.copyWith(items: newItems);
    }
  }
}

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
    // If editing, set the invoice in the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.invoiceToEdit != null) {
        ref.read(invoiceProvider.notifier).setInvoice(widget.invoiceToEdit!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final invoice = ref.watch(invoiceProvider);
    final profile = ref.watch(businessProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.invoiceToEdit != null ? "Edit Invoice" : "New Invoice"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- Settings Section ---
            Card(
              elevation: 0,
              color: Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildDropdown(
                      "Invoice Style",
                      invoice.style,
                      ['Modern', 'Professional', 'Minimal'],
                      (val) =>
                          ref.read(invoiceProvider.notifier).updateStyle(val!),
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      "Invoice No",
                      invoice.invoiceNo,
                      (val) => ref
                          .read(invoiceProvider.notifier)
                          .updateInvoiceNo(val),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionHeader("Supplier Details (You)"),
            _buildTextField(
                "Name",
                invoice.supplier.name,
                (val) =>
                    ref.read(invoiceProvider.notifier).updateSupplierName(val)),
            _buildTextField(
                "GSTIN",
                invoice.supplier.gstin,
                (val) => ref
                    .read(invoiceProvider.notifier)
                    .updateSupplierGstin(val)),

            const SizedBox(height: 20),
            _buildSectionHeader("Receiver Details (Client)"),
            _buildTextField(
                "Name",
                invoice.receiver.name,
                (val) =>
                    ref.read(invoiceProvider.notifier).updateReceiverName(val)),
            _buildTextField(
                "GSTIN",
                invoice.receiver.gstin,
                (val) => ref
                    .read(invoiceProvider.notifier)
                    .updateReceiverGstin(val)),

            const SizedBox(height: 20),
            _buildSectionHeader("Items"),
            ...invoice.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(children: [
                    Row(
                      children: [
                        Expanded(
                            child: Text("Item ${index + 1}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold))),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => ref
                              .read(invoiceProvider.notifier)
                              .removeItem(index),
                        )
                      ],
                    ),
                    _buildTextField("Description", item.description, (val) {
                      ref
                          .read(invoiceProvider.notifier)
                          .updateItemDescription(index, val);
                    }),
                    Row(children: [
                      Expanded(
                          child: _buildTextField("Amount",
                              item.amount == 0 ? "" : item.amount.toString(),
                              (val) {
                        ref
                            .read(invoiceProvider.notifier)
                            .updateItemAmount(index, val);
                      })),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _buildTextField(
                              "GST %", item.gstRate.toString(), (val) {
                        ref
                            .read(invoiceProvider.notifier)
                            .updateItemGstRate(index, val);
                      })),
                    ])
                  ]),
                ),
              );
            }),
            TextButton.icon(
              onPressed: () => ref.read(invoiceProvider.notifier).addItem(),
              icon: const Icon(Icons.add),
              label: const Text("Add Item"),
            ),

            const SizedBox(height: 100), // Space for bottom bar
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: () => _showPreview(context, invoice, profile),
                icon: const Icon(Icons.visibility),
                label: const Text("Preview"),
              ),
              ElevatedButton.icon(
                onPressed: () => _saveInvoice(context, ref, invoice),
                icon: const Icon(Icons.save),
                label: const Text("Save"),
              ),
              OutlinedButton.icon(
                onPressed: () => _printInvoice(invoice, profile),
                icon: const Icon(Icons.print),
                label: const Text("Print"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveInvoice(
      BuildContext context, WidgetRef ref, Invoice invoice) async {
    // If it's a new invoice, ensure ID is generated
    Invoice toSave = invoice;
    if (toSave.id == null) {
      toSave = toSave.copyWith(id: _generateId());
    }

    await InvoiceRepository().saveInvoice(toSave);

    // Only increment sequence if it was a NEW invoice (id was null initially)
    if (invoice.id == null) {
      await ref
          .read(businessProfileProvider.notifier)
          .incrementInvoiceSequence();
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Invoice Saved!")));
      Navigator.pop(context);
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
            useActions: false, // We have our own buttons
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
          alignment: Alignment.centerLeft,
          child: Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
    );
  }

  Widget _buildTextField(
      String label, String initialValue, Function(String) onChanged) {
    // Using a key to enforce rebuild when initialValue changes (important for reset/edit)
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        key: Key(initialValue),
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items,
      Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      key: Key(value),
      initialValue: value,
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
