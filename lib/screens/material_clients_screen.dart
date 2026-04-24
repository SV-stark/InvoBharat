import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:invobharat/models/client.dart';
import 'package:invobharat/providers/client_provider.dart';
import 'package:invobharat/widgets/material_client_form.dart';
import 'package:go_router/go_router.dart';

class MaterialClientsScreen extends ConsumerStatefulWidget {
  const MaterialClientsScreen({super.key});

  @override
  ConsumerState<MaterialClientsScreen> createState() =>
      _MaterialClientsScreenState();
}

class _MaterialClientsScreenState extends ConsumerState<MaterialClientsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final clients = ref.watch(clientListProvider);

    final filteredClients = _searchQuery.isEmpty
        ? clients
        : clients
              .where(
                (final c) =>
                    c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    c.gstin.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    c.email.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    c.phone.contains(_searchQuery),
              )
              .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: "Search clients...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (final val) => setState(() => _searchQuery = val),
            ),
          ),
        ),
      ),
      body: filteredClients.isEmpty
          ? _buildEmptyState(context, ref)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredClients.length,
              itemBuilder: (final context, final index) {
                final client = filteredClients[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        client.name.isNotEmpty
                            ? client.name[0].toUpperCase()
                            : '?',
                      ),
                    ),
                    title: Text(
                      client.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      client.gstin.isNotEmpty
                          ? 'GSTIN: ${client.gstin}'
                          : 'No GSTIN',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.receipt_long,
                            color: Colors.teal,
                          ),
                          onPressed: () => context.push('/client-ledger', extra: client),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () =>
                              _showClientDialog(context, client, ref),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(context, client, ref),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showClientDialog(context, null, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(final BuildContext context, final WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.contacts, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? "No clients match your search"
                : "No clients yet",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          if (_searchQuery.isEmpty)
            FilledButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Client'),
              onPressed: () => _showClientDialog(context, null, ref),
            ),
        ],
      ),
    );
  }

  void _showClientDialog(
    final BuildContext context,
    final Client? client,
    final WidgetRef ref,
  ) async {
    await showDialog(
      context: context,
      builder: (final context) => MaterialClientFormDialog(client: client),
    );
  }

  void _confirmDelete(
    final BuildContext context,
    final Client client,
    final WidgetRef ref,
  ) async {
    final result = await showDialog<String>(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('Delete Client?'),
        content: Text('Are you sure you want to delete ${client.name}?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
            onPressed: () => Navigator.pop(context, 'Delete'),
          ),
        ],
      ),
    );

    if (result == 'Delete') {
      await ref.read(clientListProvider.notifier).deleteClient(client.id);
    }
  }
}
