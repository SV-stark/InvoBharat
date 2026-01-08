import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/client.dart';
import '../providers/client_provider.dart';
import '../widgets/client_form.dart';

class ClientsScreen extends ConsumerWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = ref.watch(clientListProvider);

    return ScaffoldPage(
      header: PageHeader(
        title: const Text('Clients'),
        commandBar: CommandBar(
          primaryItems: [
            CommandBarButton(
              icon: const Icon(FluentIcons.add),
              label: const Text('New Client'),
              onPressed: () {
                _showClientDialog(context, null, ref);
              },
            ),
          ],
        ),
      ),
      content: clients.isEmpty
          ? _buildEmptyState(context, ref)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: clients.length,
              itemBuilder: (context, index) {
                final client = clients[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Card(
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            client.name.isNotEmpty
                                ? client.name[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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
                            icon: const Icon(FluentIcons.edit),
                            onPressed: () =>
                                _showClientDialog(context, client, ref),
                          ),
                          IconButton(
                            icon: const Icon(FluentIcons.delete),
                            onPressed: () =>
                                _confirmDelete(context, client, ref),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(FluentIcons.contact, size: 48),
          const SizedBox(height: 16),
          const Text('No clients yet'),
          const SizedBox(height: 16),
          Button(
            child: const Text('Add Client'),
            onPressed: () => _showClientDialog(context, null, ref),
          ),
        ],
      ),
    );
  }

  void _showClientDialog(
      BuildContext context, Client? client, WidgetRef ref) async {
    await showDialog(
      context: context,
      builder: (context) => ClientFormDialog(client: client),
    );
  }

  void _confirmDelete(
      BuildContext context, Client client, WidgetRef ref) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Delete Client?'),
        content: Text('Are you sure you want to delete ${client.name}?'),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, 'Cancel'),
          ),
          FilledButton(
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
