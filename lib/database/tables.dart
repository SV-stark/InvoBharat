import 'package:drift/drift.dart';

class BusinessProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get companyName => text()();
  TextColumn get address => text()();
  TextColumn get gstin => text()();
  TextColumn get email => text()();
  TextColumn get phone => text()();
  TextColumn get state => text()();
  IntColumn get colorValue => integer()();
  TextColumn get logoPath => text().nullable()();
  TextColumn get invoiceSeries => text()();
  IntColumn get invoiceSequence => integer()();
  TextColumn get signaturePath => text().nullable()();
  TextColumn get stampPath => text().nullable()();
  TextColumn get termsAndConditions => text()();
  TextColumn get defaultNotes => text()();
  TextColumn get currencySymbol => text()();
  TextColumn get bankName => text()();
  TextColumn get accountNumber => text()();
  TextColumn get ifscCode => text()();
  TextColumn get branchName => text()();
  TextColumn get upiId => text().nullable()();
  TextColumn get upiName => text().nullable()();
  TextColumn get pan => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class Clients extends Table {
  TextColumn get id => text()();
  TextColumn get profileId => text().references(BusinessProfiles, #id)();
  TextColumn get name => text()();
  TextColumn get address => text()();
  TextColumn get gstin => text()();
  TextColumn get pan => text()();
  TextColumn get state => text()();
  TextColumn get stateCode => text()();
  TextColumn get email => text()();
  TextColumn get phone => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class Invoices extends Table {
  TextColumn get id => text()();
  TextColumn get profileId => text().references(BusinessProfiles, #id)();
  TextColumn get clientId => text().references(
      Clients, #id)(); // Optional link? No, receiver is embedded in JSON.
  // In JSON model, 'Supplier' and 'Receiver' are embedded objects.
  // In SQL, normalization suggests using referencing IDs, BUT historic invoices should preserve their snapshot of details.
  // Design Decision: Store ClientId for reference, but also store snapshot of receiver details to handle updates?
  // OR just store the JSON dump of supplier/receiver if we don't need to query by them deeply?
  // Use "TextColumn get receiverSnapshot => text()();" (JSON)
  // Let's stick to normalized for now, but `Invoice` model has `required Receiver receiver`.

  TextColumn get invoiceNo => text()();
  TextColumn get type =>
      text().withDefault(const Constant('invoice'))(); // Stores enum name
  DateTimeColumn get invoiceDate => dateTime()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get placeOfSupply => text()();
  TextColumn get style => text().withDefault(const Constant('Modern'))();
  TextColumn get reverseCharge => text().withDefault(const Constant('N'))();
  TextColumn get paymentTerms => text()();
  TextColumn get comments => text()();

  // Bank details snapshot for this invoice (in case profile changes)
  TextColumn get bankName => text()();
  TextColumn get accountNo => text()();
  TextColumn get ifscCode => text()();
  TextColumn get branch => text()();

  // Supplier Snapshot (Fix for GSTR-1 Import & History)
  TextColumn get supplierName => text().nullable()();
  TextColumn get supplierAddress => text().nullable()();
  TextColumn get supplierGstin => text().nullable()();
  TextColumn get supplierEmail => text().nullable()();
  TextColumn get supplierPhone => text().nullable()();

  // Receiver Snapshot (New V4)
  TextColumn get receiverName => text().nullable()();
  TextColumn get receiverAddress => text().nullable()();
  TextColumn get receiverGstin => text().nullable()();
  TextColumn get receiverPan => text().nullable()();
  TextColumn get receiverState => text().nullable()();
  TextColumn get receiverStateCode => text().nullable()();
  TextColumn get receiverEmail => text().nullable()();

  // Credit/Debit Note Fields
  TextColumn get originalInvoiceNumber => text().nullable()();
  DateTimeColumn get originalInvoiceDate => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class InvoiceItems extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceId => text().references(Invoices, #id)();
  TextColumn get description => text()();
  TextColumn get sacCode => text()();
  TextColumn get codeType => text()();
  TextColumn get year => text()();
  RealColumn get amount => real()();
  RealColumn get discount => real()();
  RealColumn get quantity => real()();
  TextColumn get unit => text()();
  RealColumn get gstRate => real()();

  @override
  Set<Column> get primaryKey => {id};
}

class Payments extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceId => text().references(Invoices, #id)();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get method => text()(); // e.g. Cash, UPI
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
