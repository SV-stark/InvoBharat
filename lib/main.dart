import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/dashboard_screen.dart';
import 'screens/windows/fluent_home.dart';
import 'providers/business_profile_provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: InvoBharatApp()));
}

class InvoBharatApp extends ConsumerWidget {
  const InvoBharatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (Platform.isWindows) {
      // Return FluentApp for Windows
      return fluent.FluentApp(
        title: 'InvoBharat',
        debugShowCheckedModeBanner: false,
        themeMode: _getFluentThemeMode(ref.watch(themeProvider)),
        theme: fluent.FluentThemeData(
          brightness: Brightness.light,
          visualDensity: fluent.VisualDensity.standard,
          shadowColor: fluent.Colors.black,
        ),
        darkTheme: fluent.FluentThemeData(
          brightness: Brightness.dark,
          visualDensity: fluent.VisualDensity.standard,
          shadowColor: fluent.Colors.black,
        ),
        home: const FluentHome(),
      );
    }

    // Return MaterialApp for Android/Other
    final profile = ref.watch(businessProfileProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'InvoBharat',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
            seedColor: profile.color, brightness: Brightness.light),
        textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
            seedColor: profile.color, brightness: Brightness.dark),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      home: const DashboardScreen(),
    );
  }

  fluent.ThemeMode _getFluentThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return fluent.ThemeMode.system;
      case ThemeMode.light:
        return fluent.ThemeMode.light;
      case ThemeMode.dark:
        return fluent.ThemeMode.dark;
    }
  }
}
