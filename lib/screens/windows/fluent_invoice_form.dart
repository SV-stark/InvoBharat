import 'dart:async';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/models/business_profile.dart';
import 'package:invobharat/providers/business_profile_provider.dart';
import 'package:invobharat/providers/invoice_provider.dart';

import 'package:invobharat/models/client.dart';
import 'package:invobharat/providers/client_provider.dart';

import 'package:invobharat/utils/pdf_generator.dart';
import 'package:invobharat/utils/constants.dart';
import 'package:invobharat/utils/validators.dart';
import 'package:invobharat/mixins/invoice_form_mixin.dart';
import 'package:invobharat/widgets/adaptive_widgets.dart'; // NEW Import

// Generates a unique ID

class FluentInvoiceForm extends ConsumerStatefulWidget {
  final Invoice? invoiceToEdit;
  final String? estimateIdToMarkConverted;
  const FluentInvoiceForm({
    super.key,
    this.invoiceToEdit,
    this.estimateIdToMarkConverted,
  });

  @override
  ConsumerState<FluentInvoiceForm> createState() => _FluentInvoiceFormState();
}

class _FluentInvoiceFormState extends ConsumerState<FluentInvoiceForm>
    with InvoiceFormMixin {
  @override
  void initState() {
    super.initState();
    initInvoiceControllers(widget.invoiceToEdit);

    // Sync with provider if editing
    if (widget.invoiceToEdit != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(invoiceProvider.notifier).setInvoice(widget.invoiceToEdit!);
        syncInvoiceControllers(ref.read(invoiceProvider));
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        syncInvoiceControllers(ref.read(invoiceProvider));
      });
    }
  }

  @override
  void dispose() {
    disposeInvoiceControllers();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final invoice = ref.watch(invoiceProvider);
    final profile = ref.watch(businessProfileProvider);

    // No need to manually check controller text empty, mixin handles standard cases usage via controller binding

    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: Text(
          widget.invoiceToEdit != null ? "Edit Invoice" : "New Invoice",
        ),
        leading: Navigator.canPop(context)
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  icon: const Icon(FluentIcons.back),
                  onPressed: () => Navigator.pop(context),
                ),
              )
            : null,
      ),
      bottomBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: FluentTheme.of(context).cardColor,
          border: Border(
            top: BorderSide(
              color: FluentTheme.of(
                context,
              ).resources.dividerStrokeColorDefault,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Button(
              onPressed: () => _showPreview(context, invoice, profile),
              child: const Text("Preview"),
            ),
            const SizedBox(width: 10),
            Button(
              onPressed: () => printInvoice(invoice, profile),
              child: const Text("Print"),
            ),
            const SizedBox(width: 10),
            FilledButton(
              onPressed: () => _saveInvoiceUI(context, invoice),
              child: const Text("Save"),
            ),
          ],
        ),
      ),
      children: [
        Expander(
          header: Text(
            "Invoice Details",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: FluentTheme.of(context).accentColor,
            ),
          ),
          initiallyExpanded: true,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoLabel(
                label: "Invoice Style",
                child: ComboBox<String>(
                  value: invoice.style,
                  items: ['Modern', 'Professional', 'Minimal']
                      .map((final e) => ComboBoxItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (final val) {
                    if (val != null) {
                      ref.read(invoiceProvider.notifier).updateStyle(val);
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: AppTextInput(
                      label: "Invoice No",
                      controller: invoiceNoCtrl,
                      onChanged: (final val) => ref
                          .read(invoiceProvider.notifier)
                          .updateInvoiceNo(val),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InfoLabel(
                      label: "Date",
                      child: DatePicker(
                        selected: invoice.invoiceDate,
                        onChanged: (final date) =>
                            ref.read(invoiceProvider.notifier).updateDate(date),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              InfoLabel(
                label: "Place of Supply",
                child: AutoSuggestBox<String>(
                  controller:
                      posCtrl, // Use mixin controller (renamed from _placeOfSupplyController)
                  items: IndianStates.states
                      .map(
                        (final e) =>
                            AutoSuggestBoxItem<String>(value: e, label: e),
                      )
                      .toList(),
                  onSelected: (final item) {
                    ref
                        .read(invoiceProvider.notifier)
                        .updatePlaceOfSupply(item.value!);
                  },
                  onChanged: (final text, final reason) {
                    if (reason == TextChangedReason.userInput) {
                      ref
                          .read(invoiceProvider.notifier)
                          .updatePlaceOfSupply(text);
                    }
                  },
                  placeholder: "Select State",
                ),
              ),
              const SizedBox(height: 10),
              InfoLabel(
                label: "Reverse Charge",
                child: ComboBox<String>(
                  value: invoice.reverseCharge.isEmpty
                      ? "N"
                      : invoice.reverseCharge,
                  items: const [
                    ComboBoxItem(value: "N", child: Text("No")),
                    ComboBoxItem(value: "Y", child: Text("Yes")),
                  ],
                  onChanged: (final val) {
                    if (val != null) {
                      ref
                          .read(invoiceProvider.notifier)
                          .updateReverseCharge(val);
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              AppTextInput(
                label: "Delivery Address (Optional)",
                controller: deliveryAddressCtrl,
                placeholder: "Leave empty if same as Receiver Address",
                maxLines: 3,
                onChanged: (final val) => ref
                    .read(invoiceProvider.notifier)
                    .updateDeliveryAddress(val),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Parties Section
        Expander(
          header: Text(
            "Parties",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: FluentTheme.of(context).accentColor,
            ),
          ),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Supplier (Read Only)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Supplier",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Card(
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.companyName,
                              style: FluentTheme.of(
                                context,
                              ).typography.bodyStrong,
                            ),
                            Text(
                              profile.gstin,
                              style: FluentTheme.of(context).typography.caption,
                            ),
                            Text(
                              profile.address,
                              style: FluentTheme.of(context).typography.caption,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    HyperlinkButton(
                      child: const Text("Edit in Settings"),
                      onPressed: () {
                        // Ideally navigate to settings, but user can just click Settings tab
                        displayInfoBar(
                          context,
                          builder: (final context, final close) {
                            return InfoBar(
                              title: const Text("Go to Settings"),
                              content: const Text(
                                "Please edit supplier details in the Settings tab.",
                              ),
                              action: IconButton(
                                icon: const Icon(FluentIcons.clear),
                                onPressed: close,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Receiver (Editable)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Receiver (Client)",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(FluentIcons.contact_list),
                          onPressed: () {
                            final clients = ref.read(clientListProvider);
                            _showClientSelector(context, clients);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    AppTextInput(
                      label:
                          "Receiver Name", // Label added conceptually, though UI might just show placeholder
                      controller: receiverNameCtrl,
                      placeholder: "Name",
                      onChanged: (final val) => ref
                          .read(invoiceProvider.notifier)
                          .updateReceiverName(val),
                    ),
                    const SizedBox(height: 5),
                    AppTextInput(
                      label: "Email",
                      controller: receiverEmailCtrl,
                      placeholder: "Email",
                      validator: Validators.email,
                      onChanged: (final val) => ref
                          .read(invoiceProvider.notifier)
                          .updateReceiverEmail(val),
                    ),
                    const SizedBox(height: 5),
                    AppTextInput(
                      label: "GSTIN",
                      controller: receiverGstinCtrl,
                      placeholder: "GSTIN",
                      validator: Validators.gstin,
                      onChanged: (final val) => ref
                          .read(invoiceProvider.notifier)
                          .updateReceiverGstin(val),
                    ),
                    const SizedBox(height: 5),
                    AutoSuggestBox<String>(
                      controller:
                          receiverStateCtrl, // Use mixin controller (AutoSuggest requires controller for text)
                      placeholder: "State",
                      items: IndianStates.states
                          .map(
                            (final e) =>
                                AutoSuggestBoxItem<String>(value: e, label: e),
                          )
                          .toList(),
                      onSelected: (final item) {
                        ref
                            .read(invoiceProvider.notifier)
                            .updateReceiverState(item.value!);
                      },
                      onChanged: (final text, final reason) {
                        if (reason == TextChangedReason.userInput) {
                          ref
                              .read(invoiceProvider.notifier)
                              .updateReceiverState(text);
                        }
                      },
                    ),
                    const SizedBox(height: 5),
                    TextFormBox(
                      placeholder: "State Code (e.g. 29)",
                      initialValue: invoice
                          .receiver
                          .stateCode, // Keep initialValue if we don't track stateCode in mixin (we don't for now, let's proceed)
                      // Actually mixin doesn't have stateCodeCtrl.
                      // Should I add it? Yes to be thorough, but for now I leaving as is to minimize regression risk of missing field.
                      onChanged: (final val) => ref
                          .read(invoiceProvider.notifier)
                          .updateReceiverStateCode(val),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Items",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: FluentTheme.of(context).accentColor,
          ),
        ),
        const SizedBox(height: 10),
        ...invoice.items.asMap().entries.map((final entry) {
          final index = entry.key;
          final item = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppTextInput(
                          label: "Description",
                          initialValue: item.description,
                          placeholder: "Description",
                          onChanged: (final val) => ref
                              .read(invoiceProvider.notifier)
                              .updateItemDescription(index, val),
                        ),
                      ),
                      IconButton(
                        icon: Icon(FluentIcons.delete, color: Colors.red),
                        onPressed: () => ref
                            .read(invoiceProvider.notifier)
                            .removeItem(index),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: ComboBox<String>(
                          value: item.codeType,
                          items: ['SAC', 'HSN']
                              .map(
                                (final e) =>
                                    ComboBoxItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (final val) {
                            if (val != null) {
                              ref
                                  .read(invoiceProvider.notifier)
                                  .updateItemCodeType(index, val);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 5),
                      // Quantity
                      Expanded(
                        child: AppTextInput(
                          label: "Qty",
                          placeholder: "Qty",
                          initialValue: item.quantity.toString(),
                          validator: Validators.doubleValue,
                          onChanged: (final val) => ref
                              .read(invoiceProvider.notifier)
                              .updateItemQuantity(index, val),
                        ),
                      ),
                      const SizedBox(width: 5),
                      // Unit
                      Expanded(
                        child: AppTextInput(
                          label: "Unit",
                          placeholder: "Unit",
                          initialValue: item.unit,
                          onChanged: (final val) => ref
                              .read(invoiceProvider.notifier)
                              .updateItemUnit(index, val),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: AppTextInput(
                          label: "Code",
                          placeholder: "Code",
                          initialValue: item.sacCode,
                          onChanged: (final val) => ref
                              .read(invoiceProvider.notifier)
                              .updateItemSac(index, val),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: AppTextInput(
                          label: "Amount",
                          placeholder: "Amount",
                          initialValue: item.amount == 0
                              ? ""
                              : item.amount.toString(),
                          validator: Validators.doubleValue,
                          onChanged: (final val) => ref
                              .read(invoiceProvider.notifier)
                              .updateItemAmount(index, val),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: AppTextInput(
                          label: "GST %",
                          placeholder: "GST %",
                          initialValue: item.gstRate.toString(),
                          validator: Validators.doubleValue,
                          onChanged: (final val) => ref
                              .read(invoiceProvider.notifier)
                              .updateItemGstRate(index, val),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        Button(
          onPressed: () => ref.read(invoiceProvider.notifier).addItem(),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FluentIcons.add),
              SizedBox(width: 8),
              Text("Add Item"),
            ],
          ),
        ),
        const SizedBox(height: 50),
      ],
    );
  }

  void _saveInvoiceUI(final BuildContext context, final Invoice invoice) async {
    try {
      await saveInvoice(
        invoice: invoice,
        estimateIdToMarkConverted: widget.estimateIdToMarkConverted,
        context: context,
      );

      if (context.mounted) {
        unawaited(
          displayInfoBar(
            context,
            builder: (final context, final close) {
              return InfoBar(
                title: const Text('Success'),
                content: const Text('Invoice saved successfully'),
                action: IconButton(
                  icon: const Icon(FluentIcons.clear),
                  onPressed: close,
                ),
                severity: InfoBarSeverity.success,
              );
            },
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        unawaited(
          displayInfoBar(
            context,
            builder: (final context, final close) => InfoBar(
              title: const Text("Error"),
              content: Text(e.toString()),
              severity: InfoBarSeverity.error,
              onClose: close,
            ),
          ),
        );
      }
    }
  }

  void _showPreview(
    final BuildContext context,
    final Invoice invoice,
    final BusinessProfile profile,
  ) {
    Navigator.push(
      context,
      FluentPageRoute(
        builder: (final context) => ScaffoldPage(
          header: PageHeader(
            title: const Text("Invoice Preview"),
            leading: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: const Icon(FluentIcons.back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          content: PdfPreview(
            build: (final format) => generateInvoicePdf(invoice, profile),
            canChangePageFormat: false,
            initialPageFormat: PdfPageFormat.a4,
            pdfPreviewPageDecoration: BoxDecoration(
              color: FluentTheme.of(context).cardColor,
              boxShadow: const [BoxShadow(blurRadius: 4)],
            ),
          ),
        ),
      ),
    );
  }

  void _showClientSelector(
    final BuildContext context,
    final List<Client> clients,
  ) {
    unawaited(
      showDialog(
        context: context,
        builder: (final context) {
          return ContentDialog(
            title: const Text("Select Client"),
            content: SizedBox(
              height: 300,
              width: 400,
              child: ListView.builder(
                itemCount: clients.length,
                itemBuilder: (final context, final index) {
                  final client = clients[index];
                  return ListTile(
                    title: Text(client.name),
                    subtitle: Text(
                      client.gstin.isNotEmpty
                          ? client.gstin
                          : (client.phone.isNotEmpty
                                ? client.phone
                                : "No details"),
                    ),
                    onPressed: () {
                      onClientSelected(client); // Uses Mixin
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            actions: [
              Button(
                child: const Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        },
      ),
    );
  }
}
