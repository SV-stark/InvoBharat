import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:invobharat/providers/database_provider.dart'; // New
import 'package:invobharat/providers/business_profile_provider.dart';
import 'package:invobharat/providers/theme_provider.dart';
import 'package:invobharat/screens/dashboard_screen.dart';
import 'package:invobharat/screens/windows/fluent_home.dart';

void main() {
  runApp(const ProviderScope(child: InvoBharatApp()));
}

class InvoBharatApp extends ConsumerWidget {
  const InvoBharatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(businessProfileProvider);

    final appInit = ref.watch(appInitializationProvider);

    return appInit.when(
      data: (_) {
        if (Platform.isWindows || Platform.isLinux) {
          final accentColor = _getAccentColor(profile.color);
          // Return FluentApp for Windows and Linux
          return fluent.FluentApp(
            title: 'InvoBharat',
            debugShowCheckedModeBanner: false,
            themeMode: _getFluentThemeMode(ref.watch(themeProvider)),
            theme: fluent.FluentThemeData(
              brightness: Brightness.light,
              visualDensity: fluent.VisualDensity.standard,
              shadowColor: fluent.Colors.black,
              accentColor: accentColor,
            ),
            darkTheme: fluent.FluentThemeData(
              brightness: Brightness.dark,
              visualDensity: fluent.VisualDensity.standard,
              shadowColor: fluent.Colors.black,
              accentColor: accentColor,
            ),
            home: const FluentHome(),
          );
        }

        // Return MaterialApp for Android/Other
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
      },
      loading: () {
        if (Platform.isWindows || Platform.isLinux) {
          return const fluent.FluentApp(
            home: fluent.ScaffoldPage(
              content: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    fluent.ProgressRing(),
                    SizedBox(height: 20),
                    Text("Upgrading Database..."),
                  ],
                ),
              ),
            ),
          );
        }
        return const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text("Upgrading Database..."),
                ],
              ),
            ),
          ),
        );
      },
      error: (err, stack) {
        return fluent.FluentApp(
          home: fluent.ScaffoldPage(
            content: Center(
              child: Text("Error initializing app: $err"),
            ),
          ),
        );
      },
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

  fluent.AccentColor _getAccentColor(Color color) {
    // Map standard colors to Fluent AccentColors
    final colorMap = {
      fluent.Colors.teal.toARGB32(): fluent.Colors.teal,
      fluent.Colors.blue.toARGB32(): fluent.Colors.blue,
      fluent.Colors.red.toARGB32(): fluent.Colors.red,
      fluent.Colors.orange.toARGB32(): fluent.Colors.orange,
      fluent.Colors.green.toARGB32(): fluent.Colors.green,
      fluent.Colors.purple.toARGB32(): fluent.Colors.purple,
      fluent.Colors.magenta.toARGB32(): fluent.Colors.magenta,
      fluent.Colors.yellow.toARGB32(): fluent.Colors.yellow,
    };

    if (colorMap.containsKey(color.toARGB32())) {
      return colorMap[color.toARGB32()]!;
    }

    // Custom Color Swatch Generation
    final Map<String, Color> swatch = {
      'normal': color,
      'dark': color, // Ideally darken
      'light': color, // Ideally lighten
      'darkest': color,
      'darker': color,
      'lighter': color,
      'lightest': color,
    };
    return fluent.AccentColor('custom', swatch);
  }
}
