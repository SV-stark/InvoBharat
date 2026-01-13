import 'package:fluent_ui/fluent_ui.dart';
import '../../../../models/invoice.dart';

class InvoiceItemDialog extends StatefulWidget {
  final InvoiceItem? item;
  final Function(InvoiceItem) onSave;

  const InvoiceItemDialog({super.key, this.item, required this.onSave});

  @override
  State<InvoiceItemDialog> createState() => _InvoiceItemDialogState();
}

class _InvoiceItemDialogState extends State<InvoiceItemDialog> {
  late TextEditingController _descCtrl;
  late TextEditingController _sacCtrl;
  late TextEditingController _unitCtrl;

  late double qty;
  late double price;
  late double discount;
  late double gst;

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController(text: widget.item?.description ?? "");
    _sacCtrl = TextEditingController(text: widget.item?.sacCode ?? "");
    _unitCtrl = TextEditingController(text: widget.item?.unit ?? "Nos");

    qty = widget.item?.quantity ?? 1;
    price = widget.item?.amount ?? 0;
    discount = widget.item?.discount ?? 0;
    gst = widget.item?.gstRate ?? 18;
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _sacCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(widget.item == null ? "Add Item" : "Edit Item"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InfoLabel(
            label: "Description",
            child: TextBox(
              placeholder: "Item description",
              controller: _descCtrl,
              maxLines: 2,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: InfoLabel(
                  label: "HSN/SAC Code",
                  child: TextBox(
                    placeholder: "e.g. 998311",
                    controller: _sacCtrl,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InfoLabel(
                  label: "Unit",
                  child: TextBox(
                    placeholder: "Nos, Kg...",
                    controller: _unitCtrl,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: InfoLabel(
                  label: "Quantity",
                  child: NumberBox<double>(
                    value: qty,
                    onChanged: (v) => setState(() => qty = v ?? 1),
                    min: 0.1,
                    mode: SpinButtonPlacementMode.inline,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InfoLabel(
                  label: "Price",
                  child: NumberBox<double>(
                    value: price,
                    onChanged: (v) => setState(() => price = v ?? 0),
                    mode: SpinButtonPlacementMode.inline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: InfoLabel(
                  label: "Discount",
                  child: NumberBox<double>(
                    value: discount,
                    onChanged: (v) => setState(() => discount = v ?? 0),
                    mode: SpinButtonPlacementMode.inline,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InfoLabel(
                  label: "GST Rate",
                  child: ComboBox<double>(
                    value: gst,
                    items: [0.0, 5.0, 12.0, 18.0, 28.0]
                        .map((r) => ComboBoxItem(value: r, child: Text("$r%")))
                        .toList(),
                    onChanged: (v) => setState(() => gst = v ?? 0),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Button(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context)),
        FilledButton(
            child: const Text("Save"),
            onPressed: () {
              final newItem = InvoiceItem(
                description: _descCtrl.text,
                quantity: qty,
                amount: price,
                discount: discount,
                gstRate: gst,
                unit: _unitCtrl.text,
                sacCode: _sacCtrl.text,
              );
              widget.onSave(newItem);
              Navigator.pop(context);
            }),
      ],
    );
  }
}
