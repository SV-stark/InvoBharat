import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/invoice.dart';
import '../models/payment_transaction.dart';
import 'invoice_repository.dart';

class FileInvoiceRepository implements InvoiceRepository {
  final String profileId;

  FileInvoiceRepository({required this.profileId});

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    // New path structure: .../InvoBharat/profiles/<profileId>/invoices
    final path = '${directory.path}/InvoBharat/profiles/$profileId/invoices';
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return path;
  }

  // Static helper to get path for a specific profile (useful for backups/migration)
  static Future<String> getProfilePath(String pid) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/InvoBharat/profiles/$pid/invoices';
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return path;
  }

  @override
  Future<void> saveInvoice(Invoice invoice) async {
    final path = await _localPath;
    String fileName;

    if (invoice.id != null) {
      fileName = 'inv_${invoice.id}.json';
    } else {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      fileName = 'inv_$id.json';
    }

    final file = File('$path/$fileName');
    await file.writeAsString(jsonEncode(invoice.toJson()));

    // NEW: Credit Note Linking
    if (invoice.type == InvoiceType.creditNote &&
        invoice.originalInvoiceNumber != null &&
        invoice.originalInvoiceNumber!.isNotEmpty) {
      await _linkCreditNoteToOriginal(invoice);
    }
  }

  Future<void> _linkCreditNoteToOriginal(Invoice cn) async {
    try {
      final allInvoices = await getAllInvoices();
      final originalInv = allInvoices.cast<Invoice?>().firstWhere(
            (inv) => inv?.invoiceNo == cn.originalInvoiceNumber,
            orElse: () => null,
          );

      if (originalInv != null) {
        // Check for existing CN payment
        final cnPaymentId = "CN-PAY-${cn.id ?? ''}";
        final existingPaymentIndex =
            originalInv.payments.indexWhere((p) => p.id == cnPaymentId);

        List<PaymentTransaction> updatedPayments =
            List.from(originalInv.payments);

        final newPayment = PaymentTransaction(
          id: cnPaymentId,
          invoiceId: originalInv.id ?? '', // Should handle null id if any
          date: cn.invoiceDate,
          amount: cn.grandTotal,
          paymentMode: 'Credit Note',
          notes: 'Auto-generated from Credit Note ${cn.invoiceNo}',
        );

        if (existingPaymentIndex != -1) {
          updatedPayments[existingPaymentIndex] = newPayment;
        } else {
          updatedPayments.add(newPayment);
        }

        final updatedOriginal = originalInv.copyWith(payments: updatedPayments);

        // Save Original Invoice
        // Reuse saveInvoice? No, infinite loop if not careful.
        // Direct save.
        final path = await _localPath;
        // Find filename for original
        // We know ID is in originalInv.id
        if (originalInv.id != null) {
          final file = File('$path/inv_${originalInv.id}.json');
          await file.writeAsString(jsonEncode(updatedOriginal.toJson()));
        }
      }
    } catch (e) {
      debugPrint("Error linking Credit Note: $e");
    }
  }

  @override
  Future<Invoice?> getInvoice(String id) async {
    try {
      final path = await _localPath;
      final file = File('$path/inv_$id.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        return Invoice.fromJson(jsonDecode(content));
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching invoice $id: $e");
      return null;
    }
  }

  @override
  Future<List<Invoice>> getAllInvoices() async {
    try {
      final path = await _localPath;
      final dir = Directory(path);
      List<Invoice> invoices = [];

      if (!await dir.exists()) return [];

      // Use Stream to avoid blocking
      await for (var file in dir.list(followLinks: false)) {
        if (file is File && file.path.endsWith('.json')) {
          try {
            final String contents = await file.readAsString();
            invoices.add(Invoice.fromJson(jsonDecode(contents)));
          } catch (e) {
            // debugPrint in release might be silenced, but that's fine.
          }
          // Yield to UI thread occasionally to prevent "Not Responding"
          if (invoices.length % 50 == 0) {
            await Future.delayed(Duration.zero);
          }
        }
      }

      // Sort by date desc
      invoices.sort((a, b) => b.invoiceDate.compareTo(a.invoiceDate));
      return invoices;
    } catch (e) {
      debugPrint("Error loading invoices: $e");
      return [];
    }
  }

  // Fetch invoices for a specific profile ID (static or instance method)
  static Future<List<Invoice>> getAllInvoicesForProfile(String pid) async {
    try {
      final path = await getProfilePath(pid);
      final dir = Directory(path);
      List<Invoice> invoices = [];

      if (!dir.existsSync()) return [];

      final List<FileSystemEntity> files = dir.listSync();

      for (var file in files) {
        if (file is File && file.path.endsWith('.json')) {
          final String contents = await file.readAsString();
          try {
            invoices.add(Invoice.fromJson(jsonDecode(contents)));
          } catch (e) {
            debugPrint("Error parsing ${file.path}: $e");
          }
        }
      }
      return invoices;
    } catch (e) {
      debugPrint("Error loading invoices for profile $pid: $e");
      return [];
    }
  }

  @override
  Future<void> deleteInvoice(String id) async {
    final path = await _localPath;
    final file = File('$path/inv_$id.json');
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<void> deleteAll() async {
    final path = await _localPath;
    final dir = Directory(path);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  @override
  Future<bool> checkInvoiceExists(String invoiceNumber,
      {String? excludeId}) async {
    final allInvoices = await getAllInvoices();
    return allInvoices.any((inv) =>
        inv.invoiceNo == invoiceNumber &&
        (excludeId == null || inv.id != excludeId));
  }
}
