import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/utils/gst_helper.dart'; // New Import

import 'package:invobharat/providers/business_profile_provider.dart';

final invoiceProvider =
    NotifierProvider<InvoiceNotifier, Invoice>(InvoiceNotifier.new);

class InvoiceNotifier extends Notifier<Invoice> {
  @override
  Invoice build() {
    final profile = ref.watch(businessProfileProvider);
    // Initialize with defaults from profile
    return Invoice(
      supplier: Supplier(
        name: profile.companyName,
        address: profile.address,
        gstin: profile.gstin,
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
        const InvoiceItem(
            ), // We can't generate ID here because it's const
        // We'll update it in init or make it non-const?
        // Actually, we can just make it not const in the provider.
      ],
      // Pre-fill bank details
      bankName: profile.bankName,
      accountNo: profile.accountNumber,
      ifscCode: profile.ifscCode,
      branch: profile.branchName,
    );
  }

  void setInvoice(final Invoice invoice) {
    state = invoice;
  }

  void reset() {
    final profile = ref.read(businessProfileProvider);
    state = Invoice(
      supplier: Supplier(
        name: profile.companyName,
        address: profile.address,
        gstin: profile.gstin,
        email: profile.email,
        phone: profile.phone,
        state: profile.state,
      ),
      receiver: const Receiver(),
      invoiceDate: DateTime.now(),
      invoiceNo:
          "${profile.invoiceSeries}${profile.invoiceSequence.toString().padLeft(3, '0')}",
      items: [
        InvoiceItem(
            id: const Uuid().v4()),
      ],
      bankName: profile.bankName,
      accountNo: profile.accountNumber,
      ifscCode: profile.ifscCode,
      branch: profile.branchName,
    );
  }

  void updateDate(final DateTime date) {
    state = state.copyWith(invoiceDate: date);
  }

  void updatePlaceOfSupply(final String val) {
    state = state.copyWith(placeOfSupply: val);
  }

  void updateReverseCharge(final String val) {
    state = state.copyWith(reverseCharge: val);
  }

  void updateDeliveryAddress(final String val) {
    state = state.copyWith(deliveryAddress: val);
  }

  void updateDueDate(final DateTime? date) {
    state = state.copyWith(dueDate: date);
  }

  void updatePaymentTerms(final String val) {
    state = state.copyWith(paymentTerms: val);
  }

  void updateTermComments(final String val) {
    state = state.copyWith(comments: val);
  }

  void updateStyle(final String val) {
    state = state.copyWith(style: val);
  }

  void updateInvoiceNo(final String val) {
    state = state.copyWith(invoiceNo: val);
  }

  void updateCurrency(final String val) {
    state = state.copyWith(currency: val);
  }

  void updateDiscountAmount(final String val) {
    state = state.copyWith(discountAmount: double.tryParse(val) ?? 0.0);
  }

  void updateSupplierName(final String val) {
    state = state.copyWith(supplier: state.supplier.copyWith(name: val));
  }

  void updateSupplierGstin(final String val) {
    state = state.copyWith(supplier: state.supplier.copyWith(gstin: val));
  }

  void updateReceiverName(final String val) {
    state = state.copyWith(receiver: state.receiver.copyWith(name: val));
  }

  void updateReceiverGstin(final String val) {
    state = state.copyWith(receiver: state.receiver.copyWith(gstin: val));

    // Auto-populate state
    if (val.length >= 2) {
      final stateName = GstUtils.getStateName(val);
      if (stateName != null) {
        // Only update if state is empty or user wants auto-update?
        // Usually, if they type GSTIN, they expect State to match.
        // We will overwrite state.
        updateReceiverState(stateName);
      }
    }
  }

  void updateReceiverState(final String val) {
    state = state.copyWith(receiver: state.receiver.copyWith(state: val));
  }

  void updateReceiverAddress(final String val) {
    state = state.copyWith(receiver: state.receiver.copyWith(address: val));
  }

  void updateReceiverStateCode(final String val) {
    state = state.copyWith(receiver: state.receiver.copyWith(stateCode: val));
  }

  void updateReceiverEmail(final String val) {
    state = state.copyWith(receiver: state.receiver.copyWith(email: val));
  }

  void updateItemDescription(final int index, final String val) {
    final newItems = List<InvoiceItem>.from(state.items);
    newItems[index] = newItems[index].copyWith(description: val);
    state = state.copyWith(items: newItems);
  }

  void updateItemAmount(final int index, final String val) {
    final newItems = List<InvoiceItem>.from(state.items);
    newItems[index] =
        newItems[index].copyWith(amount: double.tryParse(val) ?? 0.0);
    state = state.copyWith(items: newItems);
  }

  void updateItemGstRate(final int index, final String val) {
    final newItems = List<InvoiceItem>.from(state.items);
    newItems[index] =
        newItems[index].copyWith(gstRate: double.tryParse(val) ?? 0.0);
    state = state.copyWith(items: newItems);
  }

  void updateItemCodeType(final int index, final String val) {
    final newItems = List<InvoiceItem>.from(state.items);
    newItems[index] = newItems[index].copyWith(codeType: val);
    state = state.copyWith(items: newItems);
  }

  void updateItemSac(final int index, final String val) {
    final newItems = List<InvoiceItem>.from(state.items);
    newItems[index] = newItems[index].copyWith(sacCode: val);
    state = state.copyWith(items: newItems);
  }

  void updateItemYear(final int index, final String val) {
    final newItems = List<InvoiceItem>.from(state.items);
    newItems[index] = newItems[index].copyWith(year: val);
    state = state.copyWith(items: newItems);
  }

  void updateItemDiscount(final int index, final String val) {
    final newItems = List<InvoiceItem>.from(state.items);
    newItems[index] =
        newItems[index].copyWith(discount: double.tryParse(val) ?? 0.0);
    state = state.copyWith(items: newItems);
  }

  void updateItemQuantity(final int index, final String val) {
    final newItems = List<InvoiceItem>.from(state.items);
    newItems[index] =
        newItems[index].copyWith(quantity: double.tryParse(val) ?? 1.0);
    state = state.copyWith(items: newItems);
  }

  void updateItemUnit(final int index, final String val) {
    final newItems = List<InvoiceItem>.from(state.items);
    newItems[index] = newItems[index].copyWith(unit: val);
    state = state.copyWith(items: newItems);
  }

  void addItem() {
    state = state.copyWith(items: [
      ...state.items,
      InvoiceItem(
          id: const Uuid().v4())
    ]);
  }

  void updateInvoiceType(final InvoiceType type) {
    state = state.copyWith(type: type);
  }

  void updateOriginalInvoiceNumber(final String val) {
    state = state.copyWith(originalInvoiceNumber: val);
  }

  void updateOriginalInvoiceDate(final DateTime? date) {
    state = state.copyWith(originalInvoiceDate: date);
  }

  void removeItem(final int index) {
    if (state.items.length > 1) {
      final newItems = List<InvoiceItem>.from(state.items);
      newItems.removeAt(index);
      state = state.copyWith(items: newItems);
    }
  }

  void replaceItem(final int index, final InvoiceItem item) {
    if (index >= 0 && index < state.items.length) {
      final newItems = List<InvoiceItem>.from(state.items);
      newItems[index] = item;
      state = state.copyWith(items: newItems);
    }
  }

  void addInvoiceItem(final InvoiceItem item) {
    state = state.copyWith(items: [...state.items, item]);
  }

  void batchUpdate(final Invoice Function(Invoice) updater) {
    state = updater(state);
  }

  void updateItemAt(final int index, final InvoiceItem Function(InvoiceItem) updater) {
    if (index < 0 || index >= state.items.length) return;
    final newItems = List<InvoiceItem>.from(state.items);
    newItems[index] = updater(newItems[index]);
    state = state.copyWith(items: newItems);
  }
}
