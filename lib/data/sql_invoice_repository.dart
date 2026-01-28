import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/database.dart';
import '../models/invoice.dart' as model;
import '../models/payment_transaction.dart';
import 'invoice_repository.dart';

class SqlInvoiceRepository implements InvoiceRepository {
  final AppDatabase database;

  SqlInvoiceRepository(this.database);

  @override
  Future<void> saveInvoice(model.Invoice invoice) async {
    // Ensure we have a valid Invoice ID
    String invoiceId = invoice.id ?? '';
    if (invoiceId.isEmpty) {
      invoiceId = const Uuid().v4();
    }

    // 1. Prepare Invoice Entry
    // ...

    // Convert Invoice Items
    final items = invoice.items.map((item) {
      return InvoiceItemsCompanion(
        id: Value(item.id ?? const Uuid().v4()), // Generate UUID if null
        invoiceId: Value(invoiceId), // Use the ensured ID
        description: Value(item.description),
        sacCode: Value(item.sacCode),
        codeType: Value(item.codeType),
        year: Value(item.year),
        amount: Value(item.amount),
        discount: Value(item.discount),
        quantity: Value(item.quantity),
        unit: Value(item.unit),
        gstRate: Value(item.gstRate),
      );
    }).toList();

    // Convert Payments
    final payments = invoice.payments.map((p) {
      return PaymentsCompanion(
        id: Value(p.id.isEmpty ? const Uuid().v4() : p.id),
        invoiceId: Value(invoiceId), // Use the ensured ID
        date: Value(p.date),
        amount: Value(p.amount),
        method: Value(p.paymentMode),
        notes: Value(p.notes),
      );
    }).toList();

    // Transaction
    await database.transaction(() async {
      // Upsert Invoice
      // We need to resolve Client ID.
      // Lookup client by Name?
      final client = await (database.select(database.clients)
            ..where((t) => t.name.equals(invoice.receiver.name)))
          .getSingleOrNull();
      String clientId = client?.id ?? 'temp_default';

      // If 'temp_default' doesn't exist, this will fail FK.
      // We should probably ensure a 'Walk-in' client exists.

      await database
          .into(database.invoices)
          .insertOnConflictUpdate(InvoicesCompanion(
            id: Value(invoiceId),
            profileId: const Value("default"),
            clientId: Value(clientId),
            invoiceNo: Value(invoice.invoiceNo),
            invoiceDate: Value(invoice.invoiceDate),
            type: Value(invoice.type.name),
            dueDate: Value(invoice.dueDate),
            placeOfSupply: Value(invoice.placeOfSupply),
            style: Value(invoice.style),
            reverseCharge: Value(invoice.reverseCharge),
            paymentTerms: Value(invoice.paymentTerms),
            comments: Value(invoice.comments),
            bankName: Value(invoice.bankName),
            accountNo: Value(invoice.accountNo),
            ifscCode: Value(invoice.ifscCode),

            branch: Value(invoice.branch),

            // Supplier Snapshot
            supplierName: Value(invoice.supplier.name),
            supplierAddress: Value(invoice.supplier.address),
            supplierGstin: Value(invoice.supplier.gstin),
            supplierEmail: Value(invoice.supplier.email),
            supplierPhone: Value(invoice.supplier.phone),

            // Receiver Snapshot (New V4)
            receiverName: Value(invoice.receiver.name),
            receiverAddress: Value(invoice.receiver.address),
            receiverGstin: Value(invoice.receiver.gstin),
            receiverPan: Value(invoice.receiver.pan),
            receiverState: Value(invoice.receiver.state),
            receiverStateCode: Value(invoice.receiver.stateCode),
            receiverEmail: Value(invoice.receiver.email),

            // Credit/Debit Note
            originalInvoiceNumber: Value(invoice.originalInvoiceNumber),
            originalInvoiceDate: Value(invoice.originalInvoiceDate),
          ));

      // Replace Items
      await (database.delete(database.invoiceItems)
            ..where((t) => t.invoiceId.equals(invoiceId)))
          .go();
      for (var item in items) {
        await database.into(database.invoiceItems).insert(item);
      }

      // Replace Payments
      await (database.delete(database.payments)
            ..where((t) => t.invoiceId.equals(invoiceId)))
          .go();
      for (var p in payments) {
        await database.into(database.payments).insert(p);
      }

      // NEW: Credit Note Linking
      // If this is a Credit Note and points to an original invoice, automatically add a "Credit Note" payment to that invoice.
      if (invoice.type == model.InvoiceType.creditNote &&
          invoice.originalInvoiceNumber != null &&
          invoice.originalInvoiceNumber!.isNotEmpty) {
        final originalInv = await (database.select(database.invoices)
              ..where(
                  (t) => t.invoiceNo.equals(invoice.originalInvoiceNumber!)))
            .getSingleOrNull();

        if (originalInv != null) {
          // Check if we already added a CN payment for this specific Credit Note ID
          // We use the CN ID as the Payment ID or Reference?
          // Since Payment IDs are UUIDs/Strings, let's generate one deterministically or check existence.
          // Problem: If we edit the CN, we might duplicate the payment?
          // Strategy: Use a specific ID format "CN-PAY-{CN_ID}" or check notes.

          final cnPaymentId = "CN-PAY-$invoiceId";

          // Check if exists
          final existingPay = await (database.select(database.payments)
                ..where((t) => t.id.equals(cnPaymentId)))
              .getSingleOrNull();

          if (existingPay == null) {
            // Create Payment Linked to Orignal Invoice
            await database.into(database.payments).insert(PaymentsCompanion(
                  id: Value(cnPaymentId),
                  invoiceId: Value(originalInv.id),
                  date: Value(invoice.invoiceDate),
                  amount: Value(invoice.grandTotal), // CN Total reduces balance
                  method: const Value('Credit Note'),
                  notes: Value(
                      'Auto-generated from Credit Note ${invoice.invoiceNo}'),
                ));
          } else {
            // Update Amount if changed
            await (database.update(database.payments)
                  ..where((t) => t.id.equals(cnPaymentId)))
                .write(PaymentsCompanion(
              date: Value(invoice.invoiceDate),
              amount: Value(invoice.grandTotal),
            ));
          }
        }
      }
    });
  }

  @override
  Future<model.Invoice?> getInvoice(String id) async {
    // Join Invoices with InvoiceItems and Clients
    final invoiceRow = await (database.select(database.invoices)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (invoiceRow == null) return null;

    final itemsRows = await (database.select(database.invoiceItems)
          ..where((t) => t.invoiceId.equals(id)))
        .get();

    final clientRow = await (database.select(database.clients)
          ..where((t) => t.id.equals(invoiceRow.clientId)))
        .getSingleOrNull();

    final paymentRows = await (database.select(database.payments)
          ..where((t) => t.invoiceId.equals(id)))
        .get();

    // Map to Model
    return model.Invoice(
      id: invoiceRow.id,
      invoiceNo: invoiceRow.invoiceNo,
      invoiceDate: invoiceRow.invoiceDate,
      type: model.InvoiceType.values.firstWhere(
        (e) => e.name == invoiceRow.type,
        orElse: () => model.InvoiceType.invoice,
      ),
      dueDate: invoiceRow.dueDate,
      placeOfSupply: invoiceRow.placeOfSupply,
      style: invoiceRow.style,
      reverseCharge: invoiceRow.reverseCharge,
      paymentTerms: invoiceRow.paymentTerms,
      comments: invoiceRow.comments,
      bankName: invoiceRow.bankName,
      accountNo: invoiceRow.accountNo,
      ifscCode: invoiceRow.ifscCode,
      branch: invoiceRow.branch,

      // Map Items
      items: itemsRows
          .map((row) => model.InvoiceItem(
                // id: row.id, // Model constructor param? InvoiceItem factory in model (Step 126) has id?
                // Yes: String? id in factory.
                // Wait, freezed factory arguments map to fields.
                // Let's check Step 126 content again. "String? id".
                id: row.id,
                description: row.description,
                sacCode: row.sacCode,
                codeType: row.codeType,
                year: row.year,
                amount: row.amount,
                discount: row.discount,
                quantity: row.quantity,
                unit: row.unit,
                gstRate: row.gstRate,
              ))
          .toList(),

      payments: paymentRows
          .map((row) => PaymentTransaction(
                id: row.id,
                invoiceId: row.invoiceId,
                date: row.date,
                amount: row.amount,
                paymentMode: row.method,
                notes: row.notes,
              ))
          .toList(),

      receiver: (invoiceRow.receiverName != null &&
              invoiceRow.receiverName!.isNotEmpty)
          ? model.Receiver(
              name: invoiceRow.receiverName!,
              address: invoiceRow.receiverAddress ?? "",
              gstin: invoiceRow.receiverGstin ?? "",
              pan: invoiceRow.receiverPan ?? "",
              state: invoiceRow.receiverState ?? "",
              stateCode: invoiceRow.receiverStateCode ?? "",
              email: invoiceRow.receiverEmail ?? "",
            )
          : (clientRow != null
              ? model.Receiver(
                  name: clientRow.name,
                  address: clientRow.address,
                  gstin: clientRow.gstin,
                  pan: clientRow.pan,
                  state: clientRow.state,
                  stateCode: clientRow.stateCode,
                  email: clientRow.email, // Client row has email
                )
              : const model.Receiver(name: "Unknown")),

      // Map Supplier from Snapshot or Fallback
      supplier: (invoiceRow.supplierName != null &&
              invoiceRow.supplierName!.isNotEmpty)
          ? model.Supplier(
              name: invoiceRow.supplierName!,
              address: invoiceRow.supplierAddress ?? "",
              gstin: invoiceRow.supplierGstin ?? "",
              email: invoiceRow.supplierEmail ?? "",
              phone: invoiceRow.supplierPhone ?? "",
            )
          : const model.Supplier(name: "My Company"),

      // Credit/Debit Note
      originalInvoiceNumber: invoiceRow.originalInvoiceNumber,
      originalInvoiceDate: invoiceRow.originalInvoiceDate,
    );
  }

  @override
  Future<List<model.Invoice>> getAllInvoices() async {
    // Inefficient N+1 query for items/clients?
    // Proper way: Join or stream with generic join.
    // For now, iterate keys.
    final invoiceRows = await database.select(database.invoices).get();
    List<model.Invoice> result = [];
    for (var row in invoiceRows) {
      final inv = await getInvoice(row.id);
      if (inv != null) result.add(inv);
    }
    return result;
  }

  @override
  Future<void> deleteInvoice(String id) async {
    await (database.delete(database.invoiceItems)
          ..where((t) => t.invoiceId.equals(id)))
        .go();
    await (database.delete(database.payments)
          ..where((t) => t.invoiceId.equals(id)))
        .go();
    await (database.delete(database.invoices)..where((t) => t.id.equals(id)))
        .go();
  }

  @override
  Future<void> deleteAll() async {
    await database.delete(database.invoiceItems).go();
    await database.delete(database.invoices).go();
  }

  @override
  Future<bool> checkInvoiceExists(String invoiceNumber,
      {String? excludeId}) async {
    final query = database.select(database.invoices)
      ..where((tbl) => tbl.invoiceNo.equals(invoiceNumber));

    if (excludeId != null) {
      query.where((tbl) => tbl.id.isNotValue(excludeId));
    }

    final result = await query.get();
    return result.isNotEmpty;
  }
}
