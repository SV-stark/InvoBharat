import 'dart:async';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invobharat/models/client.dart';
import 'package:invobharat/providers/client_provider.dart';
import 'package:invobharat/utils/validators.dart';
import 'package:invobharat/utils/constants.dart';

class WizardAddClientDialog extends ConsumerStatefulWidget {
  final Function(Client) onClientAdded;

  const WizardAddClientDialog({super.key, required this.onClientAdded});

  @override
  ConsumerState<WizardAddClientDialog> createState() =>
      _WizardAddClientDialogState();
}

class _WizardAddClientDialogState extends ConsumerState<WizardAddClientDialog> {
  final _formKey = GlobalKey<FormState>();
  String name = "";
  String address = "";
  String gstin = "";
  String state = "Karnataka"; // Default
  String email = "";
  String phone = "";

  // Controllers to avoid recreation if we used them,
  // but here we are using simple string assignment which is fine for simple forms,
  // EXCEPT AutoSuggestBox and TextFormBox might need controllers if we want to pre-fill or manage state perfectly.
  // The original code used `onChanged: (v) => name = v`.
  // However, AutoSuggestBox for state used `controller: TextEditingController(text: state)`. This was the leak.

  late TextEditingController _stateCtrl;

  @override
  void initState() {
    super.initState();
    _stateCtrl = TextEditingController(text: state);
  }

  @override
  void dispose() {
    _stateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return ContentDialog(
      title: const Text("Add New Client"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InfoLabel(
              label: "Client Name *",
              child: TextFormBox(
                placeholder: "Company or Person Name",
                validator: Validators.required,
                onChanged: (final v) => name = v,
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: "Address",
              child: TextFormBox(
                placeholder: "Full Address",
                onChanged: (final v) => address = v,
                maxLines: 2,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: InfoLabel(
                    label: "GSTIN",
                    child: TextFormBox(
                      placeholder: "Optional",
                      validator: Validators.gstin,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onChanged: (final v) => gstin = v,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InfoLabel(
                    label: "State",
                    child: AutoSuggestBox<String>(
                      placeholder: "e.g. Karnataka",
                      controller: _stateCtrl,
                      items: IndianStates.states
                          .map(
                            (final e) =>
                                AutoSuggestBoxItem<String>(value: e, label: e),
                          )
                          .toList(),
                      onSelected: (final item) {
                        setState(() {
                          state = item.value ?? "";
                          _stateCtrl.text = state;
                        });
                      },
                      onChanged: (final text, final reason) {
                        if (reason == TextChangedReason.userInput) {
                          state = text;
                        }
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
                    label: "Email",
                    child: TextBox(
                      placeholder: "billing@client.com",
                      onChanged: (final v) => email = v,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InfoLabel(
                    label: "Phone",
                    child: TextBox(
                      placeholder: "Mobile / Landline",
                      onChanged: (final v) => phone = v,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        Button(
          child: const Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          child: const Text("Save Client"),
          onPressed: () async {
            if (!_formKey.currentState!.validate()) return;
            // Capture context for async gap
            final ctx = context;

            final newClient = Client(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: name,
              address: address,
              gstin: gstin,
              state: state,
              email: email,
              phone: phone,
            );

            await ref.read(clientRepositoryProvider).saveClient(newClient);
            ref.invalidate(clientListProvider);

            if (!ctx.mounted) return;
            widget.onClientAdded(newClient);
            Navigator.pop(ctx);
            unawaited(
              displayInfoBar(
                ctx,
                builder: (final c, final close) => InfoBar(
                  title: const Text("Success"),
                  content: const Text("Client added successfully"),
                  severity: InfoBarSeverity.success,
                  onClose: close,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
