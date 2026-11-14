import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:invobharat/providers/bank_provider.dart';
import 'package:invobharat/providers/invoice_provider.dart';
import 'package:invobharat/utils/formatters.dart';

class WizardPaymentHistorySection extends ConsumerWidget {
  const WizardPaymentHistorySection({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final invoice = ref.watch(invoiceProvider);
    final notifier = ref.read(invoiceProvider.notifier);

    if (invoice.payments.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Payment History",
          style: FluentTheme.of(context).typography.subtitle,
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                color: FluentTheme.of(
                  context,
                ).accentColor.withValues(alpha: 0.1),
                child: const Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Date",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "Amount",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "TDS",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "Mode",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Notes",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 36),
                  ],
                ),
              ),
              ...invoice.payments.map((final payment) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          DateFormat('dd MMM yyyy').format(payment.date),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          payment.amount.toIndianFormat(
                            includeSymbol: true,
                            symbol: invoice.currency,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          payment.tdsDeducted > 0
                              ? payment.tdsDeducted.toIndianFormat(
                                  includeSymbol: true,
                                  symbol: invoice.currency,
                                )
                              : "-",
                        ),
                      ),
                      Expanded(child: Text(payment.paymentMode)),
                      Expanded(
                        flex: 2,
                        child: Text(
                          (payment.notes ?? '').isEmpty ? "-" : payment.notes!,
                        ),
                      ),
                      IconButton(
                        icon: Icon(FluentIcons.delete, color: Colors.red),
                        onPressed: () => notifier.removePayment(payment.id),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class WizardFooterSection extends ConsumerWidget {
  final TextEditingController commentsCtrl;

  const WizardFooterSection({super.key, required this.commentsCtrl});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final invoice = ref.watch(invoiceProvider);
    final notifier = ref.read(invoiceProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Additional Notes",
          style: FluentTheme.of(context).typography.subtitle,
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: InfoLabel(
                label: "Terms & Conditions / Comments",
                child: TextBox(
                  placeholder: "Thanks for your business.",
                  controller: commentsCtrl,
                  onChanged: (final v) => notifier.updateTermComments(v),
                  maxLines: 4,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoLabel(
                    label: "Invoice Style",
                    child: ComboBox<String>(
                      value: invoice.style,
                      items:
                          [
                                'Modern',
                                'Professional',
                                'Minimal',
                                'Classic',
                                'Corporate',
                                'Creative',
                              ]
                              .map(
                                (final e) =>
                                    ComboBoxItem(value: e, child: Text(e)),
                              )
                              .toList(),
                      onChanged: (final v) {
                        if (v != null) notifier.updateStyle(v);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class WizardBankSection extends ConsumerWidget {
  const WizardBankSection({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final invoice = ref.watch(invoiceProvider);
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Bank Details",
                  style: FluentTheme.of(context).typography.subtitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Button(
                onPressed: () => _showBankSelector(context),
                child: const Row(
                  children: [
                    Icon(FluentIcons.bank),
                    SizedBox(width: 8),
                    Text("Switch Bank"),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (invoice.bankName.isNotEmpty) ...[
            Text(
              invoice.bankName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("A/C: ${invoice.accountNo}"),
            Text("IFSC: ${invoice.ifscCode}"),
            if (invoice.branch.isNotEmpty) Text("Branch: ${invoice.branch}"),
          ] else
            const Text(
              "No bank details selected",
              style: TextStyle(color: Colors.grey),
            ),
        ],
      ),
    );
  }

  void _showBankSelector(final BuildContext context) {
    showDialog(
      context: context,
      builder: (final context) {
        return ContentDialog(
          title: const Text("Select Bank Account"),
          content: Consumer(
            builder: (final context, final ref, final child) {
              final banksAsync = ref.watch(bankListProvider);
              return banksAsync.when(
                data: (final banks) {
                  if (banks.isEmpty) {
                    return const Text("No bank accounts found in settings.");
                  }
                  return SizedBox(
                    height: 300,
                    child: ListView.builder(
                      itemCount: banks.length,
                      itemBuilder: (final context, final index) {
                        final bank = banks[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Card(
                            child: ListTile(
                              title: Text(bank.bankName),
                              subtitle: Text(
                                "${bank.accountNo} (${bank.ifscCode})",
                              ),
                              trailing: bank.isDefault
                                  ? const Icon(
                                      FluentIcons.favorite_star_fill,
                                      color: Colors.warningPrimaryColor,
                                    )
                                  : null,
                              onPressed: () {
                                ref
                                    .read(invoiceProvider.notifier)
                                    .updateBankDetails(
                                      bank.bankName,
                                      bank.accountNo,
                                      bank.ifscCode,
                                      bank.branch,
                                    );
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: ProgressBar()),
                error: (final err, final stack) => Text("Error: $err"),
              );
            },
          ),
          actions: [
            Button(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
}
