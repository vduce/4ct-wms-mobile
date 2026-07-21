import 'package:flutter/material.dart';

abstract final class AuthenticatedFooterAssets {
  static const light = 'assets/operations/supervisor_footer_light.png';
  static const dark =
      'assets/operations/supervisor_footer_dark_transparent.png';
}

class AuthenticatedFooter extends StatelessWidget {
  const AuthenticatedFooter({required this.height, super.key});

  static const imageKey = Key('authenticated-footer-image');

  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final asset = theme.brightness == Brightness.dark
        ? AuthenticatedFooterAssets.dark
        : AuthenticatedFooterAssets.light;

    return SizedBox(
      width: double.infinity,
      height: height + bottomInset,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: ClipRect(
          child: Image.asset(
            asset,
            key: imageKey,
            width: double.infinity,
            height: height,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            excludeFromSemantics: true,
          ),
        ),
      ),
    );
  }
}
