import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  Widget build(final BuildContext context) {
    final platform = Theme.of(context).platform;
    if (platform == TargetPlatform.windows ||
        platform == TargetPlatform.linux) {
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
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;

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
    this.inputFormatters,
    this.focusNode,
  });

  @override
  Widget build(final BuildContext context) {
    final platform = Theme.of(context).platform;
    if (platform == TargetPlatform.windows ||
        platform == TargetPlatform.linux) {
      return fluent.InfoLabel(
        label: label,
        child: fluent.TextFormBox(
          controller: controller,
          focusNode: focusNode,
          initialValue: initialValue,
          placeholder: placeholder,
          onChanged: onChanged,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          readOnly: readOnly,
          inputFormatters: inputFormatters,
          autovalidateMode: fluent.AutovalidateMode.onUserInteraction,
        ),
      );
    }
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
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
      inputFormatters: inputFormatters,
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

  static Future<bool?> show(
    final BuildContext context, {
    required final String title,
    required final String content,
    final VoidCallback? onConfirm,
    final String confirmText = "Confirm",
    final String cancelText = "Cancel",
    final bool isDestructive = false,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (final context) => AppDialog(
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
  Widget build(final BuildContext context) {
    final platform = Theme.of(context).platform;
    if (platform == TargetPlatform.windows ||
        platform == TargetPlatform.linux) {
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
                    backgroundColor: fluent.WidgetStateProperty.all(
                      fluent.Colors.red,
                    ),
                  )
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

class AdaptiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const AdaptiveCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(final BuildContext context) {
    final platform = Theme.of(context).platform;
    if (platform == TargetPlatform.windows ||
        platform == TargetPlatform.linux) {
      return fluent.Card(
        padding: padding ?? const EdgeInsets.all(16),
        child: InkWell(onTap: onTap, child: child),
      );
    }
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

class AdaptiveSectionCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget? action;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  const AdaptiveSectionCard({
    super.key,
    required this.title,
    this.icon,
    this.action,
    required this.children,
    this.padding,
  });

  @override
  Widget build(final BuildContext context) {
    final platform = Theme.of(context).platform;
    if (platform == TargetPlatform.windows ||
        platform == TargetPlatform.linux) {
      return fluent.Card(
        padding: padding ?? const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: fluent.FluentTheme.of(context).typography.subtitle,
                ),
                const Spacer(),
                ?action,
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
        ),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ?action,
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
}

class AdaptiveSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const AdaptiveSwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(final BuildContext context) {
    final platform = Theme.of(context).platform;
    if (platform == TargetPlatform.windows ||
        platform == TargetPlatform.linux) {
      return fluent.ToggleSwitch(
        checked: value,
        onChanged: onChanged,
        content: Text(label),
      );
    }
    return SwitchListTile.adaptive(
      title: Text(label),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class AdaptiveSelect<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  const AdaptiveSelect({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(final BuildContext context) {
    final platform = Theme.of(context).platform;
    if (platform == TargetPlatform.windows ||
        platform == TargetPlatform.linux) {
      return fluent.InfoLabel(
        label: label,
        child: fluent.ComboBox<T>(
          value: value,
          items: items.map((final item) {
            return fluent.ComboBoxItem<T>(value: item.value, child: item.child);
          }).toList(),
          onChanged: onChanged,
        ),
      );
    }

    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
