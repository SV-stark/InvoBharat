import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../models/invoice.dart';
import '../models/business_profile.dart';
import '../models/client.dart';
import '../utils/pdf_generator.dart';
import '../utils/gst_utils.dart';
import '../providers/business_profile_provider.dart';
import '../providers/client_provider.dart';
import '../providers/invoice_provider.dart';
import '../providers/item_template_provider.dart';
import '../mixins/invoice_form_mixin.dart';
import '../widgets/adaptive_widgets.dart'; // NEW Import

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
  Widget build(BuildContext context) {
    final invoice = ref.watch(invoiceProvider);
    final profile = ref.watch(businessProfileProvider);
    final theme = Theme.of(context);
    final clients = ref.watch(clientListProvider);

    // Listen to provider changes to sync controllers if needed
    // Best practice: only sync if external change (not our own typing)
    // But detecting valid external change is hard.
    // For now, we rely on manual sync when needed (shortcuts, load).

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
              onPressed: () => printInvoice(invoice, profile)),
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
                    (val) =>
                        ref.read(invoiceProvider.notifier).updateStyle(val!),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextInput(
                          controller: invoiceNoCtrl,
                          label: "Invoice No",
                          onChanged: (val) => ref
                              .read(invoiceProvider.notifier)
                              .updateInvoiceNo(val),
                          validator: (val) =>
                              val == null || val.isEmpty ? "Required" : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDatePicker(
                            context,
                            "Date",
                            invoice.invoiceDate,
                            (val) => ref
                                .read(invoiceProvider.notifier)
                                .updateDate(val)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextInput(
                            controller: posCtrl,
                            label: "Place of Supply",
                            onChanged: (val) => ref
                                .read(invoiceProvider.notifier)
                                .updatePlaceOfSupply(val),
                            validator: (val) =>
                                val == null || val.isEmpty ? "Required" : null),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 120,
                        child: _buildDropdown(
                          "Currency",
                          invoice.currency,
                          ['INR', 'USD', 'EUR', 'GBP'],
                          (val) => ref
                              .read(invoiceProvider.notifier)
                              .updateCurrency(val!),
                        ),
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
                  const SizedBox(height: 16),
                  _buildDatePicker(
                      context,
                      "Due Date",
                      invoice.dueDate,
                      (val) => ref
                          .read(invoiceProvider.notifier)
                          .updateDueDate(val)),
                  const SizedBox(height: 16),
                  AppTextInput(
                    controller: paymentTermsCtrl,
                    label: "Payment Terms",
                    onChanged: (val) => ref
                        .read(invoiceProvider.notifier)
                        .updatePaymentTerms(val),
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
                  AppTextInput(
                    controller: receiverNameCtrl,
                    label: "Client Name",
                    onChanged: (val) => ref
                        .read(invoiceProvider.notifier)
                        .updateReceiverName(val),
                    validator: (val) =>
                        val == null || val.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildGstinField(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppTextInput(
                          controller: receiverStateCtrl,
                          label: "State",
                          onChanged: (val) => ref
                              .read(invoiceProvider.notifier)
                              .updateReceiverState(val),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppTextInput(
                      controller: receiverAddressCtrl,
                      label: "Billing Address",
                      maxLines: 2,
                      onChanged: (val) => ref
                          .read(invoiceProvider.notifier)
                          .updateReceiverAddress(val)),
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
                          return _buildInlineItemEditor(context, index, item);
                        },
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                ref.read(invoiceProvider.notifier).addItem(),
                            icon: const Icon(Icons.add),
                            label: const Text("Add New Item"),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(
                                  color: theme.primaryColor
                                      .withValues(alpha: 0.5)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showTemplateSelector(context),
                            icon: const Icon(Icons.copy_all),
                            label: const Text("From Template"),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(
                                  color: theme.primaryColor
                                      .withValues(alpha: 0.5)),
                            ),
                          ),
                        ),
                      ],
                    )
                  ]),

              const SizedBox(height: 16),
              // Discount and Grand Total
              Card(
                elevation: 0,
                color:
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text("Discount (Flat ₹): ",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 120,
                            child: AppTextInput(
                              controller: TextEditingController(
                                  text: invoice.discountAmount.toString()),
                              label: "Amount",
                              onChanged: (val) => ref
                                  .read(invoiceProvider.notifier)
                                  .updateDiscountAmount(val),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
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
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  void _saveInvoiceUI(BuildContext context, Invoice invoice) async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please fix errors")));
      return;
    }
    try {
      await saveInvoice(
        invoice: invoice,
        context: context,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invoice saved successfully")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving invoice: $e")),
        );
      }
    }
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

  Widget _buildDatePicker(BuildContext context, String label,
      DateTime? selectedDate, Function(DateTime) onDateSelected) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedDate != null
                  ? DateFormat('dd MMM yyyy').format(selectedDate)
                  : "Select Date",
              style: TextStyle(
                  color: selectedDate != null ? Colors.black : Colors.grey),
            ),
            const Icon(Icons.calendar_today, size: 20),
          ],
        ),
      ),
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
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              final searchController = TextEditingController();
              String searchQuery = '';
              
              // Sort clients: recent first (alphabetically for now, can be enhanced)
              final sortedClients = List<Client>.from(clients)
                ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
              
              // Filter clients based on search
              final filteredClients = searchQuery.isEmpty
                  ? sortedClients
                  : sortedClients.where((c) =>
                      c.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                      c.gstin.toLowerCase().contains(searchQuery.toLowerCase()) ||
                      c.address.toLowerCase().contains(searchQuery.toLowerCase())).toList();
              
              return Container(
                padding: const EdgeInsets.all(16),
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Select Client",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onChanged: (value) => setState(() => searchQuery = value),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: filteredClients.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
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
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final client = filteredClients[index];
                                final initial = client.name.isNotEmpty
                                    ? client.name[0].toUpperCase()
                                    : "?";
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                    child: Text(
                                      initial,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
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
                    )
                  ],
                ),
              );
            },
          );
        });
  }

  void _showTemplateSelector(BuildContext context) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (context) {
          // We need to fetch templates
          // Assuming provider is available globally
          return Consumer(builder: (context, ref, child) {
            final templates = ref.watch(itemTemplateListProvider);
            return Container(
              padding: const EdgeInsets.all(16),
              height: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Select Template",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: templates.isEmpty
                        ? const Center(child: Text("No templates found."))
                        : ListView.builder(
                            itemCount: templates.length,
                            itemBuilder: (context, index) {
                              final template = templates[index];
                              return ListTile(
                                title: Text(template.description),
                                subtitle: Text(
                                    "₹${template.amount} (GST: ${template.gstRate}%)"),
                                onTap: () {
                                  // Add Item
                                  ref.read(invoiceProvider.notifier).addItem(
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

                                  final notifier =
                                      ref.read(invoiceProvider.notifier);
                                  notifier.addItem(); // Adds empty

                                  // We need to wait for state update? Not if it's sync StateNotifier.
                                  // But `addItem` might be async? No normally sync.
                                  // However, reading back immediately might be stale if inside build? No we are in callback.
                                  // Let's TRY to perform updates.
                                  // Accessing `invoiceProvider` subsequent times should get updated state if using ref.read inside callback?
                                  // Actually `addItem` updates state. `ref.read` should get new state.
                                  final newItems =
                                      ref.read(invoiceProvider).items;
                                  final idx = newItems.length - 1;

                                  notifier.updateItemDescription(
                                      idx, template.description);
                                  notifier.updateItemAmount(
                                      idx, template.amount.toString());
                                  notifier.updateItemQuantity(
                                      idx, template.quantity.toString()); // NEW
                                  notifier.updateItemUnit(idx, template.unit);
                                  notifier.updateItemGstRate(
                                      idx, template.gstRate.toString());
                                  notifier.updateItemSac(idx, template.sacCode);
                                  notifier.updateItemCodeType(
                                      idx, template.codeType);

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
        });
  }

  Widget _buildInlineItemEditor(BuildContext context, int index, InvoiceItem item) {
    final notifier = ref.read(invoiceProvider.notifier);
    
    return StatefulBuilder(
      builder: (context, setState) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
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
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (val) => notifier.updateItemDescription(index, val),
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
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => notifier.updateItemQuantity(index, val),
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
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        ),
                        onChanged: (val) => notifier.updateItemUnit(index, val),
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
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          prefixText: "₹",
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => notifier.updateItemAmount(index, val),
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
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => notifier.updateItemGstRate(index, val),
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
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        ),
                        onChanged: (val) => notifier.updateItemSac(index, val),
                      ),
                    ),
                    const Spacer(),
                    
                    // Total
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
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
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
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

  void _editItemDialog(BuildContext context, int index, InvoiceItem item) {
    // Reusing the same UI logic but in a Dialog
    final descriptionCtrl = TextEditingController(text: item.description);
    final amountCtrl = TextEditingController(text: item.amount.toString());
    final qtyCtrl = TextEditingController(text: item.quantity.toString());
    final gstCtrl = TextEditingController(text: item.gstRate.toString());
    final unitCtrl = TextEditingController(text: item.unit);
    final sacCtrl = TextEditingController(text: item.sacCode);
    // String codeType = item.codeType; // Unused in this snippet but declared

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
                  // SAC Code
                  TextField(
                    controller: sacCtrl, // Add SAC
                    decoration: const InputDecoration(
                        labelText: "HSN/SAC Code",
                        border: OutlineInputBorder()),
                  ),
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
                      notifier.updateItemSac(index, sacCtrl.text);
                      Navigator.pop(context);
                    },
                    child: const Text("Update"))
              ],
            ),
          );
        });
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

  Widget _buildGstinField() {
    return StatefulBuilder(
      builder: (context, setState) {
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
                  color: validation.isValid ? Colors.green[600] : Colors.red[600],
                  fontSize: 12,
                ),
              ),
              onChanged: (val) {
                ref.read(invoiceProvider.notifier).updateReceiverGstin(val);
                // Auto-update state if GSTIN is valid
                if (validation.isValid && validation.stateName != null) {
                  receiverStateCtrl.text = validation.stateName!;
                  ref.read(invoiceProvider.notifier).updateReceiverState(validation.stateName!);
                }
                setState(() {});
              },
              validator: (val) {
                if (val != null && val.isNotEmpty && !GstUtils.isValidGstin(val)) {
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
