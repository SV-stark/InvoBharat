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
import 'package:invobharat/models/invoice.dart';
import 'package:invobharat/models/client.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (final context, final state) {
        if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
          return const FluentHome();
        }
        return const DashboardScreen();
      },
    ),
    GoRoute(
      path: '/invoice-form',
      builder: (final context, final state) {
        if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
          return FluentInvoiceWizard(invoiceToEdit: state.extra as Invoice?);
        }
        return InvoiceFormScreen(invoiceToEdit: state.extra as Invoice?);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (final context, final state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/payments',
      builder: (final context, final state) => const PaymentHistoryScreen(),
    ),
    GoRoute(
      path: '/audit',
      builder: (final context, final state) => const AuditReportScreen(),
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
        if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
          return FluentEstimateForm(estimateId: state.extra as String?);
        }
        return EstimateForm(estimateId: state.extra as String?);
      },
    ),
    GoRoute(
      path: '/invoices',
      builder: (final context, final state) => const InvoicesListScreen(),
    ),
    GoRoute(
      path: '/client-ledger',
      builder: (final context, final state) => ClientLedgerScreen(client: state.extra as Client),
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
      builder: (final context, final state) => InvoiceDetailScreen(
        invoice: state.extra as Invoice,
      ),
    ),
  ],
);
