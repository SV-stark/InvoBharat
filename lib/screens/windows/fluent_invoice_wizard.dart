import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/providers/business_profile_provider.dart';
import 'package:invobharat/providers/client_provider.dart';
import 'package:invobharat/providers/invoice_repository_provider.dart';
import 'package:invobharat/providers/item_template_provider.dart';
import 'package:invobharat/utils/pdf_generator.dart';
import 'package:url_launcher/url_launcher.dart'; // New
import 'package:invobharat/mixins/invoice_form_mixin.dart';
import 'package:invobharat/providers/invoice_provider.dart'; // NEW Import

import 'package:invobharat/utils/constants.dart';
import 'package:invobharat/screens/windows/widgets/wizard_add_client_dialog.dart';
import 'package:invobharat/screens/windows/widgets/invoice_item_dialog.dart';

class FluentInvoiceWizard extends ConsumerStatefulWidget {
  final Invoice? invoiceToEdit;
  const FluentInvoiceWizard({super.key, this.invoiceToEdit});

  @override
  ConsumerState<FluentInvoiceWizard> createState() =>
      _FluentInvoiceWizardState();
}

class _FluentInvoiceWizardState extends ConsumerState<FluentInvoiceWizard>
    with InvoiceFormMixin {
  // Invoice Data State - REMOVED (Handled by Provider & Mixin)

  // Unused fields removed

  @override
  void initState() {
    super.initState();
    initInvoiceControllers(widget.invoiceToEdit); // Mixin init

    if (widget.invoiceToEdit != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(invoiceProvider.notifier).setInvoice(widget.invoiceToEdit!);
        syncInvoiceControllers(ref.read(invoiceProvider));
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Ensure reset if new
        ref.read(invoiceProvider.notifier).reset();
        syncInvoiceControllers(ref.read(invoiceProvider));
      });
    }
  }

  @override
  void dispose() {
    disposeInvoiceControllers(); // Mixin dispose
    super.dispose();
  }

  // Removed _initializeData and _buildCurrentInvoice as they are replaced by Provider logic

  @override
  Widget build(final BuildContext context) {
    final invoice = ref.watch(invoiceProvider);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () {
          Navigator.maybePop(context);
        },
      },
      child: ScaffoldPage.scrollable(
        header: PageHeader(
          leading: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              icon: const Icon(FluentIcons.back),
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
          title: Text(
            widget.invoiceToEdit == null ? 'New Invoice' : 'Edit Invoice',
          ),
          commandBar: CommandBar(
            primaryItems: [
              CommandBarButton(
                icon: const Icon(FluentIcons.print),
                label: const Text("Preview PDF"),
                onPressed: () => _showPreviewDialog(invoice),
              ),
              CommandBarButton(
                icon: const Icon(FluentIcons.save),
                label: const Text("Save Invoice"),
                onPressed: () => _saveInvoice(invoice),
              ),
            ],
          ),
        ),
        children: [
          _buildDetailsSection(),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          _buildItemsSection(),
          const SizedBox(height: 20),
          _buildPaymentHistorySection(), // New
          if (ref.watch(invoiceProvider).payments.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
          ],
          _buildFooterSection(),
        ],
      ),
    );
  }

  // Renamed from _buildDetailsStep and removed ParametricScroll
  Widget _buildDetailsSection() {
    final invoice = ref.watch(invoiceProvider);
    final notifier = ref.read(invoiceProvider.notifier);
    final clients = ref.watch(clientListProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Client Selection
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Bill To",
                style: FluentTheme.of(context).typography.subtitle,
              ),
              const SizedBox(height: 10),
              if (invoice.receiver.name.isEmpty)
                Row(
                  children: [
                    Expanded(
                      child: AutoSuggestBox<String>(
                        placeholder: "Search Client Name...",
                        items: clients
                            .map(
                              (final c) => AutoSuggestBoxItem<String>(
                                value: c.id,
                                label: c.name,
                                child: Text(c.name),
                              ),
                            )
                            .toList(),
                        onSelected: (final item) {
                          final client = clients.firstWhere(
                            (final c) => c.id == item.value,
                          );
                          onClientSelected(client); // Mixin method
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Button(
                      onPressed: _showAddClientDialog,
                      child: const Icon(FluentIcons.add),
                    ),
                  ],
                )
              else
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            invoice.receiver.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(FluentIcons.edit),
                            onPressed: () => notifier.updateReceiverName(""),
                          ), // Clear name to reset selection
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(invoice.receiver.address),
                      if (invoice.receiver.gstin.isNotEmpty)
                        Text("GSTIN: ${invoice.receiver.gstin}"),
                      if (invoice.receiver.state.isNotEmpty)
                        Text("State: ${invoice.receiver.state}"),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              InfoLabel(
                label: "Client Not Found?",
                child: const Text(
                  "You can create a one-time client by searching, or add a permanent client using the '+' button.",
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),
        // Right Column: Invoice Details
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Invoice Details",
                style: FluentTheme.of(context).typography.subtitle,
              ),
              const SizedBox(height: 10),
              InfoLabel(
                label: "Document Type",
                child: ComboBox<InvoiceType>(
                  value: invoice.type,
                  items: InvoiceType.values.map((final e) {
                    String label = e.name;
                    if (e == InvoiceType.deliveryChallan) {
                      label = "Delivery Challan";
                    }
                    if (e == InvoiceType.creditNote) {
                      label = "Credit Note";
                    }
                    if (e == InvoiceType.debitNote) {
                      label = "Debit Note";
                    }
                    if (e == InvoiceType.invoice) {
                      label = "Invoice";
                    }
                    return ComboBoxItem(value: e, child: Text(label));
                  }).toList(),
                  onChanged: (final v) {
                    if (v != null) notifier.updateInvoiceType(v);
                  },
                ),
              ),
              if (invoice.type == InvoiceType.creditNote ||
                  invoice.type == InvoiceType.debitNote) ...[
                const SizedBox(height: 10),
                InfoLabel(
                  label: "Original Invoice No.",
                  child: TextBox(
                    placeholder: "e.g. INV-001",
                    onChanged: (final v) =>
                        notifier.updateOriginalInvoiceNumber(v),
                    controller: originalInvoiceNoCtrl,
                  ),
                ),
                const SizedBox(height: 10),
                DatePicker(
                  header: "Original Invoice Date",
                  selected: invoice.originalInvoiceDate ?? DateTime.now(),
                  onChanged: (final d) => notifier.updateOriginalInvoiceDate(d),
                ),
              ],
              const SizedBox(height: 10),
              InfoLabel(
                label: "Invoice Number",
                child: TextBox(
                  placeholder: "INV-001",
                  controller: invoiceNoCtrl, // Mixin Controller
                  onChanged: (final v) => notifier.updateInvoiceNo(v),
                ),
              ),
              const SizedBox(height: 10),
              InfoLabel(
                label: "Invoice Date",
                child: DatePicker(
                  selected: invoice.invoiceDate,
                  onChanged: (final v) => notifier.updateDate(v),
                ),
              ),
              const SizedBox(height: 10),
              InfoLabel(
                label: "Due Date",
                child: DatePicker(
                  selected: invoice.dueDate ?? DateTime.now(),
                  onChanged: (final v) => notifier.updateDueDate(v),
                ),
              ),
              const SizedBox(height: 10),
              InfoLabel(
                label: "Place of Supply",
                child: AutoSuggestBox<String>(
                  placeholder: "State Name",
                  controller: posCtrl, // Mixin Controller
                  items: IndianStates.states
                      .map(
                        (final e) =>
                            AutoSuggestBoxItem<String>(value: e, label: e),
                      )
                      .toList(),
                  onSelected: (final item) {
                    notifier.updatePlaceOfSupply(item.value ?? "");
                  },
                  onChanged: (final text, final reason) {
                    if (reason == TextChangedReason.userInput) {
                      notifier.updatePlaceOfSupply(text);
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              InfoLabel(
                label: "Payment Terms",
                child: TextBox(
                  placeholder: "e.g. Due on Receipt",
                  controller: paymentTermsCtrl, // Mixin Controller
                  onChanged: (final v) => notifier.updatePaymentTerms(v),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemsSection() {
    final currency = NumberFormat.simpleCurrency(name: 'INR');
    final invoice = ref.watch(invoiceProvider);
    final notifier = ref.read(invoiceProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Items Table Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          color: FluentTheme.of(context).accentColor.withValues(alpha: 0.1),
          child: const Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  "Description",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Text(
                  "HSN/SAC",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Text(
                  "Qty",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "Price",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Text(
                  "GST",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "Total",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(width: 80), // Actions width to match row
            ],
          ),
        ),

        // List of Items
        if (invoice.items.isEmpty)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                "No items added yet.",
                style: TextStyle(color: Colors.grey.withValues(alpha: 0.8)),
              ),
            ),
          )
        else
          Column(
            children: invoice.items.asMap().entries.map((final entry) {
              final index = entry.key;
              final item = entry.value;
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        item.description.isEmpty
                            ? "(No description)"
                            : item.description,
                      ),
                    ),
                    Expanded(
                      child: Text(item.sacCode.isEmpty ? "-" : item.sacCode),
                    ),
                    Expanded(child: Text("${item.quantity} ${item.unit}")),
                    Expanded(
                      flex: 2,
                      child: Text(currency.format(item.amount)),
                    ),
                    Expanded(child: Text("${item.gstRate}%")),
                    Expanded(
                      flex: 2,
                      child: Text(
                        currency.format(item.totalAmount),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(FluentIcons.edit),
                            onPressed: () =>
                                _showItemDialog(item: item, index: index),
                          ),
                          IconButton(
                            icon: Icon(FluentIcons.delete, color: Colors.red),
                            onPressed: () => notifier.removeItem(index),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

        const SizedBox(height: 10),

        // Add Item Button & Totals
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Button(
              onPressed: () => _showItemDialog(),
              child: const Row(
                children: [
                  Icon(FluentIcons.add),
                  SizedBox(width: 8),
                  Text("Add Item"),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Button(
              onPressed: _showTemplateSelector,
              child: const Row(
                children: [
                  Icon(FluentIcons.copy),
                  SizedBox(width: 8),
                  Text("From Template"),
                ],
              ),
            ),
            const Spacer(),
            // Summary Card
            Card(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: 250,
                child: Column(
                  children: [
                    _buildSummaryRow(
                      "Subtotal",
                      currency.format(invoice.totalTaxableValue),
                    ),
                    _buildSummaryRow(
                      "Total GST",
                      currency.format(
                        invoice.totalCGST +
                            invoice.totalSGST +
                            invoice.totalIGST,
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Discount"),
                          SizedBox(
                            width: 100,
                            child: NumberBox<double>(
                              value: invoice.discountAmount,
                              onChanged: (final v) =>
                                  notifier.updateDiscountAmount(v.toString()),
                              mode: SpinButtonPlacementMode.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildSummaryRow(
                      "Grand Total",
                      currency.format(invoice.grandTotal),
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    final String label,
    final String value, {
    final bool isBold = false,
  }) {
    final style = isBold
        ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
        : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }

  void _showAddClientDialog() async {
    await showDialog(
      context: context,
      builder: (final dialogContext) {
        return WizardAddClientDialog(
          onClientAdded: (final newClient) {
            onClientSelected(newClient);
          },
        );
      },
    );
  }

  void _showTemplateSelector() {
    showDialog(
      context: context,
      builder: (final context) {
        return ContentDialog(
          title: const Text("Select Template"),
          content: Consumer(
            builder: (final context, final ref, final child) {
              final templates = ref.watch(itemTemplateListProvider);
              if (templates.isEmpty) {
                return const Text(
                  "No templates found. Go to Templates to create one.",
                );
              }
              return SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: templates.length,
                  itemBuilder: (final context, final index) {
                    final t = templates[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Card(
                        child: ListTile(
                          title: Text(
                            t.description,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "₹${t.amount} / ${t.unit} (Qty: ${t.quantity})",
                          ),
                          onPressed: () {
                            final newItem = InvoiceItem(
                              description: t.description,
                              quantity: t.quantity,
                              amount: t.amount,
                              gstRate: t.gstRate,
                              unit: t.unit,
                              sacCode: t.sacCode,
                              codeType: t.codeType,
                            );
                            final notifier = ref.read(invoiceProvider.notifier);
                            notifier.addInvoiceItem(newItem);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            Button(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  void _showItemDialog({final InvoiceItem? item, final int? index}) async {
    await showDialog(
      context: context,
      builder: (final context) {
        return InvoiceItemDialog(
          item: item,
          onSave: (final newItem) {
            final notifier = ref.read(invoiceProvider.notifier);
            if (index != null) {
              notifier.replaceItem(index, newItem);
            } else {
              notifier.addInvoiceItem(newItem);
            }
          },
        );
      },
    );
  }

  Widget _buildPaymentHistorySection() {
    final invoice = ref.watch(invoiceProvider);
    final currency = NumberFormat.simpleCurrency(name: 'INR');

    if (invoice.payments.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Payment History",
          style: FluentTheme.of(context).typography.subtitle,
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                color: FluentTheme.of(
                  context,
                ).accentColor.withValues(alpha: 0.1),
                child: const Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Date",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "Amount",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "Mode",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Notes",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              ...invoice.payments.map((final payment) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          DateFormat('dd MMM yyyy').format(payment.date),
                        ),
                      ),
                      Expanded(child: Text(currency.format(payment.amount))),
                      Expanded(child: Text(payment.paymentMode)),
                      Expanded(
                        flex: 2,
                        child: Text(
                          (payment.notes ?? '').isEmpty ? "-" : payment.notes!,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooterSection() {
    final invoice = ref.watch(invoiceProvider);
    final notifier = ref.read(invoiceProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Additional Notes",
          style: FluentTheme.of(context).typography.subtitle,
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: InfoLabel(
                label: "Terms & Conditions / Comments",
                child: TextBox(
                  placeholder: "Thanks for your business.",
                  controller: TextEditingController(text: invoice.comments),
                  onChanged: (final v) => notifier.updateTermComments(v),
                  maxLines: 4,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoLabel(
                    label: "Invoice Style",
                    child: ComboBox<String>(
                      value: invoice.style,
                      items: ['Modern', 'Professional', 'Minimal']
                          .map(
                            (final e) => ComboBoxItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (final v) {
                        if (v != null) notifier.updateStyle(v);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showPreviewDialog(final Invoice invoice) {
    final profile = ref.read(businessProfileProvider);

    showDialog(
      context: context,
      builder: (final context) {
        return ContentDialog(
          constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 800),
          title: const Text("Invoice Preview"),
          content: PdfPreview(
            build: (final format) => generateInvoicePdf(invoice, profile),
            canChangeOrientation: false,
            canChangePageFormat: false,
            canDebug: false,
            pdfFileName: "${invoice.invoiceNo}.pdf",
          ),
          actions: [
            Button(
              child: const Text("Close"),
              onPressed: () => Navigator.pop(context),
            ),
            if (widget.invoiceToEdit != null)
              Button(
                child: const Text("Email Client"),
                onPressed: () async {
                  final email =
                      invoice.receiver.email; // Now exists in Receiver model
                  if (email.isEmpty) {
                    displayInfoBar(
                      context,
                      builder: (final context, final close) {
                        return InfoBar(
                          title: const Text("Validation"),
                          content: const Text("Client email is missing"),
                          severity: InfoBarSeverity.warning,
                          onClose: close,
                        );
                      },
                    );
                    return;
                  }
                  final Uri emailLaunchUri = Uri(
                    scheme: 'mailto',
                    path: email,
                    query:
                        'subject=Invoice ${invoice.invoiceNo}&body=Dear ${invoice.receiver.name},\n\nPlease find attached invoice ${invoice.invoiceNo}.\n\nRegards,\n${invoice.supplier.name}',
                  );
                  if (await canLaunchUrl(emailLaunchUri)) {
                    await launchUrl(emailLaunchUri);
                  } else {
                    // ignore: use_build_context_synchronously
                    displayInfoBar(
                      context,
                      builder: (final context, final close) {
                        return InfoBar(
                          title: const Text("Error"),
                          content: const Text("Could not launch email client"),
                          severity: InfoBarSeverity.error,
                          onClose: close,
                        );
                      },
                    );
                  }
                },
              ),
            FilledButton(
              child: const Text("Save & Close"),
              onPressed: () {
                Navigator.pop(context);
                _saveInvoice(invoice);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveInvoice(final Invoice invoice) async {
    // Validation
    if (invoice.receiver.name.isEmpty) {
      displayInfoBar(
        context,
        builder: (final context, final close) {
          return InfoBar(
            title: const Text("Required"),
            content: const Text("Please select a client"),
            severity: InfoBarSeverity.warning,
            onClose: close,
          );
        },
      );
      return;
    }
    if (invoice.invoiceNo.isEmpty) {
      displayInfoBar(
        context,
        builder: (final context, final close) {
          return InfoBar(
            title: const Text("Required"),
            content: const Text("Invoice Number is required"),
            severity: InfoBarSeverity.warning,
            onClose: close,
          );
        },
      );
      return;
    }
    if (invoice.items.isEmpty) {
      displayInfoBar(
        context,
        builder: (final context, final close) {
          return InfoBar(
            title: const Text("Required"),
            content: const Text("Please add at least one item"),
            severity: InfoBarSeverity.warning,
            onClose: close,
          );
        },
      );
      return;
    }

    // Check for uniqueness
    final repository = ref.read(invoiceRepositoryProvider);
    // Use invoice.invoiceNo, which is updated via provider
    final exists = await repository.checkInvoiceExists(
      invoice.invoiceNo,
      excludeId: widget.invoiceToEdit?.id,
    );

    if (!mounted) return;

    if (exists) {
      displayInfoBar(
        context,
        builder: (final context, final close) {
          return InfoBar(
            title: const Text("Duplicate Invoice Number"),
            content: Text(
              "Invoice number '${invoice.invoiceNo}' already exists.",
            ),
            severity: InfoBarSeverity.warning,
            onClose: close,
          );
        },
      );
      return;
    }

    try {
      // Use Mixin's saveInvoice? No, mixin saveInvoice returns bool and handles specific actions.
      // But we have custom UI here.
      // Let's call repository directly as before.
      await repository.saveInvoice(invoice);
      final context = this.context;
      if (!context.mounted) return;

      displayInfoBar(
        context,
        builder: (final context, final close) {
          return InfoBar(
            title: const Text("Success"),
            content: const Text("Invoice Saved Successfully"),
            severity: InfoBarSeverity.success,
            onClose: close,
          );
        },
      );

      Navigator.pop(context); // Go back to dashboard/list
    } catch (e) {
      final context = this.context;
      if (!context.mounted) return;
      displayInfoBar(
        context,
        builder: (final context, final close) {
          return InfoBar(
            title: const Text("Error"),
            content: Text("Failed to save: $e"),
            severity: InfoBarSeverity.error,
            onClose: close,
          );
        },
      );
    }
  }
}
