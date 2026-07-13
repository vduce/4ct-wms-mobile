import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations_context.dart';
import '../../../shared/widgets/adani_gradient_button.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/page_shell.dart';
import '../data/session_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpRequested = false;
  bool _busy = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return PageShell(
      header: const AppLogo(maxWidth: 260, maxHeight: 150),
      title: l10n.appTitle,
      subtitle: l10n.loginSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: l10n.emailOrUsernameLabel,
              prefixIcon: const Icon(Icons.alternate_email),
            ),
          ),
          const SizedBox(height: 12),
          if (_otpRequested)
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10n.otpLabel,
                prefixIcon: const Icon(Icons.password),
                counterText: '',
              ),
            ),
          const SizedBox(height: 20),
          AdaniGradientButton(
            onPressed: _busy ? null : _submit,
            icon: _busy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(_otpRequested ? Icons.verified_user : Icons.sms),
            label: Text(
              _otpRequested ? l10n.verifyOtpButton : l10n.sendOtpButton,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final controller = ref.read(sessionControllerProvider.notifier);
    setState(() => _busy = true);
    try {
      if (!_otpRequested) {
        final username = _emailController.text.trim();
        if (username.isEmpty) {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.enterEmailOrUsernameError)),
          );
          return;
        }
        await controller.requestOtp(username);
        setState(() => _otpRequested = true);
        messenger.showSnackBar(SnackBar(content: Text(l10n.otpSentMessage)));
      } else {
        final otp = _otpController.text.trim();
        if (otp.length != 6) {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.enterSixDigitOtpError)),
          );
          return;
        }
        await controller.verifyOtp(otp);
      }
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
