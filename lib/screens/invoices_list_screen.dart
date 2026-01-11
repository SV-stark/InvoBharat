import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/invoice_repository_provider.dart';
// import '../models/invoice.dart'; // Removed unused import
import 'invoice_detail_screen.dart';
import 'invoice_form.dart';

class InvoicesListScreen extends ConsumerStatefulWidget {
  const InvoicesListScreen({super.key});

  @override
  ConsumerState<InvoicesListScreen> createState() => _InvoicesListScreenState();
}

class _InvoicesListScreenState extends ConsumerState<InvoicesListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _filter = 'All'; // All, Unpaid, Paid (Derived)
  DateTimeRange? _dateRange;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invoiceListAsync = ref.watch(invoiceListProvider);
    final theme = Theme.of(context);

    // Derived Logic for Paid/Unpaid relies on `paymentStatus` getter in Invoice model
    // which checks totalPaid >= grandTotal.

    return Scaffold(
      appBar: AppBar(
        title: const Text("Invoices"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                        hintText: "Search Client / Invoice #",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 16)),
                    onChanged: (val) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.filter_list,
                      color: _dateRange != null || _filter != 'All'
                          ? theme.primaryColor
                          : null),
                  onPressed: _showFilterDialog,
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const InvoiceFormScreen()))
            .then((_) => ref.refresh(invoiceListProvider)),
        child: const Icon(Icons.add),
      ),
      body: invoiceListAsync.when(
        data: (invoices) {
          // Filter Logic
          final filtered = invoices.where((inv) {
            // Search
            final query = _searchCtrl.text.toLowerCase();
            final matchesSearch = query.isEmpty ||
                inv.receiver.name.toLowerCase().contains(query) ||
                inv.invoiceNo.toLowerCase().contains(query);

            if (!matchesSearch) return false;

            // Date Range
            if (_dateRange != null) {
              if (inv.invoiceDate.isBefore(_dateRange!.start) ||
                  inv.invoiceDate
                      .isAfter(_dateRange!.end.add(const Duration(days: 1)))) {
                return false;
              }
            }

            // Archive Filter
            if (_filter == 'Archived') {
              if (!inv.isArchived) return false;
            } else {
              // For All, Paid, Unpaid -> Only show Active (unarchived)
              if (inv.isArchived) return false;

              if (_filter == 'Paid') {
                if (inv.paymentStatus != 'Paid') return false;
              } else if (_filter == 'Unpaid') {
                if (inv.paymentStatus == 'Paid') {
                  return false; // Show Pending/Partial
                }
              }
            }

            return true;
          }).toList();

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text("No invoices found", style: theme.textTheme.titleMedium),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final invoice = filtered[index];
              return Dismissible(
                key: Key(invoice.id!),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Delete Invoice?"),
                      content: Text(
                          "Are you sure you want to delete ${invoice.invoiceNo}?"),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text("Cancel")),
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text("Delete",
                                style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) async {
                  await ref
                      .read(invoiceRepositoryProvider)
                      .deleteInvoice(invoice.id!);
                  ref.invalidate(invoiceListProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Invoice deleted")));
                  }
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child:
                      const Icon(Icons.delete, color: Colors.white, size: 30),
                ),
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InvoiceDetailScreen(invoice: invoice),
                        ),
                      ).then((_) => ref.refresh(invoiceListProvider));
                    },
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.5),
                      child: const Icon(Icons.description_outlined),
                    ),
                    title: Text(
                      invoice.receiver.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "${invoice.invoiceNo} • ${DateFormat('dd MMM yyyy').format(invoice.invoiceDate)}"),
                        if (invoice.dueDate != null)
                          Text(
                            "Due: ${DateFormat('dd MMM').format(invoice.dueDate!)}",
                            style: TextStyle(
                                fontSize: 11,
                                color:
                                    invoice.dueDate!.isBefore(DateTime.now()) &&
                                            invoice.paymentStatus != 'Paid'
                                        ? Colors.red
                                        : Colors.grey),
                          )
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "₹${invoice.grandTotal.toStringAsFixed(2)}",
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        _buildStatusBadge(invoice.paymentStatus),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Filters"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                      key: ValueKey(_filter),
                      initialValue: _filter,
                      decoration: const InputDecoration(labelText: "Status"),
                      items: const [
                        DropdownMenuItem(
                            value: 'All', child: Text("All Active")),
                        DropdownMenuItem(value: 'Paid', child: Text("Paid")),
                        DropdownMenuItem(
                            value: 'Unpaid', child: Text("Unpaid")),
                        DropdownMenuItem(
                            value: 'Archived', child: Text("Archived")),
                      ],
                      onChanged: (val) {
                        setDialogState(() => _filter = val!);
                      }),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text("Date Range"),
                    subtitle: Text(_dateRange == null
                        ? "All Time"
                        : "${DateFormat('dd/MM').format(_dateRange!.start)} - ${DateFormat('dd/MM').format(_dateRange!.end)}"),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                          initialDateRange: _dateRange);
                      if (picked != null) {
                        setDialogState(() => _dateRange = picked);
                      }
                    },
                  ),
                  if (_dateRange != null)
                    TextButton(
                        onPressed: () =>
                            setDialogState(() => _dateRange = null),
                        child: const Text("Clear Date Filter"))
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel")),
                FilledButton(
                    onPressed: () {
                      setState(() {}); // Apply to main screen
                      Navigator.pop(context);
                    },
                    child: const Text("Apply")),
              ],
            );
          });
        });
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status == 'Paid') color = Colors.green;
    if (status == 'Partial') color = Colors.orange;
    if (status == 'Unpaid') color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withValues(alpha: 0.5))),
      child: Text(status, style: TextStyle(color: color, fontSize: 10)),
    );
  }
}
