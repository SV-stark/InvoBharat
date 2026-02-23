import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/providers/invoice_provider.dart';
import 'package:invobharat/widgets/adaptive_widgets.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final Widget? action;

  const SectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.action,
  });

  @override
  Widget build(final BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 20, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (action != null) action!,
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
}

class InvoiceHeaderSection extends ConsumerWidget {
  final TextEditingController invoiceNoCtrl;
  final TextEditingController posCtrl;
  final TextEditingController paymentTermsCtrl;

  const InvoiceHeaderSection({
    super.key,
    required this.invoiceNoCtrl,
    required this.posCtrl,
    required this.paymentTermsCtrl,
  });

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final invoice = ref.watch(invoiceProvider);
    return SectionCard(
      title: "Invoice Details",
      icon: Icons.description_outlined,
      children: [
        _buildDropdownField(
          label: "Invoice Style",
          value: invoice.style,
          items: ['Modern', 'Professional', 'Minimal'],
          onChanged: (final val) =>
              ref.read(invoiceProvider.notifier).updateStyle(val!),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AppTextInput(
                controller: invoiceNoCtrl,
                label: "Invoice No",
                onChanged: (final val) =>
                    ref.read(invoiceProvider.notifier).updateInvoiceNo(val),
                validator: (final val) =>
                    val == null || val.isEmpty ? "Required" : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateField(
                context: context,
                label: "Date",
                selectedDate: invoice.invoiceDate,
                onDateSelected: (final val) =>
                    ref.read(invoiceProvider.notifier).updateDate(val),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AppTextInput(
                controller: posCtrl,
                label: "Place of Supply",
                onChanged: (final val) =>
                    ref.read(invoiceProvider.notifier).updatePlaceOfSupply(val),
                validator: (final val) =>
                    val == null || val.isEmpty ? "Required" : null,
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 120,
              child: _buildDropdownField(
                label: "Currency",
                value: invoice.currency,
                items: ['INR', 'USD', 'EUR', 'GBP'],
                onChanged: (final val) =>
                    ref.read(invoiceProvider.notifier).updateCurrency(val!),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 120,
              child: _buildDropdownField(
                label: "Rev. Charge",
                value: invoice.reverseCharge.isEmpty
                    ? "N"
                    : invoice.reverseCharge,
                items: ['N', 'Y'],
                onChanged: (final val) => ref
                    .read(invoiceProvider.notifier)
                    .updateReverseCharge(val!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDateField(
          context: context,
          label: "Due Date",
          selectedDate: invoice.dueDate,
          onDateSelected: (final val) =>
              ref.read(invoiceProvider.notifier).updateDueDate(val),
        ),
        const SizedBox(height: 16),
        AppTextInput(
          controller: paymentTermsCtrl,
          label: "Payment Terms",
          onChanged: (final val) =>
              ref.read(invoiceProvider.notifier).updatePaymentTerms(val),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required final BuildContext context,
    required final String label,
    required final DateTime? selectedDate,
    required final Function(DateTime) onDateSelected,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedDate != null
                  ? DateFormat('dd MMM yyyy').format(selectedDate!)
                  : "Select Date",
              style: TextStyle(
                color: selectedDate != null ? Colors.black : Colors.grey,
              ),
            ),
            const Icon(Icons.calendar_today, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required final String label,
    required final String value,
    required final List<String> items,
    required final Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      key: ValueKey(value),
      initialValue: value,
      items: items
          .map((final e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }
}

class ClientDetailsSection extends ConsumerWidget {
  final TextEditingController receiverNameCtrl;
  final TextEditingController receiverStateCtrl;
  final TextEditingController receiverAddressCtrl;
  final VoidCallback onSelectClient;
  final Widget gstinField;

  const ClientDetailsSection({
    super.key,
    required this.receiverNameCtrl,
    required this.receiverStateCtrl,
    required this.receiverAddressCtrl,
    required this.onSelectClient,
    required this.gstinField,
  });

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    return SectionCard(
      title: "Client Details",
      icon: Icons.person_outline,
      action: TextButton.icon(
        onPressed: onSelectClient,
        icon: const Icon(Icons.list),
        label: const Text("Select Client"),
      ),
      children: [
        AppTextInput(
          controller: receiverNameCtrl,
          label: "Client Name",
          onChanged: (final val) =>
              ref.read(invoiceProvider.notifier).updateReceiverName(val),
          validator: (final val) =>
              val == null || val.isEmpty ? "Required" : null,
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: gstinField),
            const SizedBox(width: 16),
            Expanded(
              child: AppTextInput(
                controller: receiverStateCtrl,
                label: "State",
                onChanged: (final val) =>
                    ref.read(invoiceProvider.notifier).updateReceiverState(val),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppTextInput(
          controller: receiverAddressCtrl,
          label: "Billing Address",
          maxLines: 2,
          onChanged: (final val) =>
              ref.read(invoiceProvider.notifier).updateReceiverAddress(val),
        ),
      ],
    );
  }
}

class InvoiceItemsSection extends ConsumerWidget {
  final VoidCallback onAddItem;
  final VoidCallback onAddFromTemplate;
  final Widget Function(BuildContext, int, InvoiceItem) itemBuilder;

  const InvoiceItemsSection({
    super.key,
    required this.onAddItem,
    required this.onAddFromTemplate,
    required this.itemBuilder,
  });

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final invoice = ref.watch(invoiceProvider);
    final theme = Theme.of(context);

    return SectionCard(
      title: "Items",
      icon: Icons.shopping_cart_outlined,
      children: [
        if (invoice.items.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                "No items added yet",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: invoice.items.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (final context, final index) {
              final item = invoice.items[index];
              return itemBuilder(context, index, item);
            },
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onAddItem,
                icon: const Icon(Icons.add),
                label: const Text("Add New Item"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: theme.primaryColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onAddFromTemplate,
                icon: const Icon(Icons.copy_all),
                label: const Text("From Template"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: theme.primaryColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class InvoiceSummarySection extends ConsumerWidget {
  const InvoiceSummarySection({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final invoice = ref.watch(invoiceProvider);
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  "Discount (Flat ₹): ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  child: AppTextInput(
                    controller: TextEditingController(
                      text: invoice.discountAmount.toString(),
                    ),
                    label: "Amount",
                    onChanged: (final val) => ref
                        .read(invoiceProvider.notifier)
                        .updateDiscountAmount(val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Grand Total",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "₹${invoice.grandTotal.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
