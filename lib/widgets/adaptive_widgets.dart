import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

class AdaptiveButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool isFilled;

  const AdaptiveButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.isFilled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows || Platform.isLinux) {
      return isFilled
          ? fluent.FilledButton(onPressed: onPressed, child: child)
          : fluent.Button(onPressed: onPressed, child: child);
    }
    return isFilled
        ? FilledButton(onPressed: onPressed, child: child)
        : OutlinedButton(onPressed: onPressed, child: child);
  }
}

class AdaptiveTextField extends StatelessWidget {
  final String? label;
  final String? placeholder;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  const AdaptiveTextField({
    super.key,
    this.label,
    this.placeholder,
    this.initialValue,
    this.onChanged,
    this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows || Platform.isLinux) {
      return fluent.InfoLabel(
        label: label ?? "",
        child: fluent.TextFormBox(
          controller: controller,
          initialValue: initialValue,
          placeholder: placeholder,
          onChanged: onChanged,
          keyboardType: keyboardType,
        ),
      );
    }
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        hintText: placeholder,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
      keyboardType: keyboardType,
    );
  }
}
