import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/models/hsn_code.dart';
import 'package:invobharat/data/hsn_repository.dart';
import 'package:invobharat/utils/constants.dart';

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
  Widget build(final BuildContext context) {
    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 600),
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
                  child: Consumer(
                    builder: (final context, final ref, _) {
                      return AutoSuggestBox<HsnCode>(
                        controller: _sacCtrl,
                        placeholder: "e.g. 998311",
                        items: HsnRepository.commonCodes.map((final e) {
                          final labelText = "${e.code} - ${e.description}";
                          return AutoSuggestBoxItem<HsnCode>(
                            value: e,
                            label: labelText,
                            child: Text(
                              labelText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onSelected: () {
                              if (_descCtrl.text.isEmpty) {
                                _descCtrl.text = e.description;
                              }
                              if (gst == 0 || gst == 18) {
                                setState(() {
                                  gst = e.rate;
                                });
                              }
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _sacCtrl.text = e.code;
                              });
                            },
                          );
                        }).toList(),
                        onChanged: (final text, final reason) {
                          // No specific action needed on text change, controller handles it
                        },
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InfoLabel(
                  label: "Unit",
                  child: AutoSuggestBox<String>(
                    controller: _unitCtrl,
                    placeholder: "e.g. NOS",
                    items: AppConstants.uqcs.map((final e) {
                      return AutoSuggestBoxItem<String>(
                        value: e.split(' - ').first,
                        label: e,
                        child: Text(
                          e,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onSelected: () {
                          final unitVal = e.split(' - ').first;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _unitCtrl.text = unitVal;
                          });
                        },
                      );
                    }).toList(),
                    onChanged: (final text, final reason) {
                      // No action needed, controller handles user-typed values
                    },
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
                    onChanged: (final v) => setState(() => qty = v ?? 1),
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
                    onChanged: (final v) => setState(() => price = v ?? 0),
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
                    onChanged: (final v) => setState(() => discount = v ?? 0),
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
                        .map(
                          (final r) =>
                              ComboBoxItem(value: r, child: Text("$r%")),
                        )
                        .toList(),
                    onChanged: (final v) => setState(() => gst = v ?? 0),
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
          onPressed: () => Navigator.pop(context),
        ),
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
          },
        ),
      ],
    );
  }
}
