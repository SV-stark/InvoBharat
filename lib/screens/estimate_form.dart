import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../models/estimate.dart';
import '../models/invoice.dart'; // For Supplier/Receiver/InvoiceItem reuse
import '../providers/business_profile_provider.dart';
import '../providers/estimate_provider.dart';
import '../providers/invoice_repository_provider.dart'; // For converting to invoice
// WARNING: item_list_editor might not exist or needs verification.
// Glancing at file list: screens/invoice_form.dart exists. Components likely inside it or widgets folder.
// I will implement a simplified embedded form logic here similar to invoice_form.dart if I don't see reusable widgets.
// Based on file list, `widgets` has 3 children. Let's assume standard logic for now and replicate if needed.

// We need to check if there are reusable widgets for Client/Items.
// Assuming we copy logic from InvoiceForm for now to be safe, but adapted for Estimates.

class EstimateForm extends ConsumerStatefulWidget {
  final String? estimateId;

  const EstimateForm({super.key, this.estimateId});

  @override
  ConsumerState<EstimateForm> createState() => _EstimateFormState();
}

class _EstimateFormState extends ConsumerState<EstimateForm> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _date;
  late DateTime? _expiryDate;
  late TextEditingController _estimateNoController;
  late TextEditingController _notesController;
  late TextEditingController _termsController;

  // Receiver Details
  final _receiverNameController = TextEditingController();
  final _receiverAddressController = TextEditingController();
  final _receiverGstinController = TextEditingController();
  final _receiverStateController = TextEditingController();

  List<InvoiceItem> _items = [];

  bool _isInit = true;
  Estimate? _existingEstimate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _initializeData();
      _isInit = false;
    }
  }

  Future<void> _initializeData() async {
    final profile = ref.read(businessProfileProvider);
    _date = DateTime.now();
    _expiryDate = DateTime.now().add(const Duration(days: 30));
    _estimateNoController = TextEditingController(
        text:
            'EST-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}');
    _notesController = TextEditingController(text: profile.defaultNotes);
    _termsController = TextEditingController(text: profile.termsAndConditions);

    if (widget.estimateId != null) {
      final estimates = await ref.read(estimateListProvider.future);
      try {
        _existingEstimate =
            estimates.firstWhere((e) => e.id == widget.estimateId);
        _date = _existingEstimate!.date;
        _expiryDate = _existingEstimate!.expiryDate;
        _estimateNoController.text = _existingEstimate!.estimateNo;
        _notesController.text = _existingEstimate!.notes;
        _termsController.text = _existingEstimate!.terms;

        _receiverNameController.text = _existingEstimate!.receiver.name;
        _receiverAddressController.text = _existingEstimate!.receiver.address;
        _receiverGstinController.text = _existingEstimate!.receiver.gstin;
        _receiverStateController.text = _existingEstimate!.receiver.state;

        _items = List.from(_existingEstimate!.items);
      } catch (e) {
        // Handle not found
      }
    }
    if (mounted) setState(() {});
  }

  void _saveEstimate() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Add at least one item')));
      return;
    }

    final profile = ref.read(businessProfileProvider);

    final supplier = Supplier(
      name: profile.companyName,
      address: profile.address,
      gstin: profile.gstin,
      email: profile.email,
      phone: profile.phone,
      state: profile.state,
    );

    final receiver = Receiver(
      name: _receiverNameController.text,
      address: _receiverAddressController.text,
      gstin: _receiverGstinController.text,
      state: _receiverStateController.text,
    );

    final newEstimate = Estimate(
      id: _existingEstimate?.id ?? const Uuid().v4(),
      estimateNo: _estimateNoController.text,
      date: _date,
      expiryDate: _expiryDate,
      supplier: supplier,
      receiver: receiver,
      items: _items,
      notes: _notesController.text,
      terms: _termsController.text,
      status: _existingEstimate?.status ?? 'Draft',
    );

    await ref.read(estimateListProvider.notifier).saveEstimate(newEstimate);
    if (mounted) Navigator.pop(context);
  }

  void _convertToInvoice() async {
    if (_existingEstimate == null) return;

    // Create Invoice from Estimate
    final profile = ref.read(businessProfileProvider);

    // Auto-generate invoice number (simple logic for now)
    final invoiceNo = '${profile.invoiceSeries}${profile.invoiceSequence}';

    final newInvoice = Invoice(
      id: const Uuid().v4(),
      style: 'Modern',
      supplier: _existingEstimate!.supplier,
      receiver: _existingEstimate!.receiver,
      invoiceNo: invoiceNo,
      invoiceDate: DateTime.now(),
      placeOfSupply: _existingEstimate!.receiver.state,
      items: _existingEstimate!.items,
      comments: _existingEstimate!.notes,
      bankName: profile.bankName,
      accountNo: profile.accountNumber,
      ifscCode: profile.ifscCode,
      branch: profile.branchName,
    );

    await ref.read(invoiceRepositoryProvider).saveInvoice(newInvoice);

    // Update Estimate Status
    final updatedEstimate = _existingEstimate!.copyWith(status: 'Converted');
    await ref.read(estimateListProvider.notifier).saveEstimate(updatedEstimate);

    // Increment sequence
    await ref.read(businessProfileNotifierProvider).incrementInvoiceSequence();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Converted to Invoice $invoiceNo')));
      Navigator.pop(context);
    }
  }

  // --- UI Helpers (Simplified for brevity, would ideally refactor `invoice_form.dart` to share these widgets) ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.estimateId == null ? "New Estimate" : "Edit Estimate"),
        actions: [
          if (_existingEstimate != null &&
              _existingEstimate!.status != 'Converted')
            TextButton.icon(
              onPressed: _convertToInvoice,
              icon: const Icon(Icons.transform, color: Colors.white),
              label: const Text("Convert to Invoice",
                  style: TextStyle(color: Colors.white)),
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveEstimate,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header info
              Row(
                children: [
                  Expanded(
                      child: _buildTextField(
                          "Estimate No", _estimateNoController)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildDatePicker(
                          "Date", _date, (d) => setState(() => _date = d))),
                ],
              ),
              const SizedBox(height: 16),
              // Receiver
              const Text("Client Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildTextField("Client Name", _receiverNameController),
              _buildTextField("Address", _receiverAddressController),
              Row(
                children: [
                  Expanded(
                      child:
                          _buildTextField("GSTIN", _receiverGstinController)),
                  const SizedBox(width: 16),
                  Expanded(
                      child:
                          _buildTextField("State", _receiverStateController)),
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
              ..._items.asMap().entries.map((entry) {
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
              _buildTextField("Notes", _notesController, maxLines: 2),
              _buildTextField("Terms", _termsController, maxLines: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
            labelText: label, border: const OutlineInputBorder()),
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildDatePicker(
      String label, DateTime date, Function(DateTime) onSelect) {
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
    // Show simple dialog to add item
    // In real app, reuse item editor widget
    final newItem = await showDialog<InvoiceItem>(
      context: context,
      builder: (ctx) => const _ItemEditDialog(),
    );
    if (newItem != null) {
      setState(() => _items.add(newItem));
    }
  }

  void _editItem(int index) async {
    final newItem = await showDialog<InvoiceItem>(
      context: context,
      builder: (ctx) => _ItemEditDialog(item: _items[index]),
    );
    if (newItem != null) {
      setState(() => _items[index] = newItem);
    }
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
  }

  Widget _buildSummary() {
    double total = _items.fold(0, (sum, item) => sum + item.totalAmount);
    return Align(
        alignment: Alignment.centerRight,
        child: Text("Total: ₹${total.toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)));
  }
}

// Simple Dialog for Item Edit (Quick & Dirty)
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
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Item"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: "Description")),
          TextField(
              controller: _qtyCtrl,
              decoration: const InputDecoration(labelText: "Quantity"),
              keyboardType: TextInputType.number),
          TextField(
              controller: _rateCtrl,
              decoration: const InputDecoration(labelText: "Rate"),
              keyboardType: TextInputType.number),
          TextField(
              controller: _gstCtrl,
              decoration: const InputDecoration(labelText: "GST %"),
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
