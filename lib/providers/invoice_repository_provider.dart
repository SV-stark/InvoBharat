import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/invoice_repository.dart';
import '../models/invoice.dart'; // New import
import 'business_profile_provider.dart';

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  final profile = ref.watch(businessProfileProvider);
  return InvoiceRepository(profileId: profile.id);
});

final invoiceListProvider = FutureProvider<List<Invoice>>((ref) async {
  return ref.watch(invoiceRepositoryProvider).getAllInvoices();
});
