import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'linux_dashboard.dart';

class LinuxHome extends ConsumerStatefulWidget {
  const LinuxHome({super.key});

  @override
  ConsumerState<LinuxHome> createState() => _LinuxHomeState();
}

class _LinuxHomeState extends ConsumerState<LinuxHome> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const LinuxDashboard(),
          _buildPlaceholder("Clients", Icons.contacts),
          _buildPlaceholder("New Invoice", Icons.add),
          _buildPlaceholder("Settings", Icons.settings),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            label: "Dashboard",
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
          ),
          NavigationDestination(
            label: "Clients",
            icon: Icon(Icons.contacts_outlined),
            selectedIcon: Icon(Icons.contacts),
          ),
          NavigationDestination(
            label: "New Invoice",
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
          ),
          NavigationDestination(
            label: "Settings",
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String title, IconData icon) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text("$title Coming Soon",
                style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
