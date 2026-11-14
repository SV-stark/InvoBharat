import 'package:fluent_ui/fluent_ui.dart';
import 'package:invobharat/utils/constants.dart';

class PaymentDialog extends StatefulWidget {
  final double balanceDue;
  final String currencySymbol;
  final void Function(
    double amount,
    DateTime date,
    String mode,
    String notes,
    double tdsDeducted,
  )
  onConfirm;

  const PaymentDialog({
    super.key,
    required this.balanceDue,
    required this.currencySymbol,
    required this.onConfirm,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  late TextEditingController _amountController;
  late TextEditingController _tdsController;
  late TextEditingController _notesController;
  DateTime _selectedDate = DateTime.now();
  String _selectedMode = 'Cash';

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.balanceDue.toStringAsFixed(2),
    );
    _tdsController = TextEditingController(text: '0.00');
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _tdsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return ContentDialog(
      title: const Text("Record Payment"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoLabel(
            label: "Amount Received",
            child: TextBox(
              controller: _amountController,
              placeholder: "Enter amount received",
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              prefix: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(widget.currencySymbol),
              ),
            ),
          ),
          const SizedBox(height: 10),
          InfoLabel(
            label: "TDS Deducted (Optional)",
            child: TextBox(
              controller: _tdsController,
              placeholder: "e.g. 194J / 194C TDS withheld by client",
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              prefix: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(widget.currencySymbol),
              ),
            ),
          ),
          const SizedBox(height: 10),
          InfoLabel(
            label: "Date",
            child: DatePicker(
              selected: _selectedDate,
              onChanged: (final v) => setState(() => _selectedDate = v),
            ),
          ),
          const SizedBox(height: 10),
          InfoLabel(
            label: "Payment Mode",
            child: ComboBox<String>(
              value: _selectedMode,
              items: AppConstants.paymentModes
                  .map((final e) => ComboBoxItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (final v) {
                if (v != null) setState(() => _selectedMode = v);
              },
            ),
          ),
          const SizedBox(height: 10),
          InfoLabel(
            label: "Notes",
            child: TextBox(
              controller: _notesController,
              placeholder: "Transaction ID, remarks, etc.",
              maxLines: 2,
            ),
          ),
        ],
      ),
      actions: [
        Button(
          child: const Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          child: const Text("Reflect Payment"),
          onPressed: () {
            final amount = double.tryParse(_amountController.text) ?? 0.0;
            final tds = double.tryParse(_tdsController.text) ?? 0.0;
            if (amount <= 0 && tds <= 0) return;

            widget.onConfirm(
              amount < 0 ? 0.0 : amount,
              _selectedDate,
              _selectedMode,
              _notesController.text,
              tds < 0 ? 0.0 : tds,
            );
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
