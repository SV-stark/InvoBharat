import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../models/invoice.dart';
import '../utils/pdf_generator.dart';

final invoiceProvider = StateProvider<Invoice>((ref) {
  return Invoice(
    supplier: Supplier(
      name: "Rakesh R S Garg & Co",
      address: "MIDDLE BAZAR, SHIMLA-171001 (HIMACHAL PRADESH)",
      gstin: "02ABIFR3682C1ZF",
      pan: "ABIFR3682C",
      email: "shimla@rsgarg.co.in",
      phone: "9418318830",
    ),
    receiver: Receiver(
      name: "Oberoi Hotels Pvt. Ltd.",
      gstin: "02AAAC03408K1ZT",
    ),
    invoiceDate: DateTime.now(),
    invoiceNo: "RRSG/SML/21",
    placeOfSupply: "HIMACHAL PRADESH (02)",
    bankName: "CANARA BANK",
    branch: "MIDDLE BAZAR",
    accountNo: "120026964730",
    ifscCode: "CNRB0001964",
    items: [
      InvoiceItem(description: "Digital Signature Charges", year: "2025-26", amount: 1428, gstRate: 0), // Base example
      InvoiceItem(description: "Support Charges", sacCode: "998224", year: "2025-26", amount: 484, gstRate: 18),
    ],
  );
});

class InvoiceFormScreen extends ConsumerWidget {
  const InvoiceFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoice = ref.watch(invoiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("InvoBharat Generator")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final pdfBytes = await generateInvoicePdf(invoice);
          await Printing.layoutPdf(onLayout: (_) => pdfBytes);
        },
        label: const Text("Preview PDF"),
        icon: const Icon(Icons.picture_as_pdf),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSectionHeader("Supplier Details"),
            _buildTextField("Name", invoice.supplier.name, (val) => ref.read(invoiceProvider.notifier).update((state) => state..supplier.name = val)),
            _buildTextField("GSTIN", invoice.supplier.gstin, (val) => ref.read(invoiceProvider.notifier).update((state) => state..supplier.gstin = val)),
            
            const SizedBox(height: 20),
            _buildSectionHeader("Receiver Details"),
            _buildTextField("Name", invoice.receiver.name, (val) => ref.read(invoiceProvider.notifier).update((state) => state..receiver.name = val)),
            _buildTextField("GSTIN", invoice.receiver.gstin, (val) => ref.read(invoiceProvider.notifier).update((state) => state..receiver.gstin = val)),

            const SizedBox(height: 20),
            _buildSectionHeader("Items"),
             ...invoice.items.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(children: [
                    _buildTextField("Description", item.description, (val) {
                       // Update item logic (simplified)
                    }),
                     Row(children: [
                       Expanded(child: _buildTextField("Amount", item.amount.toString(), (val) {})),
                       const SizedBox(width: 10),
                       Expanded(child: _buildTextField("GST %", item.gstRate.toString(), (val) {})),
                     ])
                  ]),
                ),
              );
            }).toList(),
            
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(alignment: Alignment.centerLeft, child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
    );
  }

  Widget _buildTextField(String label, String initialValue, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
