import 'package:flutter/material.dart';

class PageShell extends StatelessWidget {
  const PageShell({
    required this.title,
    required this.child,
    this.header,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? header;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SizedBox(height: 48),
                if (header != null) ...[header!, const SizedBox(height: 28)],
                Text(title, style: textTheme.headlineMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(subtitle!, style: textTheme.bodyMedium),
                ],
                const SizedBox(height: 28),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
