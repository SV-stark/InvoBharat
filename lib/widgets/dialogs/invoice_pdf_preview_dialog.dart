import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/models/business_profile.dart';
import 'package:invobharat/utils/pdf_generator.dart';
import 'package:invobharat/providers/app_config_provider.dart';

class InvoicePdfPreviewDialog extends ConsumerStatefulWidget {
  final Invoice invoice;
  final BusinessProfile profile;

  const InvoicePdfPreviewDialog({
    super.key,
    required this.invoice,
    required this.profile,
  });

  static Future<void> show(
    final BuildContext context, {
    required final Invoice invoice,
    required final BusinessProfile profile,
  }) {
    return showDialog(
      context: context,
      builder: (final ctx) =>
          InvoicePdfPreviewDialog(invoice: invoice, profile: profile),
    );
  }

  @override
  ConsumerState<InvoicePdfPreviewDialog> createState() =>
      _InvoicePdfPreviewDialogState();
}

class _InvoicePdfPreviewDialogState
    extends ConsumerState<InvoicePdfPreviewDialog> {
  late String _selectedStyle;
  late bool _showHsnSummary;
  bool _isSaving = false;

  final List<Map<String, dynamic>> _styles = [
    {'name': 'Modern', 'icon': Icons.space_dashboard_rounded},
    {'name': 'Professional', 'icon': Icons.business_center_rounded},
    {'name': 'Minimal', 'icon': Icons.article_outlined},
    {'name': 'Classic', 'icon': Icons.gavel_rounded},
    {'name': 'Corporate', 'icon': Icons.corporate_fare_rounded},
    {'name': 'Creative', 'icon': Icons.brush_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _selectedStyle = widget.invoice.style.isEmpty
        ? 'Modern'
        : widget.invoice.style;
    _showHsnSummary = ref.read(appConfigProvider).showHsnSummaryInPdf;
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final effectiveInvoice = widget.invoice.copyWith(style: _selectedStyle);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 1000,
        height: MediaQuery.of(context).size.height * 0.88,
        color: theme.scaffoldBackgroundColor,
        child: Column(
          children: [
            // Top Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.15),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Invoice Preview",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Invoice #${widget.invoice.invoiceNo.isEmpty ? 'Draft' : widget.invoice.invoiceNo}",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.hintColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // HSN Summary Toggle
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("HSN Summary", style: theme.textTheme.bodySmall),
                          Switch(
                            value: _showHsnSummary,
                            onChanged: (val) {
                              setState(() {
                                _showHsnSummary = val;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: "Close",
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Template Selector Chips Bar
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _styles.map((style) {
                        final String name = style['name'];
                        final IconData icon = style['icon'];
                        final bool isSelected = _selectedStyle == name;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            avatar: Icon(
                              icon,
                              size: 16,
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.primary,
                            ),
                            label: Text(name),
                            selected: isSelected,
                            selectedColor: theme.colorScheme.primary,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 13,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedStyle = name;
                                });
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            // PDF Preview Body
            Expanded(
              child: KeyedSubtree(
                key: ValueKey("pdf_preview_${_selectedStyle}_$_showHsnSummary"),
                child: PdfPreview(
                  build: (format) => generateInvoicePdf(
                    effectiveInvoice,
                    widget.profile,
                    showHsnSummary: _showHsnSummary,
                  ),
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  canDebug: false,
                  actions: [
                    PdfPreviewAction(
                      icon: const Icon(Icons.download_rounded),
                      onPressed: (actionCtx, build, pageFormat) async {
                        if (_isSaving) return;
                        setState(() => _isSaving = true);
                        try {
                          final bytes = await build(pageFormat);
                          final fileName =
                              "Invoice_${effectiveInvoice.invoiceNo.isEmpty ? 'Draft' : effectiveInvoice.invoiceNo}.pdf";
                          await saveInvoicePdf(bytes, fileName);
                          if (actionCtx.mounted) {
                            final messenger = ScaffoldMessenger.maybeOf(
                              actionCtx,
                            );
                            if (messenger != null) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "PDF Saved successfully: $fileName",
                                  ),
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (actionCtx.mounted) {
                            final messenger = ScaffoldMessenger.maybeOf(
                              actionCtx,
                            );
                            if (messenger != null) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text("Failed to save PDF: $e"),
                                ),
                              );
                            }
                          }
                        } finally {
                          if (mounted) setState(() => _isSaving = false);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
