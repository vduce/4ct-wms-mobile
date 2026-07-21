import 'package:flutter/material.dart';

import '../../../shared/widgets/authenticated_footer.dart';

class TenantScopePage extends StatelessWidget {
  const TenantScopePage({
    required this.child,
    this.showFooter = true,
    super.key,
  });

  final Widget child;
  final bool showFooter;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    if (!showFooter || mediaQuery.viewInsets.bottom > 0) return child;

    final width = mediaQuery.size.width;
    final footerHeight = width < 600
        ? (width * 0.20).clamp(64.0, 84.0).toDouble()
        : (width * 0.11).clamp(84.0, 112.0).toDouble();

    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: IgnorePointer(
            child: AuthenticatedFooter(height: footerHeight),
          ),
        ),
      ],
    );
  }
}
