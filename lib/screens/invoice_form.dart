import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../models/invoice.dart';
import '../models/business_profile.dart'; // Import for manual usage if needed
import '../utils/pdf_generator.dart';
import '../providers/business_profile_provider.dart';
import '../data/invoice_repository.dart';

import '../providers/invoice_provider.dart';

// Generates a unique ID
String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();

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
    if (widget.invoiceToEdit != null) {
      ref.read(invoiceProvider.notifier).setInvoice(widget.invoiceToEdit!);
    }
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
              color: Theme.of(context).cardColor, // Adaptive color
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(12)),
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
                    Row(children: [
                      Expanded(
                        child: _buildTextField(
                          "Invoice No",
                          invoice.invoiceNo,
                          (val) => ref
                              .read(invoiceProvider.notifier)
                              .updateInvoiceNo(val),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                                context: context,
                                initialDate: invoice.invoiceDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100));
                            if (date != null) {
                              ref
                                  .read(invoiceProvider.notifier)
                                  .updateDate(date);
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: "Invoice Date",
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                            child: Text(DateFormat('dd-MMM-yyyy')
                                .format(invoice.invoiceDate)),
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    _buildTextField(
                        "Place of Supply",
                        invoice.placeOfSupply,
                        (val) => ref
                            .read(invoiceProvider.notifier)
                            .updatePlaceOfSupply(val)),
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
                      // SAC/HSN Toggle
                      SizedBox(
                        width: 80,
                        child: DropdownButtonFormField<String>(
                          key: ValueKey(item.codeType),
                          initialValue: item.codeType,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 8)),
                          items: const [
                            DropdownMenuItem(value: 'SAC', child: Text('SAC')),
                            DropdownMenuItem(value: 'HSN', child: Text('HSN')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              ref
                                  .read(invoiceProvider.notifier)
                                  .updateItemCodeType(index, val);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 5),
                      // SAC/HSN Code Input
                      Expanded(
                          child: _buildTextField("Code", item.sacCode, (val) {
                        ref
                            .read(invoiceProvider.notifier)
                            .updateItemSac(index, val);
                      })),
                      const SizedBox(width: 10),
                      // Year Dropdown
                      Expanded(
                          child: DropdownButtonFormField<String>(
                        key: ValueKey(item.year),
                        initialValue: item.year.isEmpty ? null : item.year,
                        hint: const Text("Year"),
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8)),
                        items: _getYearList()
                            .map((y) =>
                                DropdownMenuItem(value: y, child: Text(y)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            ref
                                .read(invoiceProvider.notifier)
                                .updateItemYear(index, val);
                          }
                        },
                      )),
                    ]),
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
                              "Discount",
                              item.discount == 0
                                  ? ""
                                  : item.discount.toString(), (val) {
                        ref
                            .read(invoiceProvider.notifier)
                            .updateItemDiscount(index, val);
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        // Removed Key(initialValue) to prevent focus loss
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

  List<String> _getYearList() {
    List<String> years = [];
    int startYear = 2017;
    int currentYear = DateTime.now().year;
    // Cover until next year to be safe
    for (int y = startYear; y <= currentYear + 1; y++) {
      years.add("$y-${(y + 1).toString().substring(2)}");
    }
    return years.reversed.toList();
  }
}
