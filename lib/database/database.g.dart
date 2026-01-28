// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $BusinessProfilesTable extends BusinessProfiles
    with TableInfo<$BusinessProfilesTable, BusinessProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BusinessProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _companyNameMeta =
      const VerificationMeta('companyName');
  @override
  late final GeneratedColumn<String> companyName = GeneratedColumn<String>(
      'company_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _gstinMeta = const VerificationMeta('gstin');
  @override
  late final GeneratedColumn<String> gstin = GeneratedColumn<String>(
      'gstin', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
      'state', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorValueMeta =
      const VerificationMeta('colorValue');
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
      'color_value', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _logoPathMeta =
      const VerificationMeta('logoPath');
  @override
  late final GeneratedColumn<String> logoPath = GeneratedColumn<String>(
      'logo_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _invoiceSeriesMeta =
      const VerificationMeta('invoiceSeries');
  @override
  late final GeneratedColumn<String> invoiceSeries = GeneratedColumn<String>(
      'invoice_series', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _invoiceSequenceMeta =
      const VerificationMeta('invoiceSequence');
  @override
  late final GeneratedColumn<int> invoiceSequence = GeneratedColumn<int>(
      'invoice_sequence', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _signaturePathMeta =
      const VerificationMeta('signaturePath');
  @override
  late final GeneratedColumn<String> signaturePath = GeneratedColumn<String>(
      'signature_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _stampPathMeta =
      const VerificationMeta('stampPath');
  @override
  late final GeneratedColumn<String> stampPath = GeneratedColumn<String>(
      'stamp_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _termsAndConditionsMeta =
      const VerificationMeta('termsAndConditions');
  @override
  late final GeneratedColumn<String> termsAndConditions =
      GeneratedColumn<String>('terms_and_conditions', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _defaultNotesMeta =
      const VerificationMeta('defaultNotes');
  @override
  late final GeneratedColumn<String> defaultNotes = GeneratedColumn<String>(
      'default_notes', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _currencySymbolMeta =
      const VerificationMeta('currencySymbol');
  @override
  late final GeneratedColumn<String> currencySymbol = GeneratedColumn<String>(
      'currency_symbol', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bankNameMeta =
      const VerificationMeta('bankName');
  @override
  late final GeneratedColumn<String> bankName = GeneratedColumn<String>(
      'bank_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _accountNumberMeta =
      const VerificationMeta('accountNumber');
  @override
  late final GeneratedColumn<String> accountNumber = GeneratedColumn<String>(
      'account_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ifscCodeMeta =
      const VerificationMeta('ifscCode');
  @override
  late final GeneratedColumn<String> ifscCode = GeneratedColumn<String>(
      'ifsc_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _branchNameMeta =
      const VerificationMeta('branchName');
  @override
  late final GeneratedColumn<String> branchName = GeneratedColumn<String>(
      'branch_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _upiIdMeta = const VerificationMeta('upiId');
  @override
  late final GeneratedColumn<String> upiId = GeneratedColumn<String>(
      'upi_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _upiNameMeta =
      const VerificationMeta('upiName');
  @override
  late final GeneratedColumn<String> upiName = GeneratedColumn<String>(
      'upi_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        companyName,
        address,
        gstin,
        email,
        phone,
        state,
        colorValue,
        logoPath,
        invoiceSeries,
        invoiceSequence,
        signaturePath,
        stampPath,
        termsAndConditions,
        defaultNotes,
        currencySymbol,
        bankName,
        accountNumber,
        ifscCode,
        branchName,
        upiId,
        upiName
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'business_profiles';
  @override
  VerificationContext validateIntegrity(Insertable<BusinessProfile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('company_name')) {
      context.handle(
          _companyNameMeta,
          companyName.isAcceptableOrUnknown(
              data['company_name']!, _companyNameMeta));
    } else if (isInserting) {
      context.missing(_companyNameMeta);
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('gstin')) {
      context.handle(
          _gstinMeta, gstin.isAcceptableOrUnknown(data['gstin']!, _gstinMeta));
    } else if (isInserting) {
      context.missing(_gstinMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
          _stateMeta, state.isAcceptableOrUnknown(data['state']!, _stateMeta));
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
          _colorValueMeta,
          colorValue.isAcceptableOrUnknown(
              data['color_value']!, _colorValueMeta));
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('logo_path')) {
      context.handle(_logoPathMeta,
          logoPath.isAcceptableOrUnknown(data['logo_path']!, _logoPathMeta));
    }
    if (data.containsKey('invoice_series')) {
      context.handle(
          _invoiceSeriesMeta,
          invoiceSeries.isAcceptableOrUnknown(
              data['invoice_series']!, _invoiceSeriesMeta));
    } else if (isInserting) {
      context.missing(_invoiceSeriesMeta);
    }
    if (data.containsKey('invoice_sequence')) {
      context.handle(
          _invoiceSequenceMeta,
          invoiceSequence.isAcceptableOrUnknown(
              data['invoice_sequence']!, _invoiceSequenceMeta));
    } else if (isInserting) {
      context.missing(_invoiceSequenceMeta);
    }
    if (data.containsKey('signature_path')) {
      context.handle(
          _signaturePathMeta,
          signaturePath.isAcceptableOrUnknown(
              data['signature_path']!, _signaturePathMeta));
    }
    if (data.containsKey('stamp_path')) {
      context.handle(_stampPathMeta,
          stampPath.isAcceptableOrUnknown(data['stamp_path']!, _stampPathMeta));
    }
    if (data.containsKey('terms_and_conditions')) {
      context.handle(
          _termsAndConditionsMeta,
          termsAndConditions.isAcceptableOrUnknown(
              data['terms_and_conditions']!, _termsAndConditionsMeta));
    } else if (isInserting) {
      context.missing(_termsAndConditionsMeta);
    }
    if (data.containsKey('default_notes')) {
      context.handle(
          _defaultNotesMeta,
          defaultNotes.isAcceptableOrUnknown(
              data['default_notes']!, _defaultNotesMeta));
    } else if (isInserting) {
      context.missing(_defaultNotesMeta);
    }
    if (data.containsKey('currency_symbol')) {
      context.handle(
          _currencySymbolMeta,
          currencySymbol.isAcceptableOrUnknown(
              data['currency_symbol']!, _currencySymbolMeta));
    } else if (isInserting) {
      context.missing(_currencySymbolMeta);
    }
    if (data.containsKey('bank_name')) {
      context.handle(_bankNameMeta,
          bankName.isAcceptableOrUnknown(data['bank_name']!, _bankNameMeta));
    } else if (isInserting) {
      context.missing(_bankNameMeta);
    }
    if (data.containsKey('account_number')) {
      context.handle(
          _accountNumberMeta,
          accountNumber.isAcceptableOrUnknown(
              data['account_number']!, _accountNumberMeta));
    } else if (isInserting) {
      context.missing(_accountNumberMeta);
    }
    if (data.containsKey('ifsc_code')) {
      context.handle(_ifscCodeMeta,
          ifscCode.isAcceptableOrUnknown(data['ifsc_code']!, _ifscCodeMeta));
    } else if (isInserting) {
      context.missing(_ifscCodeMeta);
    }
    if (data.containsKey('branch_name')) {
      context.handle(
          _branchNameMeta,
          branchName.isAcceptableOrUnknown(
              data['branch_name']!, _branchNameMeta));
    } else if (isInserting) {
      context.missing(_branchNameMeta);
    }
    if (data.containsKey('upi_id')) {
      context.handle(
          _upiIdMeta, upiId.isAcceptableOrUnknown(data['upi_id']!, _upiIdMeta));
    }
    if (data.containsKey('upi_name')) {
      context.handle(_upiNameMeta,
          upiName.isAcceptableOrUnknown(data['upi_name']!, _upiNameMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BusinessProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BusinessProfile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      companyName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}company_name'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address'])!,
      gstin: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gstin'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone'])!,
      state: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}state'])!,
      colorValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color_value'])!,
      logoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}logo_path']),
      invoiceSeries: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_series'])!,
      invoiceSequence: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}invoice_sequence'])!,
      signaturePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}signature_path']),
      stampPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}stamp_path']),
      termsAndConditions: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}terms_and_conditions'])!,
      defaultNotes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}default_notes'])!,
      currencySymbol: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}currency_symbol'])!,
      bankName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bank_name'])!,
      accountNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_number'])!,
      ifscCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ifsc_code'])!,
      branchName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}branch_name'])!,
      upiId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}upi_id']),
      upiName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}upi_name']),
    );
  }

  @override
  $BusinessProfilesTable createAlias(String alias) {
    return $BusinessProfilesTable(attachedDatabase, alias);
  }
}

class BusinessProfile extends DataClass implements Insertable<BusinessProfile> {
  final String id;
  final String companyName;
  final String address;
  final String gstin;
  final String email;
  final String phone;
  final String state;
  final int colorValue;
  final String? logoPath;
  final String invoiceSeries;
  final int invoiceSequence;
  final String? signaturePath;
  final String? stampPath;
  final String termsAndConditions;
  final String defaultNotes;
  final String currencySymbol;
  final String bankName;
  final String accountNumber;
  final String ifscCode;
  final String branchName;
  final String? upiId;
  final String? upiName;
  const BusinessProfile(
      {required this.id,
      required this.companyName,
      required this.address,
      required this.gstin,
      required this.email,
      required this.phone,
      required this.state,
      required this.colorValue,
      this.logoPath,
      required this.invoiceSeries,
      required this.invoiceSequence,
      this.signaturePath,
      this.stampPath,
      required this.termsAndConditions,
      required this.defaultNotes,
      required this.currencySymbol,
      required this.bankName,
      required this.accountNumber,
      required this.ifscCode,
      required this.branchName,
      this.upiId,
      this.upiName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company_name'] = Variable<String>(companyName);
    map['address'] = Variable<String>(address);
    map['gstin'] = Variable<String>(gstin);
    map['email'] = Variable<String>(email);
    map['phone'] = Variable<String>(phone);
    map['state'] = Variable<String>(state);
    map['color_value'] = Variable<int>(colorValue);
    if (!nullToAbsent || logoPath != null) {
      map['logo_path'] = Variable<String>(logoPath);
    }
    map['invoice_series'] = Variable<String>(invoiceSeries);
    map['invoice_sequence'] = Variable<int>(invoiceSequence);
    if (!nullToAbsent || signaturePath != null) {
      map['signature_path'] = Variable<String>(signaturePath);
    }
    if (!nullToAbsent || stampPath != null) {
      map['stamp_path'] = Variable<String>(stampPath);
    }
    map['terms_and_conditions'] = Variable<String>(termsAndConditions);
    map['default_notes'] = Variable<String>(defaultNotes);
    map['currency_symbol'] = Variable<String>(currencySymbol);
    map['bank_name'] = Variable<String>(bankName);
    map['account_number'] = Variable<String>(accountNumber);
    map['ifsc_code'] = Variable<String>(ifscCode);
    map['branch_name'] = Variable<String>(branchName);
    if (!nullToAbsent || upiId != null) {
      map['upi_id'] = Variable<String>(upiId);
    }
    if (!nullToAbsent || upiName != null) {
      map['upi_name'] = Variable<String>(upiName);
    }
    return map;
  }

  BusinessProfilesCompanion toCompanion(bool nullToAbsent) {
    return BusinessProfilesCompanion(
      id: Value(id),
      companyName: Value(companyName),
      address: Value(address),
      gstin: Value(gstin),
      email: Value(email),
      phone: Value(phone),
      state: Value(state),
      colorValue: Value(colorValue),
      logoPath: logoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(logoPath),
      invoiceSeries: Value(invoiceSeries),
      invoiceSequence: Value(invoiceSequence),
      signaturePath: signaturePath == null && nullToAbsent
          ? const Value.absent()
          : Value(signaturePath),
      stampPath: stampPath == null && nullToAbsent
          ? const Value.absent()
          : Value(stampPath),
      termsAndConditions: Value(termsAndConditions),
      defaultNotes: Value(defaultNotes),
      currencySymbol: Value(currencySymbol),
      bankName: Value(bankName),
      accountNumber: Value(accountNumber),
      ifscCode: Value(ifscCode),
      branchName: Value(branchName),
      upiId:
          upiId == null && nullToAbsent ? const Value.absent() : Value(upiId),
      upiName: upiName == null && nullToAbsent
          ? const Value.absent()
          : Value(upiName),
    );
  }

  factory BusinessProfile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BusinessProfile(
      id: serializer.fromJson<String>(json['id']),
      companyName: serializer.fromJson<String>(json['companyName']),
      address: serializer.fromJson<String>(json['address']),
      gstin: serializer.fromJson<String>(json['gstin']),
      email: serializer.fromJson<String>(json['email']),
      phone: serializer.fromJson<String>(json['phone']),
      state: serializer.fromJson<String>(json['state']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      logoPath: serializer.fromJson<String?>(json['logoPath']),
      invoiceSeries: serializer.fromJson<String>(json['invoiceSeries']),
      invoiceSequence: serializer.fromJson<int>(json['invoiceSequence']),
      signaturePath: serializer.fromJson<String?>(json['signaturePath']),
      stampPath: serializer.fromJson<String?>(json['stampPath']),
      termsAndConditions:
          serializer.fromJson<String>(json['termsAndConditions']),
      defaultNotes: serializer.fromJson<String>(json['defaultNotes']),
      currencySymbol: serializer.fromJson<String>(json['currencySymbol']),
      bankName: serializer.fromJson<String>(json['bankName']),
      accountNumber: serializer.fromJson<String>(json['accountNumber']),
      ifscCode: serializer.fromJson<String>(json['ifscCode']),
      branchName: serializer.fromJson<String>(json['branchName']),
      upiId: serializer.fromJson<String?>(json['upiId']),
      upiName: serializer.fromJson<String?>(json['upiName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyName': serializer.toJson<String>(companyName),
      'address': serializer.toJson<String>(address),
      'gstin': serializer.toJson<String>(gstin),
      'email': serializer.toJson<String>(email),
      'phone': serializer.toJson<String>(phone),
      'state': serializer.toJson<String>(state),
      'colorValue': serializer.toJson<int>(colorValue),
      'logoPath': serializer.toJson<String?>(logoPath),
      'invoiceSeries': serializer.toJson<String>(invoiceSeries),
      'invoiceSequence': serializer.toJson<int>(invoiceSequence),
      'signaturePath': serializer.toJson<String?>(signaturePath),
      'stampPath': serializer.toJson<String?>(stampPath),
      'termsAndConditions': serializer.toJson<String>(termsAndConditions),
      'defaultNotes': serializer.toJson<String>(defaultNotes),
      'currencySymbol': serializer.toJson<String>(currencySymbol),
      'bankName': serializer.toJson<String>(bankName),
      'accountNumber': serializer.toJson<String>(accountNumber),
      'ifscCode': serializer.toJson<String>(ifscCode),
      'branchName': serializer.toJson<String>(branchName),
      'upiId': serializer.toJson<String?>(upiId),
      'upiName': serializer.toJson<String?>(upiName),
    };
  }

  BusinessProfile copyWith(
          {String? id,
          String? companyName,
          String? address,
          String? gstin,
          String? email,
          String? phone,
          String? state,
          int? colorValue,
          Value<String?> logoPath = const Value.absent(),
          String? invoiceSeries,
          int? invoiceSequence,
          Value<String?> signaturePath = const Value.absent(),
          Value<String?> stampPath = const Value.absent(),
          String? termsAndConditions,
          String? defaultNotes,
          String? currencySymbol,
          String? bankName,
          String? accountNumber,
          String? ifscCode,
          String? branchName,
          Value<String?> upiId = const Value.absent(),
          Value<String?> upiName = const Value.absent()}) =>
      BusinessProfile(
        id: id ?? this.id,
        companyName: companyName ?? this.companyName,
        address: address ?? this.address,
        gstin: gstin ?? this.gstin,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        state: state ?? this.state,
        colorValue: colorValue ?? this.colorValue,
        logoPath: logoPath.present ? logoPath.value : this.logoPath,
        invoiceSeries: invoiceSeries ?? this.invoiceSeries,
        invoiceSequence: invoiceSequence ?? this.invoiceSequence,
        signaturePath:
            signaturePath.present ? signaturePath.value : this.signaturePath,
        stampPath: stampPath.present ? stampPath.value : this.stampPath,
        termsAndConditions: termsAndConditions ?? this.termsAndConditions,
        defaultNotes: defaultNotes ?? this.defaultNotes,
        currencySymbol: currencySymbol ?? this.currencySymbol,
        bankName: bankName ?? this.bankName,
        accountNumber: accountNumber ?? this.accountNumber,
        ifscCode: ifscCode ?? this.ifscCode,
        branchName: branchName ?? this.branchName,
        upiId: upiId.present ? upiId.value : this.upiId,
        upiName: upiName.present ? upiName.value : this.upiName,
      );
  BusinessProfile copyWithCompanion(BusinessProfilesCompanion data) {
    return BusinessProfile(
      id: data.id.present ? data.id.value : this.id,
      companyName:
          data.companyName.present ? data.companyName.value : this.companyName,
      address: data.address.present ? data.address.value : this.address,
      gstin: data.gstin.present ? data.gstin.value : this.gstin,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      state: data.state.present ? data.state.value : this.state,
      colorValue:
          data.colorValue.present ? data.colorValue.value : this.colorValue,
      logoPath: data.logoPath.present ? data.logoPath.value : this.logoPath,
      invoiceSeries: data.invoiceSeries.present
          ? data.invoiceSeries.value
          : this.invoiceSeries,
      invoiceSequence: data.invoiceSequence.present
          ? data.invoiceSequence.value
          : this.invoiceSequence,
      signaturePath: data.signaturePath.present
          ? data.signaturePath.value
          : this.signaturePath,
      stampPath: data.stampPath.present ? data.stampPath.value : this.stampPath,
      termsAndConditions: data.termsAndConditions.present
          ? data.termsAndConditions.value
          : this.termsAndConditions,
      defaultNotes: data.defaultNotes.present
          ? data.defaultNotes.value
          : this.defaultNotes,
      currencySymbol: data.currencySymbol.present
          ? data.currencySymbol.value
          : this.currencySymbol,
      bankName: data.bankName.present ? data.bankName.value : this.bankName,
      accountNumber: data.accountNumber.present
          ? data.accountNumber.value
          : this.accountNumber,
      ifscCode: data.ifscCode.present ? data.ifscCode.value : this.ifscCode,
      branchName:
          data.branchName.present ? data.branchName.value : this.branchName,
      upiId: data.upiId.present ? data.upiId.value : this.upiId,
      upiName: data.upiName.present ? data.upiName.value : this.upiName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BusinessProfile(')
          ..write('id: $id, ')
          ..write('companyName: $companyName, ')
          ..write('address: $address, ')
          ..write('gstin: $gstin, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('state: $state, ')
          ..write('colorValue: $colorValue, ')
          ..write('logoPath: $logoPath, ')
          ..write('invoiceSeries: $invoiceSeries, ')
          ..write('invoiceSequence: $invoiceSequence, ')
          ..write('signaturePath: $signaturePath, ')
          ..write('stampPath: $stampPath, ')
          ..write('termsAndConditions: $termsAndConditions, ')
          ..write('defaultNotes: $defaultNotes, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('bankName: $bankName, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('ifscCode: $ifscCode, ')
          ..write('branchName: $branchName, ')
          ..write('upiId: $upiId, ')
          ..write('upiName: $upiName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        companyName,
        address,
        gstin,
        email,
        phone,
        state,
        colorValue,
        logoPath,
        invoiceSeries,
        invoiceSequence,
        signaturePath,
        stampPath,
        termsAndConditions,
        defaultNotes,
        currencySymbol,
        bankName,
        accountNumber,
        ifscCode,
        branchName,
        upiId,
        upiName
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BusinessProfile &&
          other.id == this.id &&
          other.companyName == this.companyName &&
          other.address == this.address &&
          other.gstin == this.gstin &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.state == this.state &&
          other.colorValue == this.colorValue &&
          other.logoPath == this.logoPath &&
          other.invoiceSeries == this.invoiceSeries &&
          other.invoiceSequence == this.invoiceSequence &&
          other.signaturePath == this.signaturePath &&
          other.stampPath == this.stampPath &&
          other.termsAndConditions == this.termsAndConditions &&
          other.defaultNotes == this.defaultNotes &&
          other.currencySymbol == this.currencySymbol &&
          other.bankName == this.bankName &&
          other.accountNumber == this.accountNumber &&
          other.ifscCode == this.ifscCode &&
          other.branchName == this.branchName &&
          other.upiId == this.upiId &&
          other.upiName == this.upiName);
}

class BusinessProfilesCompanion extends UpdateCompanion<BusinessProfile> {
  final Value<String> id;
  final Value<String> companyName;
  final Value<String> address;
  final Value<String> gstin;
  final Value<String> email;
  final Value<String> phone;
  final Value<String> state;
  final Value<int> colorValue;
  final Value<String?> logoPath;
  final Value<String> invoiceSeries;
  final Value<int> invoiceSequence;
  final Value<String?> signaturePath;
  final Value<String?> stampPath;
  final Value<String> termsAndConditions;
  final Value<String> defaultNotes;
  final Value<String> currencySymbol;
  final Value<String> bankName;
  final Value<String> accountNumber;
  final Value<String> ifscCode;
  final Value<String> branchName;
  final Value<String?> upiId;
  final Value<String?> upiName;
  final Value<int> rowid;
  const BusinessProfilesCompanion({
    this.id = const Value.absent(),
    this.companyName = const Value.absent(),
    this.address = const Value.absent(),
    this.gstin = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.state = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.logoPath = const Value.absent(),
    this.invoiceSeries = const Value.absent(),
    this.invoiceSequence = const Value.absent(),
    this.signaturePath = const Value.absent(),
    this.stampPath = const Value.absent(),
    this.termsAndConditions = const Value.absent(),
    this.defaultNotes = const Value.absent(),
    this.currencySymbol = const Value.absent(),
    this.bankName = const Value.absent(),
    this.accountNumber = const Value.absent(),
    this.ifscCode = const Value.absent(),
    this.branchName = const Value.absent(),
    this.upiId = const Value.absent(),
    this.upiName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BusinessProfilesCompanion.insert({
    required String id,
    required String companyName,
    required String address,
    required String gstin,
    required String email,
    required String phone,
    required String state,
    required int colorValue,
    this.logoPath = const Value.absent(),
    required String invoiceSeries,
    required int invoiceSequence,
    this.signaturePath = const Value.absent(),
    this.stampPath = const Value.absent(),
    required String termsAndConditions,
    required String defaultNotes,
    required String currencySymbol,
    required String bankName,
    required String accountNumber,
    required String ifscCode,
    required String branchName,
    this.upiId = const Value.absent(),
    this.upiName = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        companyName = Value(companyName),
        address = Value(address),
        gstin = Value(gstin),
        email = Value(email),
        phone = Value(phone),
        state = Value(state),
        colorValue = Value(colorValue),
        invoiceSeries = Value(invoiceSeries),
        invoiceSequence = Value(invoiceSequence),
        termsAndConditions = Value(termsAndConditions),
        defaultNotes = Value(defaultNotes),
        currencySymbol = Value(currencySymbol),
        bankName = Value(bankName),
        accountNumber = Value(accountNumber),
        ifscCode = Value(ifscCode),
        branchName = Value(branchName);
  static Insertable<BusinessProfile> custom({
    Expression<String>? id,
    Expression<String>? companyName,
    Expression<String>? address,
    Expression<String>? gstin,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<String>? state,
    Expression<int>? colorValue,
    Expression<String>? logoPath,
    Expression<String>? invoiceSeries,
    Expression<int>? invoiceSequence,
    Expression<String>? signaturePath,
    Expression<String>? stampPath,
    Expression<String>? termsAndConditions,
    Expression<String>? defaultNotes,
    Expression<String>? currencySymbol,
    Expression<String>? bankName,
    Expression<String>? accountNumber,
    Expression<String>? ifscCode,
    Expression<String>? branchName,
    Expression<String>? upiId,
    Expression<String>? upiName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyName != null) 'company_name': companyName,
      if (address != null) 'address': address,
      if (gstin != null) 'gstin': gstin,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (state != null) 'state': state,
      if (colorValue != null) 'color_value': colorValue,
      if (logoPath != null) 'logo_path': logoPath,
      if (invoiceSeries != null) 'invoice_series': invoiceSeries,
      if (invoiceSequence != null) 'invoice_sequence': invoiceSequence,
      if (signaturePath != null) 'signature_path': signaturePath,
      if (stampPath != null) 'stamp_path': stampPath,
      if (termsAndConditions != null)
        'terms_and_conditions': termsAndConditions,
      if (defaultNotes != null) 'default_notes': defaultNotes,
      if (currencySymbol != null) 'currency_symbol': currencySymbol,
      if (bankName != null) 'bank_name': bankName,
      if (accountNumber != null) 'account_number': accountNumber,
      if (ifscCode != null) 'ifsc_code': ifscCode,
      if (branchName != null) 'branch_name': branchName,
      if (upiId != null) 'upi_id': upiId,
      if (upiName != null) 'upi_name': upiName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BusinessProfilesCompanion copyWith(
      {Value<String>? id,
      Value<String>? companyName,
      Value<String>? address,
      Value<String>? gstin,
      Value<String>? email,
      Value<String>? phone,
      Value<String>? state,
      Value<int>? colorValue,
      Value<String?>? logoPath,
      Value<String>? invoiceSeries,
      Value<int>? invoiceSequence,
      Value<String?>? signaturePath,
      Value<String?>? stampPath,
      Value<String>? termsAndConditions,
      Value<String>? defaultNotes,
      Value<String>? currencySymbol,
      Value<String>? bankName,
      Value<String>? accountNumber,
      Value<String>? ifscCode,
      Value<String>? branchName,
      Value<String?>? upiId,
      Value<String?>? upiName,
      Value<int>? rowid}) {
    return BusinessProfilesCompanion(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      address: address ?? this.address,
      gstin: gstin ?? this.gstin,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      state: state ?? this.state,
      colorValue: colorValue ?? this.colorValue,
      logoPath: logoPath ?? this.logoPath,
      invoiceSeries: invoiceSeries ?? this.invoiceSeries,
      invoiceSequence: invoiceSequence ?? this.invoiceSequence,
      signaturePath: signaturePath ?? this.signaturePath,
      stampPath: stampPath ?? this.stampPath,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      defaultNotes: defaultNotes ?? this.defaultNotes,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      branchName: branchName ?? this.branchName,
      upiId: upiId ?? this.upiId,
      upiName: upiName ?? this.upiName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (companyName.present) {
      map['company_name'] = Variable<String>(companyName.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (gstin.present) {
      map['gstin'] = Variable<String>(gstin.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (logoPath.present) {
      map['logo_path'] = Variable<String>(logoPath.value);
    }
    if (invoiceSeries.present) {
      map['invoice_series'] = Variable<String>(invoiceSeries.value);
    }
    if (invoiceSequence.present) {
      map['invoice_sequence'] = Variable<int>(invoiceSequence.value);
    }
    if (signaturePath.present) {
      map['signature_path'] = Variable<String>(signaturePath.value);
    }
    if (stampPath.present) {
      map['stamp_path'] = Variable<String>(stampPath.value);
    }
    if (termsAndConditions.present) {
      map['terms_and_conditions'] = Variable<String>(termsAndConditions.value);
    }
    if (defaultNotes.present) {
      map['default_notes'] = Variable<String>(defaultNotes.value);
    }
    if (currencySymbol.present) {
      map['currency_symbol'] = Variable<String>(currencySymbol.value);
    }
    if (bankName.present) {
      map['bank_name'] = Variable<String>(bankName.value);
    }
    if (accountNumber.present) {
      map['account_number'] = Variable<String>(accountNumber.value);
    }
    if (ifscCode.present) {
      map['ifsc_code'] = Variable<String>(ifscCode.value);
    }
    if (branchName.present) {
      map['branch_name'] = Variable<String>(branchName.value);
    }
    if (upiId.present) {
      map['upi_id'] = Variable<String>(upiId.value);
    }
    if (upiName.present) {
      map['upi_name'] = Variable<String>(upiName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BusinessProfilesCompanion(')
          ..write('id: $id, ')
          ..write('companyName: $companyName, ')
          ..write('address: $address, ')
          ..write('gstin: $gstin, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('state: $state, ')
          ..write('colorValue: $colorValue, ')
          ..write('logoPath: $logoPath, ')
          ..write('invoiceSeries: $invoiceSeries, ')
          ..write('invoiceSequence: $invoiceSequence, ')
          ..write('signaturePath: $signaturePath, ')
          ..write('stampPath: $stampPath, ')
          ..write('termsAndConditions: $termsAndConditions, ')
          ..write('defaultNotes: $defaultNotes, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('bankName: $bankName, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('ifscCode: $ifscCode, ')
          ..write('branchName: $branchName, ')
          ..write('upiId: $upiId, ')
          ..write('upiName: $upiName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClientsTable extends Clients with TableInfo<$ClientsTable, Client> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES business_profiles (id)'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _gstinMeta = const VerificationMeta('gstin');
  @override
  late final GeneratedColumn<String> gstin = GeneratedColumn<String>(
      'gstin', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _panMeta = const VerificationMeta('pan');
  @override
  late final GeneratedColumn<String> pan = GeneratedColumn<String>(
      'pan', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
      'state', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _stateCodeMeta =
      const VerificationMeta('stateCode');
  @override
  late final GeneratedColumn<String> stateCode = GeneratedColumn<String>(
      'state_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        profileId,
        name,
        address,
        gstin,
        pan,
        state,
        stateCode,
        email,
        phone
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clients';
  @override
  VerificationContext validateIntegrity(Insertable<Client> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('gstin')) {
      context.handle(
          _gstinMeta, gstin.isAcceptableOrUnknown(data['gstin']!, _gstinMeta));
    } else if (isInserting) {
      context.missing(_gstinMeta);
    }
    if (data.containsKey('pan')) {
      context.handle(
          _panMeta, pan.isAcceptableOrUnknown(data['pan']!, _panMeta));
    } else if (isInserting) {
      context.missing(_panMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
          _stateMeta, state.isAcceptableOrUnknown(data['state']!, _stateMeta));
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('state_code')) {
      context.handle(_stateCodeMeta,
          stateCode.isAcceptableOrUnknown(data['state_code']!, _stateCodeMeta));
    } else if (isInserting) {
      context.missing(_stateCodeMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Client map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Client(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address'])!,
      gstin: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gstin'])!,
      pan: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pan'])!,
      state: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}state'])!,
      stateCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}state_code'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone'])!,
    );
  }

  @override
  $ClientsTable createAlias(String alias) {
    return $ClientsTable(attachedDatabase, alias);
  }
}

class Client extends DataClass implements Insertable<Client> {
  final String id;
  final String profileId;
  final String name;
  final String address;
  final String gstin;
  final String pan;
  final String state;
  final String stateCode;
  final String email;
  final String phone;
  const Client(
      {required this.id,
      required this.profileId,
      required this.name,
      required this.address,
      required this.gstin,
      required this.pan,
      required this.state,
      required this.stateCode,
      required this.email,
      required this.phone});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['name'] = Variable<String>(name);
    map['address'] = Variable<String>(address);
    map['gstin'] = Variable<String>(gstin);
    map['pan'] = Variable<String>(pan);
    map['state'] = Variable<String>(state);
    map['state_code'] = Variable<String>(stateCode);
    map['email'] = Variable<String>(email);
    map['phone'] = Variable<String>(phone);
    return map;
  }

  ClientsCompanion toCompanion(bool nullToAbsent) {
    return ClientsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      name: Value(name),
      address: Value(address),
      gstin: Value(gstin),
      pan: Value(pan),
      state: Value(state),
      stateCode: Value(stateCode),
      email: Value(email),
      phone: Value(phone),
    );
  }

  factory Client.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Client(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      name: serializer.fromJson<String>(json['name']),
      address: serializer.fromJson<String>(json['address']),
      gstin: serializer.fromJson<String>(json['gstin']),
      pan: serializer.fromJson<String>(json['pan']),
      state: serializer.fromJson<String>(json['state']),
      stateCode: serializer.fromJson<String>(json['stateCode']),
      email: serializer.fromJson<String>(json['email']),
      phone: serializer.fromJson<String>(json['phone']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'name': serializer.toJson<String>(name),
      'address': serializer.toJson<String>(address),
      'gstin': serializer.toJson<String>(gstin),
      'pan': serializer.toJson<String>(pan),
      'state': serializer.toJson<String>(state),
      'stateCode': serializer.toJson<String>(stateCode),
      'email': serializer.toJson<String>(email),
      'phone': serializer.toJson<String>(phone),
    };
  }

  Client copyWith(
          {String? id,
          String? profileId,
          String? name,
          String? address,
          String? gstin,
          String? pan,
          String? state,
          String? stateCode,
          String? email,
          String? phone}) =>
      Client(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        name: name ?? this.name,
        address: address ?? this.address,
        gstin: gstin ?? this.gstin,
        pan: pan ?? this.pan,
        state: state ?? this.state,
        stateCode: stateCode ?? this.stateCode,
        email: email ?? this.email,
        phone: phone ?? this.phone,
      );
  Client copyWithCompanion(ClientsCompanion data) {
    return Client(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      name: data.name.present ? data.name.value : this.name,
      address: data.address.present ? data.address.value : this.address,
      gstin: data.gstin.present ? data.gstin.value : this.gstin,
      pan: data.pan.present ? data.pan.value : this.pan,
      state: data.state.present ? data.state.value : this.state,
      stateCode: data.stateCode.present ? data.stateCode.value : this.stateCode,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Client(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('gstin: $gstin, ')
          ..write('pan: $pan, ')
          ..write('state: $state, ')
          ..write('stateCode: $stateCode, ')
          ..write('email: $email, ')
          ..write('phone: $phone')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, profileId, name, address, gstin, pan, state, stateCode, email, phone);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Client &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.name == this.name &&
          other.address == this.address &&
          other.gstin == this.gstin &&
          other.pan == this.pan &&
          other.state == this.state &&
          other.stateCode == this.stateCode &&
          other.email == this.email &&
          other.phone == this.phone);
}

class ClientsCompanion extends UpdateCompanion<Client> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> name;
  final Value<String> address;
  final Value<String> gstin;
  final Value<String> pan;
  final Value<String> state;
  final Value<String> stateCode;
  final Value<String> email;
  final Value<String> phone;
  final Value<int> rowid;
  const ClientsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.name = const Value.absent(),
    this.address = const Value.absent(),
    this.gstin = const Value.absent(),
    this.pan = const Value.absent(),
    this.state = const Value.absent(),
    this.stateCode = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClientsCompanion.insert({
    required String id,
    required String profileId,
    required String name,
    required String address,
    required String gstin,
    required String pan,
    required String state,
    required String stateCode,
    required String email,
    required String phone,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        profileId = Value(profileId),
        name = Value(name),
        address = Value(address),
        gstin = Value(gstin),
        pan = Value(pan),
        state = Value(state),
        stateCode = Value(stateCode),
        email = Value(email),
        phone = Value(phone);
  static Insertable<Client> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? name,
    Expression<String>? address,
    Expression<String>? gstin,
    Expression<String>? pan,
    Expression<String>? state,
    Expression<String>? stateCode,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (name != null) 'name': name,
      if (address != null) 'address': address,
      if (gstin != null) 'gstin': gstin,
      if (pan != null) 'pan': pan,
      if (state != null) 'state': state,
      if (stateCode != null) 'state_code': stateCode,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClientsCompanion copyWith(
      {Value<String>? id,
      Value<String>? profileId,
      Value<String>? name,
      Value<String>? address,
      Value<String>? gstin,
      Value<String>? pan,
      Value<String>? state,
      Value<String>? stateCode,
      Value<String>? email,
      Value<String>? phone,
      Value<int>? rowid}) {
    return ClientsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      address: address ?? this.address,
      gstin: gstin ?? this.gstin,
      pan: pan ?? this.pan,
      state: state ?? this.state,
      stateCode: stateCode ?? this.stateCode,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (gstin.present) {
      map['gstin'] = Variable<String>(gstin.value);
    }
    if (pan.present) {
      map['pan'] = Variable<String>(pan.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (stateCode.present) {
      map['state_code'] = Variable<String>(stateCode.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('gstin: $gstin, ')
          ..write('pan: $pan, ')
          ..write('state: $state, ')
          ..write('stateCode: $stateCode, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvoicesTable extends Invoices with TableInfo<$InvoicesTable, Invoice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES business_profiles (id)'));
  static const VerificationMeta _clientIdMeta =
      const VerificationMeta('clientId');
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
      'client_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES clients (id)'));
  static const VerificationMeta _invoiceNoMeta =
      const VerificationMeta('invoiceNo');
  @override
  late final GeneratedColumn<String> invoiceNo = GeneratedColumn<String>(
      'invoice_no', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('invoice'));
  static const VerificationMeta _invoiceDateMeta =
      const VerificationMeta('invoiceDate');
  @override
  late final GeneratedColumn<DateTime> invoiceDate = GeneratedColumn<DateTime>(
      'invoice_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _placeOfSupplyMeta =
      const VerificationMeta('placeOfSupply');
  @override
  late final GeneratedColumn<String> placeOfSupply = GeneratedColumn<String>(
      'place_of_supply', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _styleMeta = const VerificationMeta('style');
  @override
  late final GeneratedColumn<String> style = GeneratedColumn<String>(
      'style', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Modern'));
  static const VerificationMeta _reverseChargeMeta =
      const VerificationMeta('reverseCharge');
  @override
  late final GeneratedColumn<String> reverseCharge = GeneratedColumn<String>(
      'reverse_charge', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('N'));
  static const VerificationMeta _paymentTermsMeta =
      const VerificationMeta('paymentTerms');
  @override
  late final GeneratedColumn<String> paymentTerms = GeneratedColumn<String>(
      'payment_terms', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _commentsMeta =
      const VerificationMeta('comments');
  @override
  late final GeneratedColumn<String> comments = GeneratedColumn<String>(
      'comments', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bankNameMeta =
      const VerificationMeta('bankName');
  @override
  late final GeneratedColumn<String> bankName = GeneratedColumn<String>(
      'bank_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _accountNoMeta =
      const VerificationMeta('accountNo');
  @override
  late final GeneratedColumn<String> accountNo = GeneratedColumn<String>(
      'account_no', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ifscCodeMeta =
      const VerificationMeta('ifscCode');
  @override
  late final GeneratedColumn<String> ifscCode = GeneratedColumn<String>(
      'ifsc_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _branchMeta = const VerificationMeta('branch');
  @override
  late final GeneratedColumn<String> branch = GeneratedColumn<String>(
      'branch', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _supplierNameMeta =
      const VerificationMeta('supplierName');
  @override
  late final GeneratedColumn<String> supplierName = GeneratedColumn<String>(
      'supplier_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _supplierAddressMeta =
      const VerificationMeta('supplierAddress');
  @override
  late final GeneratedColumn<String> supplierAddress = GeneratedColumn<String>(
      'supplier_address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _supplierGstinMeta =
      const VerificationMeta('supplierGstin');
  @override
  late final GeneratedColumn<String> supplierGstin = GeneratedColumn<String>(
      'supplier_gstin', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _supplierEmailMeta =
      const VerificationMeta('supplierEmail');
  @override
  late final GeneratedColumn<String> supplierEmail = GeneratedColumn<String>(
      'supplier_email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _supplierPhoneMeta =
      const VerificationMeta('supplierPhone');
  @override
  late final GeneratedColumn<String> supplierPhone = GeneratedColumn<String>(
      'supplier_phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _receiverNameMeta =
      const VerificationMeta('receiverName');
  @override
  late final GeneratedColumn<String> receiverName = GeneratedColumn<String>(
      'receiver_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _receiverAddressMeta =
      const VerificationMeta('receiverAddress');
  @override
  late final GeneratedColumn<String> receiverAddress = GeneratedColumn<String>(
      'receiver_address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _receiverGstinMeta =
      const VerificationMeta('receiverGstin');
  @override
  late final GeneratedColumn<String> receiverGstin = GeneratedColumn<String>(
      'receiver_gstin', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _receiverPanMeta =
      const VerificationMeta('receiverPan');
  @override
  late final GeneratedColumn<String> receiverPan = GeneratedColumn<String>(
      'receiver_pan', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _receiverStateMeta =
      const VerificationMeta('receiverState');
  @override
  late final GeneratedColumn<String> receiverState = GeneratedColumn<String>(
      'receiver_state', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _receiverStateCodeMeta =
      const VerificationMeta('receiverStateCode');
  @override
  late final GeneratedColumn<String> receiverStateCode =
      GeneratedColumn<String>('receiver_state_code', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _receiverEmailMeta =
      const VerificationMeta('receiverEmail');
  @override
  late final GeneratedColumn<String> receiverEmail = GeneratedColumn<String>(
      'receiver_email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _originalInvoiceNumberMeta =
      const VerificationMeta('originalInvoiceNumber');
  @override
  late final GeneratedColumn<String> originalInvoiceNumber =
      GeneratedColumn<String>('original_invoice_number', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _originalInvoiceDateMeta =
      const VerificationMeta('originalInvoiceDate');
  @override
  late final GeneratedColumn<DateTime> originalInvoiceDate =
      GeneratedColumn<DateTime>('original_invoice_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        profileId,
        clientId,
        invoiceNo,
        type,
        invoiceDate,
        dueDate,
        placeOfSupply,
        style,
        reverseCharge,
        paymentTerms,
        comments,
        bankName,
        accountNo,
        ifscCode,
        branch,
        supplierName,
        supplierAddress,
        supplierGstin,
        supplierEmail,
        supplierPhone,
        receiverName,
        receiverAddress,
        receiverGstin,
        receiverPan,
        receiverState,
        receiverStateCode,
        receiverEmail,
        originalInvoiceNumber,
        originalInvoiceDate
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoices';
  @override
  VerificationContext validateIntegrity(Insertable<Invoice> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(_clientIdMeta,
          clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta));
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('invoice_no')) {
      context.handle(_invoiceNoMeta,
          invoiceNo.isAcceptableOrUnknown(data['invoice_no']!, _invoiceNoMeta));
    } else if (isInserting) {
      context.missing(_invoiceNoMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('invoice_date')) {
      context.handle(
          _invoiceDateMeta,
          invoiceDate.isAcceptableOrUnknown(
              data['invoice_date']!, _invoiceDateMeta));
    } else if (isInserting) {
      context.missing(_invoiceDateMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('place_of_supply')) {
      context.handle(
          _placeOfSupplyMeta,
          placeOfSupply.isAcceptableOrUnknown(
              data['place_of_supply']!, _placeOfSupplyMeta));
    } else if (isInserting) {
      context.missing(_placeOfSupplyMeta);
    }
    if (data.containsKey('style')) {
      context.handle(
          _styleMeta, style.isAcceptableOrUnknown(data['style']!, _styleMeta));
    }
    if (data.containsKey('reverse_charge')) {
      context.handle(
          _reverseChargeMeta,
          reverseCharge.isAcceptableOrUnknown(
              data['reverse_charge']!, _reverseChargeMeta));
    }
    if (data.containsKey('payment_terms')) {
      context.handle(
          _paymentTermsMeta,
          paymentTerms.isAcceptableOrUnknown(
              data['payment_terms']!, _paymentTermsMeta));
    } else if (isInserting) {
      context.missing(_paymentTermsMeta);
    }
    if (data.containsKey('comments')) {
      context.handle(_commentsMeta,
          comments.isAcceptableOrUnknown(data['comments']!, _commentsMeta));
    } else if (isInserting) {
      context.missing(_commentsMeta);
    }
    if (data.containsKey('bank_name')) {
      context.handle(_bankNameMeta,
          bankName.isAcceptableOrUnknown(data['bank_name']!, _bankNameMeta));
    } else if (isInserting) {
      context.missing(_bankNameMeta);
    }
    if (data.containsKey('account_no')) {
      context.handle(_accountNoMeta,
          accountNo.isAcceptableOrUnknown(data['account_no']!, _accountNoMeta));
    } else if (isInserting) {
      context.missing(_accountNoMeta);
    }
    if (data.containsKey('ifsc_code')) {
      context.handle(_ifscCodeMeta,
          ifscCode.isAcceptableOrUnknown(data['ifsc_code']!, _ifscCodeMeta));
    } else if (isInserting) {
      context.missing(_ifscCodeMeta);
    }
    if (data.containsKey('branch')) {
      context.handle(_branchMeta,
          branch.isAcceptableOrUnknown(data['branch']!, _branchMeta));
    } else if (isInserting) {
      context.missing(_branchMeta);
    }
    if (data.containsKey('supplier_name')) {
      context.handle(
          _supplierNameMeta,
          supplierName.isAcceptableOrUnknown(
              data['supplier_name']!, _supplierNameMeta));
    }
    if (data.containsKey('supplier_address')) {
      context.handle(
          _supplierAddressMeta,
          supplierAddress.isAcceptableOrUnknown(
              data['supplier_address']!, _supplierAddressMeta));
    }
    if (data.containsKey('supplier_gstin')) {
      context.handle(
          _supplierGstinMeta,
          supplierGstin.isAcceptableOrUnknown(
              data['supplier_gstin']!, _supplierGstinMeta));
    }
    if (data.containsKey('supplier_email')) {
      context.handle(
          _supplierEmailMeta,
          supplierEmail.isAcceptableOrUnknown(
              data['supplier_email']!, _supplierEmailMeta));
    }
    if (data.containsKey('supplier_phone')) {
      context.handle(
          _supplierPhoneMeta,
          supplierPhone.isAcceptableOrUnknown(
              data['supplier_phone']!, _supplierPhoneMeta));
    }
    if (data.containsKey('receiver_name')) {
      context.handle(
          _receiverNameMeta,
          receiverName.isAcceptableOrUnknown(
              data['receiver_name']!, _receiverNameMeta));
    }
    if (data.containsKey('receiver_address')) {
      context.handle(
          _receiverAddressMeta,
          receiverAddress.isAcceptableOrUnknown(
              data['receiver_address']!, _receiverAddressMeta));
    }
    if (data.containsKey('receiver_gstin')) {
      context.handle(
          _receiverGstinMeta,
          receiverGstin.isAcceptableOrUnknown(
              data['receiver_gstin']!, _receiverGstinMeta));
    }
    if (data.containsKey('receiver_pan')) {
      context.handle(
          _receiverPanMeta,
          receiverPan.isAcceptableOrUnknown(
              data['receiver_pan']!, _receiverPanMeta));
    }
    if (data.containsKey('receiver_state')) {
      context.handle(
          _receiverStateMeta,
          receiverState.isAcceptableOrUnknown(
              data['receiver_state']!, _receiverStateMeta));
    }
    if (data.containsKey('receiver_state_code')) {
      context.handle(
          _receiverStateCodeMeta,
          receiverStateCode.isAcceptableOrUnknown(
              data['receiver_state_code']!, _receiverStateCodeMeta));
    }
    if (data.containsKey('receiver_email')) {
      context.handle(
          _receiverEmailMeta,
          receiverEmail.isAcceptableOrUnknown(
              data['receiver_email']!, _receiverEmailMeta));
    }
    if (data.containsKey('original_invoice_number')) {
      context.handle(
          _originalInvoiceNumberMeta,
          originalInvoiceNumber.isAcceptableOrUnknown(
              data['original_invoice_number']!, _originalInvoiceNumberMeta));
    }
    if (data.containsKey('original_invoice_date')) {
      context.handle(
          _originalInvoiceDateMeta,
          originalInvoiceDate.isAcceptableOrUnknown(
              data['original_invoice_date']!, _originalInvoiceDateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Invoice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Invoice(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_id'])!,
      clientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_id'])!,
      invoiceNo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_no'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      invoiceDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}invoice_date'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date']),
      placeOfSupply: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}place_of_supply'])!,
      style: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}style'])!,
      reverseCharge: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reverse_charge'])!,
      paymentTerms: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_terms'])!,
      comments: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}comments'])!,
      bankName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bank_name'])!,
      accountNo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_no'])!,
      ifscCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ifsc_code'])!,
      branch: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}branch'])!,
      supplierName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}supplier_name']),
      supplierAddress: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}supplier_address']),
      supplierGstin: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}supplier_gstin']),
      supplierEmail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}supplier_email']),
      supplierPhone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}supplier_phone']),
      receiverName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}receiver_name']),
      receiverAddress: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}receiver_address']),
      receiverGstin: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}receiver_gstin']),
      receiverPan: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}receiver_pan']),
      receiverState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}receiver_state']),
      receiverStateCode: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}receiver_state_code']),
      receiverEmail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}receiver_email']),
      originalInvoiceNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}original_invoice_number']),
      originalInvoiceDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}original_invoice_date']),
    );
  }

  @override
  $InvoicesTable createAlias(String alias) {
    return $InvoicesTable(attachedDatabase, alias);
  }
}

class Invoice extends DataClass implements Insertable<Invoice> {
  final String id;
  final String profileId;
  final String clientId;
  final String invoiceNo;
  final String type;
  final DateTime invoiceDate;
  final DateTime? dueDate;
  final String placeOfSupply;
  final String style;
  final String reverseCharge;
  final String paymentTerms;
  final String comments;
  final String bankName;
  final String accountNo;
  final String ifscCode;
  final String branch;
  final String? supplierName;
  final String? supplierAddress;
  final String? supplierGstin;
  final String? supplierEmail;
  final String? supplierPhone;
  final String? receiverName;
  final String? receiverAddress;
  final String? receiverGstin;
  final String? receiverPan;
  final String? receiverState;
  final String? receiverStateCode;
  final String? receiverEmail;
  final String? originalInvoiceNumber;
  final DateTime? originalInvoiceDate;
  const Invoice(
      {required this.id,
      required this.profileId,
      required this.clientId,
      required this.invoiceNo,
      required this.type,
      required this.invoiceDate,
      this.dueDate,
      required this.placeOfSupply,
      required this.style,
      required this.reverseCharge,
      required this.paymentTerms,
      required this.comments,
      required this.bankName,
      required this.accountNo,
      required this.ifscCode,
      required this.branch,
      this.supplierName,
      this.supplierAddress,
      this.supplierGstin,
      this.supplierEmail,
      this.supplierPhone,
      this.receiverName,
      this.receiverAddress,
      this.receiverGstin,
      this.receiverPan,
      this.receiverState,
      this.receiverStateCode,
      this.receiverEmail,
      this.originalInvoiceNumber,
      this.originalInvoiceDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['client_id'] = Variable<String>(clientId);
    map['invoice_no'] = Variable<String>(invoiceNo);
    map['type'] = Variable<String>(type);
    map['invoice_date'] = Variable<DateTime>(invoiceDate);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['place_of_supply'] = Variable<String>(placeOfSupply);
    map['style'] = Variable<String>(style);
    map['reverse_charge'] = Variable<String>(reverseCharge);
    map['payment_terms'] = Variable<String>(paymentTerms);
    map['comments'] = Variable<String>(comments);
    map['bank_name'] = Variable<String>(bankName);
    map['account_no'] = Variable<String>(accountNo);
    map['ifsc_code'] = Variable<String>(ifscCode);
    map['branch'] = Variable<String>(branch);
    if (!nullToAbsent || supplierName != null) {
      map['supplier_name'] = Variable<String>(supplierName);
    }
    if (!nullToAbsent || supplierAddress != null) {
      map['supplier_address'] = Variable<String>(supplierAddress);
    }
    if (!nullToAbsent || supplierGstin != null) {
      map['supplier_gstin'] = Variable<String>(supplierGstin);
    }
    if (!nullToAbsent || supplierEmail != null) {
      map['supplier_email'] = Variable<String>(supplierEmail);
    }
    if (!nullToAbsent || supplierPhone != null) {
      map['supplier_phone'] = Variable<String>(supplierPhone);
    }
    if (!nullToAbsent || receiverName != null) {
      map['receiver_name'] = Variable<String>(receiverName);
    }
    if (!nullToAbsent || receiverAddress != null) {
      map['receiver_address'] = Variable<String>(receiverAddress);
    }
    if (!nullToAbsent || receiverGstin != null) {
      map['receiver_gstin'] = Variable<String>(receiverGstin);
    }
    if (!nullToAbsent || receiverPan != null) {
      map['receiver_pan'] = Variable<String>(receiverPan);
    }
    if (!nullToAbsent || receiverState != null) {
      map['receiver_state'] = Variable<String>(receiverState);
    }
    if (!nullToAbsent || receiverStateCode != null) {
      map['receiver_state_code'] = Variable<String>(receiverStateCode);
    }
    if (!nullToAbsent || receiverEmail != null) {
      map['receiver_email'] = Variable<String>(receiverEmail);
    }
    if (!nullToAbsent || originalInvoiceNumber != null) {
      map['original_invoice_number'] = Variable<String>(originalInvoiceNumber);
    }
    if (!nullToAbsent || originalInvoiceDate != null) {
      map['original_invoice_date'] = Variable<DateTime>(originalInvoiceDate);
    }
    return map;
  }

  InvoicesCompanion toCompanion(bool nullToAbsent) {
    return InvoicesCompanion(
      id: Value(id),
      profileId: Value(profileId),
      clientId: Value(clientId),
      invoiceNo: Value(invoiceNo),
      type: Value(type),
      invoiceDate: Value(invoiceDate),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      placeOfSupply: Value(placeOfSupply),
      style: Value(style),
      reverseCharge: Value(reverseCharge),
      paymentTerms: Value(paymentTerms),
      comments: Value(comments),
      bankName: Value(bankName),
      accountNo: Value(accountNo),
      ifscCode: Value(ifscCode),
      branch: Value(branch),
      supplierName: supplierName == null && nullToAbsent
          ? const Value.absent()
          : Value(supplierName),
      supplierAddress: supplierAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(supplierAddress),
      supplierGstin: supplierGstin == null && nullToAbsent
          ? const Value.absent()
          : Value(supplierGstin),
      supplierEmail: supplierEmail == null && nullToAbsent
          ? const Value.absent()
          : Value(supplierEmail),
      supplierPhone: supplierPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(supplierPhone),
      receiverName: receiverName == null && nullToAbsent
          ? const Value.absent()
          : Value(receiverName),
      receiverAddress: receiverAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(receiverAddress),
      receiverGstin: receiverGstin == null && nullToAbsent
          ? const Value.absent()
          : Value(receiverGstin),
      receiverPan: receiverPan == null && nullToAbsent
          ? const Value.absent()
          : Value(receiverPan),
      receiverState: receiverState == null && nullToAbsent
          ? const Value.absent()
          : Value(receiverState),
      receiverStateCode: receiverStateCode == null && nullToAbsent
          ? const Value.absent()
          : Value(receiverStateCode),
      receiverEmail: receiverEmail == null && nullToAbsent
          ? const Value.absent()
          : Value(receiverEmail),
      originalInvoiceNumber: originalInvoiceNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(originalInvoiceNumber),
      originalInvoiceDate: originalInvoiceDate == null && nullToAbsent
          ? const Value.absent()
          : Value(originalInvoiceDate),
    );
  }

  factory Invoice.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Invoice(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      clientId: serializer.fromJson<String>(json['clientId']),
      invoiceNo: serializer.fromJson<String>(json['invoiceNo']),
      type: serializer.fromJson<String>(json['type']),
      invoiceDate: serializer.fromJson<DateTime>(json['invoiceDate']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      placeOfSupply: serializer.fromJson<String>(json['placeOfSupply']),
      style: serializer.fromJson<String>(json['style']),
      reverseCharge: serializer.fromJson<String>(json['reverseCharge']),
      paymentTerms: serializer.fromJson<String>(json['paymentTerms']),
      comments: serializer.fromJson<String>(json['comments']),
      bankName: serializer.fromJson<String>(json['bankName']),
      accountNo: serializer.fromJson<String>(json['accountNo']),
      ifscCode: serializer.fromJson<String>(json['ifscCode']),
      branch: serializer.fromJson<String>(json['branch']),
      supplierName: serializer.fromJson<String?>(json['supplierName']),
      supplierAddress: serializer.fromJson<String?>(json['supplierAddress']),
      supplierGstin: serializer.fromJson<String?>(json['supplierGstin']),
      supplierEmail: serializer.fromJson<String?>(json['supplierEmail']),
      supplierPhone: serializer.fromJson<String?>(json['supplierPhone']),
      receiverName: serializer.fromJson<String?>(json['receiverName']),
      receiverAddress: serializer.fromJson<String?>(json['receiverAddress']),
      receiverGstin: serializer.fromJson<String?>(json['receiverGstin']),
      receiverPan: serializer.fromJson<String?>(json['receiverPan']),
      receiverState: serializer.fromJson<String?>(json['receiverState']),
      receiverStateCode:
          serializer.fromJson<String?>(json['receiverStateCode']),
      receiverEmail: serializer.fromJson<String?>(json['receiverEmail']),
      originalInvoiceNumber:
          serializer.fromJson<String?>(json['originalInvoiceNumber']),
      originalInvoiceDate:
          serializer.fromJson<DateTime?>(json['originalInvoiceDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'clientId': serializer.toJson<String>(clientId),
      'invoiceNo': serializer.toJson<String>(invoiceNo),
      'type': serializer.toJson<String>(type),
      'invoiceDate': serializer.toJson<DateTime>(invoiceDate),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'placeOfSupply': serializer.toJson<String>(placeOfSupply),
      'style': serializer.toJson<String>(style),
      'reverseCharge': serializer.toJson<String>(reverseCharge),
      'paymentTerms': serializer.toJson<String>(paymentTerms),
      'comments': serializer.toJson<String>(comments),
      'bankName': serializer.toJson<String>(bankName),
      'accountNo': serializer.toJson<String>(accountNo),
      'ifscCode': serializer.toJson<String>(ifscCode),
      'branch': serializer.toJson<String>(branch),
      'supplierName': serializer.toJson<String?>(supplierName),
      'supplierAddress': serializer.toJson<String?>(supplierAddress),
      'supplierGstin': serializer.toJson<String?>(supplierGstin),
      'supplierEmail': serializer.toJson<String?>(supplierEmail),
      'supplierPhone': serializer.toJson<String?>(supplierPhone),
      'receiverName': serializer.toJson<String?>(receiverName),
      'receiverAddress': serializer.toJson<String?>(receiverAddress),
      'receiverGstin': serializer.toJson<String?>(receiverGstin),
      'receiverPan': serializer.toJson<String?>(receiverPan),
      'receiverState': serializer.toJson<String?>(receiverState),
      'receiverStateCode': serializer.toJson<String?>(receiverStateCode),
      'receiverEmail': serializer.toJson<String?>(receiverEmail),
      'originalInvoiceNumber':
          serializer.toJson<String?>(originalInvoiceNumber),
      'originalInvoiceDate': serializer.toJson<DateTime?>(originalInvoiceDate),
    };
  }

  Invoice copyWith(
          {String? id,
          String? profileId,
          String? clientId,
          String? invoiceNo,
          String? type,
          DateTime? invoiceDate,
          Value<DateTime?> dueDate = const Value.absent(),
          String? placeOfSupply,
          String? style,
          String? reverseCharge,
          String? paymentTerms,
          String? comments,
          String? bankName,
          String? accountNo,
          String? ifscCode,
          String? branch,
          Value<String?> supplierName = const Value.absent(),
          Value<String?> supplierAddress = const Value.absent(),
          Value<String?> supplierGstin = const Value.absent(),
          Value<String?> supplierEmail = const Value.absent(),
          Value<String?> supplierPhone = const Value.absent(),
          Value<String?> receiverName = const Value.absent(),
          Value<String?> receiverAddress = const Value.absent(),
          Value<String?> receiverGstin = const Value.absent(),
          Value<String?> receiverPan = const Value.absent(),
          Value<String?> receiverState = const Value.absent(),
          Value<String?> receiverStateCode = const Value.absent(),
          Value<String?> receiverEmail = const Value.absent(),
          Value<String?> originalInvoiceNumber = const Value.absent(),
          Value<DateTime?> originalInvoiceDate = const Value.absent()}) =>
      Invoice(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        clientId: clientId ?? this.clientId,
        invoiceNo: invoiceNo ?? this.invoiceNo,
        type: type ?? this.type,
        invoiceDate: invoiceDate ?? this.invoiceDate,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        placeOfSupply: placeOfSupply ?? this.placeOfSupply,
        style: style ?? this.style,
        reverseCharge: reverseCharge ?? this.reverseCharge,
        paymentTerms: paymentTerms ?? this.paymentTerms,
        comments: comments ?? this.comments,
        bankName: bankName ?? this.bankName,
        accountNo: accountNo ?? this.accountNo,
        ifscCode: ifscCode ?? this.ifscCode,
        branch: branch ?? this.branch,
        supplierName:
            supplierName.present ? supplierName.value : this.supplierName,
        supplierAddress: supplierAddress.present
            ? supplierAddress.value
            : this.supplierAddress,
        supplierGstin:
            supplierGstin.present ? supplierGstin.value : this.supplierGstin,
        supplierEmail:
            supplierEmail.present ? supplierEmail.value : this.supplierEmail,
        supplierPhone:
            supplierPhone.present ? supplierPhone.value : this.supplierPhone,
        receiverName:
            receiverName.present ? receiverName.value : this.receiverName,
        receiverAddress: receiverAddress.present
            ? receiverAddress.value
            : this.receiverAddress,
        receiverGstin:
            receiverGstin.present ? receiverGstin.value : this.receiverGstin,
        receiverPan: receiverPan.present ? receiverPan.value : this.receiverPan,
        receiverState:
            receiverState.present ? receiverState.value : this.receiverState,
        receiverStateCode: receiverStateCode.present
            ? receiverStateCode.value
            : this.receiverStateCode,
        receiverEmail:
            receiverEmail.present ? receiverEmail.value : this.receiverEmail,
        originalInvoiceNumber: originalInvoiceNumber.present
            ? originalInvoiceNumber.value
            : this.originalInvoiceNumber,
        originalInvoiceDate: originalInvoiceDate.present
            ? originalInvoiceDate.value
            : this.originalInvoiceDate,
      );
  Invoice copyWithCompanion(InvoicesCompanion data) {
    return Invoice(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      invoiceNo: data.invoiceNo.present ? data.invoiceNo.value : this.invoiceNo,
      type: data.type.present ? data.type.value : this.type,
      invoiceDate:
          data.invoiceDate.present ? data.invoiceDate.value : this.invoiceDate,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      placeOfSupply: data.placeOfSupply.present
          ? data.placeOfSupply.value
          : this.placeOfSupply,
      style: data.style.present ? data.style.value : this.style,
      reverseCharge: data.reverseCharge.present
          ? data.reverseCharge.value
          : this.reverseCharge,
      paymentTerms: data.paymentTerms.present
          ? data.paymentTerms.value
          : this.paymentTerms,
      comments: data.comments.present ? data.comments.value : this.comments,
      bankName: data.bankName.present ? data.bankName.value : this.bankName,
      accountNo: data.accountNo.present ? data.accountNo.value : this.accountNo,
      ifscCode: data.ifscCode.present ? data.ifscCode.value : this.ifscCode,
      branch: data.branch.present ? data.branch.value : this.branch,
      supplierName: data.supplierName.present
          ? data.supplierName.value
          : this.supplierName,
      supplierAddress: data.supplierAddress.present
          ? data.supplierAddress.value
          : this.supplierAddress,
      supplierGstin: data.supplierGstin.present
          ? data.supplierGstin.value
          : this.supplierGstin,
      supplierEmail: data.supplierEmail.present
          ? data.supplierEmail.value
          : this.supplierEmail,
      supplierPhone: data.supplierPhone.present
          ? data.supplierPhone.value
          : this.supplierPhone,
      receiverName: data.receiverName.present
          ? data.receiverName.value
          : this.receiverName,
      receiverAddress: data.receiverAddress.present
          ? data.receiverAddress.value
          : this.receiverAddress,
      receiverGstin: data.receiverGstin.present
          ? data.receiverGstin.value
          : this.receiverGstin,
      receiverPan:
          data.receiverPan.present ? data.receiverPan.value : this.receiverPan,
      receiverState: data.receiverState.present
          ? data.receiverState.value
          : this.receiverState,
      receiverStateCode: data.receiverStateCode.present
          ? data.receiverStateCode.value
          : this.receiverStateCode,
      receiverEmail: data.receiverEmail.present
          ? data.receiverEmail.value
          : this.receiverEmail,
      originalInvoiceNumber: data.originalInvoiceNumber.present
          ? data.originalInvoiceNumber.value
          : this.originalInvoiceNumber,
      originalInvoiceDate: data.originalInvoiceDate.present
          ? data.originalInvoiceDate.value
          : this.originalInvoiceDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Invoice(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('clientId: $clientId, ')
          ..write('invoiceNo: $invoiceNo, ')
          ..write('type: $type, ')
          ..write('invoiceDate: $invoiceDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('placeOfSupply: $placeOfSupply, ')
          ..write('style: $style, ')
          ..write('reverseCharge: $reverseCharge, ')
          ..write('paymentTerms: $paymentTerms, ')
          ..write('comments: $comments, ')
          ..write('bankName: $bankName, ')
          ..write('accountNo: $accountNo, ')
          ..write('ifscCode: $ifscCode, ')
          ..write('branch: $branch, ')
          ..write('supplierName: $supplierName, ')
          ..write('supplierAddress: $supplierAddress, ')
          ..write('supplierGstin: $supplierGstin, ')
          ..write('supplierEmail: $supplierEmail, ')
          ..write('supplierPhone: $supplierPhone, ')
          ..write('receiverName: $receiverName, ')
          ..write('receiverAddress: $receiverAddress, ')
          ..write('receiverGstin: $receiverGstin, ')
          ..write('receiverPan: $receiverPan, ')
          ..write('receiverState: $receiverState, ')
          ..write('receiverStateCode: $receiverStateCode, ')
          ..write('receiverEmail: $receiverEmail, ')
          ..write('originalInvoiceNumber: $originalInvoiceNumber, ')
          ..write('originalInvoiceDate: $originalInvoiceDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        profileId,
        clientId,
        invoiceNo,
        type,
        invoiceDate,
        dueDate,
        placeOfSupply,
        style,
        reverseCharge,
        paymentTerms,
        comments,
        bankName,
        accountNo,
        ifscCode,
        branch,
        supplierName,
        supplierAddress,
        supplierGstin,
        supplierEmail,
        supplierPhone,
        receiverName,
        receiverAddress,
        receiverGstin,
        receiverPan,
        receiverState,
        receiverStateCode,
        receiverEmail,
        originalInvoiceNumber,
        originalInvoiceDate
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Invoice &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.clientId == this.clientId &&
          other.invoiceNo == this.invoiceNo &&
          other.type == this.type &&
          other.invoiceDate == this.invoiceDate &&
          other.dueDate == this.dueDate &&
          other.placeOfSupply == this.placeOfSupply &&
          other.style == this.style &&
          other.reverseCharge == this.reverseCharge &&
          other.paymentTerms == this.paymentTerms &&
          other.comments == this.comments &&
          other.bankName == this.bankName &&
          other.accountNo == this.accountNo &&
          other.ifscCode == this.ifscCode &&
          other.branch == this.branch &&
          other.supplierName == this.supplierName &&
          other.supplierAddress == this.supplierAddress &&
          other.supplierGstin == this.supplierGstin &&
          other.supplierEmail == this.supplierEmail &&
          other.supplierPhone == this.supplierPhone &&
          other.receiverName == this.receiverName &&
          other.receiverAddress == this.receiverAddress &&
          other.receiverGstin == this.receiverGstin &&
          other.receiverPan == this.receiverPan &&
          other.receiverState == this.receiverState &&
          other.receiverStateCode == this.receiverStateCode &&
          other.receiverEmail == this.receiverEmail &&
          other.originalInvoiceNumber == this.originalInvoiceNumber &&
          other.originalInvoiceDate == this.originalInvoiceDate);
}

class InvoicesCompanion extends UpdateCompanion<Invoice> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> clientId;
  final Value<String> invoiceNo;
  final Value<String> type;
  final Value<DateTime> invoiceDate;
  final Value<DateTime?> dueDate;
  final Value<String> placeOfSupply;
  final Value<String> style;
  final Value<String> reverseCharge;
  final Value<String> paymentTerms;
  final Value<String> comments;
  final Value<String> bankName;
  final Value<String> accountNo;
  final Value<String> ifscCode;
  final Value<String> branch;
  final Value<String?> supplierName;
  final Value<String?> supplierAddress;
  final Value<String?> supplierGstin;
  final Value<String?> supplierEmail;
  final Value<String?> supplierPhone;
  final Value<String?> receiverName;
  final Value<String?> receiverAddress;
  final Value<String?> receiverGstin;
  final Value<String?> receiverPan;
  final Value<String?> receiverState;
  final Value<String?> receiverStateCode;
  final Value<String?> receiverEmail;
  final Value<String?> originalInvoiceNumber;
  final Value<DateTime?> originalInvoiceDate;
  final Value<int> rowid;
  const InvoicesCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.invoiceNo = const Value.absent(),
    this.type = const Value.absent(),
    this.invoiceDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.placeOfSupply = const Value.absent(),
    this.style = const Value.absent(),
    this.reverseCharge = const Value.absent(),
    this.paymentTerms = const Value.absent(),
    this.comments = const Value.absent(),
    this.bankName = const Value.absent(),
    this.accountNo = const Value.absent(),
    this.ifscCode = const Value.absent(),
    this.branch = const Value.absent(),
    this.supplierName = const Value.absent(),
    this.supplierAddress = const Value.absent(),
    this.supplierGstin = const Value.absent(),
    this.supplierEmail = const Value.absent(),
    this.supplierPhone = const Value.absent(),
    this.receiverName = const Value.absent(),
    this.receiverAddress = const Value.absent(),
    this.receiverGstin = const Value.absent(),
    this.receiverPan = const Value.absent(),
    this.receiverState = const Value.absent(),
    this.receiverStateCode = const Value.absent(),
    this.receiverEmail = const Value.absent(),
    this.originalInvoiceNumber = const Value.absent(),
    this.originalInvoiceDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvoicesCompanion.insert({
    required String id,
    required String profileId,
    required String clientId,
    required String invoiceNo,
    this.type = const Value.absent(),
    required DateTime invoiceDate,
    this.dueDate = const Value.absent(),
    required String placeOfSupply,
    this.style = const Value.absent(),
    this.reverseCharge = const Value.absent(),
    required String paymentTerms,
    required String comments,
    required String bankName,
    required String accountNo,
    required String ifscCode,
    required String branch,
    this.supplierName = const Value.absent(),
    this.supplierAddress = const Value.absent(),
    this.supplierGstin = const Value.absent(),
    this.supplierEmail = const Value.absent(),
    this.supplierPhone = const Value.absent(),
    this.receiverName = const Value.absent(),
    this.receiverAddress = const Value.absent(),
    this.receiverGstin = const Value.absent(),
    this.receiverPan = const Value.absent(),
    this.receiverState = const Value.absent(),
    this.receiverStateCode = const Value.absent(),
    this.receiverEmail = const Value.absent(),
    this.originalInvoiceNumber = const Value.absent(),
    this.originalInvoiceDate = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        profileId = Value(profileId),
        clientId = Value(clientId),
        invoiceNo = Value(invoiceNo),
        invoiceDate = Value(invoiceDate),
        placeOfSupply = Value(placeOfSupply),
        paymentTerms = Value(paymentTerms),
        comments = Value(comments),
        bankName = Value(bankName),
        accountNo = Value(accountNo),
        ifscCode = Value(ifscCode),
        branch = Value(branch);
  static Insertable<Invoice> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? clientId,
    Expression<String>? invoiceNo,
    Expression<String>? type,
    Expression<DateTime>? invoiceDate,
    Expression<DateTime>? dueDate,
    Expression<String>? placeOfSupply,
    Expression<String>? style,
    Expression<String>? reverseCharge,
    Expression<String>? paymentTerms,
    Expression<String>? comments,
    Expression<String>? bankName,
    Expression<String>? accountNo,
    Expression<String>? ifscCode,
    Expression<String>? branch,
    Expression<String>? supplierName,
    Expression<String>? supplierAddress,
    Expression<String>? supplierGstin,
    Expression<String>? supplierEmail,
    Expression<String>? supplierPhone,
    Expression<String>? receiverName,
    Expression<String>? receiverAddress,
    Expression<String>? receiverGstin,
    Expression<String>? receiverPan,
    Expression<String>? receiverState,
    Expression<String>? receiverStateCode,
    Expression<String>? receiverEmail,
    Expression<String>? originalInvoiceNumber,
    Expression<DateTime>? originalInvoiceDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (clientId != null) 'client_id': clientId,
      if (invoiceNo != null) 'invoice_no': invoiceNo,
      if (type != null) 'type': type,
      if (invoiceDate != null) 'invoice_date': invoiceDate,
      if (dueDate != null) 'due_date': dueDate,
      if (placeOfSupply != null) 'place_of_supply': placeOfSupply,
      if (style != null) 'style': style,
      if (reverseCharge != null) 'reverse_charge': reverseCharge,
      if (paymentTerms != null) 'payment_terms': paymentTerms,
      if (comments != null) 'comments': comments,
      if (bankName != null) 'bank_name': bankName,
      if (accountNo != null) 'account_no': accountNo,
      if (ifscCode != null) 'ifsc_code': ifscCode,
      if (branch != null) 'branch': branch,
      if (supplierName != null) 'supplier_name': supplierName,
      if (supplierAddress != null) 'supplier_address': supplierAddress,
      if (supplierGstin != null) 'supplier_gstin': supplierGstin,
      if (supplierEmail != null) 'supplier_email': supplierEmail,
      if (supplierPhone != null) 'supplier_phone': supplierPhone,
      if (receiverName != null) 'receiver_name': receiverName,
      if (receiverAddress != null) 'receiver_address': receiverAddress,
      if (receiverGstin != null) 'receiver_gstin': receiverGstin,
      if (receiverPan != null) 'receiver_pan': receiverPan,
      if (receiverState != null) 'receiver_state': receiverState,
      if (receiverStateCode != null) 'receiver_state_code': receiverStateCode,
      if (receiverEmail != null) 'receiver_email': receiverEmail,
      if (originalInvoiceNumber != null)
        'original_invoice_number': originalInvoiceNumber,
      if (originalInvoiceDate != null)
        'original_invoice_date': originalInvoiceDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvoicesCompanion copyWith(
      {Value<String>? id,
      Value<String>? profileId,
      Value<String>? clientId,
      Value<String>? invoiceNo,
      Value<String>? type,
      Value<DateTime>? invoiceDate,
      Value<DateTime?>? dueDate,
      Value<String>? placeOfSupply,
      Value<String>? style,
      Value<String>? reverseCharge,
      Value<String>? paymentTerms,
      Value<String>? comments,
      Value<String>? bankName,
      Value<String>? accountNo,
      Value<String>? ifscCode,
      Value<String>? branch,
      Value<String?>? supplierName,
      Value<String?>? supplierAddress,
      Value<String?>? supplierGstin,
      Value<String?>? supplierEmail,
      Value<String?>? supplierPhone,
      Value<String?>? receiverName,
      Value<String?>? receiverAddress,
      Value<String?>? receiverGstin,
      Value<String?>? receiverPan,
      Value<String?>? receiverState,
      Value<String?>? receiverStateCode,
      Value<String?>? receiverEmail,
      Value<String?>? originalInvoiceNumber,
      Value<DateTime?>? originalInvoiceDate,
      Value<int>? rowid}) {
    return InvoicesCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      clientId: clientId ?? this.clientId,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      type: type ?? this.type,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      placeOfSupply: placeOfSupply ?? this.placeOfSupply,
      style: style ?? this.style,
      reverseCharge: reverseCharge ?? this.reverseCharge,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      comments: comments ?? this.comments,
      bankName: bankName ?? this.bankName,
      accountNo: accountNo ?? this.accountNo,
      ifscCode: ifscCode ?? this.ifscCode,
      branch: branch ?? this.branch,
      supplierName: supplierName ?? this.supplierName,
      supplierAddress: supplierAddress ?? this.supplierAddress,
      supplierGstin: supplierGstin ?? this.supplierGstin,
      supplierEmail: supplierEmail ?? this.supplierEmail,
      supplierPhone: supplierPhone ?? this.supplierPhone,
      receiverName: receiverName ?? this.receiverName,
      receiverAddress: receiverAddress ?? this.receiverAddress,
      receiverGstin: receiverGstin ?? this.receiverGstin,
      receiverPan: receiverPan ?? this.receiverPan,
      receiverState: receiverState ?? this.receiverState,
      receiverStateCode: receiverStateCode ?? this.receiverStateCode,
      receiverEmail: receiverEmail ?? this.receiverEmail,
      originalInvoiceNumber:
          originalInvoiceNumber ?? this.originalInvoiceNumber,
      originalInvoiceDate: originalInvoiceDate ?? this.originalInvoiceDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (invoiceNo.present) {
      map['invoice_no'] = Variable<String>(invoiceNo.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (invoiceDate.present) {
      map['invoice_date'] = Variable<DateTime>(invoiceDate.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (placeOfSupply.present) {
      map['place_of_supply'] = Variable<String>(placeOfSupply.value);
    }
    if (style.present) {
      map['style'] = Variable<String>(style.value);
    }
    if (reverseCharge.present) {
      map['reverse_charge'] = Variable<String>(reverseCharge.value);
    }
    if (paymentTerms.present) {
      map['payment_terms'] = Variable<String>(paymentTerms.value);
    }
    if (comments.present) {
      map['comments'] = Variable<String>(comments.value);
    }
    if (bankName.present) {
      map['bank_name'] = Variable<String>(bankName.value);
    }
    if (accountNo.present) {
      map['account_no'] = Variable<String>(accountNo.value);
    }
    if (ifscCode.present) {
      map['ifsc_code'] = Variable<String>(ifscCode.value);
    }
    if (branch.present) {
      map['branch'] = Variable<String>(branch.value);
    }
    if (supplierName.present) {
      map['supplier_name'] = Variable<String>(supplierName.value);
    }
    if (supplierAddress.present) {
      map['supplier_address'] = Variable<String>(supplierAddress.value);
    }
    if (supplierGstin.present) {
      map['supplier_gstin'] = Variable<String>(supplierGstin.value);
    }
    if (supplierEmail.present) {
      map['supplier_email'] = Variable<String>(supplierEmail.value);
    }
    if (supplierPhone.present) {
      map['supplier_phone'] = Variable<String>(supplierPhone.value);
    }
    if (receiverName.present) {
      map['receiver_name'] = Variable<String>(receiverName.value);
    }
    if (receiverAddress.present) {
      map['receiver_address'] = Variable<String>(receiverAddress.value);
    }
    if (receiverGstin.present) {
      map['receiver_gstin'] = Variable<String>(receiverGstin.value);
    }
    if (receiverPan.present) {
      map['receiver_pan'] = Variable<String>(receiverPan.value);
    }
    if (receiverState.present) {
      map['receiver_state'] = Variable<String>(receiverState.value);
    }
    if (receiverStateCode.present) {
      map['receiver_state_code'] = Variable<String>(receiverStateCode.value);
    }
    if (receiverEmail.present) {
      map['receiver_email'] = Variable<String>(receiverEmail.value);
    }
    if (originalInvoiceNumber.present) {
      map['original_invoice_number'] =
          Variable<String>(originalInvoiceNumber.value);
    }
    if (originalInvoiceDate.present) {
      map['original_invoice_date'] =
          Variable<DateTime>(originalInvoiceDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoicesCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('clientId: $clientId, ')
          ..write('invoiceNo: $invoiceNo, ')
          ..write('type: $type, ')
          ..write('invoiceDate: $invoiceDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('placeOfSupply: $placeOfSupply, ')
          ..write('style: $style, ')
          ..write('reverseCharge: $reverseCharge, ')
          ..write('paymentTerms: $paymentTerms, ')
          ..write('comments: $comments, ')
          ..write('bankName: $bankName, ')
          ..write('accountNo: $accountNo, ')
          ..write('ifscCode: $ifscCode, ')
          ..write('branch: $branch, ')
          ..write('supplierName: $supplierName, ')
          ..write('supplierAddress: $supplierAddress, ')
          ..write('supplierGstin: $supplierGstin, ')
          ..write('supplierEmail: $supplierEmail, ')
          ..write('supplierPhone: $supplierPhone, ')
          ..write('receiverName: $receiverName, ')
          ..write('receiverAddress: $receiverAddress, ')
          ..write('receiverGstin: $receiverGstin, ')
          ..write('receiverPan: $receiverPan, ')
          ..write('receiverState: $receiverState, ')
          ..write('receiverStateCode: $receiverStateCode, ')
          ..write('receiverEmail: $receiverEmail, ')
          ..write('originalInvoiceNumber: $originalInvoiceNumber, ')
          ..write('originalInvoiceDate: $originalInvoiceDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvoiceItemsTable extends InvoiceItems
    with TableInfo<$InvoiceItemsTable, InvoiceItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoiceItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _invoiceIdMeta =
      const VerificationMeta('invoiceId');
  @override
  late final GeneratedColumn<String> invoiceId = GeneratedColumn<String>(
      'invoice_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES invoices (id)'));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sacCodeMeta =
      const VerificationMeta('sacCode');
  @override
  late final GeneratedColumn<String> sacCode = GeneratedColumn<String>(
      'sac_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _codeTypeMeta =
      const VerificationMeta('codeType');
  @override
  late final GeneratedColumn<String> codeType = GeneratedColumn<String>(
      'code_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<String> year = GeneratedColumn<String>(
      'year', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _discountMeta =
      const VerificationMeta('discount');
  @override
  late final GeneratedColumn<double> discount = GeneratedColumn<double>(
      'discount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
      'quantity', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _gstRateMeta =
      const VerificationMeta('gstRate');
  @override
  late final GeneratedColumn<double> gstRate = GeneratedColumn<double>(
      'gst_rate', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        invoiceId,
        description,
        sacCode,
        codeType,
        year,
        amount,
        discount,
        quantity,
        unit,
        gstRate
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoice_items';
  @override
  VerificationContext validateIntegrity(Insertable<InvoiceItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('invoice_id')) {
      context.handle(_invoiceIdMeta,
          invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta));
    } else if (isInserting) {
      context.missing(_invoiceIdMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('sac_code')) {
      context.handle(_sacCodeMeta,
          sacCode.isAcceptableOrUnknown(data['sac_code']!, _sacCodeMeta));
    } else if (isInserting) {
      context.missing(_sacCodeMeta);
    }
    if (data.containsKey('code_type')) {
      context.handle(_codeTypeMeta,
          codeType.isAcceptableOrUnknown(data['code_type']!, _codeTypeMeta));
    } else if (isInserting) {
      context.missing(_codeTypeMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
          _yearMeta, year.isAcceptableOrUnknown(data['year']!, _yearMeta));
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('discount')) {
      context.handle(_discountMeta,
          discount.isAcceptableOrUnknown(data['discount']!, _discountMeta));
    } else if (isInserting) {
      context.missing(_discountMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('gst_rate')) {
      context.handle(_gstRateMeta,
          gstRate.isAcceptableOrUnknown(data['gst_rate']!, _gstRateMeta));
    } else if (isInserting) {
      context.missing(_gstRateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvoiceItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvoiceItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      invoiceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_id'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      sacCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sac_code'])!,
      codeType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code_type'])!,
      year: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}year'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      discount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}discount'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      gstRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}gst_rate'])!,
    );
  }

  @override
  $InvoiceItemsTable createAlias(String alias) {
    return $InvoiceItemsTable(attachedDatabase, alias);
  }
}

class InvoiceItem extends DataClass implements Insertable<InvoiceItem> {
  final String id;
  final String invoiceId;
  final String description;
  final String sacCode;
  final String codeType;
  final String year;
  final double amount;
  final double discount;
  final double quantity;
  final String unit;
  final double gstRate;
  const InvoiceItem(
      {required this.id,
      required this.invoiceId,
      required this.description,
      required this.sacCode,
      required this.codeType,
      required this.year,
      required this.amount,
      required this.discount,
      required this.quantity,
      required this.unit,
      required this.gstRate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['invoice_id'] = Variable<String>(invoiceId);
    map['description'] = Variable<String>(description);
    map['sac_code'] = Variable<String>(sacCode);
    map['code_type'] = Variable<String>(codeType);
    map['year'] = Variable<String>(year);
    map['amount'] = Variable<double>(amount);
    map['discount'] = Variable<double>(discount);
    map['quantity'] = Variable<double>(quantity);
    map['unit'] = Variable<String>(unit);
    map['gst_rate'] = Variable<double>(gstRate);
    return map;
  }

  InvoiceItemsCompanion toCompanion(bool nullToAbsent) {
    return InvoiceItemsCompanion(
      id: Value(id),
      invoiceId: Value(invoiceId),
      description: Value(description),
      sacCode: Value(sacCode),
      codeType: Value(codeType),
      year: Value(year),
      amount: Value(amount),
      discount: Value(discount),
      quantity: Value(quantity),
      unit: Value(unit),
      gstRate: Value(gstRate),
    );
  }

  factory InvoiceItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvoiceItem(
      id: serializer.fromJson<String>(json['id']),
      invoiceId: serializer.fromJson<String>(json['invoiceId']),
      description: serializer.fromJson<String>(json['description']),
      sacCode: serializer.fromJson<String>(json['sacCode']),
      codeType: serializer.fromJson<String>(json['codeType']),
      year: serializer.fromJson<String>(json['year']),
      amount: serializer.fromJson<double>(json['amount']),
      discount: serializer.fromJson<double>(json['discount']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unit: serializer.fromJson<String>(json['unit']),
      gstRate: serializer.fromJson<double>(json['gstRate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'invoiceId': serializer.toJson<String>(invoiceId),
      'description': serializer.toJson<String>(description),
      'sacCode': serializer.toJson<String>(sacCode),
      'codeType': serializer.toJson<String>(codeType),
      'year': serializer.toJson<String>(year),
      'amount': serializer.toJson<double>(amount),
      'discount': serializer.toJson<double>(discount),
      'quantity': serializer.toJson<double>(quantity),
      'unit': serializer.toJson<String>(unit),
      'gstRate': serializer.toJson<double>(gstRate),
    };
  }

  InvoiceItem copyWith(
          {String? id,
          String? invoiceId,
          String? description,
          String? sacCode,
          String? codeType,
          String? year,
          double? amount,
          double? discount,
          double? quantity,
          String? unit,
          double? gstRate}) =>
      InvoiceItem(
        id: id ?? this.id,
        invoiceId: invoiceId ?? this.invoiceId,
        description: description ?? this.description,
        sacCode: sacCode ?? this.sacCode,
        codeType: codeType ?? this.codeType,
        year: year ?? this.year,
        amount: amount ?? this.amount,
        discount: discount ?? this.discount,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        gstRate: gstRate ?? this.gstRate,
      );
  InvoiceItem copyWithCompanion(InvoiceItemsCompanion data) {
    return InvoiceItem(
      id: data.id.present ? data.id.value : this.id,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      description:
          data.description.present ? data.description.value : this.description,
      sacCode: data.sacCode.present ? data.sacCode.value : this.sacCode,
      codeType: data.codeType.present ? data.codeType.value : this.codeType,
      year: data.year.present ? data.year.value : this.year,
      amount: data.amount.present ? data.amount.value : this.amount,
      discount: data.discount.present ? data.discount.value : this.discount,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      gstRate: data.gstRate.present ? data.gstRate.value : this.gstRate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceItem(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('description: $description, ')
          ..write('sacCode: $sacCode, ')
          ..write('codeType: $codeType, ')
          ..write('year: $year, ')
          ..write('amount: $amount, ')
          ..write('discount: $discount, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('gstRate: $gstRate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, invoiceId, description, sacCode, codeType,
      year, amount, discount, quantity, unit, gstRate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvoiceItem &&
          other.id == this.id &&
          other.invoiceId == this.invoiceId &&
          other.description == this.description &&
          other.sacCode == this.sacCode &&
          other.codeType == this.codeType &&
          other.year == this.year &&
          other.amount == this.amount &&
          other.discount == this.discount &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.gstRate == this.gstRate);
}

class InvoiceItemsCompanion extends UpdateCompanion<InvoiceItem> {
  final Value<String> id;
  final Value<String> invoiceId;
  final Value<String> description;
  final Value<String> sacCode;
  final Value<String> codeType;
  final Value<String> year;
  final Value<double> amount;
  final Value<double> discount;
  final Value<double> quantity;
  final Value<String> unit;
  final Value<double> gstRate;
  final Value<int> rowid;
  const InvoiceItemsCompanion({
    this.id = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.description = const Value.absent(),
    this.sacCode = const Value.absent(),
    this.codeType = const Value.absent(),
    this.year = const Value.absent(),
    this.amount = const Value.absent(),
    this.discount = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.gstRate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvoiceItemsCompanion.insert({
    required String id,
    required String invoiceId,
    required String description,
    required String sacCode,
    required String codeType,
    required String year,
    required double amount,
    required double discount,
    required double quantity,
    required String unit,
    required double gstRate,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        invoiceId = Value(invoiceId),
        description = Value(description),
        sacCode = Value(sacCode),
        codeType = Value(codeType),
        year = Value(year),
        amount = Value(amount),
        discount = Value(discount),
        quantity = Value(quantity),
        unit = Value(unit),
        gstRate = Value(gstRate);
  static Insertable<InvoiceItem> custom({
    Expression<String>? id,
    Expression<String>? invoiceId,
    Expression<String>? description,
    Expression<String>? sacCode,
    Expression<String>? codeType,
    Expression<String>? year,
    Expression<double>? amount,
    Expression<double>? discount,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<double>? gstRate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (description != null) 'description': description,
      if (sacCode != null) 'sac_code': sacCode,
      if (codeType != null) 'code_type': codeType,
      if (year != null) 'year': year,
      if (amount != null) 'amount': amount,
      if (discount != null) 'discount': discount,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (gstRate != null) 'gst_rate': gstRate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvoiceItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? invoiceId,
      Value<String>? description,
      Value<String>? sacCode,
      Value<String>? codeType,
      Value<String>? year,
      Value<double>? amount,
      Value<double>? discount,
      Value<double>? quantity,
      Value<String>? unit,
      Value<double>? gstRate,
      Value<int>? rowid}) {
    return InvoiceItemsCompanion(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      description: description ?? this.description,
      sacCode: sacCode ?? this.sacCode,
      codeType: codeType ?? this.codeType,
      year: year ?? this.year,
      amount: amount ?? this.amount,
      discount: discount ?? this.discount,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      gstRate: gstRate ?? this.gstRate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<String>(invoiceId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (sacCode.present) {
      map['sac_code'] = Variable<String>(sacCode.value);
    }
    if (codeType.present) {
      map['code_type'] = Variable<String>(codeType.value);
    }
    if (year.present) {
      map['year'] = Variable<String>(year.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (discount.present) {
      map['discount'] = Variable<double>(discount.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (gstRate.present) {
      map['gst_rate'] = Variable<double>(gstRate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceItemsCompanion(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('description: $description, ')
          ..write('sacCode: $sacCode, ')
          ..write('codeType: $codeType, ')
          ..write('year: $year, ')
          ..write('amount: $amount, ')
          ..write('discount: $discount, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('gstRate: $gstRate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments with TableInfo<$PaymentsTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _invoiceIdMeta =
      const VerificationMeta('invoiceId');
  @override
  late final GeneratedColumn<String> invoiceId = GeneratedColumn<String>(
      'invoice_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES invoices (id)'));
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
      'method', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, invoiceId, amount, date, method, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(Insertable<Payment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('invoice_id')) {
      context.handle(_invoiceIdMeta,
          invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta));
    } else if (isInserting) {
      context.missing(_invoiceIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('method')) {
      context.handle(_methodMeta,
          method.isAcceptableOrUnknown(data['method']!, _methodMeta));
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      invoiceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      method: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}method'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }
}

class Payment extends DataClass implements Insertable<Payment> {
  final String id;
  final String invoiceId;
  final double amount;
  final DateTime date;
  final String method;
  final String? notes;
  const Payment(
      {required this.id,
      required this.invoiceId,
      required this.amount,
      required this.date,
      required this.method,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['invoice_id'] = Variable<String>(invoiceId);
    map['amount'] = Variable<double>(amount);
    map['date'] = Variable<DateTime>(date);
    map['method'] = Variable<String>(method);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      invoiceId: Value(invoiceId),
      amount: Value(amount),
      date: Value(date),
      method: Value(method),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory Payment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      id: serializer.fromJson<String>(json['id']),
      invoiceId: serializer.fromJson<String>(json['invoiceId']),
      amount: serializer.fromJson<double>(json['amount']),
      date: serializer.fromJson<DateTime>(json['date']),
      method: serializer.fromJson<String>(json['method']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'invoiceId': serializer.toJson<String>(invoiceId),
      'amount': serializer.toJson<double>(amount),
      'date': serializer.toJson<DateTime>(date),
      'method': serializer.toJson<String>(method),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Payment copyWith(
          {String? id,
          String? invoiceId,
          double? amount,
          DateTime? date,
          String? method,
          Value<String?> notes = const Value.absent()}) =>
      Payment(
        id: id ?? this.id,
        invoiceId: invoiceId ?? this.invoiceId,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        method: method ?? this.method,
        notes: notes.present ? notes.value : this.notes,
      );
  Payment copyWithCompanion(PaymentsCompanion data) {
    return Payment(
      id: data.id.present ? data.id.value : this.id,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      method: data.method.present ? data.method.value : this.method,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('method: $method, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, invoiceId, amount, date, method, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.id == this.id &&
          other.invoiceId == this.invoiceId &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.method == this.method &&
          other.notes == this.notes);
}

class PaymentsCompanion extends UpdateCompanion<Payment> {
  final Value<String> id;
  final Value<String> invoiceId;
  final Value<double> amount;
  final Value<DateTime> date;
  final Value<String> method;
  final Value<String?> notes;
  final Value<int> rowid;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.method = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsCompanion.insert({
    required String id,
    required String invoiceId,
    required double amount,
    required DateTime date,
    required String method,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        invoiceId = Value(invoiceId),
        amount = Value(amount),
        date = Value(date),
        method = Value(method);
  static Insertable<Payment> custom({
    Expression<String>? id,
    Expression<String>? invoiceId,
    Expression<double>? amount,
    Expression<DateTime>? date,
    Expression<String>? method,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (method != null) 'method': method,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? invoiceId,
      Value<double>? amount,
      Value<DateTime>? date,
      Value<String>? method,
      Value<String?>? notes,
      Value<int>? rowid}) {
    return PaymentsCompanion(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      method: method ?? this.method,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<String>(invoiceId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('method: $method, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BusinessProfilesTable businessProfiles =
      $BusinessProfilesTable(this);
  late final $ClientsTable clients = $ClientsTable(this);
  late final $InvoicesTable invoices = $InvoicesTable(this);
  late final $InvoiceItemsTable invoiceItems = $InvoiceItemsTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [businessProfiles, clients, invoices, invoiceItems, payments];
}

typedef $$BusinessProfilesTableCreateCompanionBuilder
    = BusinessProfilesCompanion Function({
  required String id,
  required String companyName,
  required String address,
  required String gstin,
  required String email,
  required String phone,
  required String state,
  required int colorValue,
  Value<String?> logoPath,
  required String invoiceSeries,
  required int invoiceSequence,
  Value<String?> signaturePath,
  Value<String?> stampPath,
  required String termsAndConditions,
  required String defaultNotes,
  required String currencySymbol,
  required String bankName,
  required String accountNumber,
  required String ifscCode,
  required String branchName,
  Value<String?> upiId,
  Value<String?> upiName,
  Value<int> rowid,
});
typedef $$BusinessProfilesTableUpdateCompanionBuilder
    = BusinessProfilesCompanion Function({
  Value<String> id,
  Value<String> companyName,
  Value<String> address,
  Value<String> gstin,
  Value<String> email,
  Value<String> phone,
  Value<String> state,
  Value<int> colorValue,
  Value<String?> logoPath,
  Value<String> invoiceSeries,
  Value<int> invoiceSequence,
  Value<String?> signaturePath,
  Value<String?> stampPath,
  Value<String> termsAndConditions,
  Value<String> defaultNotes,
  Value<String> currencySymbol,
  Value<String> bankName,
  Value<String> accountNumber,
  Value<String> ifscCode,
  Value<String> branchName,
  Value<String?> upiId,
  Value<String?> upiName,
  Value<int> rowid,
});

final class $$BusinessProfilesTableReferences extends BaseReferences<
    _$AppDatabase, $BusinessProfilesTable, BusinessProfile> {
  $$BusinessProfilesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ClientsTable, List<Client>> _clientsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.clients,
          aliasName: $_aliasNameGenerator(
              db.businessProfiles.id, db.clients.profileId));

  $$ClientsTableProcessedTableManager get clientsRefs {
    final manager = $$ClientsTableTableManager($_db, $_db.clients)
        .filter((f) => f.profileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_clientsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$InvoicesTable, List<Invoice>> _invoicesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.invoices,
          aliasName: $_aliasNameGenerator(
              db.businessProfiles.id, db.invoices.profileId));

  $$InvoicesTableProcessedTableManager get invoicesRefs {
    final manager = $$InvoicesTableTableManager($_db, $_db.invoices)
        .filter((f) => f.profileId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_invoicesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$BusinessProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $BusinessProfilesTable> {
  $$BusinessProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get companyName => $composableBuilder(
      column: $table.companyName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gstin => $composableBuilder(
      column: $table.gstin, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get logoPath => $composableBuilder(
      column: $table.logoPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get invoiceSeries => $composableBuilder(
      column: $table.invoiceSeries, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get invoiceSequence => $composableBuilder(
      column: $table.invoiceSequence,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get signaturePath => $composableBuilder(
      column: $table.signaturePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stampPath => $composableBuilder(
      column: $table.stampPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get termsAndConditions => $composableBuilder(
      column: $table.termsAndConditions,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get defaultNotes => $composableBuilder(
      column: $table.defaultNotes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currencySymbol => $composableBuilder(
      column: $table.currencySymbol,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bankName => $composableBuilder(
      column: $table.bankName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountNumber => $composableBuilder(
      column: $table.accountNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ifscCode => $composableBuilder(
      column: $table.ifscCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get branchName => $composableBuilder(
      column: $table.branchName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get upiId => $composableBuilder(
      column: $table.upiId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get upiName => $composableBuilder(
      column: $table.upiName, builder: (column) => ColumnFilters(column));

  Expression<bool> clientsRefs(
      Expression<bool> Function($$ClientsTableFilterComposer f) f) {
    final $$ClientsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.clients,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientsTableFilterComposer(
              $db: $db,
              $table: $db.clients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> invoicesRefs(
      Expression<bool> Function($$InvoicesTableFilterComposer f) f) {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.invoices,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoicesTableFilterComposer(
              $db: $db,
              $table: $db.invoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BusinessProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $BusinessProfilesTable> {
  $$BusinessProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get companyName => $composableBuilder(
      column: $table.companyName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gstin => $composableBuilder(
      column: $table.gstin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get logoPath => $composableBuilder(
      column: $table.logoPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get invoiceSeries => $composableBuilder(
      column: $table.invoiceSeries,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get invoiceSequence => $composableBuilder(
      column: $table.invoiceSequence,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get signaturePath => $composableBuilder(
      column: $table.signaturePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stampPath => $composableBuilder(
      column: $table.stampPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get termsAndConditions => $composableBuilder(
      column: $table.termsAndConditions,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get defaultNotes => $composableBuilder(
      column: $table.defaultNotes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currencySymbol => $composableBuilder(
      column: $table.currencySymbol,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bankName => $composableBuilder(
      column: $table.bankName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountNumber => $composableBuilder(
      column: $table.accountNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ifscCode => $composableBuilder(
      column: $table.ifscCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get branchName => $composableBuilder(
      column: $table.branchName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get upiId => $composableBuilder(
      column: $table.upiId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get upiName => $composableBuilder(
      column: $table.upiName, builder: (column) => ColumnOrderings(column));
}

class $$BusinessProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BusinessProfilesTable> {
  $$BusinessProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get companyName => $composableBuilder(
      column: $table.companyName, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get gstin =>
      $composableBuilder(column: $table.gstin, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => column);

  GeneratedColumn<String> get logoPath =>
      $composableBuilder(column: $table.logoPath, builder: (column) => column);

  GeneratedColumn<String> get invoiceSeries => $composableBuilder(
      column: $table.invoiceSeries, builder: (column) => column);

  GeneratedColumn<int> get invoiceSequence => $composableBuilder(
      column: $table.invoiceSequence, builder: (column) => column);

  GeneratedColumn<String> get signaturePath => $composableBuilder(
      column: $table.signaturePath, builder: (column) => column);

  GeneratedColumn<String> get stampPath =>
      $composableBuilder(column: $table.stampPath, builder: (column) => column);

  GeneratedColumn<String> get termsAndConditions => $composableBuilder(
      column: $table.termsAndConditions, builder: (column) => column);

  GeneratedColumn<String> get defaultNotes => $composableBuilder(
      column: $table.defaultNotes, builder: (column) => column);

  GeneratedColumn<String> get currencySymbol => $composableBuilder(
      column: $table.currencySymbol, builder: (column) => column);

  GeneratedColumn<String> get bankName =>
      $composableBuilder(column: $table.bankName, builder: (column) => column);

  GeneratedColumn<String> get accountNumber => $composableBuilder(
      column: $table.accountNumber, builder: (column) => column);

  GeneratedColumn<String> get ifscCode =>
      $composableBuilder(column: $table.ifscCode, builder: (column) => column);

  GeneratedColumn<String> get branchName => $composableBuilder(
      column: $table.branchName, builder: (column) => column);

  GeneratedColumn<String> get upiId =>
      $composableBuilder(column: $table.upiId, builder: (column) => column);

  GeneratedColumn<String> get upiName =>
      $composableBuilder(column: $table.upiName, builder: (column) => column);

  Expression<T> clientsRefs<T extends Object>(
      Expression<T> Function($$ClientsTableAnnotationComposer a) f) {
    final $$ClientsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.clients,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientsTableAnnotationComposer(
              $db: $db,
              $table: $db.clients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> invoicesRefs<T extends Object>(
      Expression<T> Function($$InvoicesTableAnnotationComposer a) f) {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.invoices,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoicesTableAnnotationComposer(
              $db: $db,
              $table: $db.invoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BusinessProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BusinessProfilesTable,
    BusinessProfile,
    $$BusinessProfilesTableFilterComposer,
    $$BusinessProfilesTableOrderingComposer,
    $$BusinessProfilesTableAnnotationComposer,
    $$BusinessProfilesTableCreateCompanionBuilder,
    $$BusinessProfilesTableUpdateCompanionBuilder,
    (BusinessProfile, $$BusinessProfilesTableReferences),
    BusinessProfile,
    PrefetchHooks Function({bool clientsRefs, bool invoicesRefs})> {
  $$BusinessProfilesTableTableManager(
      _$AppDatabase db, $BusinessProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BusinessProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BusinessProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BusinessProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> companyName = const Value.absent(),
            Value<String> address = const Value.absent(),
            Value<String> gstin = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<String> state = const Value.absent(),
            Value<int> colorValue = const Value.absent(),
            Value<String?> logoPath = const Value.absent(),
            Value<String> invoiceSeries = const Value.absent(),
            Value<int> invoiceSequence = const Value.absent(),
            Value<String?> signaturePath = const Value.absent(),
            Value<String?> stampPath = const Value.absent(),
            Value<String> termsAndConditions = const Value.absent(),
            Value<String> defaultNotes = const Value.absent(),
            Value<String> currencySymbol = const Value.absent(),
            Value<String> bankName = const Value.absent(),
            Value<String> accountNumber = const Value.absent(),
            Value<String> ifscCode = const Value.absent(),
            Value<String> branchName = const Value.absent(),
            Value<String?> upiId = const Value.absent(),
            Value<String?> upiName = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BusinessProfilesCompanion(
            id: id,
            companyName: companyName,
            address: address,
            gstin: gstin,
            email: email,
            phone: phone,
            state: state,
            colorValue: colorValue,
            logoPath: logoPath,
            invoiceSeries: invoiceSeries,
            invoiceSequence: invoiceSequence,
            signaturePath: signaturePath,
            stampPath: stampPath,
            termsAndConditions: termsAndConditions,
            defaultNotes: defaultNotes,
            currencySymbol: currencySymbol,
            bankName: bankName,
            accountNumber: accountNumber,
            ifscCode: ifscCode,
            branchName: branchName,
            upiId: upiId,
            upiName: upiName,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String companyName,
            required String address,
            required String gstin,
            required String email,
            required String phone,
            required String state,
            required int colorValue,
            Value<String?> logoPath = const Value.absent(),
            required String invoiceSeries,
            required int invoiceSequence,
            Value<String?> signaturePath = const Value.absent(),
            Value<String?> stampPath = const Value.absent(),
            required String termsAndConditions,
            required String defaultNotes,
            required String currencySymbol,
            required String bankName,
            required String accountNumber,
            required String ifscCode,
            required String branchName,
            Value<String?> upiId = const Value.absent(),
            Value<String?> upiName = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BusinessProfilesCompanion.insert(
            id: id,
            companyName: companyName,
            address: address,
            gstin: gstin,
            email: email,
            phone: phone,
            state: state,
            colorValue: colorValue,
            logoPath: logoPath,
            invoiceSeries: invoiceSeries,
            invoiceSequence: invoiceSequence,
            signaturePath: signaturePath,
            stampPath: stampPath,
            termsAndConditions: termsAndConditions,
            defaultNotes: defaultNotes,
            currencySymbol: currencySymbol,
            bankName: bankName,
            accountNumber: accountNumber,
            ifscCode: ifscCode,
            branchName: branchName,
            upiId: upiId,
            upiName: upiName,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BusinessProfilesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({clientsRefs = false, invoicesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (clientsRefs) db.clients,
                if (invoicesRefs) db.invoices
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (clientsRefs)
                    await $_getPrefetchedData<BusinessProfile,
                            $BusinessProfilesTable, Client>(
                        currentTable: table,
                        referencedTable: $$BusinessProfilesTableReferences
                            ._clientsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BusinessProfilesTableReferences(db, table, p0)
                                .clientsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.profileId == item.id),
                        typedResults: items),
                  if (invoicesRefs)
                    await $_getPrefetchedData<BusinessProfile,
                            $BusinessProfilesTable, Invoice>(
                        currentTable: table,
                        referencedTable: $$BusinessProfilesTableReferences
                            ._invoicesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BusinessProfilesTableReferences(db, table, p0)
                                .invoicesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.profileId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$BusinessProfilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BusinessProfilesTable,
    BusinessProfile,
    $$BusinessProfilesTableFilterComposer,
    $$BusinessProfilesTableOrderingComposer,
    $$BusinessProfilesTableAnnotationComposer,
    $$BusinessProfilesTableCreateCompanionBuilder,
    $$BusinessProfilesTableUpdateCompanionBuilder,
    (BusinessProfile, $$BusinessProfilesTableReferences),
    BusinessProfile,
    PrefetchHooks Function({bool clientsRefs, bool invoicesRefs})>;
typedef $$ClientsTableCreateCompanionBuilder = ClientsCompanion Function({
  required String id,
  required String profileId,
  required String name,
  required String address,
  required String gstin,
  required String pan,
  required String state,
  required String stateCode,
  required String email,
  required String phone,
  Value<int> rowid,
});
typedef $$ClientsTableUpdateCompanionBuilder = ClientsCompanion Function({
  Value<String> id,
  Value<String> profileId,
  Value<String> name,
  Value<String> address,
  Value<String> gstin,
  Value<String> pan,
  Value<String> state,
  Value<String> stateCode,
  Value<String> email,
  Value<String> phone,
  Value<int> rowid,
});

final class $$ClientsTableReferences
    extends BaseReferences<_$AppDatabase, $ClientsTable, Client> {
  $$ClientsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BusinessProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.businessProfiles.createAlias(
          $_aliasNameGenerator(db.clients.profileId, db.businessProfiles.id));

  $$BusinessProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager =
        $$BusinessProfilesTableTableManager($_db, $_db.businessProfiles)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$InvoicesTable, List<Invoice>> _invoicesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.invoices,
          aliasName: $_aliasNameGenerator(db.clients.id, db.invoices.clientId));

  $$InvoicesTableProcessedTableManager get invoicesRefs {
    final manager = $$InvoicesTableTableManager($_db, $_db.invoices)
        .filter((f) => f.clientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_invoicesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ClientsTableFilterComposer
    extends Composer<_$AppDatabase, $ClientsTable> {
  $$ClientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gstin => $composableBuilder(
      column: $table.gstin, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pan => $composableBuilder(
      column: $table.pan, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stateCode => $composableBuilder(
      column: $table.stateCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  $$BusinessProfilesTableFilterComposer get profileId {
    final $$BusinessProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.businessProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BusinessProfilesTableFilterComposer(
              $db: $db,
              $table: $db.businessProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> invoicesRefs(
      Expression<bool> Function($$InvoicesTableFilterComposer f) f) {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.invoices,
        getReferencedColumn: (t) => t.clientId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoicesTableFilterComposer(
              $db: $db,
              $table: $db.invoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ClientsTableOrderingComposer
    extends Composer<_$AppDatabase, $ClientsTable> {
  $$ClientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gstin => $composableBuilder(
      column: $table.gstin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pan => $composableBuilder(
      column: $table.pan, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stateCode => $composableBuilder(
      column: $table.stateCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  $$BusinessProfilesTableOrderingComposer get profileId {
    final $$BusinessProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.businessProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BusinessProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.businessProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ClientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClientsTable> {
  $$ClientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get gstin =>
      $composableBuilder(column: $table.gstin, builder: (column) => column);

  GeneratedColumn<String> get pan =>
      $composableBuilder(column: $table.pan, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get stateCode =>
      $composableBuilder(column: $table.stateCode, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  $$BusinessProfilesTableAnnotationComposer get profileId {
    final $$BusinessProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.businessProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BusinessProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.businessProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> invoicesRefs<T extends Object>(
      Expression<T> Function($$InvoicesTableAnnotationComposer a) f) {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.invoices,
        getReferencedColumn: (t) => t.clientId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoicesTableAnnotationComposer(
              $db: $db,
              $table: $db.invoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ClientsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ClientsTable,
    Client,
    $$ClientsTableFilterComposer,
    $$ClientsTableOrderingComposer,
    $$ClientsTableAnnotationComposer,
    $$ClientsTableCreateCompanionBuilder,
    $$ClientsTableUpdateCompanionBuilder,
    (Client, $$ClientsTableReferences),
    Client,
    PrefetchHooks Function({bool profileId, bool invoicesRefs})> {
  $$ClientsTableTableManager(_$AppDatabase db, $ClientsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> profileId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> address = const Value.absent(),
            Value<String> gstin = const Value.absent(),
            Value<String> pan = const Value.absent(),
            Value<String> state = const Value.absent(),
            Value<String> stateCode = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ClientsCompanion(
            id: id,
            profileId: profileId,
            name: name,
            address: address,
            gstin: gstin,
            pan: pan,
            state: state,
            stateCode: stateCode,
            email: email,
            phone: phone,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String profileId,
            required String name,
            required String address,
            required String gstin,
            required String pan,
            required String state,
            required String stateCode,
            required String email,
            required String phone,
            Value<int> rowid = const Value.absent(),
          }) =>
              ClientsCompanion.insert(
            id: id,
            profileId: profileId,
            name: name,
            address: address,
            gstin: gstin,
            pan: pan,
            state: state,
            stateCode: stateCode,
            email: email,
            phone: phone,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ClientsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({profileId = false, invoicesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (invoicesRefs) db.invoices],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (profileId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.profileId,
                    referencedTable:
                        $$ClientsTableReferences._profileIdTable(db),
                    referencedColumn:
                        $$ClientsTableReferences._profileIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (invoicesRefs)
                    await $_getPrefetchedData<Client, $ClientsTable, Invoice>(
                        currentTable: table,
                        referencedTable:
                            $$ClientsTableReferences._invoicesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ClientsTableReferences(db, table, p0)
                                .invoicesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.clientId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ClientsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ClientsTable,
    Client,
    $$ClientsTableFilterComposer,
    $$ClientsTableOrderingComposer,
    $$ClientsTableAnnotationComposer,
    $$ClientsTableCreateCompanionBuilder,
    $$ClientsTableUpdateCompanionBuilder,
    (Client, $$ClientsTableReferences),
    Client,
    PrefetchHooks Function({bool profileId, bool invoicesRefs})>;
typedef $$InvoicesTableCreateCompanionBuilder = InvoicesCompanion Function({
  required String id,
  required String profileId,
  required String clientId,
  required String invoiceNo,
  Value<String> type,
  required DateTime invoiceDate,
  Value<DateTime?> dueDate,
  required String placeOfSupply,
  Value<String> style,
  Value<String> reverseCharge,
  required String paymentTerms,
  required String comments,
  required String bankName,
  required String accountNo,
  required String ifscCode,
  required String branch,
  Value<String?> supplierName,
  Value<String?> supplierAddress,
  Value<String?> supplierGstin,
  Value<String?> supplierEmail,
  Value<String?> supplierPhone,
  Value<String?> receiverName,
  Value<String?> receiverAddress,
  Value<String?> receiverGstin,
  Value<String?> receiverPan,
  Value<String?> receiverState,
  Value<String?> receiverStateCode,
  Value<String?> receiverEmail,
  Value<String?> originalInvoiceNumber,
  Value<DateTime?> originalInvoiceDate,
  Value<int> rowid,
});
typedef $$InvoicesTableUpdateCompanionBuilder = InvoicesCompanion Function({
  Value<String> id,
  Value<String> profileId,
  Value<String> clientId,
  Value<String> invoiceNo,
  Value<String> type,
  Value<DateTime> invoiceDate,
  Value<DateTime?> dueDate,
  Value<String> placeOfSupply,
  Value<String> style,
  Value<String> reverseCharge,
  Value<String> paymentTerms,
  Value<String> comments,
  Value<String> bankName,
  Value<String> accountNo,
  Value<String> ifscCode,
  Value<String> branch,
  Value<String?> supplierName,
  Value<String?> supplierAddress,
  Value<String?> supplierGstin,
  Value<String?> supplierEmail,
  Value<String?> supplierPhone,
  Value<String?> receiverName,
  Value<String?> receiverAddress,
  Value<String?> receiverGstin,
  Value<String?> receiverPan,
  Value<String?> receiverState,
  Value<String?> receiverStateCode,
  Value<String?> receiverEmail,
  Value<String?> originalInvoiceNumber,
  Value<DateTime?> originalInvoiceDate,
  Value<int> rowid,
});

final class $$InvoicesTableReferences
    extends BaseReferences<_$AppDatabase, $InvoicesTable, Invoice> {
  $$InvoicesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BusinessProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.businessProfiles.createAlias(
          $_aliasNameGenerator(db.invoices.profileId, db.businessProfiles.id));

  $$BusinessProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager =
        $$BusinessProfilesTableTableManager($_db, $_db.businessProfiles)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ClientsTable _clientIdTable(_$AppDatabase db) => db.clients
      .createAlias($_aliasNameGenerator(db.invoices.clientId, db.clients.id));

  $$ClientsTableProcessedTableManager get clientId {
    final $_column = $_itemColumn<String>('client_id')!;

    final manager = $$ClientsTableTableManager($_db, $_db.clients)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$InvoiceItemsTable, List<InvoiceItem>>
      _invoiceItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.invoiceItems,
          aliasName:
              $_aliasNameGenerator(db.invoices.id, db.invoiceItems.invoiceId));

  $$InvoiceItemsTableProcessedTableManager get invoiceItemsRefs {
    final manager = $$InvoiceItemsTableTableManager($_db, $_db.invoiceItems)
        .filter((f) => f.invoiceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_invoiceItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PaymentsTable, List<Payment>> _paymentsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.payments,
          aliasName:
              $_aliasNameGenerator(db.invoices.id, db.payments.invoiceId));

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager($_db, $_db.payments)
        .filter((f) => f.invoiceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$InvoicesTableFilterComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get invoiceNo => $composableBuilder(
      column: $table.invoiceNo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get invoiceDate => $composableBuilder(
      column: $table.invoiceDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get placeOfSupply => $composableBuilder(
      column: $table.placeOfSupply, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get style => $composableBuilder(
      column: $table.style, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reverseCharge => $composableBuilder(
      column: $table.reverseCharge, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentTerms => $composableBuilder(
      column: $table.paymentTerms, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get comments => $composableBuilder(
      column: $table.comments, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bankName => $composableBuilder(
      column: $table.bankName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountNo => $composableBuilder(
      column: $table.accountNo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ifscCode => $composableBuilder(
      column: $table.ifscCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get branch => $composableBuilder(
      column: $table.branch, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supplierName => $composableBuilder(
      column: $table.supplierName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supplierAddress => $composableBuilder(
      column: $table.supplierAddress,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supplierGstin => $composableBuilder(
      column: $table.supplierGstin, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supplierEmail => $composableBuilder(
      column: $table.supplierEmail, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supplierPhone => $composableBuilder(
      column: $table.supplierPhone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get receiverName => $composableBuilder(
      column: $table.receiverName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get receiverAddress => $composableBuilder(
      column: $table.receiverAddress,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get receiverGstin => $composableBuilder(
      column: $table.receiverGstin, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get receiverPan => $composableBuilder(
      column: $table.receiverPan, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get receiverState => $composableBuilder(
      column: $table.receiverState, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get receiverStateCode => $composableBuilder(
      column: $table.receiverStateCode,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get receiverEmail => $composableBuilder(
      column: $table.receiverEmail, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originalInvoiceNumber => $composableBuilder(
      column: $table.originalInvoiceNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get originalInvoiceDate => $composableBuilder(
      column: $table.originalInvoiceDate,
      builder: (column) => ColumnFilters(column));

  $$BusinessProfilesTableFilterComposer get profileId {
    final $$BusinessProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.businessProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BusinessProfilesTableFilterComposer(
              $db: $db,
              $table: $db.businessProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ClientsTableFilterComposer get clientId {
    final $$ClientsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.clientId,
        referencedTable: $db.clients,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientsTableFilterComposer(
              $db: $db,
              $table: $db.clients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> invoiceItemsRefs(
      Expression<bool> Function($$InvoiceItemsTableFilterComposer f) f) {
    final $$InvoiceItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.invoiceItems,
        getReferencedColumn: (t) => t.invoiceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoiceItemsTableFilterComposer(
              $db: $db,
              $table: $db.invoiceItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> paymentsRefs(
      Expression<bool> Function($$PaymentsTableFilterComposer f) f) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.payments,
        getReferencedColumn: (t) => t.invoiceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentsTableFilterComposer(
              $db: $db,
              $table: $db.payments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$InvoicesTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get invoiceNo => $composableBuilder(
      column: $table.invoiceNo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get invoiceDate => $composableBuilder(
      column: $table.invoiceDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get placeOfSupply => $composableBuilder(
      column: $table.placeOfSupply,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get style => $composableBuilder(
      column: $table.style, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reverseCharge => $composableBuilder(
      column: $table.reverseCharge,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentTerms => $composableBuilder(
      column: $table.paymentTerms,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get comments => $composableBuilder(
      column: $table.comments, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bankName => $composableBuilder(
      column: $table.bankName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountNo => $composableBuilder(
      column: $table.accountNo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ifscCode => $composableBuilder(
      column: $table.ifscCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get branch => $composableBuilder(
      column: $table.branch, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supplierName => $composableBuilder(
      column: $table.supplierName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supplierAddress => $composableBuilder(
      column: $table.supplierAddress,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supplierGstin => $composableBuilder(
      column: $table.supplierGstin,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supplierEmail => $composableBuilder(
      column: $table.supplierEmail,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supplierPhone => $composableBuilder(
      column: $table.supplierPhone,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get receiverName => $composableBuilder(
      column: $table.receiverName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get receiverAddress => $composableBuilder(
      column: $table.receiverAddress,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get receiverGstin => $composableBuilder(
      column: $table.receiverGstin,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get receiverPan => $composableBuilder(
      column: $table.receiverPan, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get receiverState => $composableBuilder(
      column: $table.receiverState,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get receiverStateCode => $composableBuilder(
      column: $table.receiverStateCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get receiverEmail => $composableBuilder(
      column: $table.receiverEmail,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originalInvoiceNumber => $composableBuilder(
      column: $table.originalInvoiceNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get originalInvoiceDate => $composableBuilder(
      column: $table.originalInvoiceDate,
      builder: (column) => ColumnOrderings(column));

  $$BusinessProfilesTableOrderingComposer get profileId {
    final $$BusinessProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.businessProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BusinessProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.businessProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ClientsTableOrderingComposer get clientId {
    final $$ClientsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.clientId,
        referencedTable: $db.clients,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientsTableOrderingComposer(
              $db: $db,
              $table: $db.clients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InvoicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get invoiceNo =>
      $composableBuilder(column: $table.invoiceNo, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get invoiceDate => $composableBuilder(
      column: $table.invoiceDate, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get placeOfSupply => $composableBuilder(
      column: $table.placeOfSupply, builder: (column) => column);

  GeneratedColumn<String> get style =>
      $composableBuilder(column: $table.style, builder: (column) => column);

  GeneratedColumn<String> get reverseCharge => $composableBuilder(
      column: $table.reverseCharge, builder: (column) => column);

  GeneratedColumn<String> get paymentTerms => $composableBuilder(
      column: $table.paymentTerms, builder: (column) => column);

  GeneratedColumn<String> get comments =>
      $composableBuilder(column: $table.comments, builder: (column) => column);

  GeneratedColumn<String> get bankName =>
      $composableBuilder(column: $table.bankName, builder: (column) => column);

  GeneratedColumn<String> get accountNo =>
      $composableBuilder(column: $table.accountNo, builder: (column) => column);

  GeneratedColumn<String> get ifscCode =>
      $composableBuilder(column: $table.ifscCode, builder: (column) => column);

  GeneratedColumn<String> get branch =>
      $composableBuilder(column: $table.branch, builder: (column) => column);

  GeneratedColumn<String> get supplierName => $composableBuilder(
      column: $table.supplierName, builder: (column) => column);

  GeneratedColumn<String> get supplierAddress => $composableBuilder(
      column: $table.supplierAddress, builder: (column) => column);

  GeneratedColumn<String> get supplierGstin => $composableBuilder(
      column: $table.supplierGstin, builder: (column) => column);

  GeneratedColumn<String> get supplierEmail => $composableBuilder(
      column: $table.supplierEmail, builder: (column) => column);

  GeneratedColumn<String> get supplierPhone => $composableBuilder(
      column: $table.supplierPhone, builder: (column) => column);

  GeneratedColumn<String> get receiverName => $composableBuilder(
      column: $table.receiverName, builder: (column) => column);

  GeneratedColumn<String> get receiverAddress => $composableBuilder(
      column: $table.receiverAddress, builder: (column) => column);

  GeneratedColumn<String> get receiverGstin => $composableBuilder(
      column: $table.receiverGstin, builder: (column) => column);

  GeneratedColumn<String> get receiverPan => $composableBuilder(
      column: $table.receiverPan, builder: (column) => column);

  GeneratedColumn<String> get receiverState => $composableBuilder(
      column: $table.receiverState, builder: (column) => column);

  GeneratedColumn<String> get receiverStateCode => $composableBuilder(
      column: $table.receiverStateCode, builder: (column) => column);

  GeneratedColumn<String> get receiverEmail => $composableBuilder(
      column: $table.receiverEmail, builder: (column) => column);

  GeneratedColumn<String> get originalInvoiceNumber => $composableBuilder(
      column: $table.originalInvoiceNumber, builder: (column) => column);

  GeneratedColumn<DateTime> get originalInvoiceDate => $composableBuilder(
      column: $table.originalInvoiceDate, builder: (column) => column);

  $$BusinessProfilesTableAnnotationComposer get profileId {
    final $$BusinessProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.businessProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BusinessProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.businessProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ClientsTableAnnotationComposer get clientId {
    final $$ClientsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.clientId,
        referencedTable: $db.clients,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientsTableAnnotationComposer(
              $db: $db,
              $table: $db.clients,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> invoiceItemsRefs<T extends Object>(
      Expression<T> Function($$InvoiceItemsTableAnnotationComposer a) f) {
    final $$InvoiceItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.invoiceItems,
        getReferencedColumn: (t) => t.invoiceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoiceItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.invoiceItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> paymentsRefs<T extends Object>(
      Expression<T> Function($$PaymentsTableAnnotationComposer a) f) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.payments,
        getReferencedColumn: (t) => t.invoiceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PaymentsTableAnnotationComposer(
              $db: $db,
              $table: $db.payments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$InvoicesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InvoicesTable,
    Invoice,
    $$InvoicesTableFilterComposer,
    $$InvoicesTableOrderingComposer,
    $$InvoicesTableAnnotationComposer,
    $$InvoicesTableCreateCompanionBuilder,
    $$InvoicesTableUpdateCompanionBuilder,
    (Invoice, $$InvoicesTableReferences),
    Invoice,
    PrefetchHooks Function(
        {bool profileId,
        bool clientId,
        bool invoiceItemsRefs,
        bool paymentsRefs})> {
  $$InvoicesTableTableManager(_$AppDatabase db, $InvoicesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> profileId = const Value.absent(),
            Value<String> clientId = const Value.absent(),
            Value<String> invoiceNo = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<DateTime> invoiceDate = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<String> placeOfSupply = const Value.absent(),
            Value<String> style = const Value.absent(),
            Value<String> reverseCharge = const Value.absent(),
            Value<String> paymentTerms = const Value.absent(),
            Value<String> comments = const Value.absent(),
            Value<String> bankName = const Value.absent(),
            Value<String> accountNo = const Value.absent(),
            Value<String> ifscCode = const Value.absent(),
            Value<String> branch = const Value.absent(),
            Value<String?> supplierName = const Value.absent(),
            Value<String?> supplierAddress = const Value.absent(),
            Value<String?> supplierGstin = const Value.absent(),
            Value<String?> supplierEmail = const Value.absent(),
            Value<String?> supplierPhone = const Value.absent(),
            Value<String?> receiverName = const Value.absent(),
            Value<String?> receiverAddress = const Value.absent(),
            Value<String?> receiverGstin = const Value.absent(),
            Value<String?> receiverPan = const Value.absent(),
            Value<String?> receiverState = const Value.absent(),
            Value<String?> receiverStateCode = const Value.absent(),
            Value<String?> receiverEmail = const Value.absent(),
            Value<String?> originalInvoiceNumber = const Value.absent(),
            Value<DateTime?> originalInvoiceDate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InvoicesCompanion(
            id: id,
            profileId: profileId,
            clientId: clientId,
            invoiceNo: invoiceNo,
            type: type,
            invoiceDate: invoiceDate,
            dueDate: dueDate,
            placeOfSupply: placeOfSupply,
            style: style,
            reverseCharge: reverseCharge,
            paymentTerms: paymentTerms,
            comments: comments,
            bankName: bankName,
            accountNo: accountNo,
            ifscCode: ifscCode,
            branch: branch,
            supplierName: supplierName,
            supplierAddress: supplierAddress,
            supplierGstin: supplierGstin,
            supplierEmail: supplierEmail,
            supplierPhone: supplierPhone,
            receiverName: receiverName,
            receiverAddress: receiverAddress,
            receiverGstin: receiverGstin,
            receiverPan: receiverPan,
            receiverState: receiverState,
            receiverStateCode: receiverStateCode,
            receiverEmail: receiverEmail,
            originalInvoiceNumber: originalInvoiceNumber,
            originalInvoiceDate: originalInvoiceDate,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String profileId,
            required String clientId,
            required String invoiceNo,
            Value<String> type = const Value.absent(),
            required DateTime invoiceDate,
            Value<DateTime?> dueDate = const Value.absent(),
            required String placeOfSupply,
            Value<String> style = const Value.absent(),
            Value<String> reverseCharge = const Value.absent(),
            required String paymentTerms,
            required String comments,
            required String bankName,
            required String accountNo,
            required String ifscCode,
            required String branch,
            Value<String?> supplierName = const Value.absent(),
            Value<String?> supplierAddress = const Value.absent(),
            Value<String?> supplierGstin = const Value.absent(),
            Value<String?> supplierEmail = const Value.absent(),
            Value<String?> supplierPhone = const Value.absent(),
            Value<String?> receiverName = const Value.absent(),
            Value<String?> receiverAddress = const Value.absent(),
            Value<String?> receiverGstin = const Value.absent(),
            Value<String?> receiverPan = const Value.absent(),
            Value<String?> receiverState = const Value.absent(),
            Value<String?> receiverStateCode = const Value.absent(),
            Value<String?> receiverEmail = const Value.absent(),
            Value<String?> originalInvoiceNumber = const Value.absent(),
            Value<DateTime?> originalInvoiceDate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InvoicesCompanion.insert(
            id: id,
            profileId: profileId,
            clientId: clientId,
            invoiceNo: invoiceNo,
            type: type,
            invoiceDate: invoiceDate,
            dueDate: dueDate,
            placeOfSupply: placeOfSupply,
            style: style,
            reverseCharge: reverseCharge,
            paymentTerms: paymentTerms,
            comments: comments,
            bankName: bankName,
            accountNo: accountNo,
            ifscCode: ifscCode,
            branch: branch,
            supplierName: supplierName,
            supplierAddress: supplierAddress,
            supplierGstin: supplierGstin,
            supplierEmail: supplierEmail,
            supplierPhone: supplierPhone,
            receiverName: receiverName,
            receiverAddress: receiverAddress,
            receiverGstin: receiverGstin,
            receiverPan: receiverPan,
            receiverState: receiverState,
            receiverStateCode: receiverStateCode,
            receiverEmail: receiverEmail,
            originalInvoiceNumber: originalInvoiceNumber,
            originalInvoiceDate: originalInvoiceDate,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$InvoicesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {profileId = false,
              clientId = false,
              invoiceItemsRefs = false,
              paymentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (invoiceItemsRefs) db.invoiceItems,
                if (paymentsRefs) db.payments
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (profileId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.profileId,
                    referencedTable:
                        $$InvoicesTableReferences._profileIdTable(db),
                    referencedColumn:
                        $$InvoicesTableReferences._profileIdTable(db).id,
                  ) as T;
                }
                if (clientId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.clientId,
                    referencedTable:
                        $$InvoicesTableReferences._clientIdTable(db),
                    referencedColumn:
                        $$InvoicesTableReferences._clientIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (invoiceItemsRefs)
                    await $_getPrefetchedData<Invoice, $InvoicesTable,
                            InvoiceItem>(
                        currentTable: table,
                        referencedTable: $$InvoicesTableReferences
                            ._invoiceItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$InvoicesTableReferences(db, table, p0)
                                .invoiceItemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.invoiceId == item.id),
                        typedResults: items),
                  if (paymentsRefs)
                    await $_getPrefetchedData<Invoice, $InvoicesTable, Payment>(
                        currentTable: table,
                        referencedTable:
                            $$InvoicesTableReferences._paymentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$InvoicesTableReferences(db, table, p0)
                                .paymentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.invoiceId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$InvoicesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InvoicesTable,
    Invoice,
    $$InvoicesTableFilterComposer,
    $$InvoicesTableOrderingComposer,
    $$InvoicesTableAnnotationComposer,
    $$InvoicesTableCreateCompanionBuilder,
    $$InvoicesTableUpdateCompanionBuilder,
    (Invoice, $$InvoicesTableReferences),
    Invoice,
    PrefetchHooks Function(
        {bool profileId,
        bool clientId,
        bool invoiceItemsRefs,
        bool paymentsRefs})>;
typedef $$InvoiceItemsTableCreateCompanionBuilder = InvoiceItemsCompanion
    Function({
  required String id,
  required String invoiceId,
  required String description,
  required String sacCode,
  required String codeType,
  required String year,
  required double amount,
  required double discount,
  required double quantity,
  required String unit,
  required double gstRate,
  Value<int> rowid,
});
typedef $$InvoiceItemsTableUpdateCompanionBuilder = InvoiceItemsCompanion
    Function({
  Value<String> id,
  Value<String> invoiceId,
  Value<String> description,
  Value<String> sacCode,
  Value<String> codeType,
  Value<String> year,
  Value<double> amount,
  Value<double> discount,
  Value<double> quantity,
  Value<String> unit,
  Value<double> gstRate,
  Value<int> rowid,
});

final class $$InvoiceItemsTableReferences
    extends BaseReferences<_$AppDatabase, $InvoiceItemsTable, InvoiceItem> {
  $$InvoiceItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $InvoicesTable _invoiceIdTable(_$AppDatabase db) =>
      db.invoices.createAlias(
          $_aliasNameGenerator(db.invoiceItems.invoiceId, db.invoices.id));

  $$InvoicesTableProcessedTableManager get invoiceId {
    final $_column = $_itemColumn<String>('invoice_id')!;

    final manager = $$InvoicesTableTableManager($_db, $_db.invoices)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_invoiceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$InvoiceItemsTableFilterComposer
    extends Composer<_$AppDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sacCode => $composableBuilder(
      column: $table.sacCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get codeType => $composableBuilder(
      column: $table.codeType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get discount => $composableBuilder(
      column: $table.discount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get gstRate => $composableBuilder(
      column: $table.gstRate, builder: (column) => ColumnFilters(column));

  $$InvoicesTableFilterComposer get invoiceId {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.invoiceId,
        referencedTable: $db.invoices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoicesTableFilterComposer(
              $db: $db,
              $table: $db.invoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InvoiceItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sacCode => $composableBuilder(
      column: $table.sacCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get codeType => $composableBuilder(
      column: $table.codeType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get discount => $composableBuilder(
      column: $table.discount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get gstRate => $composableBuilder(
      column: $table.gstRate, builder: (column) => ColumnOrderings(column));

  $$InvoicesTableOrderingComposer get invoiceId {
    final $$InvoicesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.invoiceId,
        referencedTable: $db.invoices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoicesTableOrderingComposer(
              $db: $db,
              $table: $db.invoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InvoiceItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get sacCode =>
      $composableBuilder(column: $table.sacCode, builder: (column) => column);

  GeneratedColumn<String> get codeType =>
      $composableBuilder(column: $table.codeType, builder: (column) => column);

  GeneratedColumn<String> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<double> get discount =>
      $composableBuilder(column: $table.discount, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get gstRate =>
      $composableBuilder(column: $table.gstRate, builder: (column) => column);

  $$InvoicesTableAnnotationComposer get invoiceId {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.invoiceId,
        referencedTable: $db.invoices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoicesTableAnnotationComposer(
              $db: $db,
              $table: $db.invoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InvoiceItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InvoiceItemsTable,
    InvoiceItem,
    $$InvoiceItemsTableFilterComposer,
    $$InvoiceItemsTableOrderingComposer,
    $$InvoiceItemsTableAnnotationComposer,
    $$InvoiceItemsTableCreateCompanionBuilder,
    $$InvoiceItemsTableUpdateCompanionBuilder,
    (InvoiceItem, $$InvoiceItemsTableReferences),
    InvoiceItem,
    PrefetchHooks Function({bool invoiceId})> {
  $$InvoiceItemsTableTableManager(_$AppDatabase db, $InvoiceItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoiceItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoiceItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoiceItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> invoiceId = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> sacCode = const Value.absent(),
            Value<String> codeType = const Value.absent(),
            Value<String> year = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<double> discount = const Value.absent(),
            Value<double> quantity = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<double> gstRate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InvoiceItemsCompanion(
            id: id,
            invoiceId: invoiceId,
            description: description,
            sacCode: sacCode,
            codeType: codeType,
            year: year,
            amount: amount,
            discount: discount,
            quantity: quantity,
            unit: unit,
            gstRate: gstRate,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String invoiceId,
            required String description,
            required String sacCode,
            required String codeType,
            required String year,
            required double amount,
            required double discount,
            required double quantity,
            required String unit,
            required double gstRate,
            Value<int> rowid = const Value.absent(),
          }) =>
              InvoiceItemsCompanion.insert(
            id: id,
            invoiceId: invoiceId,
            description: description,
            sacCode: sacCode,
            codeType: codeType,
            year: year,
            amount: amount,
            discount: discount,
            quantity: quantity,
            unit: unit,
            gstRate: gstRate,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$InvoiceItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({invoiceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (invoiceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.invoiceId,
                    referencedTable:
                        $$InvoiceItemsTableReferences._invoiceIdTable(db),
                    referencedColumn:
                        $$InvoiceItemsTableReferences._invoiceIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$InvoiceItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InvoiceItemsTable,
    InvoiceItem,
    $$InvoiceItemsTableFilterComposer,
    $$InvoiceItemsTableOrderingComposer,
    $$InvoiceItemsTableAnnotationComposer,
    $$InvoiceItemsTableCreateCompanionBuilder,
    $$InvoiceItemsTableUpdateCompanionBuilder,
    (InvoiceItem, $$InvoiceItemsTableReferences),
    InvoiceItem,
    PrefetchHooks Function({bool invoiceId})>;
typedef $$PaymentsTableCreateCompanionBuilder = PaymentsCompanion Function({
  required String id,
  required String invoiceId,
  required double amount,
  required DateTime date,
  required String method,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$PaymentsTableUpdateCompanionBuilder = PaymentsCompanion Function({
  Value<String> id,
  Value<String> invoiceId,
  Value<double> amount,
  Value<DateTime> date,
  Value<String> method,
  Value<String?> notes,
  Value<int> rowid,
});

final class $$PaymentsTableReferences
    extends BaseReferences<_$AppDatabase, $PaymentsTable, Payment> {
  $$PaymentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $InvoicesTable _invoiceIdTable(_$AppDatabase db) => db.invoices
      .createAlias($_aliasNameGenerator(db.payments.invoiceId, db.invoices.id));

  $$InvoicesTableProcessedTableManager get invoiceId {
    final $_column = $_itemColumn<String>('invoice_id')!;

    final manager = $$InvoicesTableTableManager($_db, $_db.invoices)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_invoiceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  $$InvoicesTableFilterComposer get invoiceId {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.invoiceId,
        referencedTable: $db.invoices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoicesTableFilterComposer(
              $db: $db,
              $table: $db.invoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  $$InvoicesTableOrderingComposer get invoiceId {
    final $$InvoicesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.invoiceId,
        referencedTable: $db.invoices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoicesTableOrderingComposer(
              $db: $db,
              $table: $db.invoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$InvoicesTableAnnotationComposer get invoiceId {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.invoiceId,
        referencedTable: $db.invoices,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvoicesTableAnnotationComposer(
              $db: $db,
              $table: $db.invoices,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PaymentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PaymentsTable,
    Payment,
    $$PaymentsTableFilterComposer,
    $$PaymentsTableOrderingComposer,
    $$PaymentsTableAnnotationComposer,
    $$PaymentsTableCreateCompanionBuilder,
    $$PaymentsTableUpdateCompanionBuilder,
    (Payment, $$PaymentsTableReferences),
    Payment,
    PrefetchHooks Function({bool invoiceId})> {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> invoiceId = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> method = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PaymentsCompanion(
            id: id,
            invoiceId: invoiceId,
            amount: amount,
            date: date,
            method: method,
            notes: notes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String invoiceId,
            required double amount,
            required DateTime date,
            required String method,
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PaymentsCompanion.insert(
            id: id,
            invoiceId: invoiceId,
            amount: amount,
            date: date,
            method: method,
            notes: notes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$PaymentsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({invoiceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (invoiceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.invoiceId,
                    referencedTable:
                        $$PaymentsTableReferences._invoiceIdTable(db),
                    referencedColumn:
                        $$PaymentsTableReferences._invoiceIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PaymentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PaymentsTable,
    Payment,
    $$PaymentsTableFilterComposer,
    $$PaymentsTableOrderingComposer,
    $$PaymentsTableAnnotationComposer,
    $$PaymentsTableCreateCompanionBuilder,
    $$PaymentsTableUpdateCompanionBuilder,
    (Payment, $$PaymentsTableReferences),
    Payment,
    PrefetchHooks Function({bool invoiceId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BusinessProfilesTableTableManager get businessProfiles =>
      $$BusinessProfilesTableTableManager(_db, _db.businessProfiles);
  $$ClientsTableTableManager get clients =>
      $$ClientsTableTableManager(_db, _db.clients);
  $$InvoicesTableTableManager get invoices =>
      $$InvoicesTableTableManager(_db, _db.invoices);
  $$InvoiceItemsTableTableManager get invoiceItems =>
      $$InvoiceItemsTableTableManager(_db, _db.invoiceItems);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
}
