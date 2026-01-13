import 'package:fluent_ui/fluent_ui.dart';

class PaymentDialog extends StatefulWidget {
  final double balanceDue;
  final String currencySymbol;
  final Function(double amount, DateTime date, String mode, String notes)
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
  late TextEditingController _notesController;
  DateTime _selectedDate = DateTime.now();
  String _selectedMode = 'Cash';

  @override
  void initState() {
    super.initState();
    _amountController =
        TextEditingController(text: widget.balanceDue.toStringAsFixed(2));
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text("Record Payment"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoLabel(
            label: "Amount",
            child: TextBox(
              controller: _amountController,
              placeholder: "Enter amount",
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
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
              onChanged: (v) => setState(() => _selectedDate = v),
            ),
          ),
          const SizedBox(height: 10),
          InfoLabel(
            label: "Payment Mode",
            child: ComboBox<String>(
              value: _selectedMode,
              items: ["Cash", "Bank Transfer", "UPI", "Cheque", "Other"]
                  .map((e) => ComboBoxItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) {
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
            if (amount <= 0) return;

            widget.onConfirm(
              amount,
              _selectedDate,
              _selectedMode,
              _notesController.text,
            );
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
