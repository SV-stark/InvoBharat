// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:invobharat/providers/invoice_repository_provider.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:go_router/go_router.dart';

class InvoicesListScreen extends ConsumerStatefulWidget {
  const InvoicesListScreen({super.key});

  @override
  ConsumerState<InvoicesListScreen> createState() => _InvoicesListScreenState();
}

class _InvoicesListScreenState extends ConsumerState<InvoicesListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _filter = 'All';
  DateTimeRange? _dateRange;
  bool _isMultiSelectMode = false;
  final Set<String> _selectedIds = {};

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggleMultiSelect() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      _selectedIds.clear();
    });
  }

  void _toggleSelection(final String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _bulkDelete() async {
    if (_selectedIds.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (final ctx) => AlertDialog(
        title: const Text("Delete Selected Invoices?"),
        content: Text(
          "Are you sure you want to delete ${_selectedIds.length} invoice(s)?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final deletedInvoices = <Invoice>[];
      final repo = ref.read(invoiceRepositoryProvider);
      for (final id in _selectedIds) {
        final inv = await repo.getInvoice(id);
        if (inv != null) deletedInvoices.add(inv);
        await repo.deleteInvoice(id);
      }
      ref.invalidate(invoiceListProvider);
      setState(() {
        _isMultiSelectMode = false;
        _selectedIds.clear();
      });
      if (context.mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(
            content: Text("${deletedInvoices.length} invoice(s) deleted"),
            action: SnackBarAction(
              label: "Undo",
              onPressed: () async {
                for (final inv in deletedInvoices) {
                  await repo.saveInvoice(inv);
                }
                ref.invalidate(invoiceListProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Deletion undone")),
                  );
                }
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _duplicateInvoice(final Invoice invoice) async {
    final duplicated = invoice.copyWith(
      id: null,
      invoiceNo: '',
      invoiceDate: DateTime.now(),
      payments: [],
    );

    await context.push('/invoice-form', extra: duplicated);
    ref.invalidate(invoiceListProvider);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Invoice duplicated for editing")),
    );
  }

  @override
  Widget build(final BuildContext context) {
    final invoiceListAsync = ref.watch(invoiceListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: _isMultiSelectMode
            ? Text("${_selectedIds.length} selected")
            : const Text("Invoices"),
        leading: _isMultiSelectMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _toggleMultiSelect,
              )
            : null,
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
                      hintText: "Search Client / Invoice # / Amount",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                    onChanged: (final val) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: _dateRange != null || _filter != 'All'
                        ? theme.primaryColor
                        : null,
                  ),
                  onPressed: _showFilterDialog,
                ),
              ],
            ),
          ),
        ),
        actions: [
          if (!_isMultiSelectMode)
            IconButton(
              icon: const Icon(Icons.select_all),
              tooltip: "Multi-select",
              onPressed: _toggleMultiSelect,
            ),
          if (_isMultiSelectMode)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: "Delete selected",
              onPressed: _selectedIds.isNotEmpty ? _bulkDelete : null,
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/invoice-form').then((_) => ref.refresh(invoiceListProvider)),
        child: const Icon(Icons.add),
      ),
      body: invoiceListAsync.when(
        data: (final invoices) {
          final filtered = invoices.where((final inv) {
            final query = _searchCtrl.text.toLowerCase().trim();
            final matchesSearch =
                query.isEmpty ||
                inv.receiver.name.toLowerCase().contains(query) ||
                inv.invoiceNo.toLowerCase().contains(query) ||
                inv.grandTotal.toStringAsFixed(2).contains(query);

            if (!matchesSearch) return false;

            if (_dateRange != null) {
              if (inv.invoiceDate.isBefore(_dateRange!.start) ||
                  inv.invoiceDate.isAfter(
                    _dateRange!.end.add(const Duration(days: 1)),
                  )) {
                return false;
              }
            }

            if (_filter == 'Archived') {
              if (!inv.isArchived) return false;
            } else {
              if (inv.isArchived) return false;

              if (_filter == 'Paid') {
                if (inv.paymentStatus != 'Paid') return false;
              } else if (_filter == 'Unpaid') {
                if (inv.paymentStatus == 'Paid') {
                  return false;
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
            itemBuilder: (final context, final index) {
              final invoice = filtered[index];
              final isSelected = _selectedIds.contains(invoice.id);

              if (_isMultiSelectMode) {
                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (_) => _toggleSelection(invoice.id!),
                  title: Text(
                    invoice.receiver.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${invoice.invoiceNo} • ${DateFormat('dd MMM yyyy').format(invoice.invoiceDate)}",
                  ),
                  secondary: Text(
                    "₹${invoice.grandTotal.toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              }

              return Dismissible(
                key: Key(invoice.id!),
                direction: DismissDirection.endToStart,
                confirmDismiss: (final direction) async {
                  return await showDialog(
                    context: context,
                    builder: (final ctx) => AlertDialog(
                      title: const Text("Delete Invoice?"),
                      content: Text(
                        "Are you sure you want to delete ${invoice.invoiceNo}?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text(
                            "Delete",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (final direction) async {
                  final repo = ref.read(invoiceRepositoryProvider);
                  await repo.deleteInvoice(invoice.id!);
                  ref.invalidate(invoiceListProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Invoice deleted"),
                        action: SnackBarAction(
                          label: "Undo",
                          onPressed: () async {
                            await repo.saveInvoice(invoice);
                            ref.invalidate(invoiceListProvider);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Deletion undone"),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  }
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () {
                      context.push('/invoice-detail', extra: invoice).then((_) => ref.refresh(invoiceListProvider));
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
                          "${invoice.invoiceNo} • ${DateFormat('dd MMM yyyy').format(invoice.invoiceDate)}",
                        ),
                        if (invoice.dueDate != null)
                          Text(
                            "Due: ${DateFormat('dd MMM').format(invoice.dueDate!)}",
                            style: TextStyle(
                              fontSize: 11,
                              color:
                                  invoice.dueDate!.isBefore(DateTime.now()) &&
                                      invoice.paymentStatus != 'Paid'
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "₹${invoice.grandTotal.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _buildStatusBadge(invoice.paymentStatus),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          tooltip: "Duplicate invoice",
                          onPressed: () => _duplicateInvoice(invoice),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (final err, final stack) => Center(child: Text("Error: $err")),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (final context) {
        return StatefulBuilder(
          builder: (final context, final setDialogState) {
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
                      DropdownMenuItem(value: 'All', child: Text("All Active")),
                      DropdownMenuItem(value: 'Paid', child: Text("Paid")),
                      DropdownMenuItem(value: 'Unpaid', child: Text("Unpaid")),
                      DropdownMenuItem(
                        value: 'Archived',
                        child: Text("Archived"),
                      ),
                    ],
                    onChanged: (final val) {
                      setDialogState(() => _filter = val!);
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text("Date Range"),
                    subtitle: Text(
                      _dateRange == null
                          ? "All Time"
                          : "${DateFormat('dd/MM').format(_dateRange!.start)} - ${DateFormat('dd/MM').format(_dateRange!.end)}",
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                        initialDateRange: _dateRange,
                      );
                      if (picked != null) {
                        setDialogState(() => _dateRange = picked);
                      }
                    },
                  ),
                  if (_dateRange != null)
                    TextButton(
                      onPressed: () => setDialogState(() => _dateRange = null),
                      child: const Text("Clear Date Filter"),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                FilledButton(
                  onPressed: () {
                    setState(() {});
                    Navigator.pop(context);
                  },
                  child: const Text("Apply"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatusBadge(final String status) {
    Color color = Colors.grey;
    if (status == 'Paid') color = Colors.green;
    if (status == 'Partial') color = Colors.orange;
    if (status == 'Unpaid') color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: 10)),
    );
  }
}
