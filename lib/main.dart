import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/dashboard_screen.dart';
import 'providers/business_profile_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: InvoBharatApp()));
}

class InvoBharatApp extends ConsumerWidget {
  const InvoBharatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(businessProfileProvider);

    return MaterialApp(
      title: 'InvoBharat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: profile.color),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const DashboardScreen(),
    );
  }
}
