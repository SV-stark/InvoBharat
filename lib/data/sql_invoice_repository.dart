import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:invobharat/database/database.dart';
import 'package:invobharat/models/invoice.dart' as model;
import 'package:invobharat/models/payment_transaction.dart' as model;
import 'package:invobharat/models/estimate.dart' as model;
import 'package:invobharat/models/recurring_profile.dart' as model;
import 'package:invobharat/data/invoice_repository.dart';

class SqlInvoiceRepository implements InvoiceRepository {
  final AppDatabase database;
  final String profileId;

  SqlInvoiceRepository(this.database, this.profileId);

  @override
  Future<void> saveInvoice(final model.Invoice invoice) async {
    final targetProfileId =
        (invoice.profileId != null && invoice.profileId!.isNotEmpty)
        ? invoice.profileId!
        : profileId;

    // Ensure we have a valid Invoice ID
    String invoiceId = invoice.id ?? '';
    if (invoiceId.isEmpty) {
      invoiceId = const Uuid().v4();
    }

    // Convert Invoice Items
    final items = invoice.items.map((final item) {
      return InvoiceItemsCompanion(
        id: Value(item.id ?? const Uuid().v4()),
        invoiceId: Value(invoiceId),
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
    final payments = invoice.payments.map((final p) {
      return PaymentsCompanion(
        id: Value(p.id.isEmpty ? const Uuid().v4() : p.id),
        invoiceId: Value(invoiceId),
        date: Value(p.date),
        amount: Value(p.amount),
        method: Value(p.paymentMode),
        notes: Value(p.notes),
      );
    }).toList();

    // Transaction
    await database.transaction(() async {
      // 1. Resolve Client ID deterministically
      String? resolvedClientId;
      final gstin = invoice.receiver.gstin.trim();
      if (gstin.isNotEmpty) {
        final matchByGstin =
            await (database.select(database.clients)..where(
                  (final t) =>
                      t.profileId.equals(targetProfileId) &
                      t.gstin.equals(gstin),
                ))
                .getSingleOrNull();
        if (matchByGstin != null) {
          resolvedClientId = matchByGstin.id;
        }
      }

      if (resolvedClientId == null && invoice.receiver.name.trim().isNotEmpty) {
        final matchesByName =
            await (database.select(database.clients)..where(
                  (final t) =>
                      t.profileId.equals(targetProfileId) &
                      t.name.equals(invoice.receiver.name.trim()),
                ))
                .get();
        if (matchesByName.length == 1) {
          resolvedClientId = matchesByName.first.id;
        } else if (matchesByName.length > 1) {
          final exact = matchesByName.where(
            (final c) =>
                (invoice.receiver.phone.isNotEmpty &&
                    c.phone == invoice.receiver.phone) ||
                (invoice.receiver.email.isNotEmpty &&
                    c.email == invoice.receiver.email) ||
                (invoice.receiver.state.isNotEmpty &&
                    c.state == invoice.receiver.state),
          );
          resolvedClientId = exact.isNotEmpty
              ? exact.first.id
              : matchesByName.first.id;
        }
      }

      // 2. Atomic Sequence Increment
      final String finalInvoiceNo = invoice.invoiceNo;
      if (invoice.id == null || invoice.id!.isEmpty) {
        final profile = await (database.select(
          database.businessProfiles,
        )..where((final t) => t.id.equals(targetProfileId))).getSingleOrNull();

        if (profile != null) {
          final expectedNo =
              "${profile.invoiceSeries}${profile.invoiceSequence.toString().padLeft(3, '0')}";

          if (finalInvoiceNo == expectedNo) {
            await (database.update(
              database.businessProfiles,
            )..where((final t) => t.id.equals(targetProfileId))).write(
              BusinessProfilesCompanion(
                invoiceSequence: Value(profile.invoiceSequence + 1),
              ),
            );
          }
        }
      }

      await database
          .into(database.invoices)
          .insertOnConflictUpdate(
            InvoicesCompanion(
              id: Value(invoiceId),
              profileId: Value(targetProfileId),
              clientId: Value(resolvedClientId),
              invoiceNo: Value(finalInvoiceNo),
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

              supplierName: Value(invoice.supplier.name),
              supplierAddress: Value(invoice.supplier.address),
              supplierGstin: Value(invoice.supplier.gstin),
              supplierEmail: Value(invoice.supplier.email),
              supplierPhone: Value(invoice.supplier.phone),

              receiverName: Value(invoice.receiver.name),
              receiverAddress: Value(invoice.receiver.address),
              receiverGstin: Value(invoice.receiver.gstin),
              receiverPan: Value(invoice.receiver.pan),
              receiverState: Value(invoice.receiver.state),
              receiverStateCode: Value(invoice.receiver.stateCode),
              receiverEmail: Value(invoice.receiver.email),
              receiverPhone: Value(invoice.receiver.phone),

              originalInvoiceNumber: Value(invoice.originalInvoiceNumber),
              originalInvoiceDate: Value(invoice.originalInvoiceDate),
              poNumber: Value(invoice.poNumber),
              status: Value(invoice.status),
              sentAt: Value(invoice.sentAt),
              ewayBillNo: Value(invoice.ewayBillNo),
              vehicleNo: Value(invoice.vehicleNo),
              irnNo: Value(invoice.irnNo),
            ),
          );

      // Replace Items
      await (database.delete(
        database.invoiceItems,
      )..where((final t) => t.invoiceId.equals(invoiceId))).go();
      for (var item in items) {
        await database.into(database.invoiceItems).insert(item);
      }

      // Replace Payments
      await (database.delete(
        database.payments,
      )..where((final t) => t.invoiceId.equals(invoiceId))).go();
      for (var p in payments) {
        await database.into(database.payments).insert(p);
      }
    });
  }

  @override
  Future<model.Invoice?> getInvoice(final String id) async {
    final invoiceRow =
        await (database.select(database.invoices)..where(
              (final t) => t.id.equals(id) & t.profileId.equals(profileId),
            ))
            .getSingleOrNull();
    if (invoiceRow == null) return null;

    final itemsRows = await (database.select(
      database.invoiceItems,
    )..where((final t) => t.invoiceId.equals(id))).get();

    final clientId = invoiceRow.clientId;
    final clientRow = clientId != null
        ? await (database.select(
            database.clients,
          )..where((final t) => t.id.equals(clientId))).getSingleOrNull()
        : null;

    final paymentRows = await (database.select(
      database.payments,
    )..where((final t) => t.invoiceId.equals(id))).get();

    return model.Invoice(
      id: invoiceRow.id,
      profileId: invoiceRow.profileId,
      invoiceNo: invoiceRow.invoiceNo,
      invoiceDate: invoiceRow.invoiceDate,
      type: model.InvoiceType.values.firstWhere(
        (final e) => e.name == invoiceRow.type,
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
      items: itemsRows
          .map(
            (final row) => model.InvoiceItem(
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
            ),
          )
          .toList(),
      payments: paymentRows
          .map(
            (final row) => model.PaymentTransaction(
              id: row.id,
              invoiceId: row.invoiceId,
              date: row.date,
              amount: row.amount,
              paymentMode: row.method,
              notes: row.notes,
            ),
          )
          .toList(),
      receiver:
          (invoiceRow.receiverName != null &&
              invoiceRow.receiverName!.isNotEmpty)
          ? model.Receiver(
              name: invoiceRow.receiverName!,
              address: invoiceRow.receiverAddress ?? "",
              gstin: invoiceRow.receiverGstin ?? "",
              pan: invoiceRow.receiverPan ?? "",
              state: invoiceRow.receiverState ?? "",
              stateCode: invoiceRow.receiverStateCode ?? "",
              email: invoiceRow.receiverEmail ?? "",
              phone: invoiceRow.receiverPhone ?? "",
            )
          : (clientRow != null
                ? model.Receiver(
                    name: clientRow.name,
                    address: clientRow.address,
                    gstin: clientRow.gstin,
                    pan: clientRow.pan,
                    state: clientRow.state,
                    stateCode: clientRow.stateCode,
                    email: clientRow.email,
                    phone: clientRow.phone,
                  )
                : const model.Receiver(name: "Unknown")),
      supplier:
          (invoiceRow.supplierName != null &&
              invoiceRow.supplierName!.isNotEmpty)
          ? model.Supplier(
              name: invoiceRow.supplierName!,
              address: invoiceRow.supplierAddress ?? "",
              gstin: invoiceRow.supplierGstin ?? "",
              email: invoiceRow.supplierEmail ?? "",
              phone: invoiceRow.supplierPhone ?? "",
            )
          : const model.Supplier(name: "My Company"),
      originalInvoiceNumber: invoiceRow.originalInvoiceNumber,
      originalInvoiceDate: invoiceRow.originalInvoiceDate,
      poNumber: invoiceRow.poNumber,
      status: invoiceRow.status,
      sentAt: invoiceRow.sentAt,
      ewayBillNo: invoiceRow.ewayBillNo,
      vehicleNo: invoiceRow.vehicleNo,
      irnNo: invoiceRow.irnNo,
    );
  }

  @override
  Future<List<model.Invoice>> getAllInvoices() async {
    final invoiceRows =
        await (database.select(database.invoices)
              ..where((final t) => t.profileId.equals(profileId))
              ..orderBy([
                (final t) => OrderingTerm(
                  expression: t.invoiceDate,
                  mode: OrderingMode.desc,
                ),
              ]))
            .get();
    if (invoiceRows.isEmpty) return [];
    final invoiceIds = invoiceRows.map((final r) => r.id).toList();
    final allItems = await (database.select(
      database.invoiceItems,
    )..where((final t) => t.invoiceId.isIn(invoiceIds))).get();
    final allPayments = await (database.select(
      database.payments,
    )..where((final t) => t.invoiceId.isIn(invoiceIds))).get();

    final clientIds = invoiceRows
        .map((final r) => r.clientId)
        .whereType<String>()
        .toSet()
        .toList();

    final clientRows = clientIds.isNotEmpty
        ? await (database.select(
            database.clients,
          )..where((final t) => t.id.isIn(clientIds))).get()
        : [];

    final Map<String, dynamic> clientMap = <String, dynamic>{
      for (var c in clientRows) c.id: c,
    };

    return _mapInvoices(invoiceRows, allItems, allPayments, clientMap);
  }

  @override
  Future<List<model.Invoice>> getInvoicesPaginated({
    required final int limit,
    required final int offset,
  }) async {
    final invoiceRows =
        await (database.select(database.invoices)
              ..where((final t) => t.profileId.equals(profileId))
              ..orderBy([
                (final t) => OrderingTerm(
                  expression: t.invoiceDate,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(limit, offset: offset))
            .get();
    if (invoiceRows.isEmpty) return [];
    final invoiceIds = invoiceRows.map((final r) => r.id).toSet();
    final allItems = await (database.select(
      database.invoiceItems,
    )..where((final t) => t.invoiceId.isIn(invoiceIds))).get();
    final allPayments = await (database.select(
      database.payments,
    )..where((final t) => t.invoiceId.isIn(invoiceIds))).get();
    final filteredItems = allItems
        .where((final i) => invoiceIds.contains(i.invoiceId))
        .toList();
    final filteredPayments = allPayments
        .where((final p) => invoiceIds.contains(p.invoiceId))
        .toList();

    final clientIds = invoiceRows
        .map((final r) => r.clientId)
        .whereType<String>()
        .toSet()
        .toList();

    final clientRows = clientIds.isNotEmpty
        ? await (database.select(
            database.clients,
          )..where((final t) => t.id.isIn(clientIds))).get()
        : [];

    final Map<String, dynamic> clientMap = <String, dynamic>{
      for (var c in clientRows) c.id: c,
    };

    return _mapInvoices(
      invoiceRows,
      filteredItems,
      filteredPayments,
      clientMap,
    );
  }

  @override
  Future<int> getInvoiceCount() async {
    final result =
        await (database.selectOnly(database.invoices)
              ..addColumns([database.invoices.id.count()])
              ..where(database.invoices.profileId.equals(profileId)))
            .getSingle();
    return result.read<int>(database.invoices.id.count()) ?? 0;
  }

  List<model.Invoice> _mapInvoices(
    final List<dynamic> invoiceRows,
    final List<dynamic> allItems,
    final List<dynamic> allPayments,
    final Map<String, dynamic> clientMap,
  ) {
    return invoiceRows.map((final row) {
      final items = allItems
          .where((final item) => item.invoiceId == row.id)
          .map(
            (final itemRow) => model.InvoiceItem(
              id: itemRow.id,
              description: itemRow.description,
              sacCode: itemRow.sacCode,
              codeType: itemRow.codeType,
              year: itemRow.year,
              amount: itemRow.amount,
              discount: itemRow.discount,
              quantity: itemRow.quantity,
              unit: itemRow.unit,
              gstRate: itemRow.gstRate,
            ),
          )
          .toList();

      final payments = allPayments
          .where((final p) => p.invoiceId == row.id)
          .map(
            (final pRow) => model.PaymentTransaction(
              id: pRow.id,
              invoiceId: pRow.invoiceId,
              date: pRow.date,
              amount: pRow.amount,
              paymentMode: pRow.method,
              notes: pRow.notes,
            ),
          )
          .toList();

      final clientRow = row.clientId != null ? clientMap[row.clientId] : null;

      final receiver =
          (row.receiverName != null && row.receiverName.toString().isNotEmpty)
          ? model.Receiver(
              name: row.receiverName,
              address: row.receiverAddress ?? "",
              gstin: row.receiverGstin ?? "",
              pan: row.receiverPan ?? "",
              state: row.receiverState ?? "",
              stateCode: row.receiverStateCode ?? "",
              email: row.receiverEmail ?? "",
              phone: row.receiverPhone ?? "",
            )
          : (clientRow != null
                ? model.Receiver(
                    name: clientRow.name,
                    address: clientRow.address,
                    gstin: clientRow.gstin,
                    pan: clientRow.pan,
                    state: clientRow.state,
                    stateCode: clientRow.stateCode,
                    email: clientRow.email,
                    phone: clientRow.phone,
                  )
                : const model.Receiver(name: "Unknown"));

      return model.Invoice(
        id: row.id,
        profileId: row.profileId,
        invoiceNo: row.invoiceNo,
        invoiceDate: row.invoiceDate,
        type: model.InvoiceType.values.firstWhere(
          (final e) => e.name == row.type,
          orElse: () => model.InvoiceType.invoice,
        ),
        dueDate: row.dueDate,
        placeOfSupply: row.placeOfSupply,
        style: row.style,
        reverseCharge: row.reverseCharge,
        paymentTerms: row.paymentTerms,
        comments: row.comments,
        bankName: row.bankName,
        accountNo: row.accountNo,
        ifscCode: row.ifscCode,
        branch: row.branch,
        items: items,
        payments: payments,
        supplier: model.Supplier(
          name: row.supplierName ?? "",
          address: row.supplierAddress ?? "",
          gstin: row.supplierGstin ?? "",
          email: row.supplierEmail ?? "",
          phone: row.supplierPhone ?? "",
        ),
        receiver: receiver,
        originalInvoiceNumber: row.originalInvoiceNumber,
        originalInvoiceDate: row.originalInvoiceDate,
        poNumber: row.poNumber,
        status: row.status,
        sentAt: row.sentAt,
        ewayBillNo: row.ewayBillNo,
        vehicleNo: row.vehicleNo,
        irnNo: row.irnNo,
      );
    }).toList();
  }

  @override
  Future<void> deleteInvoice(final String id) async {
    await database.transaction(() async {
      await (database.delete(
        database.invoiceItems,
      )..where((final t) => t.invoiceId.equals(id))).go();
      await (database.delete(
        database.payments,
      )..where((final t) => t.invoiceId.equals(id))).go();
      await (database.delete(database.invoices)..where(
            (final t) => t.id.equals(id) & t.profileId.equals(profileId),
          ))
          .go();
    });
  }

  @override
  Future<void> deleteAll() async {
    await database.transaction(() async {
      final invoices = await (database.select(
        database.invoices,
      )..where((final t) => t.profileId.equals(profileId))).get();
      final ids = invoices.map((final i) => i.id).toList();
      if (ids.isNotEmpty) {
        await (database.delete(
          database.invoiceItems,
        )..where((final t) => t.invoiceId.isIn(ids))).go();
        await (database.delete(
          database.payments,
        )..where((final t) => t.invoiceId.isIn(ids))).go();
      }
      await (database.delete(
        database.invoices,
      )..where((final t) => t.profileId.equals(profileId))).go();
    });
  }

  @override
  Future<bool> checkInvoiceExists(
    final String invoiceNumber, {
    final String? excludeId,
    final DateTime? invoiceDate,
  }) async {
    if (invoiceNumber.trim().isEmpty) return false;

    final query = database.select(database.invoices)
      ..where(
        (final tbl) =>
            tbl.invoiceNo.equals(invoiceNumber.trim()) &
            tbl.profileId.equals(profileId),
      );

    if (excludeId != null && excludeId.trim().isNotEmpty) {
      query.where((final tbl) => tbl.id.equals(excludeId.trim()).not());
    }

    final targetDate = invoiceDate ?? DateTime.now();
    final fyStartYear = targetDate.month >= 4
        ? targetDate.year
        : targetDate.year - 1;
    final fyStart = DateTime(fyStartYear, 4);
    final fyEnd = DateTime(fyStartYear + 1, 3, 31, 23, 59, 59);

    query.where((final tbl) => tbl.invoiceDate.isBetweenValues(fyStart, fyEnd));

    final result = await query.get();
    return result.isNotEmpty;
  }

  @override
  Future<int> getMaxSequenceForPrefix(
    final String prefix, {
    final DateTime? invoiceDate,
  }) async {
    final targetDate = invoiceDate ?? DateTime.now();
    final fyStartYear = targetDate.month >= 4
        ? targetDate.year
        : targetDate.year - 1;
    final fyStart = DateTime(fyStartYear, 4);
    final fyEnd = DateTime(fyStartYear + 1, 3, 31, 23, 59, 59);

    final query = database.select(database.invoices)
      ..where(
        (final tbl) =>
            tbl.profileId.equals(profileId) &
            tbl.invoiceDate.isBetweenValues(fyStart, fyEnd),
      );

    final rows = await query.get();
    int maxSeq = 0;
    final cleanPrefix = prefix.trim();

    for (final row in rows) {
      final no = row.invoiceNo.trim();
      if (cleanPrefix.isEmpty) {
        final numMatch = RegExp(r'^\d+$').firstMatch(no);
        if (numMatch != null) {
          final val = int.tryParse(numMatch.group(0) ?? '') ?? 0;
          if (val > maxSeq) maxSeq = val;
        }
      } else if (no.startsWith(cleanPrefix)) {
        final rest = no.substring(cleanPrefix.length).trim();
        final numMatch = RegExp(r'^\d+').firstMatch(rest);
        if (numMatch != null) {
          final val = int.tryParse(numMatch.group(0) ?? '') ?? 0;
          if (val > maxSeq) maxSeq = val;
        }
      }
    }

    return maxSeq;
  }

  @override
  Future<void> saveEstimate(final model.Estimate estimate) async {
    final estimateId = estimate.id.isEmpty ? const Uuid().v4() : estimate.id;
    final items = estimate.items.map((final item) {
      return EstimateItemsCompanion(
        id: Value(item.id ?? const Uuid().v4()),
        estimateId: Value(estimateId),
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

    await database.transaction(() async {
      await database
          .into(database.estimates)
          .insertOnConflictUpdate(
            EstimatesCompanion(
              id: Value(estimateId),
              profileId: Value(profileId),
              estimateNo: Value(estimate.estimateNo),
              date: Value(estimate.date),
              expiryDate: Value(estimate.expiryDate),
              status: Value(estimate.status ?? 'Draft'),
              notes: Value(estimate.notes),
              terms: Value(estimate.terms),
              poNumber: Value(estimate.poNumber),
              supplierName: Value(estimate.supplier.name),
              supplierAddress: Value(estimate.supplier.address),
              supplierGstin: Value(estimate.supplier.gstin),
              supplierEmail: Value(estimate.supplier.email),
              supplierPhone: Value(estimate.supplier.phone),
              supplierState: Value(estimate.supplier.state),
              receiverName: Value(estimate.receiver.name),
              receiverAddress: Value(estimate.receiver.address),
              receiverGstin: Value(estimate.receiver.gstin),
              receiverPan: Value(estimate.receiver.pan),
              receiverState: Value(estimate.receiver.state),
              receiverStateCode: Value(estimate.receiver.stateCode),
              receiverEmail: Value(estimate.receiver.email),
              receiverPhone: Value(estimate.receiver.phone),
            ),
          );

      await (database.delete(
        database.estimateItems,
      )..where((final t) => t.estimateId.equals(estimateId))).go();

      for (final item in items) {
        await database.into(database.estimateItems).insert(item);
      }
    });
  }

  @override
  Future<List<model.Estimate>> getAllEstimates() async {
    final estimateRows =
        await (database.select(database.estimates)
              ..where((final t) => t.profileId.equals(profileId))
              ..orderBy([
                (final t) =>
                    OrderingTerm(expression: t.date, mode: OrderingMode.desc),
              ]))
            .get();
    if (estimateRows.isEmpty) return [];

    final estimateIds = estimateRows.map((final r) => r.id).toList();
    final allItems = await (database.select(
      database.estimateItems,
    )..where((final t) => t.estimateId.isIn(estimateIds))).get();

    return estimateRows.map((final row) {
      final items = allItems
          .where((final item) => item.estimateId == row.id)
          .map(
            (final itemRow) => model.InvoiceItem(
              id: itemRow.id,
              description: itemRow.description,
              sacCode: itemRow.sacCode,
              codeType: itemRow.codeType,
              year: itemRow.year,
              amount: itemRow.amount,
              discount: itemRow.discount,
              quantity: itemRow.quantity,
              unit: itemRow.unit,
              gstRate: itemRow.gstRate,
            ),
          )
          .toList();

      return model.Estimate(
        id: row.id,
        estimateNo: row.estimateNo,
        date: row.date,
        expiryDate: row.expiryDate,
        status: row.status,
        notes: row.notes,
        terms: row.terms,
        poNumber: row.poNumber,
        supplier: model.Supplier(
          name: row.supplierName ?? "",
          address: row.supplierAddress ?? "",
          gstin: row.supplierGstin ?? "",
          email: row.supplierEmail ?? "",
          phone: row.supplierPhone ?? "",
          state: row.supplierState ?? "",
        ),
        receiver: model.Receiver(
          name: row.receiverName ?? "",
          address: row.receiverAddress ?? "",
          gstin: row.receiverGstin ?? "",
          pan: row.receiverPan ?? "",
          state: row.receiverState ?? "",
          stateCode: row.receiverStateCode ?? "",
          email: row.receiverEmail ?? "",
          phone: row.receiverPhone ?? "",
        ),
        items: items,
      );
    }).toList();
  }

  @override
  Future<void> deleteEstimate(final String id) async {
    await database.transaction(() async {
      await (database.delete(
        database.estimateItems,
      )..where((final t) => t.estimateId.equals(id))).go();
      await (database.delete(database.estimates)..where(
            (final t) => t.id.equals(id) & t.profileId.equals(profileId),
          ))
          .go();
    });
  }

  @override
  Future<void> saveRecurringProfile(
    final model.RecurringProfile profile,
  ) async {
    final targetProfileId = profile.profileId.isNotEmpty
        ? profile.profileId
        : profileId;
    await database
        .into(database.recurringProfilesTable)
        .insertOnConflictUpdate(
          RecurringProfilesTableCompanion(
            id: Value(profile.id),
            profileId: Value(targetProfileId),
            interval: Value(profile.interval.index),
            nextRunDate: Value(profile.nextRunDate),
            lastRunDate: Value(profile.lastRunDate),
            isActive: Value(profile.isActive),
            dueDays: Value(profile.dueDays),
            baseInvoiceJson: Value(jsonEncode(profile.baseInvoice.toJson())),
          ),
        );
  }

  @override
  Future<List<model.RecurringProfile>> getAllRecurringProfiles() async {
    final rows = await (database.select(
      database.recurringProfilesTable,
    )..where((final t) => t.profileId.equals(profileId))).get();

    return rows.map((final row) {
      return model.RecurringProfile(
        id: row.id,
        profileId: row.profileId,
        interval: model.RecurringInterval.values[row.interval],
        nextRunDate: row.nextRunDate,
        lastRunDate: row.lastRunDate,
        isActive: row.isActive,
        dueDays: row.dueDays,
        baseInvoice: model.Invoice.fromJson(jsonDecode(row.baseInvoiceJson)),
      );
    }).toList();
  }

  @override
  Future<void> deleteRecurringProfile(final String id) async {
    await (database.delete(database.recurringProfilesTable)
          ..where((final t) => t.id.equals(id) & t.profileId.equals(profileId)))
        .go();
  }
}
