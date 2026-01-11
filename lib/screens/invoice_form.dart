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
import '../providers/item_template_provider.dart'; // NEW import

import '../services/invoice_actions.dart'; // NEW Import

// Generates a unique ID

class InvoiceFormScreen extends ConsumerStatefulWidget {
  final Invoice? invoiceToEdit;
  const InvoiceFormScreen({super.key, this.invoiceToEdit});

  @override
  ConsumerState<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends ConsumerState<InvoiceFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _invoiceNoCtrl;
  late TextEditingController _posCtrl;
  late TextEditingController _receiverNameCtrl;
  late TextEditingController _receiverGstinCtrl;
  late TextEditingController _receiverStateCtrl;
  late TextEditingController _receiverAddressCtrl;
  late TextEditingController _paymentTermsCtrl; // NEW

  @override
  void initState() {
    super.initState();
    // Initialize with existing data or defaults
    // We defer provider reading to didChangeDependencies or postFrame if needed,
    // but here we can't read provider easily in initState without listen:false or deferred.
    // However, we need to sync controllers with the provider state initially.
    // AND listen to changes?
    // Problem: If we bind controllers to provider state, typing updates provider, which triggers rebuild, which re-inits controllers? No.
    // We only init once. But if external change happens (e.g. client selection), we must update controllers.

    _invoiceNoCtrl = TextEditingController(); // Will set text later
    _posCtrl = TextEditingController();
    _receiverNameCtrl = TextEditingController();
    _receiverGstinCtrl = TextEditingController();
    _receiverStateCtrl = TextEditingController();
    _receiverAddressCtrl = TextEditingController();
    _paymentTermsCtrl = TextEditingController(); // NEW

    if (widget.invoiceToEdit != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(invoiceProvider.notifier).setInvoice(widget.invoiceToEdit!);
        _syncControllers(ref.read(invoiceProvider));
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Sync for new invoice (defaults)
        _syncControllers(ref.read(invoiceProvider));
      });
    }
  }

  void _syncControllers(Invoice invoice) {
    if (_invoiceNoCtrl.text != invoice.invoiceNo) {
      _invoiceNoCtrl.text = invoice.invoiceNo;
    }
    if (_posCtrl.text != invoice.placeOfSupply) {
      _posCtrl.text = invoice.placeOfSupply;
    }
    if (_receiverNameCtrl.text != invoice.receiver.name) {
      _receiverNameCtrl.text = invoice.receiver.name;
    }
    if (_receiverGstinCtrl.text != invoice.receiver.gstin) {
      _receiverGstinCtrl.text = invoice.receiver.gstin;
    }
    if (_receiverStateCtrl.text != invoice.receiver.state) {
      _receiverStateCtrl.text = invoice.receiver.state;
    }
    if (_receiverAddressCtrl.text != invoice.receiver.address) {
      _receiverAddressCtrl.text = invoice.receiver.address;
    }
    if (_paymentTermsCtrl.text != invoice.paymentTerms) {
      _paymentTermsCtrl.text = invoice.paymentTerms; // NEW
    }
  }

  // We need to listen to provider changes to update controllers when Client is selected
  // But standard ref.watch rebuilds the widget. If we re-set text every build, cursor jumps.
  // Exception: ref.listen allows side effects without rebuild.

  @override
  void dispose() {
    _invoiceNoCtrl.dispose();
    _posCtrl.dispose();
    _receiverNameCtrl.dispose();
    _receiverGstinCtrl.dispose();
    _receiverStateCtrl.dispose();
    _receiverAddressCtrl.dispose();
    _paymentTermsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invoice = ref.watch(invoiceProvider);
    final profile = ref.watch(businessProfileProvider);
    final theme = Theme.of(context);
    final clients = ref.watch(clientListProvider);

    // Listen for external changes (like client selection overrides)
    ref.listen<Invoice>(invoiceProvider, (prev, next) {
      // Only update controller if value is significantly different and not currently being edited?
      // Or just assume `updateReceiver` methods are called explicitly.
      // Actually, if we type in generic field, we call `update...`.
      // If we update controller in listener, we risk loop.
      // Better: When we select client, we explicitely update controllers in that callback, NOT via listener.
    });

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
                        child: _buildTextField(
                          controller: _invoiceNoCtrl,
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
                        child: _buildTextField(
                            controller: _posCtrl,
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
                  _buildTextField(
                    controller: _paymentTermsCtrl,
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
                  _buildTextField(
                    controller: _receiverNameCtrl,
                    label: "Client Name",
                    onChanged: (val) => ref
                        .read(invoiceProvider.notifier)
                        .updateReceiverName(val),
                    validator: (val) =>
                        val == null || val.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _receiverGstinCtrl,
                          label: "GSTIN",
                          onChanged: (val) => ref
                              .read(invoiceProvider.notifier)
                              .updateReceiverGstin(val),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _receiverStateCtrl,
                          label: "State",
                          onChanged: (val) => ref
                              .read(invoiceProvider.notifier)
                              .updateReceiverState(val),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                      controller: _receiverAddressCtrl,
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
                            child: _buildTextField(
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

  Widget _buildTextField(
      {required String label,
      required TextEditingController controller,
      required Function(String) onChanged,
      String? Function(String?)? validator,
      int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        isDense: true,
      ),
      validator: validator,
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
                                // Populate Fields
                                final notifier =
                                    ref.read(invoiceProvider.notifier);
                                notifier.updateReceiverName(client.name);
                                notifier.updateReceiverGstin(client.gstin);
                                notifier.updateReceiverState(client.state);
                                notifier.updateReceiverAddress(client.address);

                                // Explicitly update controllers
                                _receiverNameCtrl.text = client.name;
                                _receiverGstinCtrl.text = client.gstin;
                                _receiverStateCtrl.text = client.state;
                                _receiverAddressCtrl.text = client.address;

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
                                  // Let's check InvoiceNotifier later. For now, let's try to update.
                                  // Actually, `addItem` adds a blank item at the end.
                                  // So we can do:
                                  /*
                                  ref.read(invoiceProvider.notifier).addItem();
                                  final items = ref.read(invoiceProvider).items;
                                  final lastIndex = items.length - 1;
                                  ref.read(invoiceProvider.notifier).updateItemDescription(lastIndex, template.description);
                                  ...
                                  */
                                  // Better: Create a `addFromTemplate` method in notifier.
                                  // I'll assume I update notifier later.
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
                    child: const Text("Update"))
              ],
            ),
          );
        });
  }

  Future<void> _saveInvoice(
      BuildContext context, WidgetRef ref, Invoice invoice) async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please fix errors")));
      return;
    }

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
