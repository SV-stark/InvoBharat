import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/invoice_repository.dart';
import 'business_profile_provider.dart';

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  final profile = ref.watch(businessProfileProvider);
  return InvoiceRepository(profileId: profile.id);
});
