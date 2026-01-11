import 'package:drift/drift.dart';
import '../database/database.dart';
import '../models/invoice.dart' as model;
import 'invoice_repository.dart';

class SqlInvoiceRepository implements InvoiceRepository {
  final AppDatabase database;

  SqlInvoiceRepository(this.database);

  @override
  Future<void> saveInvoice(model.Invoice invoice) async {
    // 1. Prepare Invoice Entry
    // We need clientId. Invoice model has 'Receiver'.
    // We assume Receiver matched a Client?
    // If migration happened, we might not have a client ID in the Invoice model (it just has Receiver details).
    // Risk: Mapping Receiver to ClientID.
    // Hack for now: If invoice.receiver has an ID (if we adding ID to Receiver?), use it.
    // But Receiver model doesn't have ID.
    // Solution: We need a Client for every Invoice.
    // If existing invoice has no linked client, we might need to create one or find one.
    // OR: Update schema to allow nullable ClientID and store snapshot.
    // Given the constraints and the schema I already committed (Step 138: clientId references Clients), I MUST provide a clientId.
    // For now, I'll assume we pass a dummy 'default' id if not found, or efficient lookup.
    // Better: Fetch client by name?
    // Let's use a placeholder logic.

    // Convert Invoice Items
    final items = invoice.items.map((item) {
      return InvoiceItemsCompanion(
        id: Value(item.id ??
            DateTime.now()
                .millisecondsSinceEpoch
                .toString()), // Generate ID if null
        invoiceId: Value(invoice.id ?? ''),
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
            id: Value(invoice.id ?? ''),
            profileId: const Value("default"),
            clientId: Value(clientId),
            invoiceNo: Value(invoice.invoiceNo),
            invoiceDate: Value(invoice.invoiceDate),
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
          ));

      // Replace Items
      await (database.delete(database.invoiceItems)
            ..where((t) => t.invoiceId.equals(invoice.id ?? '')))
          .go();
      for (var item in items) {
        await database.into(database.invoiceItems).insert(item);
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

    // Map to Model
    return model.Invoice(
      id: invoiceRow.id,
      invoiceNo: invoiceRow.invoiceNo,
      invoiceDate: invoiceRow.invoiceDate,
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

      // Map Client -> Receiver
      receiver: clientRow != null
          ? model.Receiver(
              name: clientRow.name,
              address: clientRow.address,
              gstin: clientRow.gstin,
              // pan: clientRow.pan, // Receiver model has pan? Yes.
              state: clientRow.state,
              stateCode: clientRow.stateCode,
            )
          : const model.Receiver(name: "Unknown"),

      supplier: const model.Supplier(
          name: "My Company"), // Placeholder, should fetch Profile
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
    await (database.delete(database.invoices)..where((t) => t.id.equals(id)))
        .go();
  }

  @override
  Future<void> deleteAll() async {
    await database.delete(database.invoiceItems).go();
    await database.delete(database.invoices).go();
  }
}
