import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:indian_formatters/indian_formatters.dart';
import 'package:uuid/uuid.dart';
import 'package:invobharat/models/bank_account.dart' as bank_model;
import 'package:invobharat/providers/bank_provider.dart';
import 'package:invobharat/providers/business_profile_provider.dart';
import 'package:invobharat/utils/validators.dart';

class BankingSettingsTab extends ConsumerWidget {
  const BankingSettingsTab({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final banksAsync = ref.watch(bankListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Bank Accounts",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Button(
              onPressed: () => _showAddEditBankDialog(context, ref),
              child: const Row(
                children: [Icon(FluentIcons.add), Gap(8), Text("Add Bank")],
              ),
            ),
          ],
        ),
        const Gap(20),
        banksAsync.when(
          data: (final banks) {
            if (banks.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    "No bank accounts found. Add one to get started.",
                  ),
                ),
              );
            }
            return Column(
              children: banks.map((final bank) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    child: ListTile(
                      leading: const Icon(FluentIcons.bank),
                      title: Text(bank.bankName),
                      subtitle: Text("${bank.accountNo} (${bank.ifscCode})"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (bank.isDefault)
                            const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Tooltip(
                                message: "Default Bank",
                                child: Icon(
                                  FluentIcons.favorite_star_fill,
                                  color: Colors.warningPrimaryColor,
                                ),
                              ),
                            ),
                          IconButton(
                            icon: const Icon(FluentIcons.edit),
                            onPressed: () => _showAddEditBankDialog(
                              context,
                              ref,
                              bank: bank,
                            ),
                          ),
                          IconButton(
                            icon: Icon(FluentIcons.delete, color: Colors.red),
                            onPressed: () =>
                                _confirmDeleteBank(context, ref, bank),
                          ),
                        ],
                      ),
                      onPressed: () {
                        if (!bank.isDefault) {
                          ref
                              .read(bankListProvider.notifier)
                              .setDefaultBank(bank.id);
                        }
                      },
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: ProgressBar()),
          error: (final err, final stack) => Text("Error: $err"),
        ),
        const Gap(32),
        const Divider(),
        const Gap(20),
        const Text(
          "UPI Details (Shared across all banks)",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Gap(10),
        Row(
          children: [
            Expanded(
              child: InfoLabel(
                label: "UPI ID (VPA)",
                child: TextFormBox(
                  initialValue: ref.watch(businessProfileProvider).upiId,
                  placeholder: "e.g. name@bank",
                  validator: Validators.vpa,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onChanged: (final v) {
                    final profile = ref.read(businessProfileProvider);
                    ref
                        .read(businessProfileListProvider.notifier)
                        .updateProfile(profile.copyWith(upiId: v));
                  },
                ),
              ),
            ),
            const Gap(10),
            Expanded(
              child: InfoLabel(
                label: "UPI Name",
                child: TextFormBox(
                  initialValue: ref.watch(businessProfileProvider).upiName,
                  placeholder: "e.g. Business Name",
                  onChanged: (final v) {
                    final profile = ref.read(businessProfileProvider);
                    ref
                        .read(businessProfileListProvider.notifier)
                        .updateProfile(profile.copyWith(upiName: v));
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showAddEditBankDialog(
    final BuildContext context,
    final WidgetRef ref, {
    final bank_model.BankAccount? bank,
  }) async {
    final nameCtrl = TextEditingController(text: bank?.bankName);
    final accCtrl = TextEditingController(text: bank?.accountNo);
    final ifscCtrl = TextEditingController(text: bank?.ifscCode);
    final branchCtrl = TextEditingController(text: bank?.branch);

    await showDialog<bool>(
      context: context,
      builder: (final context) => ContentDialog(
        title: Text(bank == null ? "Add Bank Account" : "Edit Bank Account"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InfoLabel(
              label: "Bank Name",
              child: TextBox(controller: nameCtrl),
            ),
            const Gap(10),
            InfoLabel(
              label: "Account Number",
              child: TextBox(controller: accCtrl),
            ),
            const Gap(10),
            InfoLabel(
              label: "IFSC Code",
              child: TextBox(
                controller: ifscCtrl,
                onChanged: (final v) {
                  if (v.length >= 4) {
                    final bName = IndianValidators.getBankFromIFSC(v);
                    if (bName != null && nameCtrl.text.isEmpty) {
                      nameCtrl.text = bName;
                    }
                  }
                },
              ),
            ),
            const Gap(10),
            InfoLabel(
              label: "Branch",
              child: TextBox(controller: branchCtrl),
            ),
          ],
        ),
        actions: [
          Button(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty || accCtrl.text.isEmpty) {
                return;
              }
              final profile = ref.read(businessProfileProvider);
              final newBank = bank_model.BankAccount(
                id: bank?.id ?? const Uuid().v4(),
                profileId: profile.id,
                bankName: nameCtrl.text.trim(),
                accountNo: accCtrl.text.trim(),
                ifscCode: ifscCtrl.text.trim(),
                branch: branchCtrl.text.trim(),
                isDefault: bank?.isDefault ?? false,
              );
              await ref.read(bankListProvider.notifier).saveBank(newBank);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(bank == null ? "Add" : "Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteBank(
    final BuildContext context,
    final WidgetRef ref,
    final bank_model.BankAccount bank,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (final context) => ContentDialog(
        title: const Text("Delete Bank Account?"),
        content: Text(
          "Are you sure you want to delete '${bank.bankName}' (${bank.accountNo})?",
        ),
        actions: [
          Button(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.red),
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(bankListProvider.notifier).deleteBank(bank.id);
    }
  }
}
