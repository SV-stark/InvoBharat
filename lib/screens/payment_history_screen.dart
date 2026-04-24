import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:invobharat/providers/invoice_repository_provider.dart';
import 'package:invobharat/providers/business_profile_provider.dart';
import 'package:go_router/go_router.dart';

class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final invoiceListAsync = ref.watch(invoiceListProvider);
    final currencySymbol = ref.watch(businessProfileProvider).currency;

    return Scaffold(
      appBar: AppBar(title: const Text("Payment History")),
      body: invoiceListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (final err, final stack) => Center(child: Text("Error: $err")),
        data: (final invoices) {
          // Flatten payments from all invoices
          final allPayments = invoices.expand((final inv) {
            return inv.payments.map((final p) => {'payment': p, 'invoice': inv});
          }).toList();

          // Sort by date descending
          allPayments.sort((final a, final b) {
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
            separatorBuilder: (_, final _) => const Divider(),
            itemBuilder: (final context, final index) {
              final entry = allPayments[index];
              final payment = entry['payment'] as dynamic;
              final invoice = entry['invoice'] as dynamic;

              return ListTile(
                onTap: () {
                  context.push('/invoice-detail', extra: invoice);
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
