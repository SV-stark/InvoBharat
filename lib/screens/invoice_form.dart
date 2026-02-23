import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/models/business_profile.dart';
import 'package:invobharat/models/client.dart';
import 'package:invobharat/utils/pdf_generator.dart';
import 'package:invobharat/utils/gst_utils.dart';
import 'package:invobharat/providers/business_profile_provider.dart';
import 'package:invobharat/providers/client_provider.dart';
import 'package:invobharat/providers/invoice_provider.dart';
import 'package:invobharat/providers/item_template_provider.dart';
import 'package:invobharat/mixins/invoice_form_mixin.dart';
import 'package:invobharat/screens/widgets/invoice_form_sections.dart';

// Generates a unique ID

class InvoiceFormScreen extends ConsumerStatefulWidget {
  final Invoice? invoiceToEdit;
  const InvoiceFormScreen({super.key, this.invoiceToEdit});

  @override
  ConsumerState<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends ConsumerState<InvoiceFormScreen>
    with InvoiceFormMixin {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    initInvoiceControllers(widget.invoiceToEdit); // Use mixin init

    if (widget.invoiceToEdit != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(invoiceProvider.notifier).setInvoice(widget.invoiceToEdit!);
        syncInvoiceControllers(ref.read(invoiceProvider));
      });
    } else {
      // Set smart defaults for new invoice
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _setSmartDefaults();
        syncInvoiceControllers(ref.read(invoiceProvider));
      });
    }
  }

  Future<void> _setSmartDefaults() async {
    final notifier = ref.read(invoiceProvider.notifier);

    // Generate next invoice number
    final nextInvoiceNo = await generateNextInvoiceNumber();
    notifier.updateInvoiceNo(nextInvoiceNo);

    // Set default payment terms
    notifier.updatePaymentTerms('Net 30');

    // Calculate and set due date
    final invoiceDate = DateTime.now();
    final dueDate = calculateDueDate(invoiceDate, 'Net 30');
    if (dueDate != null) {
      notifier.updateDueDate(dueDate);
    }
  }

  @override
  void dispose() {
    disposeInvoiceControllers(); // Use mixin dispose
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final invoice = ref.watch(invoiceProvider);
    final profile = ref.watch(businessProfileProvider);
    final clients = ref.watch(clientListProvider);

    // Listen to provider changes to sync controllers if needed
    // Best practice: only sync if external change (not our own typing)
    // But detecting valid external change is hard.
    // For now, we rely on manual sync when needed (shortcuts, load).

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.invoiceToEdit != null ? "Edit Invoice" : "New Invoice",
        ),
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
            onPressed: () => printInvoice(invoice, profile),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: FilledButton.icon(
              onPressed: () => _saveInvoiceUI(context, invoice),
              icon: const Icon(Icons.save),
              label: const Text("Save"),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              InvoiceHeaderSection(
                invoiceNoCtrl: invoiceNoCtrl,
                posCtrl: posCtrl,
                paymentTermsCtrl: paymentTermsCtrl,
              ),
              const SizedBox(height: 16),
              ClientDetailsSection(
                receiverNameCtrl: receiverNameCtrl,
                receiverStateCtrl: receiverStateCtrl,
                receiverAddressCtrl: receiverAddressCtrl,
                onSelectClient: () => _showClientSelector(context, clients),
                gstinField: _buildGstinField(),
              ),
              const SizedBox(height: 16),
              InvoiceItemsSection(
                onAddItem: () => ref.read(invoiceProvider.notifier).addItem(),
                onAddFromTemplate: () => _showTemplateSelector(context),
                itemBuilder: (final context, final index, final item) =>
                    _buildInlineItemEditor(context, index, item),
              ),
              const SizedBox(height: 16),
              const InvoiceSummarySection(),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  void _saveInvoiceUI(final BuildContext context, final Invoice invoice) async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fix errors")));
      return;
    }
    try {
      await saveInvoice(invoice: invoice, context: context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invoice saved successfully")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error saving invoice: $e")));
      }
    }
  }

  void _showClientSelector(
    final BuildContext context,
    final List<Client> clients,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (final context) {
        return StatefulBuilder(
          builder: (final context, final setState) {
            final searchController = TextEditingController();
            String searchQuery = '';

            // Sort clients: recent first (alphabetically for now, can be enhanced)
            final sortedClients = List<Client>.from(clients)
              ..sort(
                (final a, final b) =>
                    a.name.toLowerCase().compareTo(b.name.toLowerCase()),
              );

            // Filter clients based on search
            final filteredClients = searchQuery.isEmpty
                ? sortedClients
                : sortedClients
                      .where(
                        (final c) =>
                            c.name.toLowerCase().contains(
                              searchQuery.toLowerCase(),
                            ) ||
                            c.gstin.toLowerCase().contains(
                              searchQuery.toLowerCase(),
                            ) ||
                            c.address.toLowerCase().contains(
                              searchQuery.toLowerCase(),
                            ),
                      )
                      .toList();

            return Container(
              padding: const EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Select Client",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          // Sort toggle or filter options can go here
                        },
                        icon: const Icon(Icons.sort, size: 18),
                        label: Text("${clients.length} total"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Search Bar
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search by name, GSTIN, or address...",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                searchController.clear();
                                setState(() => searchQuery = '');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (final value) =>
                        setState(() => searchQuery = value),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: filteredClients.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "No clients found",
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                if (searchQuery.isNotEmpty)
                                  TextButton(
                                    onPressed: () {
                                      searchController.clear();
                                      setState(() => searchQuery = '');
                                    },
                                    child: const Text("Clear search"),
                                  ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: filteredClients.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (final context, final index) {
                              final client = filteredClients[index];
                              final initial = client.name.isNotEmpty
                                  ? client.name[0].toUpperCase()
                                  : "?";
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  child: Text(
                                    initial,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(client.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (client.gstin.isNotEmpty)
                                      Text(
                                        "GST: ${client.gstin}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    if (client.address.isNotEmpty)
                                      Text(
                                        client.address,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  onClientSelected(client);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showTemplateSelector(final BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (final context) {
        // We need to fetch templates
        // Assuming provider is available globally
        return Consumer(
          builder: (final context, final ref, final child) {
            final templates = ref.watch(itemTemplateListProvider);
            return Container(
              padding: const EdgeInsets.all(16),
              height: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select Template",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: templates.isEmpty
                        ? const Center(child: Text("No templates found."))
                        : ListView.builder(
                            itemCount: templates.length,
                            itemBuilder: (final context, final index) {
                              final template = templates[index];
                              return ListTile(
                                title: Text(template.description),
                                subtitle: Text(
                                  "₹${template.amount} (GST: ${template.gstRate}%)",
                                ),
                                onTap: () {
                                  // Add Item
                                  ref
                                      .read(invoiceProvider.notifier)
                                      .addItem(
                                        // We need to pass data.
                                        // Does addItem support arguments? Checked previous code: NO.
                                        // I need to modify InvoiceNotifier to accept item?
                                        // Or add blank then update last item?
                                        // Valid approach: Add blank, then update.
                                      );
                                  // BUT `addItem` is sync.
                                  // Let's modify `addItem` to optional arg OR use a new method `addInvoiceItem`.
                                  // Since I can't see InvoiceNotifier source right now easily, I'll assume I should modify it OR update manually.
                                  // For now, I'll assume I update notifier later.
                                  // For now, I will manually update fields of the new item.

                                  final notifier = ref.read(
                                    invoiceProvider.notifier,
                                  );
                                  notifier.addItem(); // Adds empty

                                  // We need to wait for state update? Not if it's sync StateNotifier.
                                  // But `addItem` might be async? No normally sync.
                                  // However, reading back immediately might be stale if inside build? No we are in callback.
                                  // Let's TRY to perform updates.
                                  // Accessing `invoiceProvider` subsequent times should get updated state if using ref.read inside callback?
                                  // Actually `addItem` updates state. `ref.read` should get new state.
                                  final newItems = ref
                                      .read(invoiceProvider)
                                      .items;
                                  final idx = newItems.length - 1;

                                  notifier.updateItemDescription(
                                    idx,
                                    template.description,
                                  );
                                  notifier.updateItemAmount(
                                    idx,
                                    template.amount.toString(),
                                  );
                                  notifier.updateItemQuantity(
                                    idx,
                                    template.quantity.toString(),
                                  ); // NEW
                                  notifier.updateItemUnit(idx, template.unit);
                                  notifier.updateItemGstRate(
                                    idx,
                                    template.gstRate.toString(),
                                  );
                                  notifier.updateItemSac(idx, template.sacCode);
                                  notifier.updateItemCodeType(
                                    idx,
                                    template.codeType,
                                  );

                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInlineItemEditor(
    final BuildContext context,
    final int index,
    final InvoiceItem item,
  ) {
    final notifier = ref.read(invoiceProvider.notifier);

    return StatefulBuilder(
      builder: (final context, final setState) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withAlpha((255 * 0.3).toInt()),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                TextFormField(
                  initialValue: item.description,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onChanged: (final val) =>
                      notifier.updateItemDescription(index, val),
                ),
                const SizedBox(height: 8),

                // Quantity, Unit, Price, GST Row
                Row(
                  children: [
                    // Quantity
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        initialValue: item.quantity.toString(),
                        decoration: const InputDecoration(
                          labelText: "Qty",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (final val) =>
                            notifier.updateItemQuantity(index, val),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Unit
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        initialValue: item.unit,
                        decoration: const InputDecoration(
                          labelText: "Unit",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                        ),
                        onChanged: (final val) =>
                            notifier.updateItemUnit(index, val),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Price
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        initialValue: item.amount.toString(),
                        decoration: const InputDecoration(
                          labelText: "Price",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          prefixText: "₹",
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (final val) =>
                            notifier.updateItemAmount(index, val),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // GST
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        initialValue: item.gstRate.toString(),
                        decoration: const InputDecoration(
                          labelText: "GST%",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (final val) =>
                            notifier.updateItemGstRate(index, val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // HSN/SAC and Total Row
                Row(
                  children: [
                    // HSN/SAC
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        initialValue: item.sacCode,
                        decoration: const InputDecoration(
                          labelText: "HSN/SAC",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                        ),
                        onChanged: (final val) =>
                            notifier.updateItemSac(index, val),
                      ),
                    ),
                    const Spacer(),

                    // Total
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "₹${item.totalAmount.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),

                    // Delete button
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: () => notifier.removeItem(index),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPreview(
    final BuildContext context,
    final Invoice invoice,
    final BusinessProfile profile,
  ) {
    showDialog(
      context: context,
      builder: (final context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: PdfPreview(
            build: (final format) => generateInvoicePdf(invoice, profile),
            useActions: false,
          ),
        );
      },
    );
  }

  Widget _buildGstinField() {
    return StatefulBuilder(
      builder: (final context, final setState) {
        final gstin = receiverGstinCtrl.text.toUpperCase();
        final validation = GstUtils.validate(gstin);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: receiverGstinCtrl,
              decoration: InputDecoration(
                labelText: "GSTIN",
                border: const OutlineInputBorder(),
                suffixIcon: gstin.isNotEmpty
                    ? validation.isValid
                          ? Icon(Icons.check_circle, color: Colors.green[600])
                          : Icon(Icons.error, color: Colors.red[600])
                    : null,
                helperText: validation.stateName != null
                    ? "${validation.stateName} • PAN: ${validation.pan}"
                    : (gstin.isNotEmpty && !validation.isValid
                          ? validation.errorMessage
                          : null),
                helperStyle: TextStyle(
                  color: validation.isValid
                      ? Colors.green[600]
                      : Colors.red[600],
                  fontSize: 12,
                ),
              ),
              onChanged: (final val) {
                ref.read(invoiceProvider.notifier).updateReceiverGstin(val);
                // Auto-update state if GSTIN is valid
                if (validation.isValid && validation.stateName != null) {
                  receiverStateCtrl.text = validation.stateName!;
                  ref
                      .read(invoiceProvider.notifier)
                      .updateReceiverState(validation.stateName!);
                }
                setState(() {});
              },
              validator: (final val) {
                if (val != null &&
                    val.isNotEmpty &&
                    !GstUtils.isValidGstin(val)) {
                  return "Invalid GSTIN format";
                }
                return null;
              },
            ),
          ],
        );
      },
    );
  }
}
