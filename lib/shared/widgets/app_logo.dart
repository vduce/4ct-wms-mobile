import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    this.logoUrl,
    this.maxWidth = 280,
    this.maxHeight = 160,
    super.key,
  });

  static const assetPath = 'assets/branding/4ct_logo.png';

  final String? logoUrl;
  final double maxWidth;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final url = logoUrl?.trim();

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: url == null || url.isEmpty
            ? Image.asset(assetPath, fit: BoxFit.contain)
            : Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) =>
                    Image.asset(assetPath, fit: BoxFit.contain),
              ),
      ),
    );
  }
}
