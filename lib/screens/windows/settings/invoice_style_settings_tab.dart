import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:invobharat/providers/business_profile_provider.dart';
import 'package:invobharat/providers/app_config_provider.dart';
import 'package:invobharat/providers/invoice_series_provider.dart';

class InvoiceStyleSettingsTab extends ConsumerWidget {
  const InvoiceStyleSettingsTab({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final profile = ref.watch(businessProfileProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: InfoLabel(
                label: "Invoice Series Prefix",
                child: TextFormBox(
                  initialValue: profile.invoiceSeries,
                  onChanged: (final v) => ref
                      .read(businessProfileListProvider.notifier)
                      .updateProfile(profile.copyWith(invoiceSeries: v)),
                ),
              ),
            ),
            const Gap(10),
            Expanded(
              child: InfoLabel(
                label: "Current Sequence No",
                child: NumberBox(
                  value: profile.invoiceSequence,
                  onChanged: (final v) {
                    if (v != null) {
                      ref
                          .read(businessProfileListProvider.notifier)
                          .updateProfile(profile.copyWith(invoiceSequence: v));
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        const Gap(10),
        InfoLabel(
          label: "Currency Symbol",
          child: ComboBox<String>(
            value: profile.currency,
            items: [
              '₹',
              '\$',
              '€',
              '£',
              '¥',
            ].map((final e) => ComboBoxItem(value: e, child: Text(e))).toList(),
            onChanged: (final val) {
              if (val != null) {
                ref
                    .read(businessProfileListProvider.notifier)
                    .updateProfile(profile.copyWith(currency: val));
              }
            },
          ),
        ),
        const Gap(10),
        InfoLabel(
          label: "Terms & Conditions",
          child: TextFormBox(
            initialValue: profile.termsAndConditions,
            maxLines: 3,
            onChanged: (final v) => ref
                .read(businessProfileListProvider.notifier)
                .updateProfile(profile.copyWith(termsAndConditions: v)),
          ),
        ),
        const Gap(16),
        const Text(
          "PDF Invoice Configuration",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Gap(10),
        InfoLabel(
          label: "Default Invoice Template",
          child: ComboBox<String>(
            value: ref.watch(appConfigProvider).defaultInvoiceTemplate,
            items: const [
              'Modern',
              'Professional',
              'Minimal',
              'Classic',
              'Corporate',
              'Creative',
            ].map((final e) => ComboBoxItem(value: e, child: Text(e))).toList(),
            onChanged: (final val) {
              if (val != null) {
                ref
                    .read(appConfigProvider.notifier)
                    .setDefaultInvoiceTemplate(val);
              }
            },
          ),
        ),
        const Gap(10),
        ToggleSwitch(
          checked: ref.watch(appConfigProvider).showHsnSummaryInPdf,
          content: const Text("Show HSN-wise tax summary in PDF footer"),
          onChanged: (final v) {
            ref.read(appConfigProvider.notifier).setShowHsnSummaryInPdf(v);
          },
        ),
        const Gap(24),
        const Text(
          "Invoice Number Sequences",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const Gap(10),
        ...ref
            .watch(invoiceSeriesProvider)
            .map(
              (final s) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: InfoLabel(
                        label: "Prefix",
                        child: TextFormBox(
                          initialValue: s.prefix,
                          readOnly: true,
                        ),
                      ),
                    ),
                    const Gap(10),
                    Expanded(
                      child: InfoLabel(
                        label: "Next Sequence No",
                        child: NumberBox(
                          value: s.sequence,
                          onChanged: (final val) {
                            if (val != null) {
                              ref
                                  .read(invoiceSeriesProvider.notifier)
                                  .updateSequence(s.prefix, val);
                            }
                          },
                        ),
                      ),
                    ),
                    const Gap(10),
                    if (ref.watch(invoiceSeriesProvider).length > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 18.0),
                        child: Button(
                          child: Icon(FluentIcons.delete, color: Colors.red),
                          onPressed: () => ref
                              .read(invoiceSeriesProvider.notifier)
                              .removeSeries(s.prefix),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        const Gap(10),
        Button(
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FluentIcons.add),
              Gap(8),
              Text("Add Series Prefix"),
            ],
          ),
          onPressed: () => _showAddSeriesDialog(context, ref),
        ),
      ],
    );
  }

  Future<void> _showAddSeriesDialog(
    final BuildContext context,
    final WidgetRef ref,
  ) async {
    final prefixCtrl = TextEditingController();
    final seqCtrl = TextEditingController(text: "1");
    await showDialog(
      context: context,
      builder: (final context) => ContentDialog(
        title: const Text("Add New Invoice Series"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InfoLabel(
              label: "Prefix (e.g. SRV/)",
              child: TextBox(controller: prefixCtrl),
            ),
            const Gap(10),
            InfoLabel(
              label: "Starting Sequence",
              child: TextBox(controller: seqCtrl),
            ),
          ],
        ),
        actions: [
          Button(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            child: const Text("Add"),
            onPressed: () {
              if (prefixCtrl.text.isNotEmpty) {
                final seq = int.tryParse(seqCtrl.text) ?? 1;
                ref
                    .read(invoiceSeriesProvider.notifier)
                    .addSeries(prefixCtrl.text, seq);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
