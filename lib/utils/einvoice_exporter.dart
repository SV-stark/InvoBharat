import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/models/business_profile.dart';

class EInvoiceExporter {
  /// Resolves the 2-digit Indian GST state code from state name or GSTIN
  static String getStateCode(final String stateName, final String gstin) {
    // If GSTIN starts with 2 digits, those represent the state code
    if (gstin.trim().length >= 2) {
      final prefix = gstin.trim().substring(0, 2);
      if (RegExp(r'^\d{2}$').hasMatch(prefix)) {
        return prefix;
      }
    }

    final normalized = stateName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    const stateCodes = {
      'jammu': '01',
      'kashmir': '01',
      'jammuandkashmir': '01',
      'himachal': '02',
      'himachalpradesh': '02',
      'punjab': '03',
      'chandigarh': '04',
      'uttarakhand': '05',
      'haryana': '06',
      'delhi': '07',
      'nctofdelhi': '07',
      'rajasthan': '08',
      'uttarpradesh': '09',
      'up': '09',
      'bihar': '10',
      'sikkim': '11',
      'arunachal': '12',
      'arunachalpradesh': '12',
      'nagaland': '13',
      'manipur': '14',
      'mizoram': '15',
      'tripura': '16',
      'meghalaya': '17',
      'assam': '18',
      'westbengal': '19',
      'bengal': '19',
      'jharkhand': '20',
      'odisha': '21',
      'orissa': '21',
      'chhattisgarh': '22',
      'madhyapradesh': '23',
      'mp': '23',
      'gujarat': '24',
      'daman': '26',
      'diu': '26',
      'dadra': '26',
      'nagarhaveli': '26',
      'dadraandnagarhaveli': '26',
      'maharashtra': '27',
      'karnataka': '29',
      'goa': '30',
      'lakshadweep': '31',
      'kerala': '32',
      'tamilnadu': '33',
      'tamil': '33',
      'puducherry': '34',
      'pondicherry': '34',
      'andaman': '35',
      'nicobar': '35',
      'andamanandnicobar': '35',
      'telangana': '36',
      'andhrapradesh': '37',
      'andhra': '37',
      'ladakh': '38',
    };

    return stateCodes[normalized] ?? '07'; // Fallback to Delhi (07)
  }

  /// Extracts a 6-digit PIN code from address string
  static int getPincode(final String address) {
    final match = RegExp(r'\b\d{6}\b').firstMatch(address);
    if (match != null) {
      return int.tryParse(match.group(0)!) ?? 110001;
    }
    return 110001; // Default fallback PIN code
  }

  /// Truncates string to a safe maximum length and provides fallback for empty fields
  static String cleanText(final String value, final int maxLength, final String fallback) {
    final cleaned = value.trim();
    if (cleaned.isEmpty) return fallback;
    return cleaned.length > maxLength ? cleaned.substring(0, maxLength) : cleaned;
  }

  /// Maps internal unit labels to standard GST Unit Codes
  static String getGstUnitCode(final String unit) {
    final u = unit.trim().toUpperCase();
    if (u.contains('NOS') || u.contains('NUMBER')) return 'NOS';
    if (u.contains('PCS') || u.contains('PIECE')) return 'PCS';
    if (u.contains('BOX')) return 'BOX';
    if (u.contains('KGS') || u.contains('KG') || u.contains('KILOGRAM')) return 'KGS';
    if (u.contains('MTR') || u.contains('METER')) return 'MTR';
    if (u.contains('LTR') || u.contains('LITER')) return 'LTR';
    if (u.contains('SET')) return 'SET';
    if (u.contains('BAG')) return 'BAG';
    if (u.contains('HRS') || u.contains('HOUR')) return 'HRS';
    if (u.contains('OTH') || u.contains('OTHER')) return 'OTH';
    return u.isEmpty ? 'OTH' : (u.length > 8 ? u.substring(0, 8) : u);
  }

  /// Generates the standard NIC E-Invoice JSON payload
  static String generateEInvoiceJson(final Invoice invoice, final BusinessProfile profile) {
    final docType = invoice.type == InvoiceType.creditNote
        ? 'CRN'
        : invoice.type == InvoiceType.debitNote
            ? 'DBN'
            : 'INV';

    final sellerGstin = cleanText(invoice.supplier.gstin.isNotEmpty ? invoice.supplier.gstin : profile.gstin, 15, 'GSTIN_PENDING');
    final sellerName = cleanText(invoice.supplier.name.isNotEmpty ? invoice.supplier.name : profile.companyName, 100, 'Supplier Legal Name');
    final sellerAddress = cleanText(invoice.supplier.address.isNotEmpty ? invoice.supplier.address : profile.address, 100, 'Supplier Address');
    final sellerState = cleanText(invoice.supplier.state.isNotEmpty ? invoice.supplier.state : profile.state, 50, 'Delhi');
    final sellerStateCode = getStateCode(sellerState, sellerGstin);
    final sellerPin = getPincode(invoice.supplier.address.isNotEmpty ? invoice.supplier.address : profile.address);

    final buyerGstin = cleanText(invoice.receiver.gstin, 15, 'URP');
    final buyerName = cleanText(invoice.receiver.name, 100, 'Buyer Legal Name');
    final buyerAddress = cleanText(invoice.receiver.address, 100, 'Buyer Address');
    final buyerState = cleanText(invoice.receiver.state, 50, 'Delhi');
    final buyerStateCode = invoice.receiver.stateCode.isNotEmpty && invoice.receiver.stateCode.trim().length == 2
        ? invoice.receiver.stateCode.trim()
        : getStateCode(buyerState, buyerGstin);
    final buyerPin = getPincode(invoice.receiver.address);

    final List<Map<String, dynamic>> itemsList = [];
    for (int i = 0; i < invoice.items.length; i++) {
      final item = invoice.items[i];
      final qty = item.quantity;
      final price = item.amount;
      final discount = item.discount;
      final totAmt = price * qty;
      final assAmt = totAmt - discount;
      final rate = item.gstRate;

      final cgst = item.calculateCgst(invoice.isInterState);
      final sgst = item.calculateSgst(invoice.isInterState);
      final igst = item.calculateIgst(invoice.isInterState);

      itemsList.add({
        "SlNo": (i + 1).toString(),
        "PrdDesc": cleanText(item.description, 100, 'Product/Service'),
        "IsServc": item.codeType == 'SAC' ? 'Y' : 'N',
        "HsnCd": item.cleanSacCode,
        "Qty": double.parse(qty.toStringAsFixed(2)),
        "Unit": getGstUnitCode(item.unit),
        "UnitPrice": double.parse(price.toStringAsFixed(2)),
        "TotAmt": double.parse(totAmt.toStringAsFixed(2)),
        "Discount": double.parse(discount.toStringAsFixed(2)),
        "PreTaxVal": double.parse(assAmt.toStringAsFixed(2)),
        "AssAmt": double.parse(assAmt.toStringAsFixed(2)),
        "GstRt": double.parse(rate.toStringAsFixed(2)),
        "CgstAmt": double.parse(cgst.toStringAsFixed(2)),
        "SgstAmt": double.parse(sgst.toStringAsFixed(2)),
        "IgstAmt": double.parse(igst.toStringAsFixed(2)),
        "TotItemVal": double.parse(item.totalAmount.toStringAsFixed(2))
      });
    }

    final payload = {
      "Version": "1.1",
      "TranDtls": {
        "TaxSch": "GST",
        "SupTyp": buyerGstin == 'URP' ? 'B2C' : 'B2B',
        "RegRev": invoice.reverseCharge == 'Y' ? 'Y' : 'N',
        "IgstOnIntra": "N"
      },
      "DocDtls": {
        "Typ": docType,
        "No": invoice.invoiceNo.isEmpty ? 'TEMP-NO' : invoice.invoiceNo,
        "Dt": DateFormat('dd/MM/yyyy').format(invoice.invoiceDate)
      },
      "SellerDtls": {
        "Gstin": sellerGstin,
        "LglNm": sellerName,
        "Addr1": sellerAddress,
        "Loc": cleanText(sellerState, 50, 'Delhi'),
        "Pin": sellerPin,
        "Stcd": sellerStateCode
      },
      "BuyerDtls": {
        "Gstin": buyerGstin,
        "LglNm": buyerName,
        "Pos": buyerStateCode,
        "Addr1": buyerAddress,
        "Loc": cleanText(buyerState, 50, 'Delhi'),
        "Pin": buyerPin,
        "Stcd": buyerStateCode
      },
      "ItemList": itemsList,
      "ValDtls": {
        "AssVal": double.parse(invoice.totalTaxableValue.toStringAsFixed(2)),
        "CgstVal": double.parse(invoice.totalCGST.toStringAsFixed(2)),
        "SgstVal": double.parse(invoice.totalSGST.toStringAsFixed(2)),
        "IgstVal": double.parse(invoice.totalIGST.toStringAsFixed(2)),
        "Discount": double.parse(invoice.discountAmount.toStringAsFixed(2)),
        "TotInvVal": double.parse(invoice.grandTotal.toStringAsFixed(2))
      }
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// Exports and saves the E-Invoice JSON file cross-platform
  static Future<String?> exportEInvoice(
    final Invoice invoice,
    final BusinessProfile profile,
  ) async {
    final jsonContent = generateEInvoiceJson(invoice, profile);
    final bytes = Uint8List.fromList(utf8.encode(jsonContent));
    
    final cleanInvoiceNo = invoice.invoiceNo.replaceAll(RegExp(r'[^\w\s\-]+'), '_');
    final fileName = 'einvoice_${cleanInvoiceNo.isEmpty ? "draft" : cleanInvoiceNo}';

    return FileSaver.instance.saveFile(
      name: fileName,
      bytes: bytes,
      fileExtension: 'json',
      mimeType: MimeType.json,
    );
  }
}
