import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double? trend;
  final bool isTrendPercentage;
  final VoidCallback? onTap;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
    this.isTrendPercentage = true,
    this.onTap,
  });

  @override
  Widget build(final BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (trend != null)
                    _DashboardTrendIndicator(
                      trend: trend!,
                      isPercentage: isTrendPercentage,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardTrendIndicator extends StatelessWidget {
  final double trend;
  final bool isPercentage;

  const _DashboardTrendIndicator({
    required this.trend,
    required this.isPercentage,
  });

  @override
  Widget build(final BuildContext context) {
    final isPositive = trend >= 0;
    final color = isPositive ? Colors.green : Colors.red;
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;
    final text = isPercentage
        ? '${trend.abs().toStringAsFixed(1)}%'
        : '${trend >= 0 ? '+' : ''}${trend.toStringAsFixed(0)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 2),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bgColor;
  final VoidCallback onTap;

  const DashboardActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(final BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color getStatusColor(final String status) {
  switch (status) {
    case 'Paid':
      return Colors.green;
    case 'Partial':
      return Colors.orange;
    case 'Overdue':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

class DashboardStatusBadge extends StatelessWidget {
  final String status;

  const DashboardStatusBadge({super.key, required this.status});

  @override
  Widget build(final BuildContext context) {
    final color = getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class GstBreakdownDialog extends StatelessWidget {
  final double cgst;
  final double sgst;
  final double igst;
  final String currencySymbol;

  const GstBreakdownDialog({
    super.key,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.currencySymbol,
  });

  @override
  Widget build(final BuildContext context) {
    return AlertDialog(
      title: const Text("GST Breakdown"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _GstRow(label: "CGST", amount: cgst, symbol: currencySymbol),
          const SizedBox(height: 8),
          _GstRow(label: "SGST", amount: sgst, symbol: currencySymbol),
          const SizedBox(height: 8),
          _GstRow(label: "IGST", amount: igst, symbol: currencySymbol),
          const Divider(height: 24),
          _GstRow(
            label: "Total",
            amount: cgst + sgst + igst,
            symbol: currencySymbol,
            isBold: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text("Close"),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

class _GstRow extends StatelessWidget {
  final String label;
  final double amount;
  final String symbol;
  final bool isBold;

  const _GstRow({
    required this.label,
    required this.amount,
    required this.symbol,
    this.isBold = false,
  });

  @override
  Widget build(final BuildContext context) {
    final style = isBold ? const TextStyle(fontWeight: FontWeight.bold) : null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(
          NumberFormat.currency(
            symbol: symbol,
            decimalDigits: 2,
          ).format(amount),
          style: style,
        ),
      ],
    );
  }
}
