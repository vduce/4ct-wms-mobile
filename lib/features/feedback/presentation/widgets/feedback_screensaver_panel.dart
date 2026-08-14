import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/airport_feedback_design_tokens.dart';
import '../../../../l10n/app_localizations_context.dart';
import '../../domain/feedback_models.dart';
import 'feedback_header.dart';
import 'feedback_metrics.dart';
import 'feedback_qr.dart';
import 'feedback_video_card.dart';
import 'feedback_welcome_cta.dart';

class FeedbackScreensaverPanel extends StatelessWidget {
  const FeedbackScreensaverPanel({
    required this.brandingName,
    required this.videoUrl,
    required this.metrics,
    required this.temperatureCelsius,
    required this.feedbackQrUrl,
    required this.onShowQr,
    required this.onStart,
    super.key,
  });

  final String brandingName;
  final String videoUrl;
  final FeedbackMetrics metrics;
  final num? temperatureCelsius;
  final String? feedbackQrUrl;
  final VoidCallback onShowQr;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AirportFeedbackColors.darkPrimaryText
        : AirportFeedbackColors.lightPrimaryText;
    final secondaryColor = isDark
        ? AirportFeedbackColors.darkSecondaryText
        : AirportFeedbackColors.lightSecondaryText;

    return LayoutBuilder(
      builder: (context, constraints) {
        final phone = constraints.maxWidth < 520;
        final tablet =
            constraints.maxWidth >= 760 && constraints.maxHeight >= 480;
        final compact = phone || constraints.maxHeight < 620;
        final metricsItems = buildFeedbackScreensaverMetrics(context, metrics);

        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              isDark
                  ? AirportFeedbackAssets.darkAirportBackground
                  : AirportFeedbackAssets.lightAirportBackground,
              fit: BoxFit.fill,
            ),
            if (tablet)
              _TabletScreensaverHome(
                brandingName: brandingName,
                videoUrl: videoUrl,
                metrics: metricsItems,
                onStart: onStart,
                textColor: textColor,
                secondaryColor: secondaryColor,
                compact: compact,
                temperatureCelsius: temperatureCelsius,
                feedbackQrUrl: feedbackQrUrl,
                onShowQr: onShowQr,
              )
            else
              _MobileScreensaverHome(
                brandingName: brandingName,
                videoUrl: videoUrl,
                metrics: metricsItems,
                onStart: onStart,
                textColor: textColor,
                secondaryColor: secondaryColor,
                compact: compact,
                temperatureCelsius: temperatureCelsius,
                feedbackQrUrl: feedbackQrUrl,
                onShowQr: onShowQr,
              ),
          ],
        );
      },
    );
  }
}

class _MobileScreensaverHome extends StatelessWidget {
  const _MobileScreensaverHome({
    required this.brandingName,
    required this.videoUrl,
    required this.metrics,
    required this.onStart,
    required this.textColor,
    required this.secondaryColor,
    required this.compact,
    required this.temperatureCelsius,
    required this.feedbackQrUrl,
    required this.onShowQr,
  });

  final String brandingName;
  final String videoUrl;
  final List<FeedbackScreensaverMetricItem> metrics;
  final VoidCallback onStart;
  final Color textColor;
  final Color secondaryColor;
  final bool compact;
  final num? temperatureCelsius;
  final String? feedbackQrUrl;
  final VoidCallback onShowQr;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final height = MediaQuery.sizeOf(context).height;
    final narrowHeader = MediaQuery.sizeOf(context).width < 440;
    final tight = height < 720;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, tight ? 10 : 14, 16, 12),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (narrowHeader)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FeedbackBrandHeader(
                    semanticsLabel: brandingName,
                    compact: true,
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FeedbackHomeHeaderActions(
                      compact: true,
                      temperatureCelsius: temperatureCelsius,
                    ),
                  ),
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: FeedbackBrandHeader(
                      semanticsLabel: brandingName,
                      compact: true,
                    ),
                  ),
                  const SizedBox(width: 6),
                  FeedbackHomeHeaderActions(
                    compact: true,
                    temperatureCelsius: temperatureCelsius,
                  ),
                ],
              ),
            SizedBox(height: tight ? 12 : 18),
            Text(
              l10n.feedbackWelcomePrefix,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: textColor,
                fontSize: tight ? 14 : 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.feedbackAirportName,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: textColor,
                fontSize: tight ? 24 : 28,
                height: 1.16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: tight ? 6 : 8),
            Text(
              l10n.feedbackWelcomeSubtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: secondaryColor,
                fontSize: tight ? 11.5 : 13,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: tight ? 10 : 16),
            FeedbackVideoCard(videoUrl: videoUrl, compact: true),
            SizedBox(height: tight ? 18 : 24),
            FeedbackWelcomeCta(
              compact: true,
              onPressed: onStart,
              expanded: true,
            ),
            SizedBox(height: tight ? 20 : 26),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: metrics.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.15,
              ),
              itemBuilder: (context, index) => FeedbackMetricStatusCard(
                item: metrics[index],
                compact: true,
                horizontal: false,
              ),
            ),
            if (feedbackQrUrl != null) ...[
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 150,
                  child: FeedbackDirectQrCard(
                    qrUrl: feedbackQrUrl!,
                    compact: true,
                    dense: true,
                    footer: true,
                    horizontal: false,
                    onTap: onShowQr,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TabletScreensaverHome extends StatelessWidget {
  const _TabletScreensaverHome({
    required this.brandingName,
    required this.videoUrl,
    required this.metrics,
    required this.onStart,
    required this.textColor,
    required this.secondaryColor,
    required this.compact,
    required this.temperatureCelsius,
    required this.feedbackQrUrl,
    required this.onShowQr,
  });

  final String brandingName;
  final String videoUrl;
  final List<FeedbackScreensaverMetricItem> metrics;
  final VoidCallback onStart;
  final Color textColor;
  final Color secondaryColor;
  final bool compact;
  final num? temperatureCelsius;
  final String? feedbackQrUrl;
  final VoidCallback onShowQr;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final size = MediaQuery.sizeOf(context);
    final shortHeight = size.height < 650;
    final edgePadding = size.width < 900 ? 18.0 : 34.0;
    final metricWidth = math.min(210.0, math.max(148.0, size.width * 0.17));
    final columnGap = shortHeight ? 10.0 : 16.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        edgePadding,
        shortHeight ? 14 : 24,
        edgePadding,
        shortHeight ? 14 : 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FeedbackBrandHeader(
                  semanticsLabel: brandingName,
                  compact: true,
                ),
              ),
              const SizedBox(width: 12),
              FeedbackHomeHeaderActions(
                compact: compact,
                temperatureCelsius: temperatureCelsius,
              ),
            ],
          ),
          SizedBox(height: shortHeight ? 8 : 14),
          Text(
            l10n.feedbackWelcomePrefix,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: textColor,
              fontSize: compact ? 17 : 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.feedbackAirportName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: textColor,
              fontSize: compact ? 32 : 44,
              height: 1.08,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: shortHeight ? 2 : 4),
          Text(
            l10n.feedbackWelcomeSubtitle.replaceAll('\n', ' '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: secondaryColor,
              fontSize: compact ? 12 : 14,
              height: 1.3,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: shortHeight ? 8 : 14),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: metricWidth,
                  child: FeedbackTabletMetricColumn(
                    items: metrics.take(2).toList(),
                    compact: compact,
                    gap: columnGap,
                  ),
                ),
                SizedBox(width: columnGap),
                Expanded(
                  flex: 4,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: FeedbackVideoCard(
                        videoUrl: videoUrl,
                        compact: compact,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: columnGap),
                SizedBox(
                  width: metricWidth,
                  child: FeedbackTabletMetricColumn(
                    items: metrics.skip(2).toList(),
                    compact: compact,
                    gap: columnGap,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: shortHeight ? 18 : 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: metricWidth),
              SizedBox(width: columnGap),
              Expanded(
                flex: 4,
                child: Center(
                  child: SizedBox(
                    width: size.width < 900 ? 340 : 430,
                    child: FeedbackWelcomeCta(
                      compact: compact,
                      onPressed: onStart,
                      expanded: true,
                    ),
                  ),
                ),
              ),
              SizedBox(width: columnGap),
              SizedBox(
                width: metricWidth,
                child: feedbackQrUrl == null
                    ? const SizedBox.shrink()
                    : Center(
                        child: FeedbackDirectQrCard(
                          qrUrl: feedbackQrUrl!,
                          compact: compact,
                          dense: true,
                          footer: true,
                          horizontal: false,
                          onTap: onShowQr,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
