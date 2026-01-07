import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:printing/printing.dart';
import '../../models/invoice.dart';
import '../../models/business_profile.dart';
import '../../providers/business_profile_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../data/invoice_repository.dart';
import '../../utils/pdf_generator.dart';

// Generates a unique ID
String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();

class FluentInvoiceForm extends ConsumerStatefulWidget {
  final Invoice? invoiceToEdit;
  const FluentInvoiceForm({super.key, this.invoiceToEdit});

  @override
  ConsumerState<FluentInvoiceForm> createState() => _FluentInvoiceFormState();
}

class _FluentInvoiceFormState extends ConsumerState<FluentInvoiceForm> {
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

    return ScaffoldPage.scrollable(
      header: PageHeader(
        title:
            Text(widget.invoiceToEdit != null ? "Edit Invoice" : "New Invoice"),
      ),
      bottomBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: FluentTheme.of(context).cardColor,
          border: Border(
              top: BorderSide(
                  color: FluentTheme.of(context)
                      .resources
                      .dividerStrokeColorDefault)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Button(
              onPressed: () => _printInvoice(invoice, profile),
              child: const Text("Print"),
            ),
            const SizedBox(width: 10),
            FilledButton(
              onPressed: () => _saveInvoice(context, ref, invoice),
              child: const Text("Save"),
            ),
          ],
        ),
      ),
      children: [
        Expander(
          header: const Text("Invoice Details"),
          initiallyExpanded: true,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoLabel(
                label: "Invoice Style",
                child: ComboBox<String>(
                  value: invoice.style,
                  items: ['Modern', 'Professional', 'Minimal']
                      .map((e) => ComboBoxItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(invoiceProvider.notifier).updateStyle(val);
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: InfoLabel(
                      label: "Invoice No",
                      child: TextFormBox(
                        initialValue: invoice.invoiceNo,
                        onChanged: (val) => ref
                            .read(invoiceProvider.notifier)
                            .updateInvoiceNo(val),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InfoLabel(
                      label: "Date",
                      child: DatePicker(
                        selected: invoice.invoiceDate,
                        onChanged: (date) =>
                            ref.read(invoiceProvider.notifier).updateDate(date),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              InfoLabel(
                label: "Place of Supply",
                child: TextFormBox(
                  initialValue: invoice.placeOfSupply,
                  onChanged: (val) => ref
                      .read(invoiceProvider.notifier)
                      .updatePlaceOfSupply(val),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expander(
          header: const Text("Parties"),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Supplier (You)",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    TextFormBox(
                      prefix: const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(FluentIcons.contact),
                      ),
                      placeholder: "Name",
                      initialValue: invoice.supplier.name,
                      onChanged: (val) => ref
                          .read(invoiceProvider.notifier)
                          .updateSupplierName(val),
                    ),
                    const SizedBox(height: 5),
                    TextFormBox(
                      placeholder: "GSTIN",
                      initialValue: invoice.supplier.gstin,
                      onChanged: (val) => ref
                          .read(invoiceProvider.notifier)
                          .updateSupplierGstin(val),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Receiver (Client)",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    TextFormBox(
                      prefix: const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(FluentIcons.contact),
                      ),
                      placeholder: "Name",
                      initialValue: invoice.receiver.name,
                      onChanged: (val) => ref
                          .read(invoiceProvider.notifier)
                          .updateReceiverName(val),
                    ),
                    const SizedBox(height: 5),
                    TextFormBox(
                      placeholder: "GSTIN",
                      initialValue: invoice.receiver.gstin,
                      onChanged: (val) => ref
                          .read(invoiceProvider.notifier)
                          .updateReceiverGstin(val),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text("Items",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...invoice.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormBox(
                          placeholder: "Description",
                          initialValue: item.description,
                          onChanged: (val) => ref
                              .read(invoiceProvider.notifier)
                              .updateItemDescription(index, val),
                        ),
                      ),
                      IconButton(
                        icon: Icon(FluentIcons.delete, color: Colors.red),
                        onPressed: () => ref
                            .read(invoiceProvider.notifier)
                            .removeItem(index),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: ComboBox<String>(
                          value: item.codeType,
                          items: ['SAC', 'HSN']
                              .map(
                                  (e) => ComboBoxItem(value: e, child: Text(e)))
                              .toList(),
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
                      Expanded(
                        child: TextFormBox(
                          placeholder: "Code",
                          initialValue: item.sacCode,
                          onChanged: (val) => ref
                              .read(invoiceProvider.notifier)
                              .updateItemSac(index, val),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: TextFormBox(
                          placeholder: "Amount",
                          initialValue:
                              item.amount == 0 ? "" : item.amount.toString(),
                          onChanged: (val) => ref
                              .read(invoiceProvider.notifier)
                              .updateItemAmount(index, val),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: TextFormBox(
                          placeholder: "GST %",
                          initialValue: item.gstRate.toString(),
                          onChanged: (val) => ref
                              .read(invoiceProvider.notifier)
                              .updateItemGstRate(index, val),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        Button(
          onPressed: () => ref.read(invoiceProvider.notifier).addItem(),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FluentIcons.add),
              SizedBox(width: 8),
              Text("Add Item"),
            ],
          ),
        ),
        const SizedBox(height: 50),
      ],
    );
  }

  Future<void> _saveInvoice(
      BuildContext context, WidgetRef ref, Invoice invoice) async {
    Invoice toSave = invoice;
    if (toSave.id == null) {
      toSave = toSave.copyWith(id: _generateId());
    }

    await InvoiceRepository().saveInvoice(toSave);

    if (invoice.id == null) {
      await ref
          .read(businessProfileProvider.notifier)
          .incrementInvoiceSequence();
    }

    if (context.mounted) {
      displayInfoBar(
        context,
        builder: (context, close) {
          return InfoBar(
            title: const Text('Success'),
            content: const Text('Invoice saved successfully'),
            action: IconButton(
              icon: const Icon(FluentIcons.clear),
              onPressed: close,
            ),
            severity: InfoBarSeverity.success,
          );
        },
      );
      if (widget.invoiceToEdit == null) {
        // Clear form if new
        // Navigator.pop(context); // Or navigate back
      }
    }
  }

  Future<void> _printInvoice(Invoice invoice, BusinessProfile profile) async {
    final pdfBytes = await generateInvoicePdf(invoice, profile);
    await Printing.layoutPdf(onLayout: (_) => pdfBytes);
  }
}
