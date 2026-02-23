// ignore_for_file: unawaited_futures
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/models/recurring_profile.dart';
import 'package:invobharat/providers/business_profile_provider.dart';
import 'package:invobharat/providers/invoice_provider.dart';
import 'package:invobharat/providers/client_provider.dart';
import 'package:invobharat/providers/recurring_provider.dart';
import 'package:invobharat/models/client.dart';
import 'package:invobharat/utils/validators.dart';
import 'package:invobharat/mixins/invoice_form_mixin.dart';
import 'package:invobharat/widgets/adaptive_widgets.dart';

class FluentRecurringForm extends ConsumerStatefulWidget {
  final RecurringProfile? profileToEdit;
  const FluentRecurringForm({super.key, this.profileToEdit});

  @override
  ConsumerState<FluentRecurringForm> createState() =>
      _FluentRecurringFormState();
}

class _FluentRecurringFormState extends ConsumerState<FluentRecurringForm>
    with InvoiceFormMixin {
  RecurringInterval _interval = RecurringInterval.monthly;
  DateTime _nextRunDate = DateTime.now();
  final TextEditingController dueDaysCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with existing profile data or defaults
    if (widget.profileToEdit != null) {
      _interval = widget.profileToEdit!.interval;
      _nextRunDate = widget.profileToEdit!.nextRunDate;
      dueDaysCtrl.text = widget.profileToEdit!.dueDays?.toString() ?? "7";
      initInvoiceControllers(widget.profileToEdit!.baseInvoice);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(invoiceProvider.notifier)
            .setInvoice(widget.profileToEdit!.baseInvoice);
        syncInvoiceControllers(ref.read(invoiceProvider));
      });
    } else {
      // Initialize with fresh invoice for template
      dueDaysCtrl.text = "7";
      initInvoiceControllers();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(invoiceProvider.notifier).reset();
        syncInvoiceControllers(ref.read(invoiceProvider));
      });
    }
  }

  @override
  void dispose() {
    dueDaysCtrl.dispose();
    disposeInvoiceControllers();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final invoice = ref.watch(invoiceProvider);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () {
          Navigator.maybePop(context);
        },
      },
      child: ScaffoldPage.scrollable(
        header: PageHeader(
          title: Text(
            widget.profileToEdit != null
                ? "Edit Recurring Profile"
                : "New Recurring Profile",
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
                child: const Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: () => _saveProfile(context, invoice),
                child: const Text("Save Recurring Profile"),
              ),
            ],
          ),
        ),
        children: [
          // Schedule Section
          Expander(
            header: const Text(
              "Schedule Settings",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            initiallyExpanded: true,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoLabel(
                  label: "Repeat Interval",
                  child: ComboBox<RecurringInterval>(
                    value: _interval,
                    items: RecurringInterval.values.map((final e) {
                      return ComboBoxItem(
                        value: e,
                        child: Text(e.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (final val) {
                      if (val != null) setState(() => _interval = val);
                    },
                  ),
                ),
                const SizedBox(height: 10),
                InfoLabel(
                  label: "Next Run Date",
                  child: DatePicker(
                    selected: _nextRunDate,
                    onChanged: (final date) =>
                        setState(() => _nextRunDate = date),
                  ),
                ),
                const SizedBox(height: 10),
                AppTextInput(
                  label: "Due Days (Offset)",
                  controller: dueDaysCtrl,
                  placeholder: "e.g. 7",
                  validator: Validators
                      .doubleValue, // Re-using double validator usually fine for int, strictly should be int but dart handles parse.
                  // Or better, let's just use doubleValue which ensures positive number.
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Copied Invoice Form Sections (Simplified)
          Expander(
            header: const Text(
              "Invoice Template Details",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            initiallyExpanded: true,
            content: Column(
              children: [
                // Parties
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Receiver selection
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Client / Receiver",
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
                            label: "Receiver Name",
                            controller: receiverNameCtrl,
                            onChanged: (final val) => ref
                                .read(invoiceProvider.notifier)
                                .updateReceiverName(val),
                          ),
                          const SizedBox(height: 5),
                          AppTextInput(
                            label: "GSTIN",
                            controller: receiverGstinCtrl,
                            validator: Validators.gstin,
                            onChanged: (final val) => ref
                                .read(invoiceProvider.notifier)
                                .updateReceiverGstin(val),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Items
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Items",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Button(
                      child: const Text("Add Item"),
                      onPressed: () =>
                          ref.read(invoiceProvider.notifier).addItem(),
                    ),
                  ],
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
                                icon: Icon(
                                  FluentIcons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => ref
                                    .read(invoiceProvider.notifier)
                                    .removeItem(index),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
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
              ],
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  void _showClientSelector(
    final BuildContext context,
    final List<Client> clients,
  ) {
    if (clients.isEmpty) {
      displayInfoBar(
        context,
        builder: (final ctx, final close) => InfoBar(
          title: const Text("No Clients"),
          content: const Text("Please add a client first."),
          severity: InfoBarSeverity.warning,
          onClose: close,
        ),
      );
      return;
    }
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
                    onClientSelected(client);
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
    );
  }

  Future<void> _saveProfile(
    final BuildContext context,
    final Invoice invoice,
  ) async {
    // Validate
    if (invoice.receiver.name.isEmpty) {
      displayInfoBar(
        context,
        builder: (final ctx, final close) => InfoBar(
          title: const Text("Error"),
          content: const Text("Client name is required"),
          severity: InfoBarSeverity.error,
          onClose: close,
        ),
      );
      return;
    }

    final activeProfileId = ref.read(activeProfileIdProvider);
    if (activeProfileId.isEmpty) return;

    final profile = RecurringProfile(
      id: widget.profileToEdit?.id ?? const Uuid().v4(),
      profileId: activeProfileId,
      interval: _interval,
      nextRunDate: _nextRunDate,
      dueDays: int.tryParse(dueDaysCtrl.text),
      baseInvoice: invoice,
    );

    final notifier = ref.read(recurringListProvider.notifier);
    if (widget.profileToEdit != null) {
      await notifier.updateProfile(profile);
    } else {
      await notifier.addProfile(profile);
    }

    if (context.mounted) {
      Navigator.pop(context);
      displayInfoBar(
        context,
        builder: (final ctx, final close) => InfoBar(
          title: const Text("Success"),
          content: const Text("Recurring profile saved"),
          severity: InfoBarSeverity.success,
          onClose: close,
        ),
      );
    }
  }
}
