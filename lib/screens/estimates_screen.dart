import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:invobharat/utils/formatters.dart';
import 'package:invobharat/providers/business_profile_provider.dart';
import 'package:invobharat/providers/estimate_provider.dart';
import 'package:go_router/go_router.dart';

class EstimatesScreen extends ConsumerStatefulWidget {
  const EstimatesScreen({super.key});

  @override
  ConsumerState<EstimatesScreen> createState() => _EstimatesScreenState();
}

class _EstimatesScreenState extends ConsumerState<EstimatesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _sortBy = 'date_desc';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _getSortLabel(final String sortBy) {
    switch (sortBy) {
      case 'date_desc':
        return "Newest First";
      case 'date_asc':
        return "Oldest First";
      case 'amount_desc':
        return "Amount (High to Low)";
      case 'amount_asc':
        return "Amount (Low to High)";
      case 'no_desc':
        return "Estimate No (High to Low)";
      case 'no_asc':
        return "Estimate No (Low to High)";
      case 'client_asc':
        return "Client Name (A-Z)";
      case 'client_desc':
        return "Client Name (Z-A)";
      default:
        return "Newest First";
    }
  }

  @override
  Widget build(final BuildContext context) {
    final estimatesAsync = ref.watch(estimateListProvider);
    final theme = Theme.of(context);
    final currency = ref.watch(businessProfileProvider).currency;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Estimates"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(105),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: "Search Client / Estimate # / Amount",
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
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
                    PopupMenuButton<String>(
                      initialValue: _sortBy,
                      icon: Icon(
                        Icons.sort,
                        color: _sortBy != 'date_desc'
                            ? theme.primaryColor
                            : null,
                      ),
                      tooltip: "Sort estimates",
                      onSelected: (final String value) {
                        setState(() {
                          _sortBy = value;
                        });
                      },
                      itemBuilder: (final BuildContext context) =>
                          <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'date_desc',
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 18),
                                  SizedBox(width: 8),
                                  Text("Date: Newest First"),
                                ],
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'date_asc',
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 18),
                                  SizedBox(width: 8),
                                  Text("Date: Oldest First"),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
                            const PopupMenuItem<String>(
                              value: 'amount_desc',
                              child: Row(
                                children: [
                                  Icon(Icons.arrow_downward, size: 18),
                                  SizedBox(width: 8),
                                  Text("Amount: High to Low"),
                                ],
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'amount_asc',
                              child: Row(
                                children: [
                                  Icon(Icons.arrow_upward, size: 18),
                                  SizedBox(width: 8),
                                  Text("Amount: Low to High"),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
                            const PopupMenuItem<String>(
                              value: 'no_desc',
                              child: Row(
                                children: [
                                  Icon(Icons.tag, size: 18),
                                  SizedBox(width: 8),
                                  Text("Estimate No: High to Low"),
                                ],
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'no_asc',
                              child: Row(
                                children: [
                                  Icon(Icons.tag, size: 18),
                                  SizedBox(width: 8),
                                  Text("Estimate No: Low to High"),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
                            const PopupMenuItem<String>(
                              value: 'client_asc',
                              child: Row(
                                children: [
                                  Icon(Icons.person, size: 18),
                                  SizedBox(width: 8),
                                  Text("Client Name: A-Z"),
                                ],
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'client_desc',
                              child: Row(
                                children: [
                                  Icon(Icons.person, size: 18),
                                  SizedBox(width: 8),
                                  Text("Client Name: Z-A"),
                                ],
                              ),
                            ),
                          ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      InputChip(
                        avatar: const Icon(Icons.sort, size: 16),
                        label: Text("Sorted by: ${_getSortLabel(_sortBy)}"),
                        onPressed: () {
                          // No-op
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: estimatesAsync.when(
        data: (final estimates) {
          final query = _searchCtrl.text.toLowerCase().trim();
          final filtered = estimates.where((final est) {
            return query.isEmpty ||
                est.receiver.name.toLowerCase().contains(query) ||
                est.estimateNo.toLowerCase().contains(query) ||
                est.totalAmount.toStringAsFixed(2).contains(query);
          }).toList();

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.request_quote_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    query.isNotEmpty
                        ? "No estimates found"
                        : "No estimates created",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  if (query.isEmpty) ...[
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () {
                        context.push('/estimate-form');
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Create Estimate"),
                    ),
                  ],
                ],
              ),
            );
          }

          switch (_sortBy) {
            case 'date_desc':
              filtered.sort((final a, final b) => b.date.compareTo(a.date));
              break;
            case 'date_asc':
              filtered.sort((final a, final b) => a.date.compareTo(b.date));
              break;
            case 'amount_desc':
              filtered.sort(
                (final a, final b) => b.totalAmount.compareTo(a.totalAmount),
              );
              break;
            case 'amount_asc':
              filtered.sort(
                (final a, final b) => a.totalAmount.compareTo(b.totalAmount),
              );
              break;
            case 'no_desc':
              filtered.sort(
                (final a, final b) => b.estimateNo.compareTo(a.estimateNo),
              );
              break;
            case 'no_asc':
              filtered.sort(
                (final a, final b) => a.estimateNo.compareTo(b.estimateNo),
              );
              break;
            case 'client_asc':
              filtered.sort(
                (final a, final b) =>
                    a.receiver.name.compareTo(b.receiver.name),
              );
              break;
            case 'client_desc':
              filtered.sort(
                (final a, final b) =>
                    b.receiver.name.compareTo(a.receiver.name),
              );
              break;
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (final context, final index) {
              final estimate = filtered[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: const Icon(Icons.request_quote),
                  ),
                  title: Text(estimate.receiver.name),
                  subtitle: Text(
                    '${estimate.estimateNo} • ${DateFormat('dd MMM yyyy').format(estimate.date)}',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        estimate.totalAmount.toIndianFormat(
                          includeSymbol: true,
                          symbol: currency,
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      _buildStatusBadge(theme, estimate.status ?? 'Draft'),
                    ],
                  ),
                  onTap: () {
                    context.push('/estimate-form', extra: estimate.id);
                  },
                ),
              );
            },
          );
        },
        error: (final err, final stack) => Center(child: Text("Error: $err")),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/estimate-form');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatusBadge(final ThemeData theme, final String status) {
    Color color;
    switch (status) {
      case 'Accepted':
      case 'Converted':
        color = Colors.green;
        break;
      case 'Rejected':
        color = Colors.red;
        break;
      case 'Sent':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(status, style: TextStyle(fontSize: 10, color: color)),
    );
  }
}
