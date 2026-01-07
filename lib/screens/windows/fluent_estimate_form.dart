import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:uuid/uuid.dart';

import '../../models/estimate.dart';
import '../../models/invoice.dart';
import '../../providers/business_profile_provider.dart';
import '../../providers/estimate_provider.dart';
import '../../providers/invoice_repository_provider.dart';
import '../../utils/constants.dart';

class FluentEstimateForm extends ConsumerStatefulWidget {
  final String? estimateId;

  const FluentEstimateForm({super.key, this.estimateId});

  @override
  ConsumerState<FluentEstimateForm> createState() => _FluentEstimateFormState();
}

class _FluentEstimateFormState extends ConsumerState<FluentEstimateForm> {
  late DateTime _date;
  late DateTime? _expiryDate;
  late TextEditingController _estimateNoController;
  late TextEditingController _notesController;
  late TextEditingController _termsController;

  final _receiverNameController = TextEditingController();
  final _receiverAddressController = TextEditingController();
  final _receiverGstinController = TextEditingController();
  final _receiverStateController = TextEditingController();

  // For state autocomplete
  final TextEditingController _stateAutoSuggestController =
      TextEditingController();

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

  @override
  void dispose() {
    _estimateNoController.dispose();
    _notesController.dispose();
    _termsController.dispose();
    _receiverNameController.dispose();
    _receiverAddressController.dispose();
    _receiverGstinController.dispose();
    _receiverStateController.dispose();
    _stateAutoSuggestController.dispose();
    super.dispose();
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
        _stateAutoSuggestController.text = _existingEstimate!.receiver.state;

        _items = List.from(_existingEstimate!.items);
      } catch (e) {
        // Handle not found
      }
    }
    if (mounted) setState(() {});
  }

  void _saveEstimate() async {
    // Fluent TextFormBox doesn't have same validator form key logic easily,
    // but we can check basics manually.
    if (_items.isEmpty) {
      displayInfoBar(context, builder: (context, close) {
        return InfoBar(
          title: const Text("Validation Error"),
          content: const Text("Please add at least one item."),
          severity: InfoBarSeverity.warning,
          onClose: close,
        );
      });
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
      state: _stateAutoSuggestController.text.isNotEmpty
          ? _stateAutoSuggestController.text
          : _receiverStateController.text,
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

    final profile = ref.read(businessProfileProvider);
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

    final updatedEstimate = _existingEstimate!.copyWith(status: 'Converted');
    await ref.read(estimateListProvider.notifier).saveEstimate(updatedEstimate);
    await ref.read(businessProfileNotifierProvider).incrementInvoiceSequence();

    if (mounted) {
      displayInfoBar(context, builder: (context, close) {
        return InfoBar(
          title: const Text("Success"),
          content: Text('Converted to Invoice $invoiceNo'),
          severity: InfoBarSeverity.success,
          onClose: close,
        );
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: PageHeader(
        title:
            Text(widget.estimateId == null ? "New Estimate" : "Edit Estimate"),
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: IconButton(
            icon: const Icon(FluentIcons.back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        commandBar: CommandBar(
          primaryItems: [
            if (_existingEstimate != null &&
                _existingEstimate!.status != 'Converted')
              CommandBarButton(
                icon: const Icon(FluentIcons.switch_widget),
                label: const Text("Convert to Invoice"),
                onPressed: _convertToInvoice,
              ),
            CommandBarButton(
              icon: const Icon(FluentIcons.save),
              label: const Text("Save"),
              onPressed: _saveEstimate,
            ),
          ],
        ),
      ),
      children: [
        Expander(
          header: const Text("Details",
              style: TextStyle(fontWeight: FontWeight.bold)),
          initiallyExpanded: true,
          content: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: InfoLabel(
                      label: "Estimate No",
                      child: TextFormBox(
                        controller: _estimateNoController,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InfoLabel(
                      label: "Date",
                      child: DatePicker(
                        selected: _date,
                        onChanged: (d) => setState(() => _date = d),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              InfoLabel(
                label: "Client Name",
                child: TextFormBox(controller: _receiverNameController),
              ),
              const SizedBox(height: 10),
              InfoLabel(
                label: "Address",
                child: TextFormBox(controller: _receiverAddressController),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: InfoLabel(
                      label: "GSTIN",
                      child: TextFormBox(controller: _receiverGstinController),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InfoLabel(
                      label: "State",
                      child: AutoSuggestBox<String>(
                        controller: _stateAutoSuggestController,
                        items: IndianStates.states
                            .map((e) =>
                                AutoSuggestBoxItem<String>(value: e, label: e))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expander(
          header: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Items",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Button(
                onPressed: _addItem,
                child: const Text("+ Add"),
              )
            ],
          ),
          initiallyExpanded: true,
          content: Column(
            children: [
              if (_items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("No items added"),
                ),
              ..._items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Card(
                    child: ListTile(
                      title: Text(item.description.isEmpty
                          ? "Item ${index + 1}"
                          : item.description),
                      subtitle: Text(
                          "${item.quantity} x ${item.amount} = ${item.netAmount}"),
                      trailing: IconButton(
                        icon: Icon(FluentIcons.delete, color: Colors.red),
                        onPressed: () => _removeItem(index),
                      ),
                      onPressed: () => _editItem(index),
                    ),
                  ),
                );
              }),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                        "Total: ₹${_items.fold(0.0, (sum, i) => sum + i.totalAmount).toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expander(
          header: const Text("Additional Info",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            children: [
              InfoLabel(
                label: "Notes",
                child: TextFormBox(controller: _notesController, maxLines: 3),
              ),
              const SizedBox(height: 10),
              InfoLabel(
                label: "Terms",
                child: TextFormBox(controller: _termsController, maxLines: 3),
              ),
            ],
          ),
        )
      ],
    );
  }

  void _addItem() async {
    final newItem = await showDialog<InvoiceItem>(
      context: context,
      builder: (context) => const _FluentItemEditDialog(),
    );
    if (newItem != null) {
      setState(() => _items.add(newItem));
    }
  }

  void _editItem(int index) async {
    final newItem = await showDialog<InvoiceItem>(
      context: context,
      builder: (context) => _FluentItemEditDialog(item: _items[index]),
    );
    if (newItem != null) {
      setState(() => _items[index] = newItem);
    }
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
  }
}

class _FluentItemEditDialog extends StatefulWidget {
  final InvoiceItem? item;
  const _FluentItemEditDialog({this.item});

  @override
  State<_FluentItemEditDialog> createState() => _FluentItemEditDialogState();
}

class _FluentItemEditDialogState extends State<_FluentItemEditDialog> {
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
  void dispose() {
    _descCtrl.dispose();
    _qtyCtrl.dispose();
    _rateCtrl.dispose();
    _gstCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text("Edit Item"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoLabel(
              label: "Description", child: TextFormBox(controller: _descCtrl)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: InfoLabel(
                      label: "Qty", child: TextFormBox(controller: _qtyCtrl))),
              const SizedBox(width: 8),
              Expanded(
                  child: InfoLabel(
                      label: "Rate",
                      child: TextFormBox(controller: _rateCtrl))),
              const SizedBox(width: 8),
              Expanded(
                  child: InfoLabel(
                      label: "GST %",
                      child: TextFormBox(controller: _gstCtrl))),
            ],
          )
        ],
      ),
      actions: [
        Button(
          child: const Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          child: const Text("Save"),
          onPressed: () {
            final item = InvoiceItem(
              description: _descCtrl.text,
              quantity: double.tryParse(_qtyCtrl.text) ?? 1,
              amount: double.tryParse(_rateCtrl.text) ?? 0,
              gstRate: double.tryParse(_gstCtrl.text) ?? 0,
            );
            Navigator.pop(context, item);
          },
        ),
      ],
    );
  }
}
