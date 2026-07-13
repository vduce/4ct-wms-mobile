import 'package:flutter/material.dart';

import '../../app/theme/airport_feedback_design_tokens.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    AirportFeedbackColors.darkBackground,
                    AirportFeedbackColors.darkSurface,
                  ]
                : const [
                    AirportFeedbackColors.lightBackground,
                    Color(0xFFFFFFFF),
                  ],
          ),
        ),
        child: SafeArea(
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
      ),
    );
  }
}
