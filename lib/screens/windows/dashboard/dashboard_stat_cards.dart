import 'package:fluent_ui/fluent_ui.dart';
import 'package:gap/gap.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/utils/formatters.dart';

class DashboardHeroStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const DashboardHeroStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(final BuildContext context) {
    final card = Card(
      padding: const EdgeInsets.all(16),
      backgroundColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 24, color: Colors.white),
              const Icon(FluentIcons.chart, color: Colors.white),
            ],
          ),
          const Gap(16),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(4),
          Text(
            title,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
    if (onTap == null) return card;
    return GestureDetector(onTap: onTap, child: card);
  }
}

class DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(final BuildContext context) {
    final card = Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: color),
          const Gap(12),
          Text(
            value,
            style: TextStyle(
              color: FluentTheme.of(context).typography.bodyLarge?.color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(4),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
    if (onTap == null) return card;
    return GestureDetector(onTap: onTap, child: card);
  }
}

class InvoiceStatusBadge extends StatelessWidget {
  final Invoice invoice;

  const InvoiceStatusBadge({super.key, required this.invoice});

  @override
  Widget build(final BuildContext context) {
    final lifecycleStatus = invoice.status; // Draft, Sent, Viewed, Paid
    final paymentStatus =
        invoice.paymentStatus; // Unpaid, Partial, Overdue, Paid

    String text = lifecycleStatus;
    Color color = Colors.grey;

    if (lifecycleStatus == 'Draft') {
      text = "Draft";
      color = Colors.grey;
    } else if (lifecycleStatus == 'Sent' || lifecycleStatus == 'Viewed') {
      text = lifecycleStatus;
      color = Colors.blue;
      if (paymentStatus == 'Overdue') {
        text = "$lifecycleStatus (Overdue)";
        color = Colors.orange;
      }
    }

    // Payment status overrides lifecycle for Paid/Partial
    if (paymentStatus == 'Paid') {
      text = "Paid";
      color = Colors.green;
    } else if (paymentStatus == 'Partial') {
      text = "Partial Paid";
      color = Colors.teal;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(text, style: TextStyle(fontSize: 10, color: color)),
    );
  }
}

void showGstBreakdownDialog(
  final BuildContext context, {
  required final double cgst,
  required final double sgst,
  required final double igst,
  required final String currencySymbol,
}) {
  Widget buildGstRow(
    final String label,
    final double amount, {
    final bool isBold = false,
  }) {
    final style = isBold
        ? const TextStyle(fontWeight: FontWeight.bold)
        : const TextStyle();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(
          amount.toIndianFormat(includeSymbol: true, symbol: currencySymbol),
          style: style,
        ),
      ],
    );
  }

  showDialog(
    context: context,
    builder: (final context) => ContentDialog(
      title: const Text("GST Breakdown"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildGstRow("CGST", cgst),
          const Gap(8),
          buildGstRow("SGST", sgst),
          const Gap(8),
          buildGstRow("IGST", igst),
          const Gap(16),
          const Divider(),
          const Gap(16),
          buildGstRow("Total", cgst + sgst + igst, isBold: true),
        ],
      ),
      actions: [
        Button(
          child: const Text("Close"),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}
