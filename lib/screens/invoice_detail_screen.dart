import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../models/invoice.dart';
import '../models/payment_transaction.dart';
import '../models/recurring_profile.dart'; // New
import '../providers/invoice_repository_provider.dart';
import '../providers/recurring_provider.dart'; // New
import '../providers/business_profile_provider.dart'; // New
import 'package:url_launcher/url_launcher.dart'; // New
import 'package:printing/printing.dart';

import 'windows/fluent_invoice_wizard.dart';
import '../utils/pdf_generator.dart';

class InvoiceDetailScreen extends ConsumerStatefulWidget {
  final Invoice invoice;

  const InvoiceDetailScreen({super.key, required this.invoice});

  @override
  ConsumerState<InvoiceDetailScreen> createState() =>
      _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends ConsumerState<InvoiceDetailScreen> {
  late Invoice _invoice;

  @override
  void initState() {
    super.initState();
    _invoice = widget.invoice;
  }

  void _refreshInvoice() async {
    // Reload invoice from repo to get latest state
    final inv =
        await ref.read(invoiceRepositoryProvider).getInvoice(_invoice.id!);
    if (inv != null && mounted) {
      setState(() {
        _invoice = inv;
      });
    }
  }

  void _recordPayment() async {
    final payment = await showDialog<PaymentTransaction>(
      context: context,
      builder: (ctx) => _PaymentDialog(
          invoiceId: _invoice.id!, balanceDue: _invoice.balanceDue),
    );

    if (payment != null) {
      final updatedInvoice = _invoice.copyWith(
        payments: [..._invoice.payments, payment],
      );
      await ref.read(invoiceRepositoryProvider).saveInvoice(updatedInvoice);
      _refreshInvoice();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Payment Recorded")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency =
        NumberFormat.simpleCurrency(name: _invoice.currency, decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: Text(_invoice.invoiceNo.isEmpty
            ? "Invoice Details"
            : _invoice.invoiceNo),
        actions: [
          IconButton(
            icon: const Icon(Icons.email),
            tooltip: "Email Client",
            onPressed: () async {
              final email = _invoice.receiver.email;
              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Client has no email")));
                return;
              }

              final Uri emailLaunchUri = Uri(
                scheme: 'mailto',
                path: email,
                query:
                    'subject=Invoice ${_invoice.invoiceNo}&body=Dear ${_invoice.receiver.name},\n\nPlease find attached invoice ${_invoice.invoiceNo}.\n\nRegards,\n${_invoice.supplier.name}',
              );

              if (await canLaunchUrl(emailLaunchUri)) {
                await launchUrl(emailLaunchUri);
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Could not launch email client")));
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        FluentInvoiceWizard(invoiceToEdit: _invoice)),
              );
              _refreshInvoice();
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: "Share",
            onPressed: () async {
              final profile = ref.read(businessProfileProvider);
              final bytes = await generateInvoicePdf(_invoice, profile);
              await Printing.sharePdf(
                  bytes: bytes, filename: 'invoice_${_invoice.invoiceNo}.pdf');
            },
          ),
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'recurring') _setupRecurring();
              if (val == 'archive') _toggleArchive();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'recurring', child: Text("Make Recurring")),
              PopupMenuItem(
                  value: 'archive',
                  child: Text(
                      _invoice.isArchived ? "Unarchive" : "Archive Invoice")),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Amount", style: theme.textTheme.bodyMedium),
                    Text(currency.format(_invoice.grandTotal),
                        style: theme.textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                _buildStatusBadge(_invoice.paymentStatus),
              ],
            ),
            const SizedBox(height: 24),

            // Client Info
            Text("Billed To",
                style:
                    theme.textTheme.titleMedium?.copyWith(color: Colors.grey)),
            const SizedBox(height: 4),
            Text(_invoice.receiver.name, style: theme.textTheme.titleLarge),
            Text(_invoice.receiver.address),
            if (_invoice.receiver.gstin.isNotEmpty)
              Text("GSTIN: ${_invoice.receiver.gstin}"),

            const SizedBox(height: 24),

            // Items
            Text("Items",
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _invoice.items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = _invoice.items[index];
                  return ListTile(
                    title: Text(item.description),
                    subtitle: Text("${item.quantity} x ${item.amount}"),
                    trailing: Text(currency.format(item.totalAmount)),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Payments Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Payments",
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                if (_invoice.balanceDue > 0.1)
                  OutlinedButton.icon(
                    onPressed: _recordPayment,
                    icon: const Icon(Icons.add),
                    label: const Text("Record Payment"),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _invoice.payments.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: Text("No payments recorded yet")))
                : Card(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _invoice.payments.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final p = _invoice.payments[index];
                        return ListTile(
                          leading:
                              const Icon(Icons.payment, color: Colors.green),
                          title: Text(currency.format(p.amount)),
                          subtitle: Text(
                              "${DateFormat('dd MMM yyyy').format(p.date)} • ${p.paymentMode}"),
                        );
                      },
                    ),
                  ),

            const SizedBox(height: 16),
            // Balance Due
            if (_invoice.balanceDue > 0)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Balance Due",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.red)),
                    Text(currency.format(_invoice.balanceDue),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                            fontSize: 18)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'Paid':
        color = Colors.green;
        break;
      case 'Partial':
        color = Colors.orange;
        break;
      case 'Overdue':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(status,
          style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }

  void _setupRecurring() async {
    final activeProfileId = ref.read(activeProfileIdProvider);
    if (activeProfileId.isEmpty) return;

    RecurringInterval interval = RecurringInterval.monthly;
    DateTime startDate = DateTime.now().add(const Duration(days: 30));

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Setup Recurring Invoice"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<RecurringInterval>(
                key: ValueKey(interval),
                initialValue: interval,
                decoration: const InputDecoration(labelText: "Interval"),
                items: RecurringInterval.values
                    .map((e) => DropdownMenuItem(
                        value: e, child: Text(e.name.toUpperCase())))
                    .toList(),
                onChanged: (val) => setState(() => interval = val!),
              ),
              const SizedBox(height: 16),
              InputDecorator(
                decoration: const InputDecoration(labelText: "Next Run Date"),
                child: InkWell(
                  onTap: () async {
                    final d = await showDatePicker(
                        context: context,
                        initialDate: startDate,
                        firstDate: DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365 * 2)));
                    if (d != null) setState(() => startDate = d);
                  },
                  child: Text(DateFormat('dd MMM yyyy').format(startDate)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Cancel")),
            ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text("Save")),
          ],
        ),
      ),
    );

    if (result == true) {
      final base = _invoice.copyWith(
          payments: [],
          id: null,
          invoiceNo: '',
          invoiceDate: DateTime.now()); // Template
      final profile = RecurringProfile(
        id: const Uuid().v4(),
        profileId: activeProfileId,
        interval: interval,
        nextRunDate: startDate,
        baseInvoice: base,
      );

      await ref.read(recurringListProvider.notifier).addProfile(profile);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Recurring Profile Created")));
      }
    }
  }

  void _toggleArchive() async {
    final updated = _invoice.copyWith(isArchived: !_invoice.isArchived);
    await ref.read(invoiceRepositoryProvider).saveInvoice(updated);
    _refreshInvoice();
    ref.invalidate(invoiceListProvider); // Refresh list
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_invoice.isArchived
              ? "Invoice Unarchived"
              : "Invoice Archived")));
    }
  }
}

class _PaymentDialog extends StatefulWidget {
  final String invoiceId;
  final double balanceDue;

  const _PaymentDialog({required this.invoiceId, required this.balanceDue});

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _mode = 'Cash';
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _amountCtrl.text = widget.balanceDue.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Record Payment"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _amountCtrl,
              decoration:
                  const InputDecoration(labelText: "Amount", prefixText: "₹"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: ValueKey(_mode),
              initialValue: _mode,
              decoration: const InputDecoration(labelText: "Payment Mode"),
              items: ['Cash', 'UPI', 'Bank Transfer', 'Cheque']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => _mode = val!),
            ),
            const SizedBox(height: 16),
            InputDecorator(
              decoration: const InputDecoration(labelText: "Date"),
              child: InkWell(
                onTap: () async {
                  final d = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now());
                  if (d != null) setState(() => _date = d);
                },
                child: Text(DateFormat('dd/MM/yyyy').format(_date)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
                controller: _notesCtrl,
                decoration:
                    const InputDecoration(labelText: "Notes (Optional)")),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel")),
        ElevatedButton(
            onPressed: () {
              final amt = double.tryParse(_amountCtrl.text);
              if (amt == null || amt <= 0) return;

              final payment = PaymentTransaction(
                id: const Uuid().v4(),
                invoiceId: widget.invoiceId,
                date: _date,
                amount: amt,
                paymentMode: _mode,
                notes: _notesCtrl.text,
              );
              Navigator.pop(context, payment);
            },
            child: const Text("Save")),
      ],
    );
  }
}
