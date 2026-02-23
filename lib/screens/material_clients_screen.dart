import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invobharat/models/client.dart';
import 'package:invobharat/providers/client_provider.dart';
import 'package:invobharat/widgets/material_client_form.dart';

class MaterialClientsScreen extends ConsumerWidget {
  const MaterialClientsScreen({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final clients = ref.watch(clientListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        centerTitle: true,
      ),
      body: clients.isEmpty
          ? _buildEmptyState(context, ref)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: clients.length,
              itemBuilder: (final context, final index) {
                final client = clients[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(client.name.isNotEmpty
                          ? client.name[0].toUpperCase()
                          : '?'),
                    ),
                    title: Text(client.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(client.gstin.isNotEmpty
                        ? 'GSTIN: ${client.gstin}'
                        : 'No GSTIN'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
          const Text('No clients yet'),
          const SizedBox(height: 16),
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
      final BuildContext context, final Client? client, final WidgetRef ref) async {
    await showDialog(
      context: context,
      builder: (final context) => MaterialClientFormDialog(client: client),
    );
  }

  void _confirmDelete(
      final BuildContext context, final Client client, final WidgetRef ref) async {
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
