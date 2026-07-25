import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    this.logoUrl,
    this.assetPath = fourCtAssetPath,
    this.adaptSvgBlackToTheme = false,
    this.maxWidth = 480,
    this.maxHeight = 260,
    super.key,
  });

  static const fourCtAssetPath = 'assets/branding/4ct_logo.png';

  final String? logoUrl;
  final String assetPath;
  final bool adaptSvgBlackToTheme;
  final double maxWidth;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final url = logoUrl?.trim();

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: url == null || url.isEmpty
            ? _buildAssetLogo(context)
            : Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => _buildAssetLogo(context),
              ),
      ),
    );
  }

  Widget _buildAssetLogo(BuildContext context) {
    if (assetPath.toLowerCase().endsWith('.svg')) {
      final colorMapper = adaptSvgBlackToTheme
          ? Theme.of(context).brightness == Brightness.dark
                ? const _BlackToColorMapper(Colors.white)
                : const _BlackToColorMapper(Colors.black)
          : null;

      return SvgPicture.asset(
        assetPath,
        fit: BoxFit.contain,
        colorMapper: colorMapper,
      );
    }

    return Image.asset(assetPath, fit: BoxFit.contain);
  }
}

class AdaniBrandMark extends StatelessWidget {
  const AdaniBrandMark({this.size = 28, super.key});

  static const lightAssetPath = 'assets/branding/adani_logo_light.jpg';
  static const darkAssetPath = 'assets/branding/adani_logo_dark.jpg';

  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: Image.asset(
          isDark ? darkAssetPath : lightAssetPath,
          width: size,
          height: size,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          filterQuality: FilterQuality.high,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => ColoredBox(
            color: isDark ? const Color(0xFF393939) : Colors.white,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: isDark ? Colors.white : const Color(0xFF7004A0),
              size: size * 0.82,
            ),
          ),
        ),
      ),
    );
  }
}

class _BlackToColorMapper extends ColorMapper {
  const _BlackToColorMapper(this.replacementColor);

  final Color replacementColor;

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    return color == Colors.black ? replacementColor : color;
  }
}
