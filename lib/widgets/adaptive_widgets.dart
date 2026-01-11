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

class AppTextInput extends StatelessWidget {
  final String label;
  final String? placeholder;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool readOnly;

  const AppTextInput({
    super.key,
    required this.label,
    this.placeholder,
    this.initialValue,
    this.onChanged,
    this.controller,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows || Platform.isLinux) {
      return fluent.InfoLabel(
        label: label,
        child: fluent.TextFormBox(
          controller: controller,
          initialValue: initialValue,
          placeholder: placeholder,
          onChanged: onChanged,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          readOnly: readOnly,
          autovalidateMode: fluent.AutovalidateMode.onUserInteraction,
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
      validator: validator,
      maxLines: maxLines,
      readOnly: readOnly,
    );
  }
}

class AppDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final String confirmText;
  final String cancelText;
  final bool isDestructive;

  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
    this.onCancel,
    this.confirmText = "Confirm",
    this.cancelText = "Cancel",
    this.isDestructive = false,
  });

  static Future<bool?> show(BuildContext context,
      {required String title,
      required String content,
      VoidCallback? onConfirm,
      String confirmText = "Confirm",
      String cancelText = "Cancel",
      bool isDestructive = false}) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        content: content,
        onConfirm: () {
          if (onConfirm != null) onConfirm();
          Navigator.pop(context, true);
        },
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows || Platform.isLinux) {
      return fluent.ContentDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          fluent.Button(
            child: Text(cancelText),
            onPressed: () {
              if (onCancel != null) {
                onCancel!();
              } else {
                Navigator.pop(context, false);
              }
            },
          ),
          fluent.FilledButton(
            style: isDestructive
                ? fluent.ButtonStyle(
                    backgroundColor:
                        fluent.WidgetStateProperty.all(fluent.Colors.red))
                : null,
            onPressed: onConfirm,
            child: Text(confirmText),
          ),
        ],
      );
    }
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () {
            if (onCancel != null) {
              onCancel!();
            } else {
              Navigator.pop(context, false);
            }
          },
          child: Text(cancelText),
        ),
        FilledButton(
          style: isDestructive
              ? FilledButton.styleFrom(backgroundColor: Colors.red)
              : null,
          onPressed: onConfirm,
          child: Text(confirmText),
        ),
      ],
    );
  }
}
