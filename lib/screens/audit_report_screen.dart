import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/invoice_repository_provider.dart';
import '../services/audit_service.dart';

class AuditReportScreen extends ConsumerWidget {
  const AuditReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoiceListAsync = ref.watch(invoiceListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Audit Report"),
      ),
      body: invoiceListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (invoices) {
          final missingSequences = AuditService.detectGaps(invoices);

          if (missingSequences.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 64, color: Colors.green),
                  SizedBox(height: 16),
                  Text("No invoice sequence gaps found.",
                      style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: missingSequences.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final missing = missingSequences[index];
              return ListTile(
                leading: const Icon(Icons.warning, color: Colors.orange),
                title: Text("Missing Invoice: $missing"),
                subtitle: const Text(
                    "This invoice number is skipped in your sequence."),
              );
            },
          );
        },
      ),
    );
  }
}
