import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invobharat/models/client.dart';
import 'package:invobharat/providers/client_provider.dart';
import 'package:invobharat/widgets/client_form.dart';
import 'package:invobharat/screens/client_ledger_screen.dart';

class ClientsScreen extends ConsumerWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
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
              itemBuilder: (final context, final index) {
                final client = clients[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Card(
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
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
                          IconButton(
                            icon: const Icon(FluentIcons.history),
                            onPressed: () {
                              Navigator.push(
                                context,
                                FluentPageRoute(
                                  builder: (final context) =>
                                      ClientLedgerScreen(client: client),
                                ),
                              );
                            },
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

  Widget _buildEmptyState(final BuildContext context, final WidgetRef ref) {
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
      final BuildContext context, final Client? client, final WidgetRef ref) async {
    await showDialog(
      context: context,
      builder: (final context) => ClientFormDialog(client: client),
    );
  }

  void _confirmDelete(
      final BuildContext context, final Client client, final WidgetRef ref) async {
    final result = await showDialog<String>(
      context: context,
      builder: (final context) => ContentDialog(
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
