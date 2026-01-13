import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/client.dart';
import '../../../../providers/client_provider.dart';
import '../../../../utils/validators.dart';
import '../../../../utils/constants.dart';

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
  Widget build(BuildContext context) {
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
                onChanged: (v) => name = v,
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: "Address",
              child: TextFormBox(
                placeholder: "Full Address",
                onChanged: (v) => address = v,
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
                      onChanged: (v) => gstin = v,
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
                          .map((e) =>
                              AutoSuggestBoxItem<String>(value: e, label: e))
                          .toList(),
                      onSelected: (item) {
                        setState(() {
                          state = item.value ?? "";
                          _stateCtrl.text = state;
                        });
                      },
                      onChanged: (text, reason) {
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
                      onChanged: (v) => email = v,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InfoLabel(
                    label: "Phone",
                    child: TextBox(
                      placeholder: "Mobile / Landline",
                      onChanged: (v) => phone = v,
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
            onPressed: () => Navigator.pop(context)),
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

              if (mounted) {
                widget.onClientAdded(newClient);
                Navigator.pop(ctx);
                displayInfoBar(ctx,
                    builder: (c, close) => InfoBar(
                        title: const Text("Success"),
                        content: const Text("Client added successfully"),
                        severity: InfoBarSeverity.success,
                        onClose: close));
              }
            }),
      ],
    );
  }
}
