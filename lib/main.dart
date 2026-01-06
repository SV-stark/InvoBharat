import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/invoice_form.dart';

void main() {
  runApp(const ProviderScope(child: InvoBharatApp()));
}

class InvoBharatApp extends StatelessWidget {
  const InvoBharatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InvoBharat',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const InvoiceFormScreen(),
    );
  }
}
