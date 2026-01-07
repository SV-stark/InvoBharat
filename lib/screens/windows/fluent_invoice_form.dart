import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../../models/invoice.dart';
import '../../models/business_profile.dart';
import '../../providers/business_profile_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../data/invoice_repository.dart';
import '../../utils/pdf_generator.dart';
import '../../utils/constants.dart';

// Generates a unique ID
String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();

class FluentInvoiceForm extends ConsumerStatefulWidget {
  final Invoice? invoiceToEdit;
  const FluentInvoiceForm({super.key, this.invoiceToEdit});

  @override
  ConsumerState<FluentInvoiceForm> createState() => _FluentInvoiceFormState();
}

class _FluentInvoiceFormState extends ConsumerState<FluentInvoiceForm> {
  late TextEditingController _placeOfSupplyController;

  @override
  void initState() {
    super.initState();
    _placeOfSupplyController = TextEditingController();
    if (widget.invoiceToEdit != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(invoiceProvider.notifier).setInvoice(widget.invoiceToEdit!);
        _placeOfSupplyController.text = widget.invoiceToEdit!.placeOfSupply;
      });
    } else {
      // Set default if any or just ref read
      // But better to just sync with provider in build or use a listener
      // Because provider might change from elsewhere? No, mostly here.
      // Actually, we should initialize it from the provider state in build?
      // No, controller is stateful.
      // Let's keep it simple: sync on init, and update provider on change.
    }
  }

  @override
  void dispose() {
    _placeOfSupplyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invoice = ref.watch(invoiceProvider);
    final profile = ref.watch(businessProfileProvider);

    // Sync controller if empty (first load of new invoice) or if external change?
    if (_placeOfSupplyController.text.isEmpty &&
        invoice.placeOfSupply.isNotEmpty) {
      _placeOfSupplyController.text = invoice.placeOfSupply;
    }

    return ScaffoldPage.scrollable(
      header: PageHeader(
        title:
            Text(widget.invoiceToEdit != null ? "Edit Invoice" : "New Invoice"),
        leading: Navigator.canPop(context)
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  icon: const Icon(FluentIcons.back),
                  onPressed: () => Navigator.pop(context),
                ),
              )
            : null,
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
              onPressed: () => _showPreview(context, invoice, profile),
              child: const Text("Preview"),
            ),
            const SizedBox(width: 10),
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
          header: Text("Invoice Details",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: FluentTheme.of(context).accentColor)),
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
                child: AutoSuggestBox<String>(
                  controller: _placeOfSupplyController,
                  items: IndianStates.states
                      .map(
                          (e) => AutoSuggestBoxItem<String>(value: e, label: e))
                      .toList(),
                  onSelected: (item) {
                    ref
                        .read(invoiceProvider.notifier)
                        .updatePlaceOfSupply(item.value!);
                  },
                  onChanged: (text, reason) {
                    if (reason == TextChangedReason.userInput) {
                      ref
                          .read(invoiceProvider.notifier)
                          .updatePlaceOfSupply(text);
                    }
                  },
                  placeholder: "Select State",
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Parties Section
        Expander(
          header: Text("Parties",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: FluentTheme.of(context).accentColor)),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Supplier (Read Only)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Supplier",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Card(
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(profile.companyName,
                                style: FluentTheme.of(context)
                                    .typography
                                    .bodyStrong),
                            Text(profile.gstin,
                                style:
                                    FluentTheme.of(context).typography.caption),
                            Text(profile.address,
                                style:
                                    FluentTheme.of(context).typography.caption),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    HyperlinkButton(
                      child: const Text("Edit in Settings"),
                      onPressed: () {
                        // Ideally navigate to settings, but user can just click Settings tab
                        displayInfoBar(context, builder: (context, close) {
                          return InfoBar(
                            title: const Text("Go to Settings"),
                            content: const Text(
                                "Please edit supplier details in the Settings tab."),
                            action: IconButton(
                                icon: const Icon(FluentIcons.clear),
                                onPressed: close),
                            severity: InfoBarSeverity.info,
                          );
                        });
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Receiver (Editable)
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
        Text("Items",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: FluentTheme.of(context).accentColor)),
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

    // Sync supplier state from profile if not present
    final profile = ref.read(businessProfileProvider);
    if (toSave.supplier.state.isEmpty && profile.state.isNotEmpty) {
      toSave = toSave.copyWith(
          supplier: toSave.supplier.copyWith(state: profile.state));
    }

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
    }
  }

  Future<void> _printInvoice(Invoice invoice, BusinessProfile profile) async {
    final pdfBytes = await generateInvoicePdf(invoice, profile);
    await Printing.layoutPdf(onLayout: (_) => pdfBytes);
  }

  void _showPreview(
      BuildContext context, Invoice invoice, BusinessProfile profile) {
    Navigator.push(
      context,
      FluentPageRoute(
        builder: (context) => ScaffoldPage(
          header: PageHeader(
            title: const Text("Invoice Preview"),
            leading: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: const Icon(FluentIcons.back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          content: PdfPreview(
            build: (format) => generateInvoicePdf(invoice, profile),
            allowPrinting: true,
            allowSharing: true,
            canChangePageFormat: false,
            initialPageFormat: PdfPageFormat.a4,
            pdfPreviewPageDecoration: BoxDecoration(
              color: FluentTheme.of(context).cardColor,
              boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black)],
            ),
          ),
        ),
      ),
    );
  }
}
