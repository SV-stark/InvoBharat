import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/invoice_repository_provider.dart';
import '../providers/business_profile_provider.dart';
import 'invoice_detail_screen.dart';

class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoiceListAsync = ref.watch(invoiceListProvider);
    final currencySymbol = ref.watch(businessProfileProvider).currencySymbol;

    return Scaffold(
      appBar: AppBar(title: const Text("Payment History")),
      body: invoiceListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (invoices) {
          // Flatten payments from all invoices
          final allPayments = invoices.expand((inv) {
            return inv.payments.map((p) => {'payment': p, 'invoice': inv});
          }).toList();

          // Sort by date descending
          allPayments.sort((a, b) {
            final pA = a['payment'] as dynamic;
            final pB = b['payment'] as dynamic;
            return pB.date.compareTo(pA.date);
          });

          if (allPayments.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No payments recorded yet."),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: allPayments.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final entry = allPayments[index];
              final payment = entry['payment'] as dynamic;
              final invoice = entry['invoice'] as dynamic;

              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InvoiceDetailScreen(invoice: invoice),
                    ),
                  );
                },
                leading: CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: const Icon(Icons.check, color: Colors.green, size: 20),
                ),
                title: Text(invoice.receiver.name),
                subtitle: Text(
                  "${DateFormat('dd MMM yyyy').format(payment.date)} • ${payment.paymentMode}\nInvoice #${invoice.invoiceNo}",
                ),
                trailing: Text(
                  NumberFormat.currency(
                    symbol: currencySymbol,
                  ).format(payment.amount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
