import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/invoice.dart';

import '../providers/business_profile_provider.dart';

final invoiceProvider =
    NotifierProvider<InvoiceNotifier, Invoice>(InvoiceNotifier.new);

class InvoiceNotifier extends Notifier<Invoice> {
  @override
  Invoice build() {
    final profile = ref.watch(businessProfileProvider);
    // Initialize with defaults from profile
    return Invoice(
      id: null, // New invoice
      style: 'Modern',
      supplier: Supplier(
        name: profile.companyName,
        address: profile.address,
        gstin: profile.gstin,
        pan: "", // Optional: Add to profile model if needed
        email: profile.email,

        phone: profile.phone,
        state: profile.state,
      ),
      receiver: const Receiver(), // Empty
      invoiceDate: DateTime.now(),
      invoiceNo:
          "${profile.invoiceSeries}${profile.invoiceSequence.toString().padLeft(3, '0')}",
      items: [
        // One empty item to start
        const InvoiceItem(description: "", amount: 0, gstRate: 18),
      ],
      // Pre-fill bank details
      bankName: profile.bankName,
      accountNo: profile.accountNumber,
      ifscCode: profile.ifscCode,
      branch: profile.branchName,
    );
  }

  void setInvoice(Invoice invoice) {
    state = invoice;
  }

  void updateDate(DateTime date) {
    state = state.copyWith(invoiceDate: date);
  }

  void updatePlaceOfSupply(String val) {
    state = state.copyWith(placeOfSupply: val);
  }

  void updateReverseCharge(String val) {
    state = state.copyWith(reverseCharge: val);
  }

  void updateDeliveryAddress(String val) {
    state = state.copyWith(deliveryAddress: val);
  }

  void updateStyle(String val) {
    state = state.copyWith(style: val);
  }

  void updateInvoiceNo(String val) {
    state = state.copyWith(invoiceNo: val);
  }

  void updateSupplierName(String val) {
    state = state.copyWith(supplier: state.supplier.copyWith(name: val));
  }

  void updateSupplierGstin(String val) {
    state = state.copyWith(supplier: state.supplier.copyWith(gstin: val));
  }

  void updateReceiverName(String val) {
    state = state.copyWith(receiver: state.receiver.copyWith(name: val));
  }

  void updateReceiverGstin(String val) {
    state = state.copyWith(receiver: state.receiver.copyWith(gstin: val));
  }

  void updateReceiverState(String val) {
    state = state.copyWith(receiver: state.receiver.copyWith(state: val));
  }

  void updateReceiverAddress(String val) {
    state = state.copyWith(receiver: state.receiver.copyWith(address: val));
  }

  void updateReceiverStateCode(String val) {
    state = state.copyWith(receiver: state.receiver.copyWith(stateCode: val));
  }

  void updateItemDescription(int index, String val) {
    final newItems = List<InvoiceItem>.from(state.items);
    newItems[index] = newItems[index].copyWith(description: val);
    state = state.copyWith(items: newItems);
  }

  void updateItemAmount(int index, String val) {
    final newItems = List<InvoiceItem>.from(state.items);
    newItems[index] =
        newItems[index].copyWith(amount: double.tryParse(val) ?? 0.0);
    state = state.copyWith(items: newItems);
  }

  void updateItemGstRate(int index, String val) {
    final newItems = List<InvoiceItem>.from(state.items);
    newItems[index] =
        newItems[index].copyWith(gstRate: double.tryParse(val) ?? 0.0);
    state = state.copyWith(items: newItems);
  }

  void updateItemCodeType(int index, String val) {
    final newItems = List<InvoiceItem>.from(state.items);
    newItems[index] = newItems[index].copyWith(codeType: val);
    state = state.copyWith(items: newItems);
  }

  void updateItemSac(int index, String val) {
    final newItems = List<InvoiceItem>.from(state.items);
    newItems[index] = newItems[index].copyWith(sacCode: val);
    state = state.copyWith(items: newItems);
  }

  void updateItemYear(int index, String val) {
    final newItems = List<InvoiceItem>.from(state.items);
    newItems[index] = newItems[index].copyWith(year: val);
    state = state.copyWith(items: newItems);
  }

  void updateItemDiscount(int index, String val) {
    final newItems = List<InvoiceItem>.from(state.items);
    newItems[index] =
        newItems[index].copyWith(discount: double.tryParse(val) ?? 0.0);
    state = state.copyWith(items: newItems);
  }

  void updateItemQuantity(int index, String val) {
    final newItems = List<InvoiceItem>.from(state.items);
    newItems[index] =
        newItems[index].copyWith(quantity: double.tryParse(val) ?? 1.0);
    state = state.copyWith(items: newItems);
  }

  void updateItemUnit(int index, String val) {
    final newItems = List<InvoiceItem>.from(state.items);
    newItems[index] = newItems[index].copyWith(unit: val);
    state = state.copyWith(items: newItems);
  }

  void addItem() {
    state = state.copyWith(items: [
      ...state.items,
      // ignore: prefer_const_constructors
      InvoiceItem(description: "", amount: 0, gstRate: 18)
    ]);
  }

  void removeItem(int index) {
    if (state.items.length > 1) {
      final newItems = List<InvoiceItem>.from(state.items);
      newItems.removeAt(index);
      state = state.copyWith(items: newItems);
    }
  }
}
