import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../models/invoice.dart';
import '../../models/client.dart';
import '../../providers/business_profile_provider.dart';
import '../../providers/client_provider.dart';
import '../../providers/invoice_repository_provider.dart';
import '../../utils/pdf_generator.dart';
import '../../utils/constants.dart';

class FluentInvoiceWizard extends ConsumerStatefulWidget {
  final Invoice? invoiceToEdit;
  const FluentInvoiceWizard({super.key, this.invoiceToEdit});

  @override
  ConsumerState<FluentInvoiceWizard> createState() =>
      _FluentInvoiceWizardState();
}

class _FluentInvoiceWizardState extends ConsumerState<FluentInvoiceWizard> {
  // Invoice Data State
  late String _invoiceNo;
  DateTime _invoiceDate = DateTime.now();
  DateTime? _dueDate;
  String _placeOfSupply = "";
  late String _paymentTerms;
  late String _comments;
  String _invoiceStyle = "Modern";

  // Client Data
  Receiver? _selectedClient;

  // Items
  List<InvoiceItem> _items = [];

  @override
  void initState() {
    super.initState();
    _invoiceNo = "";
    _items = [];
    _paymentTerms = "Due on Receipt";
    _comments = "Thanks for your business.";
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_invoiceNo.isEmpty) {
      _initializeData();
    }
  }

  void _initializeData() {
    if (widget.invoiceToEdit != null) {
      final inv = widget.invoiceToEdit!;
      _invoiceNo = inv.invoiceNo;
      _invoiceDate = inv.invoiceDate;
      _dueDate = inv.dueDate;
      _placeOfSupply = inv.placeOfSupply;
      _selectedClient = inv.receiver;
      _items = List.from(inv.items);
      _paymentTerms = inv.paymentTerms;
      _comments = inv.comments;
      _invoiceStyle = inv.style;
    } else {
      final profile = ref.read(businessProfileProvider);
      _invoiceNo =
          "${profile.invoiceSeries}${profile.invoiceSequence.toString().padLeft(3, '0')}";
      _items = [const InvoiceItem(description: "", amount: 0, gstRate: 18)];
      _paymentTerms = "Due on Receipt";
      _dueDate = DateTime.now().add(const Duration(days: 15));
      _comments = "Thanks for your business.";
      _invoiceStyle = "Modern"; // Default
    }
  }

  Invoice _buildCurrentInvoice() {
    final profile = ref.read(businessProfileProvider);
    return Invoice(
      id: widget.invoiceToEdit?.id, // Keep ID if editing
      invoiceNo: _invoiceNo,
      invoiceDate: _invoiceDate,
      dueDate: _dueDate,
      placeOfSupply: _placeOfSupply,
      paymentTerms: _paymentTerms,
      comments: _comments,
      style: _invoiceStyle,
      receiver: _selectedClient ?? const Receiver(),
      supplier: Supplier(
        name: profile.companyName,
        address: profile.address,
        gstin: profile.gstin,
        email: profile.email,
        phone: profile.phone,
        state: profile.state,
        pan: "", // Add if mapped
      ),
      items: _items,
      bankName: profile.bankName,
      accountNo: profile.accountNumber,
      ifscCode: profile.ifscCode,
      branch: profile.branchName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: PageHeader(
        title:
            Text(widget.invoiceToEdit == null ? 'New Invoice' : 'Edit Invoice'),
        commandBar: CommandBar(
          primaryItems: [
            CommandBarButton(
              icon: const Icon(FluentIcons.print),
              label: const Text("Preview PDF"),
              onPressed: _showPreviewDialog,
            ),
            CommandBarButton(
              icon: const Icon(FluentIcons.save),
              label: const Text("Save Invoice"),
              onPressed: _saveInvoice,
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
        const Divider(),
        const SizedBox(height: 20),
        _buildFooterSection(),
      ],
    );
  }

  // Renamed from _buildDetailsStep and removed ParametricScroll
  Widget _buildDetailsSection() {
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
              Text("Bill To",
                  style: FluentTheme.of(context).typography.subtitle),
              const SizedBox(height: 10),
              if (_selectedClient == null)
                Row(
                  children: [
                    Expanded(
                      child: AutoSuggestBox<String>(
                        placeholder: "Search Client Name...",
                        items: clients
                            .map((c) => AutoSuggestBoxItem<String>(
                                value: c.id,
                                label: c.name,
                                child: Text(c.name)))
                            .toList(),
                        onSelected: (item) {
                          final client =
                              clients.firstWhere((c) => c.id == item.value);
                          setState(() {
                            _selectedClient = Receiver(
                              name: client.name,
                              address: client.address,
                              gstin: client.gstin,
                              state: client.state,
                            );
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Button(
                      onPressed: _showAddClientDialog,
                      child: const Icon(FluentIcons.add),
                    )
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
                          Text(_selectedClient!.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                              icon: const Icon(FluentIcons.edit),
                              onPressed: () =>
                                  setState(() => _selectedClient = null))
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(_selectedClient!.address),
                      if (_selectedClient!.gstin.isNotEmpty)
                        Text("GSTIN: ${_selectedClient!.gstin}"),
                      if (_selectedClient!.state.isNotEmpty)
                        Text("State: ${_selectedClient!.state}"),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              InfoLabel(
                label: "Client Not Found?",
                child: const Text(
                    "You can create a one-time client by searching, or add a permanent client using the '+' button."),
              )
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
              Text("Invoice Details",
                  style: FluentTheme.of(context).typography.subtitle),
              const SizedBox(height: 10),
              InfoLabel(
                label: "Invoice Number",
                child: TextBox(
                  placeholder: "INV-001",
                  controller: TextEditingController(text: _invoiceNo)
                    ..selection =
                        TextSelection.collapsed(offset: _invoiceNo.length),
                  onChanged: (v) => _invoiceNo = v,
                ),
              ),
              const SizedBox(height: 10),
              InfoLabel(
                label: "Invoice Date",
                child: DatePicker(
                  selected: _invoiceDate,
                  onChanged: (v) => setState(() => _invoiceDate = v),
                ),
              ),
              const SizedBox(height: 10),
              InfoLabel(
                label: "Due Date",
                child: DatePicker(
                  selected: _dueDate ?? DateTime.now(),
                  onChanged: (v) => setState(() => _dueDate = v),
                ),
              ),
              const SizedBox(height: 10),
              InfoLabel(
                label: "Place of Supply",
                child: AutoSuggestBox<String>(
                  placeholder: "State Name",
                  controller: TextEditingController(text: _placeOfSupply),
                  items: IndianStates.states
                      .map(
                          (e) => AutoSuggestBoxItem<String>(value: e, label: e))
                      .toList(),
                  onSelected: (item) {
                    setState(() => _placeOfSupply = item.value ?? "");
                  },
                  onChanged: (text, reason) {
                    if (reason == TextChangedReason.userInput) {
                      _placeOfSupply = text;
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              InfoLabel(
                label: "Payment Terms",
                child: TextBox(
                  placeholder: "e.g. Due on Receipt",
                  controller: TextEditingController(text: _paymentTerms)
                    ..selection =
                        TextSelection.collapsed(offset: _paymentTerms.length),
                  onChanged: (v) => _paymentTerms = v,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Renamed from _buildItemsStep
  Widget _buildItemsSection() {
    final currency = NumberFormat.simpleCurrency(name: 'INR');

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
                  child: Text("Description",
                      style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(
                  flex: 1,
                  child: Text("HSN/SAC",
                      style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(
                  flex: 1,
                  child: Text("Qty",
                      style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(
                  flex: 2,
                  child: Text("Price",
                      style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(
                  flex: 1,
                  child: Text("GST",
                      style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(
                  flex: 2,
                  child: Text("Total",
                      style: TextStyle(fontWeight: FontWeight.bold))),
              SizedBox(width: 80), // Actions width to match row
            ],
          ),
        ),

        // List of Items (Using Column/Map instead of ListView for proper scrolling)
        if (_items.isEmpty)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text("No items added yet.",
                  style: TextStyle(color: Colors.grey.withValues(alpha: 0.8))),
            ),
          )
        else
          Column(
            children: _items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: Colors.grey.withValues(alpha: 0.2))),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child: Text(item.description.isEmpty
                            ? "(No description)"
                            : item.description)),
                    Expanded(
                        flex: 1,
                        child: Text(item.sacCode.isEmpty ? "-" : item.sacCode)),
                    Expanded(
                        flex: 1, child: Text("${item.quantity} ${item.unit}")),
                    Expanded(
                        flex: 2, child: Text(currency.format(item.amount))),
                    Expanded(flex: 1, child: Text("${item.gstRate}%")),
                    Expanded(
                        flex: 2,
                        child: Text(currency.format(item.totalAmount),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold))),
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
                            onPressed: () {
                              setState(() {
                                _items.removeAt(index);
                              });
                            },
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
                        currency.format(
                            _items.fold(0.0, (sum, i) => sum + i.netAmount))),
                    _buildSummaryRow(
                        "Total GST",
                        currency.format(_items.fold(
                            0.0,
                            (sum, i) =>
                                sum +
                                i.cgstAmount +
                                i.sgstAmount +
                                i.igstAmount))),
                    const Divider(),
                    _buildSummaryRow(
                        "Grand Total",
                        currency.format(
                            _items.fold(0.0, (sum, i) => sum + i.totalAmount)),
                        isBold: true),
                  ],
                ),
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
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
    String name = "";
    String address = "";
    String gstin = "";
    String state = "Karnataka"; // Default
    String email = "";
    String phone = "";

    await showDialog(
        context: context,
        builder: (dialogContext) {
          return ContentDialog(
            title: const Text("Add New Client"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InfoLabel(
                  label: "Client Name *",
                  child: TextBox(
                    placeholder: "Company or Person Name",
                    onChanged: (v) => name = v,
                  ),
                ),
                const SizedBox(height: 10),
                InfoLabel(
                  label: "Address",
                  child: TextBox(
                    placeholder: "Full Address",
                    onChanged: (v) => address = v,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: InfoLabel(
                        label: "GSTIN",
                        child: TextBox(
                          placeholder: "Optional",
                          onChanged: (v) => gstin = v,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InfoLabel(
                        label: "State",
                        child: AutoSuggestBox<String>(
                          placeholder: "e.g. Karnataka",
                          controller: TextEditingController(text: state),
                          items: IndianStates.states
                              .map((e) => AutoSuggestBoxItem<String>(
                                  value: e, label: e))
                              .toList(),
                          onSelected: (item) {
                            state = item.value ?? "";
                          },
                          onChanged: (text, reason) {
                            if (reason == TextChangedReason.userInput) {
                              state = text;
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: InfoLabel(
                        label: "Email",
                        child: TextBox(
                          placeholder: "billing@client.com",
                          onChanged: (v) => email = v,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InfoLabel(
                        label: "Phone",
                        child: TextBox(
                          placeholder: "Mobile / Landline",
                          onChanged: (v) => phone = v,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              Button(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.pop(dialogContext)),
              FilledButton(
                  child: const Text("Save Client"),
                  onPressed: () async {
                    if (name.isEmpty) return;
                    final context = this.context;

                    final newClient = Client(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: name,
                      address: address,
                      gstin: gstin,
                      state: state,
                      email: email,
                      phone: phone,
                    );

                    await ref
                        .read(clientRepositoryProvider)
                        .saveClient(newClient);

                    ref.invalidate(clientListProvider);

                    // Create Receiver for UI selection
                    final newReceiver = Receiver(
                      name: name,
                      address: address,
                      gstin: gstin,
                      state: state,
                      // Receiver doesn't have ID, email, phone
                    );

                    if (!context.mounted) return;

                    setState(() {
                      _selectedClient = newReceiver;
                    });
                    Navigator.pop(dialogContext);
                    displayInfoBar(context,
                        builder: (c, close) => InfoBar(
                            title: const Text("Success"),
                            content: const Text("Client added successfully"),
                            severity: InfoBarSeverity.success,
                            onClose: close));
                  }),
            ],
          );
        });
  }

  void _showItemDialog({InvoiceItem? item, int? index}) async {
    // Temp controllers
    String desc = item?.description ?? "";
    double qty = item?.quantity ?? 1;
    double price = item?.amount ?? 0;
    double discount = item?.discount ?? 0;
    double gst = item?.gstRate ?? 18;
    String unit = item?.unit ?? "Nos";
    String sacCode = item?.sacCode ?? "";

    await showDialog(
        context: context,
        builder: (context) {
          return ContentDialog(
            title: Text(item == null ? "Add Item" : "Edit Item"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InfoLabel(
                  label: "Description",
                  child: TextBox(
                    placeholder: "Item description",
                    controller: TextEditingController(text: desc),
                    onChanged: (v) => desc = v,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: InfoLabel(
                        label: "HSN/SAC Code",
                        child: TextBox(
                          placeholder: "e.g. 998311",
                          controller: TextEditingController(text: sacCode),
                          onChanged: (v) => sacCode = v,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InfoLabel(
                        label: "Unit",
                        child: TextBox(
                          placeholder: "Nos, Kg...",
                          controller: TextEditingController(text: unit),
                          onChanged: (v) => unit = v,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: InfoLabel(
                        label: "Quantity",
                        child: NumberBox<double>(
                          value: qty,
                          onChanged: (v) => qty = v ?? 1,
                          min: 0.1,
                          mode: SpinButtonPlacementMode.inline,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InfoLabel(
                        label: "Price",
                        child: NumberBox<double>(
                          value: price,
                          onChanged: (v) => price = v ?? 0,
                          mode: SpinButtonPlacementMode.inline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: InfoLabel(
                        label: "Discount",
                        child: NumberBox<double>(
                          value: discount,
                          onChanged: (v) => discount = v ?? 0,
                          mode: SpinButtonPlacementMode.inline,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InfoLabel(
                        label: "GST Rate",
                        child: ComboBox<double>(
                          value: gst,
                          items: [0.0, 5.0, 12.0, 18.0, 28.0]
                              .map((r) =>
                                  ComboBoxItem(value: r, child: Text("$r%")))
                              .toList(),
                          onChanged: (v) => gst = v ?? 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              Button(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.pop(context)),
              FilledButton(
                  child: const Text("Save"),
                  onPressed: () {
                    final newItem = InvoiceItem(
                      description: desc,
                      quantity: qty,
                      amount: price,
                      discount: discount,
                      gstRate: gst,
                      unit: unit,
                      sacCode: sacCode,
                    );

                    setState(() {
                      if (index != null) {
                        _items[index] = newItem;
                      } else {
                        _items.add(newItem);
                      }
                    });
                    Navigator.pop(context);
                  }),
            ],
          );
        });
  }

  Widget _buildFooterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Additional Notes",
            style: FluentTheme.of(context).typography.subtitle),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: InfoLabel(
                label: "Terms & Conditions / Comments",
                child: TextBox(
                  placeholder: "Thanks for your business.",
                  controller: TextEditingController(text: _comments),
                  onChanged: (v) => _comments = v,
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
                      value: _invoiceStyle,
                      items: ['Modern', 'Professional', 'Minimal']
                          .map((e) => ComboBoxItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _invoiceStyle = v);
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

  void _showPreviewDialog() {
    final invoice = _buildCurrentInvoice();
    final profile = ref.read(businessProfileProvider);

    showDialog(
      context: context,
      builder: (context) {
        return ContentDialog(
          constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 800),
          title: const Text("Invoice Preview"),
          content: PdfPreview(
            build: (format) => generateInvoicePdf(invoice, profile),
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
            FilledButton(
              child: const Text("Save & Close"),
              onPressed: () {
                Navigator.pop(context);
                _saveInvoice();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveInvoice() async {
    // Validation
    if (_selectedClient == null || _selectedClient!.name.isEmpty) {
      displayInfoBar(context, builder: (context, close) {
        return InfoBar(
            title: const Text("Required"),
            content: const Text("Please select a client"),
            severity: InfoBarSeverity.warning,
            onClose: close);
      });
      return;
    }
    if (_invoiceNo.isEmpty) {
      displayInfoBar(context, builder: (context, close) {
        return InfoBar(
            title: const Text("Required"),
            content: const Text("Invoice Number is required"),
            severity: InfoBarSeverity.warning,
            onClose: close);
      });
      return;
    }
    if (_items.isEmpty) {
      displayInfoBar(context, builder: (context, close) {
        return InfoBar(
            title: const Text("Required"),
            content: const Text("Please add at least one item"),
            severity: InfoBarSeverity.warning,
            onClose: close);
      });
      return;
    }

    final repository = ref.read(invoiceRepositoryProvider);
    final invoice = _buildCurrentInvoice();

    try {
      await repository.saveInvoice(invoice);
      final context = this.context;
      if (!context.mounted) return;

      displayInfoBar(context, builder: (context, close) {
        return InfoBar(
            title: const Text("Success"),
            content: const Text("Invoice Saved Successfully"),
            severity: InfoBarSeverity.success,
            onClose: close);
      });

      Navigator.pop(context); // Go back to dashboard/list
    } catch (e) {
      final context = this.context;
      if (!context.mounted) return;
      displayInfoBar(context, builder: (context, close) {
        return InfoBar(
            title: const Text("Error"),
            content: Text("Failed to save: $e"),
            severity: InfoBarSeverity.error,
            onClose: close);
      });
    }
  }
}
