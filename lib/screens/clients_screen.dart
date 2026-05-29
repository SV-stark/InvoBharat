import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invobharat/models/client.dart';
import 'package:invobharat/providers/client_provider.dart';
import 'package:invobharat/widgets/client_form.dart';
import 'package:go_router/go_router.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'name_asc';
  final _sortController = FlyoutController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    _sortController.dispose();
    super.dispose();
  }

  String _getSortLabel(final String sortBy) {
    switch (sortBy) {
      case 'name_asc':
        return "Name A-Z";
      case 'name_desc':
        return "Name Z-A";
      case 'email_asc':
        return "Email";
      case 'phone':
        return "Phone";
      default:
        return "Name A-Z";
    }
  }

  @override
  Widget build(final BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: const Text('Clients'),
        commandBar: CommandBar(
          primaryItems: [
            CommandBarButton(
              icon: const Icon(FluentIcons.add),
              label: const Text('New Client'),
              onPressed: () => _showClientDialog(context, null),
            ),
            CommandBarBuilderItem(
              wrappedItem: CommandBarButton(
                icon: const Icon(FluentIcons.sort),
                label: Text('Sort: ${_getSortLabel(_sortBy)}'),
                onPressed: () {},
              ),
              builder: (final context, final mode, final w) {
                return FlyoutTarget(
                  controller: _sortController,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6.0,
                      vertical: 4.0,
                    ),
                    child: Button(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(FluentIcons.sort, size: 16),
                          const SizedBox(width: 8),
                          Text('Sort: ${_getSortLabel(_sortBy)}'),
                        ],
                      ),
                      onPressed: () {
                        _sortController.showFlyout(
                          autoModeConfiguration: FlyoutAutoConfiguration(
                            preferredMode: FlyoutPlacementMode.bottomCenter,
                          ),
                          builder: (final flyoutContext) {
                            return MenuFlyout(
                              items: [
                                MenuFlyoutItem(
                                  text: const Text('Name: A-Z'),
                                  onPressed: () {
                                    Flyout.of(flyoutContext).close();
                                    setState(() => _sortBy = 'name_asc');
                                  },
                                ),
                                MenuFlyoutItem(
                                  text: const Text('Name: Z-A'),
                                  onPressed: () {
                                    Flyout.of(flyoutContext).close();
                                    setState(() => _sortBy = 'name_desc');
                                  },
                                ),
                                MenuFlyoutItem(
                                  text: const Text('Email: A-Z'),
                                  onPressed: () {
                                    Flyout.of(flyoutContext).close();
                                    setState(() => _sortBy = 'email_asc');
                                  },
                                ),
                                MenuFlyoutItem(
                                  text: const Text('Phone'),
                                  onPressed: () {
                                    Flyout.of(flyoutContext).close();
                                    setState(() => _sortBy = 'phone');
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      content: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextBox(
              controller: _searchCtrl,
              placeholder: 'Search clients...',
              prefix: const Icon(FluentIcons.search),
              suffix: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(FluentIcons.clear),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              onChanged: (final val) => setState(() => _searchQuery = val),
            ),
          ),
          Expanded(
            child: Consumer(
              builder: (final context, final ref, final child) {
                final clients = ref.watch(clientListProvider);
                final filteredClients = _searchQuery.isEmpty
                    ? clients
                    : clients
                          .where(
                            (final c) =>
                                c.name.toLowerCase().contains(
                                  _searchQuery.toLowerCase(),
                                ) ||
                                c.gstin.toLowerCase().contains(
                                  _searchQuery.toLowerCase(),
                                ) ||
                                c.email.toLowerCase().contains(
                                  _searchQuery.toLowerCase(),
                                ),
                          )
                          .toList();

                final sortedClients = filteredClients.toList();
                switch (_sortBy) {
                  case 'name_asc':
                    sortedClients.sort(
                      (final a, final b) => a.name.compareTo(b.name),
                    );
                    break;
                  case 'name_desc':
                    sortedClients.sort(
                      (final a, final b) => b.name.compareTo(a.name),
                    );
                    break;
                  case 'email_asc':
                    sortedClients.sort(
                      (final a, final b) => a.email.compareTo(b.email),
                    );
                    break;
                  case 'phone':
                    sortedClients.sort(
                      (final a, final b) => a.phone.compareTo(b.phone),
                    );
                    break;
                }

                if (sortedClients.isEmpty) {
                  return _buildEmptyState(context, ref);
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedClients.length,
                  itemBuilder: (final context, final index) {
                    final client = sortedClients[index];
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
                                icon: const Icon(FluentIcons.history),
                                onPressed: () => context.push(
                                  '/client-ledger',
                                  extra: client,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(FluentIcons.edit),
                                onPressed: () =>
                                    _showClientDialog(context, client),
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
                );
              },
            ),
          ),
        ],
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
          Text(
            _searchQuery.isNotEmpty
                ? "No clients match your search"
                : "No clients yet",
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 16),
            Button(
              child: const Text('Add Client'),
              onPressed: () => _showClientDialog(context, null),
            ),
          ],
        ],
      ),
    );
  }

  void _showClientDialog(
    final BuildContext context,
    final Client? client,
  ) async {
    await showDialog(
      context: context,
      builder: (final context) => ClientFormDialog(client: client),
    );
  }

  void _confirmDelete(
    final BuildContext context,
    final Client client,
    final WidgetRef ref,
  ) async {
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
