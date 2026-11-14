import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:invobharat/services/email_service.dart';

class EmailSettingsTab extends ConsumerStatefulWidget {
  const EmailSettingsTab({super.key});

  @override
  ConsumerState<EmailSettingsTab> createState() => _EmailSettingsTabState();
}

class _EmailSettingsTabState extends ConsumerState<EmailSettingsTab> {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSecure = true;
  bool _obscurePassword = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final settings = await EmailService.getSettingsStatic();
    if (settings != null) {
      if (mounted) {
        setState(() {
          _hostController.text = settings.smtpHost;
          _portController.text = settings.smtpPort.toString();
          _emailController.text = settings.email;
          _usernameController.text = settings.username;
          _passwordController.text = settings.password ?? '';
          _isSecure = settings.isSecure;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      if (!_isSecure) {
        final proceed = await showDialog<bool>(
          context: context,
          builder: (final ctx) => ContentDialog(
            title: const Text("Insecure SMTP Connection Warning"),
            content: const Text(
              "You have disabled SSL/TLS. Your email credentials and messages will be sent in cleartext without encryption. Are you sure you want to proceed?",
            ),
            actions: [
              Button(
                child: const Text("Cancel"),
                onPressed: () => Navigator.pop(ctx, false),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text("Proceed Anyway"),
              ),
            ],
          ),
        );
        if (proceed != true) return;
      }

      setState(() {
        _isLoading = true;
      });

      final settings = EmailSettings(
        smtpHost: _hostController.text.trim(),
        smtpPort: int.tryParse(_portController.text.trim()) ?? 587,
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        isSecure: _isSecure,
      );

      await EmailService.saveSettingsStatic(settings);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        await displayInfoBar(
          context,
          builder: (final context, final close) => const InfoBar(
            title: Text("Success"),
            content: Text("Email settings saved successfully!"),
            severity: InfoBarSeverity.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    if (_isLoading) {
      return const Center(child: ProgressRing());
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "SMTP Configuration",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Gap(8),
          const Text(
            "Configure your email provider to send invoices directly from InvoBharat.",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const Gap(24),
          InfoLabel(
            label: "SMTP Host",
            child: TextBox(
              controller: _hostController,
              placeholder: "e.g. smtp.gmail.com",
            ),
          ),
          const Gap(16),
          Row(
            children: [
              Expanded(
                child: InfoLabel(
                  label: "SMTP Port",
                  child: TextBox(
                    controller: _portController,
                    placeholder: "e.g. 587 or 465",
                  ),
                ),
              ),
              const Gap(16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ToggleSwitch(
                    checked: _isSecure,
                    content: Text(
                      _isSecure
                          ? "Secure Connection (SSL/TLS)"
                          : "Insecure Connection",
                    ),
                    onChanged: (final v) => setState(() => _isSecure = v),
                  ),
                ),
              ),
            ],
          ),
          const Gap(16),
          InfoLabel(
            label: "Email Address",
            child: TextBox(
              controller: _emailController,
              placeholder: "youremail@domain.com",
            ),
          ),
          const Gap(16),
          InfoLabel(
            label: "Username",
            child: TextBox(
              controller: _usernameController,
              placeholder: "Typically same as email",
            ),
          ),
          const Gap(16),
          InfoLabel(
            label: "App Password",
            child: TextBox(
              controller: _passwordController,
              obscureText: _obscurePassword,
              placeholder: "16-character app password",
              suffix: IconButton(
                icon: Icon(
                  _obscurePassword ? FluentIcons.hide : FluentIcons.red_eye,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
          const Gap(24),
          FilledButton(
            onPressed: _saveSettings,
            child: const Text("Save Email Settings"),
          ),
        ],
      ),
    );
  }
}
