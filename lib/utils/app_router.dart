import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:invobharat/screens/dashboard_screen.dart';
import 'package:invobharat/screens/windows/fluent_home.dart';
import 'package:invobharat/screens/invoice_form.dart';
import 'package:invobharat/screens/settings_screen.dart';
import 'package:invobharat/screens/payment_history_screen.dart';
import 'package:invobharat/screens/audit_report_screen.dart';
import 'package:invobharat/screens/recurring_invoices_screen.dart';
import 'package:invobharat/screens/material_clients_screen.dart';
import 'package:invobharat/screens/invoices_list_screen.dart';
import 'package:invobharat/screens/invoice_detail_screen.dart';
import 'package:invobharat/screens/windows/fluent_invoice_wizard.dart';
import 'package:invobharat/screens/windows/fluent_recurring_screen.dart';
import 'package:invobharat/screens/windows/fluent_estimates_screen.dart';
import 'package:invobharat/screens/clients_screen.dart';
import 'package:invobharat/screens/estimates_screen.dart';
import 'package:invobharat/screens/estimate_form.dart';
import 'package:invobharat/screens/item_templates_screen.dart';
import 'package:invobharat/screens/windows/fluent_item_templates_screen.dart';
import 'package:invobharat/screens/windows/fluent_recurring_form.dart';
import 'package:invobharat/screens/windows/fluent_estimate_form.dart';
import 'package:invobharat/screens/client_ledger_screen.dart';
import 'package:invobharat/screens/windows/fluent_settings.dart';
import 'package:flutter/material.dart' hide Colors, Builder;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:invobharat/services/logger_service.dart';
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/models/client.dart';

Widget _wrapMaterial(final Widget child) {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    return Material(child: ScaffoldMessenger(child: child));
  }
  return child;
}

final appRouter = GoRouter(
  initialLocation: '/',
  errorBuilder: (final context, final state) => Scaffold(
    appBar: AppBar(title: const Text('Page Not Found')),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Error: ${state.error ?? 'Unknown error'}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Return Home'),
          ),
        ],
      ),
    ),
  ),
  routes: [
    GoRoute(
      path: '/',
      builder: (final context, final state) {
        final tabStr = state.uri.queryParameters['tab'];
        final initialTab = int.tryParse(tabStr ?? '');
        if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
          return FluentHome(initialTab: initialTab);
        }
        return const DashboardScreen();
      },
    ),
    GoRoute(
      path: '/invoice-form',
      builder: (final context, final state) {
        Invoice? invoice;
        String? estimateId;

        if (state.extra is Invoice) {
          invoice = state.extra as Invoice;
        } else if (state.extra is Map<String, dynamic>) {
          final map = state.extra as Map<String, dynamic>;
          invoice = map['invoice'] as Invoice?;
          estimateId = map['estimateId'] as String?;
        }

        if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
          return FluentInvoiceWizard(
            invoiceToEdit: invoice,
            estimateId: estimateId,
          );
        }
        return InvoiceFormScreen(
          invoiceToEdit: invoice,
          estimateId: estimateId,
        );
      },
    ),

    GoRoute(
      path: '/payments',
      builder: (final context, final state) =>
          _wrapMaterial(const PaymentHistoryScreen()),
    ),
    GoRoute(
      path: '/audit',
      builder: (final context, final state) =>
          _wrapMaterial(const AuditReportScreen()),
    ),
    GoRoute(
      path: '/recurring',
      builder: (final context, final state) {
        if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
          return const FluentRecurringScreen();
        }
        return const RecurringInvoicesScreen();
      },
    ),
    GoRoute(
      path: '/clients',
      builder: (final context, final state) {
        if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
          return const ClientsScreen();
        }
        return const MaterialClientsScreen();
      },
    ),
    GoRoute(
      path: '/estimates',
      builder: (final context, final state) {
        if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
          return const FluentEstimatesScreen();
        }
        return const EstimatesScreen();
      },
    ),
    GoRoute(
      path: '/item-templates',
      builder: (final context, final state) {
        if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
          return const FluentItemTemplatesScreen();
        }
        return const ItemTemplatesScreen();
      },
    ),
    GoRoute(
      path: '/recurring-form',
      builder: (final context, final state) {
        if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
          return const FluentRecurringForm();
        }
        return const Scaffold(); // fallback
      },
    ),
    GoRoute(
      path: '/estimate-form',
      builder: (final context, final state) {
        final estimateId = state.extra is String ? state.extra as String : null;
        if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
          return FluentEstimateForm(estimateId: estimateId);
        }
        return EstimateForm(estimateId: estimateId);
      },
    ),
    GoRoute(
      path: '/invoices',
      builder: (final context, final state) =>
          _wrapMaterial(const InvoicesListScreen()),
    ),
    GoRoute(
      path: '/client-ledger',
      builder: (final context, final state) {
        final client = state.extra is Client
            ? state.extra as Client
            : const Client(id: '', name: 'Unknown');
        return _wrapMaterial(ClientLedgerScreen(client: client));
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (final context, final state) {
        if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
          return const FluentSettings();
        }
        return const SettingsScreen();
      },
    ),
    GoRoute(
      path: '/invoice-detail',
      builder: (final context, final state) {
        if (state.extra is Invoice) {
          return _wrapMaterial(
            InvoiceDetailScreen(invoice: state.extra as Invoice),
          );
        }
        return _wrapMaterial(
          Scaffold(
            appBar: AppBar(title: const Text('Invoice Details')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No invoice data provided.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Go to Invoices'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
    GoRoute(
      path: '/logs',
      builder: (final context, final state) {
        if (kReleaseMode) {
          return const Scaffold(
            body: Center(
              child: Text("Diagnostics screen is disabled in production."),
            ),
          );
        }
        return Consumer(
          builder: (final context, final ref, final child) {
            final talker = ref.watch(talkerProvider);
            return TalkerScreen(
              talker: talker,
              theme: const TalkerScreenTheme(
                backgroundColor: Color(0xFF1A1D24),
              ),
            );
          },
        );
      },
    ),
  ],
);
