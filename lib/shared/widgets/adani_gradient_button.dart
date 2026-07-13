import 'package:flutter/material.dart';

import '../../app/theme/airport_feedback_design_tokens.dart';

class AdaniGradientButton extends StatelessWidget {
  const AdaniGradientButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon,
    this.height = 56,
    this.radius = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    this.gradient,
    super.key,
  });

  final Widget label;
  final Widget? icon;
  final Widget? trailingIcon;
  final VoidCallback? onPressed;
  final double height;
  final double radius;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveGradient =
        gradient ??
        (isDark
            ? AirportFeedbackGradients.darkSubmit
            : AirportFeedbackGradients.lightSubmit);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onPressed,
        child: Ink(
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            gradient: onPressed == null ? null : effectiveGradient,
            color: onPressed == null
                ? Theme.of(context).colorScheme.outlineVariant
                : null,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: onPressed == null
                ? const []
                : [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.24),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
          ),
          child: DefaultTextStyle.merge(
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
            child: IconTheme.merge(
              data: const IconThemeData(color: Colors.white, size: 22),
              child: _ButtonContent(
                label: label,
                icon: icon,
                trailingIcon: trailingIcon,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.icon,
    required this.trailingIcon,
  });

  final Widget label;
  final Widget? icon;
  final Widget? trailingIcon;

  @override
  Widget build(BuildContext context) {
    if (trailingIcon == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: 10)],
          Flexible(child: label),
        ],
      );
    }

    if (icon == null) {
      return Row(
        children: [
          const SizedBox(width: 28),
          Expanded(child: Center(child: label)),
          SizedBox(
            width: 28,
            child: Align(alignment: Alignment.centerRight, child: trailingIcon),
          ),
        ],
      );
    }

    return Row(
      children: [
        icon!,
        const SizedBox(width: 12),
        Expanded(child: label),
        const SizedBox(width: 12),
        trailingIcon!,
      ],
    );
  }
}
