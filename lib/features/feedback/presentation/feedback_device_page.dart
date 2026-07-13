import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme/airport_feedback_design_tokens.dart';
import '../../../l10n/app_localizations_context.dart';
import '../../../shared/widgets/adani_gradient_button.dart';
import '../../../shared/widgets/app_loading_dialog.dart';
import '../../../shared/widgets/app_lottie_message_dialog.dart';
import '../../auth/data/session_controller.dart';
import '../../tenant/data/tenant_controller.dart';
import '../data/feedback_repository.dart';
import '../domain/feedback_models.dart';

enum _FeedbackStep { screensaver, choice, negative, thanks }

class FeedbackDevicePage extends ConsumerStatefulWidget {
  const FeedbackDevicePage({super.key});

  @override
  ConsumerState<FeedbackDevicePage> createState() => _FeedbackDevicePageState();
}

class _FeedbackDevicePageState extends ConsumerState<FeedbackDevicePage> {
  static const _idleDuration = Duration(seconds: 60);
  static const _thanksDuration = Duration(seconds: 3);

  final Set<String> _selectedReasonIds = <String>{};
  Timer? _idleTimer;
  Timer? _thanksTimer;
  _FeedbackStep _step = _FeedbackStep.screensaver;
  bool _submitting = false;
  bool _lastFeedbackPositive = true;
  String _comment = '';

  @override
  void initState() {
    super.initState();
    _startIdleTimer();
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _thanksTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedbackDeviceStateProvider);
    final branding = ref.watch(tenantControllerProvider).branding;

    return Scaffold(
      body: state.when(
        data: (data) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _handleGlobalTap,
          onPanDown: (_) => _startIdleTimer(),
          child: _KioskScaffold(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: switch (_step) {
                _FeedbackStep.screensaver => _ScreensaverPanel(
                  key: const ValueKey('screensaver'),
                  brandingName: branding.appName,
                  onStart: _showChoice,
                ),
                _FeedbackStep.choice => _ChoicePanel(
                  key: const ValueKey('choice'),
                  submitting: _submitting,
                  onBack: _resetToScreensaver,
                  onPositive: () => _submitPositive(data),
                  onNegative: _showNegative,
                ),
                _FeedbackStep.negative => _NegativeFeedbackPanel(
                  key: const ValueKey('negative'),
                  reasons: data.reasons,
                  selectedReasonIds: _selectedReasonIds,
                  comment: _comment,
                  submitting: _submitting,
                  onBack: _showChoice,
                  onToggleReason: _toggleReason,
                  onAddComment: () => _openCommentSheet(context),
                  onSubmit: () => _submitNegative(data),
                ),
                _FeedbackStep.thanks => _ThanksPanel(
                  key: const ValueKey('thanks'),
                  positive: _lastFeedbackPositive,
                  onDone: _resetToScreensaver,
                ),
              },
            ),
          ),
        ),
        loading: () => const _LoadingShell(),
        error: (error, _) => _ErrorShell(
          message: error.toString(),
          onRetry: () => ref.invalidate(feedbackDeviceStateProvider),
          onSignOut: () =>
              ref.read(sessionControllerProvider.notifier).signOut(),
        ),
      ),
    );
  }

  void _handleGlobalTap() {
    _startIdleTimer();
    if (_step == _FeedbackStep.screensaver) {
      _showChoice();
    }
  }

  void _startIdleTimer() {
    _idleTimer?.cancel();
    if (_step == _FeedbackStep.screensaver || _step == _FeedbackStep.thanks) {
      return;
    }
    _idleTimer = Timer(_idleDuration, _resetToScreensaver);
  }

  void _showChoice() {
    setState(() {
      _step = _FeedbackStep.choice;
      _selectedReasonIds.clear();
      _comment = '';
    });
    _startIdleTimer();
  }

  void _showNegative() {
    setState(() => _step = _FeedbackStep.negative);
    _startIdleTimer();
  }

  void _toggleReason(String id) {
    setState(() {
      if (_selectedReasonIds.contains(id)) {
        _selectedReasonIds.remove(id);
      } else {
        _selectedReasonIds.add(id);
      }
    });
    _startIdleTimer();
  }

  Future<void> _openCommentSheet(BuildContext context) async {
    _startIdleTimer();
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _CommentSheet(initialComment: _comment),
    );
    if (result != null && mounted) {
      setState(() => _comment = result.trim());
      _startIdleTimer();
    }
  }

  Future<void> _submitPositive(FeedbackDeviceState data) async {
    final washroom = data.washroom;
    final submitFailedError = context.l10n.feedbackSubmitFailedError;
    if (washroom == null) {
      _showSnack(context.l10n.feedbackNoWashroomError);
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref
          .read(feedbackRepositoryProvider)
          .submitFeedback(
            washroomId: washroom.id,
            positive: true,
            reasons: const [],
          );
      _showThanks(positive: true);
    } catch (_) {
      _showSnack(submitFailedError);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _submitNegative(FeedbackDeviceState data) async {
    final washroom = data.washroom;
    final submitFailedError = context.l10n.feedbackSubmitFailedError;
    if (washroom == null) {
      _showSnack(context.l10n.feedbackNoWashroomError);
      return;
    }
    if (_selectedReasonIds.isEmpty) {
      _showSnack(context.l10n.feedbackSelectIssueError);
      return;
    }

    final selectedReasons = data.reasons
        .where((reason) => _selectedReasonIds.contains(reason.id))
        .map((reason) => reason.reason)
        .toList();

    setState(() => _submitting = true);
    try {
      await ref
          .read(feedbackRepositoryProvider)
          .submitFeedback(
            washroomId: washroom.id,
            positive: false,
            reasons: selectedReasons,
            comment: _comment,
          );
      _showThanks(positive: false);
    } catch (_) {
      _showSnack(submitFailedError);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showThanks({required bool positive}) {
    _idleTimer?.cancel();
    _thanksTimer?.cancel();
    setState(() {
      _lastFeedbackPositive = positive;
      _step = _FeedbackStep.thanks;
    });
    _thanksTimer = Timer(_thanksDuration, _resetToScreensaver);
    ref.invalidate(feedbackDeviceStateProvider);
  }

  void _resetToScreensaver() {
    _idleTimer?.cancel();
    _thanksTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _step = _FeedbackStep.screensaver;
      _selectedReasonIds.clear();
      _comment = '';
      _submitting = false;
    });
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _KioskScaffold extends StatelessWidget {
  const _KioskScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  AirportFeedbackColors.darkBackground,
                  Color(0xFF001B34),
                  AirportFeedbackColors.darkBackground,
                ]
              : const [
                  AirportFeedbackColors.lightBackground,
                  Color(0xFFFFFFFF),
                ],
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}

class _ScreensaverPanel extends StatelessWidget {
  const _ScreensaverPanel({
    required this.brandingName,
    required this.onStart,
    super.key,
  });

  final String brandingName;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
        final compact =
            phone || constraints.maxWidth < 720 || constraints.maxHeight < 620;
        final horizontalPadding = phone ? 22.0 : (compact ? 22.0 : 42.0);
        final topPadding = phone ? 14.0 : (compact ? 20.0 : 34.0);
        final contentWidth = math.min(
          phone
              ? constraints.maxWidth - (horizontalPadding * 2)
              : constraints.maxWidth * (compact ? 0.74 : 0.48),
          compact ? 390.0 : 460.0,
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              isDark
                  ? AirportFeedbackAssets.darkAirportBackground
                  : AirportFeedbackAssets.lightAirportBackground,
              fit: BoxFit.cover,
              alignment: isDark ? Alignment.centerRight : Alignment.center,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: isDark
                      ? [
                          AirportFeedbackColors.darkBackground.withValues(
                            alpha: 0.88,
                          ),
                          AirportFeedbackColors.darkBackground.withValues(
                            alpha: 0.34,
                          ),
                          Colors.transparent,
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.78),
                          Colors.white.withValues(alpha: 0.36),
                          Colors.transparent,
                        ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                topPadding,
                horizontalPadding,
                compact ? 22 : 34,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _BrandHeader(
                          semanticsLabel: brandingName,
                          compact: compact,
                        ),
                      ),
                      SizedBox(width: phone ? 8 : 14),
                      _LanguagePill(compact: compact),
                    ],
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: contentWidth),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.feedbackWelcomePrefix,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: textColor,
                                    fontSize: phone ? 18 : (compact ? 19 : 23),
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.feedbackAirportName,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(
                                    color: textColor,
                                    fontSize: phone ? 31 : (compact ? 35 : 48),
                                    height: 1.06,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            SizedBox(height: phone ? 14 : (compact ? 18 : 26)),
                            Text(
                              l10n.feedbackWelcomeSubtitle,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: secondaryColor,
                                    fontSize: phone
                                        ? 12.5
                                        : (compact ? 15 : 18),
                                    height: phone ? 1.34 : 1.45,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            SizedBox(height: phone ? 68 : (compact ? 28 : 42)),
                            _WelcomeCta(compact: compact, onPressed: onStart),
                            SizedBox(height: phone ? 28 : (compact ? 26 : 44)),
                            _QrStartCard(compact: compact),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.semanticsLabel, required this.compact});

  final String semanticsLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final phone = MediaQuery.sizeOf(context).width < 520;
    final logoHeight = phone ? 37.0 : (compact ? 34.0 : 48.0);
    final logoWidth = phone ? 170.0 : (compact ? 194.0 : 258.0);

    return Semantics(
      label: semanticsLabel,
      child: Row(
        children: [
          _AdaniWordmark(compact: compact),
          Container(
            width: 1,
            height: phone ? 24 : (compact ? 27 : 36),
            margin: EdgeInsets.symmetric(
              horizontal: phone ? 8 : (compact ? 12 : 18),
            ),
            color:
                (isDark ? Colors.white : AirportFeedbackColors.lightPrimaryText)
                    .withValues(alpha: 0.35),
          ),
          Flexible(
            child: SizedBox(
              height: logoHeight,
              child: Align(
                alignment: Alignment.centerLeft,
                child: SvgPicture.asset(
                  AirportFeedbackAssets.mialLogo,
                  width: logoWidth,
                  height: logoHeight,
                  fit: BoxFit.contain,
                  colorFilter: isDark
                      ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdaniWordmark extends StatelessWidget {
  const _AdaniWordmark({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final phone = MediaQuery.sizeOf(context).width < 520;

    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          AirportFeedbackColors.primaryBlue,
          AirportFeedbackColors.primaryPurple,
          AirportFeedbackColors.primaryPink,
        ],
      ).createShader(bounds),
      child: Text(
        'adani',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Colors.white,
          fontSize: phone ? 22 : (compact ? 25 : 32),
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _LanguagePill extends StatelessWidget {
  const _LanguagePill({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark
        ? Colors.white
        : AirportFeedbackColors.lightPrimaryText;
    final phone = MediaQuery.sizeOf(context).width < 520;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: phone ? 8 : (compact ? 12 : 16),
        vertical: phone ? 7 : (compact ? 9 : 11),
      ),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF071B31).withValues(alpha: 0.86)
            : Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark ? const Color(0xFF253C5C) : const Color(0xFFE6E8EF),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.language_rounded,
            color: foreground,
            size: phone ? 13 : (compact ? 16 : 18),
          ),
          SizedBox(width: phone ? 4 : 7),
          Text(
            l10n.feedbackLanguageEnglish,
            style: TextStyle(
              color: foreground,
              fontSize: phone ? 10 : (compact ? 12 : 13),
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(width: phone ? 2 : 4),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: foreground,
            size: phone ? 13 : (compact ? 16 : 18),
          ),
        ],
      ),
    );
  }
}

class _WelcomeCta extends StatelessWidget {
  const _WelcomeCta({required this.compact, required this.onPressed});

  final bool compact;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final phone = MediaQuery.sizeOf(context).width < 520;

    return SizedBox(
      width: phone ? double.infinity : (compact ? 310 : 390),
      child: AdaniGradientButton(
        onPressed: onPressed,
        height: compact ? 64 : 76,
        radius: 18,
        gradient: isDark
            ? AirportFeedbackGradients.darkWelcome
            : AirportFeedbackGradients.lightWelcome,
        padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 20),
        icon: _FeedbackCommentIcon(compact: compact),
        label: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.feedbackShareFeedbackTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact ? 15 : 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              l10n.feedbackStartSubtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.82),
                fontSize: compact ? 11 : 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        trailingIcon: Icon(
          Icons.arrow_forward_rounded,
          size: compact ? 22 : 26,
        ),
      ),
    );
  }
}

class _FeedbackCommentIcon extends StatelessWidget {
  const _FeedbackCommentIcon({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final phone = MediaQuery.sizeOf(context).width < 520;
    final size = phone ? 42.0 : (compact ? 42.0 : 48.0);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      child: CustomPaint(painter: _FeedbackCommentIconPainter()),
    );
  }
}

class _FeedbackCommentIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bubblePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final dotPaint = Paint()
      ..color = AirportFeedbackColors.primaryPurple.withValues(alpha: 0.76)
      ..style = PaintingStyle.fill;

    final bubbleRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.25,
        size.height * 0.28,
        size.width * 0.52,
        size.height * 0.39,
      ),
      Radius.circular(size.width * 0.11),
    );
    canvas.drawRRect(bubbleRect, bubblePaint);

    final tail = Path()
      ..moveTo(size.width * 0.36, size.height * 0.64)
      ..lineTo(size.width * 0.28, size.height * 0.76)
      ..lineTo(size.width * 0.49, size.height * 0.66)
      ..close();
    canvas.drawPath(tail, bubblePaint);

    final dotRadius = size.width * 0.035;
    for (final offset in const [0.42, 0.51, 0.60]) {
      canvas.drawCircle(
        Offset(size.width * offset, size.height * 0.475),
        dotRadius,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QrStartCard extends StatelessWidget {
  const _QrStartCard({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final phone = MediaQuery.sizeOf(context).width < 520;
    final foreground = isDark
        ? Colors.white
        : AirportFeedbackColors.lightPrimaryText;

    return Container(
      width: phone ? double.infinity : (compact ? 250 : 292),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 16 : 20,
        vertical: compact ? 13 : 16,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF081B33).withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF243B5A) : const Color(0xFFE6E8EF),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.qr_code_2_rounded,
            color: foreground,
            size: compact ? 30 : 36,
          ),
          SizedBox(width: compact ? 12 : 16),
          Expanded(
            child: Text(
              l10n.feedbackQrStartLabel,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foreground,
                fontSize: compact ? 13 : 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoicePanel extends StatelessWidget {
  const _ChoicePanel({
    required this.submitting,
    required this.onBack,
    required this.onPositive,
    required this.onNegative,
    super.key,
  });

  final bool submitting;
  final VoidCallback onBack;
  final VoidCallback onPositive;
  final VoidCallback onNegative;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark
        ? AirportFeedbackColors.darkPrimaryText
        : AirportFeedbackColors.lightPrimaryText;
    final secondaryText = isDark
        ? AirportFeedbackColors.darkSecondaryText
        : AirportFeedbackColors.lightSecondaryText;

    return LayoutBuilder(
      builder: (context, constraints) {
        final phone = constraints.maxWidth < 520;
        final compact =
            phone || constraints.maxWidth < 720 || constraints.maxHeight < 620;
        final stacked = constraints.maxWidth < 340;
        final shortHeight = constraints.maxHeight < 600;
        final buttonHeight = phone
            ? (shortHeight ? 184.0 : 200.0)
            : stacked
            ? (shortHeight ? 360.0 : 430.0)
            : (shortHeight ? 250.0 : 340.0);
        final children = [
          Expanded(
            child: _FeedbackChoiceButton(
              title: l10n.feedbackChoiceSatisfiedTitle,
              subtitle: l10n.feedbackChoiceSatisfiedSubtitle,
              positive: true,
              onTap: submitting ? null : onPositive,
            ),
          ),
          SizedBox(
            width: stacked ? 0 : (phone ? 14 : 36),
            height: stacked ? 18 : 0,
          ),
          Expanded(
            child: _FeedbackChoiceButton(
              title: l10n.needsAttentionButton,
              subtitle: l10n.feedbackChoiceNeedsAttentionSubtitle,
              positive: false,
              onTap: submitting ? null : onNegative,
            ),
          ),
        ];

        return Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: -80,
              height: phone ? 116 : (compact ? 156 : 230),
              child: _AirportSkylineStrip(isDark: isDark),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                phone ? 16 : (compact ? 18 : 30),
                phone ? 10 : (compact ? 14 : 24),
                phone ? 16 : (compact ? 18 : 30),
                phone ? 12 : (compact ? 18 : 24),
              ),
              child: Column(
                children: [
                  _StepHeader(
                    activeStep: 1,
                    compact: compact,
                    onBack: onBack,
                    showLanguage: true,
                  ),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 940),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _MoodFace(
                              positive: true,
                              size: phone ? 66 : (compact ? 72 : 88),
                              decorative: true,
                            ),
                            SizedBox(
                              height: phone ? 14 : (shortHeight ? 16 : 22),
                            ),
                            Text(
                              l10n.feedbackChoiceTitle,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(
                                    color: primaryText,
                                    fontSize: phone ? 28 : (compact ? 31 : 38),
                                    height: 1.08,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            SizedBox(
                              height: phone ? 7 : (shortHeight ? 8 : 12),
                            ),
                            Text(
                              l10n.feedbackChoiceSubtitle,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: secondaryText,
                                    fontSize: phone ? 12 : (compact ? 14 : 16),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            SizedBox(
                              height: phone ? 28 : (shortHeight ? 28 : 40),
                            ),
                            Flexible(
                              child: SizedBox(
                                height: buttonHeight,
                                child: stacked
                                    ? Column(children: children)
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: children,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.activeStep,
    required this.compact,
    required this.onBack,
    this.showLanguage = false,
  });

  final int activeStep;
  final bool compact;
  final VoidCallback onBack;
  final bool showLanguage;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RoundIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onPressed: onBack,
          compact: compact,
        ),
        Expanded(
          child: Center(child: _ProgressSteps(activeStep: activeStep)),
        ),
        if (showLanguage)
          _LanguagePill(compact: compact)
        else
          SizedBox(width: compact ? 44 : 52),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onPressed,
    required this.compact,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark
        ? Colors.white
        : AirportFeedbackColors.lightPrimaryText;

    return Material(
      color: isDark ? const Color(0xFF071B31) : Colors.white,
      shape: CircleBorder(
        side: BorderSide(
          color: isDark ? const Color(0xFF253C5C) : const Color(0xFFE6E8EF),
        ),
      ),
      elevation: isDark ? 0 : 8,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox.square(
          dimension: compact ? 44 : 52,
          child: Icon(icon, color: foreground, size: compact ? 18 : 20),
        ),
      ),
    );
  }
}

class _ProgressSteps extends StatelessWidget {
  const _ProgressSteps({required this.activeStep});

  final int activeStep;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final phone = MediaQuery.sizeOf(context).width < 520;
    final active = isDark
        ? AirportFeedbackColors.progressActiveDark
        : AirportFeedbackColors.progressActiveLight;
    final inactive = isDark
        ? AirportFeedbackColors.progressInactiveDark
        : AirportFeedbackColors.progressInactiveLight;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < 4; index++) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: index == activeStep ? (phone ? 18 : 22) : (phone ? 9 : 12),
            height: phone ? 9 : 12,
            decoration: BoxDecoration(
              color: index <= activeStep ? active : inactive,
              borderRadius: BorderRadius.circular(999),
            ),
            child: index < activeStep
                ? Icon(
                    Icons.check_rounded,
                    size: phone ? 8 : 10,
                    color: Colors.white,
                  )
                : null,
          ),
          if (index < 3)
            Container(
              width: phone ? 30 : 44,
              height: phone ? 2.4 : 3,
              color: index < activeStep ? active : inactive,
            ),
        ],
      ],
    );
  }
}

class _MoodFace extends StatelessWidget {
  const _MoodFace({
    required this.positive,
    required this.size,
    this.decorative = false,
  });

  final bool positive;
  final double size;
  final bool decorative;

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: positive
          ? const [Color(0xFF7BE3BF), Color(0xFF05B78C)]
          : const [Color(0xFFFF8A99), Color(0xFFF13B49)],
    );

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        if (decorative) ...[
          Positioned(
            left: -42,
            bottom: 4,
            child: Icon(
              Icons.cloud_rounded,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.12)
                  : const Color(0xFFDAD5FF),
              size: size * 0.45,
            ),
          ),
          Positioned(
            right: -34,
            top: 8,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: AirportFeedbackColors.primaryPink,
              size: size * 0.22,
            ),
          ),
          Positioned(
            left: -26,
            top: -8,
            child: Icon(
              Icons.star_rounded,
              color: AirportFeedbackColors.darkPrimaryCyan,
              size: size * 0.18,
            ),
          ),
        ],
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: gradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color:
                    (positive
                            ? AirportFeedbackColors.goodActionLight
                            : AirportFeedbackColors.badActionLight)
                        .withValues(alpha: 0.24),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: CustomPaint(painter: _FacePainter(positive: positive)),
        ),
      ],
    );
  }
}

class _FeedbackChoiceButton extends StatelessWidget {
  const _FeedbackChoiceButton({
    required this.title,
    required this.subtitle,
    required this.positive,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool positive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final phoneCard =
            constraints.maxWidth < 210 || constraints.maxHeight < 215;
        final veryTight = constraints.maxHeight < 250;
        final tight = constraints.maxHeight < 320;
        final compact = phoneCard || tight || constraints.maxWidth < 330;
        final horizontalPadding = phoneCard
            ? 12.0
            : veryTight
            ? 14.0
            : tight
            ? 20.0
            : compact
            ? 18.0
            : 28.0;
        final verticalPadding = phoneCard
            ? 12.0
            : veryTight
            ? 14.0
            : tight
            ? 18.0
            : compact
            ? 18.0
            : 28.0;
        final faceSize = phoneCard
            ? 56.0
            : veryTight
            ? 58.0
            : tight
            ? 78.0
            : compact
            ? 72.0
            : 92.0;
        final titleFontSize = phoneCard
            ? 19.0
            : veryTight
            ? 20.0
            : tight
            ? 24.0
            : compact
            ? 22.0
            : 27.0;
        final subtitleFontSize = phoneCard
            ? 10.5
            : veryTight
            ? 11.5
            : tight
            ? 13.0
            : compact
            ? 12.5
            : 15.0;
        final actionSize = phoneCard
            ? 36.0
            : veryTight
            ? 36.0
            : tight
            ? 44.0
            : compact
            ? 42.0
            : 50.0;
        final cardColor = isDark
            ? (positive
                  ? AirportFeedbackColors.goodCardDark
                  : AirportFeedbackColors.badCardDark)
            : (positive
                  ? AirportFeedbackColors.goodCardLight
                  : AirportFeedbackColors.badCardLight);
        final borderColor = isDark
            ? (positive
                  ? AirportFeedbackColors.goodCardBorderDark
                  : AirportFeedbackColors.badCardBorderDark)
            : (positive
                  ? AirportFeedbackColors.goodCardBorderLight
                  : AirportFeedbackColors.badCardBorderLight);
        final actionColor = isDark
            ? (positive
                  ? AirportFeedbackColors.goodActionDark
                  : AirportFeedbackColors.badActionDark)
            : (positive
                  ? AirportFeedbackColors.goodActionLight
                  : AirportFeedbackColors.badActionLight);
        final primaryText = isDark
            ? AirportFeedbackColors.darkPrimaryText
            : AirportFeedbackColors.lightPrimaryText;
        final secondaryText = isDark
            ? AirportFeedbackColors.darkSecondaryText
            : AirportFeedbackColors.lightSecondaryText;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(phoneCard ? 18 : 26),
            onTap: onTap,
            child: Ink(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              decoration: BoxDecoration(
                color: cardColor.withValues(alpha: isDark ? 0.92 : 0.84),
                borderRadius: BorderRadius.circular(phoneCard ? 18 : 26),
                border: Border.all(color: borderColor, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: borderColor.withValues(alpha: isDark ? 0.16 : 0.2),
                    blurRadius: 26,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _MoodFace(positive: positive, size: faceSize),
                  SizedBox(
                    height: phoneCard
                        ? 8
                        : veryTight
                        ? 8
                        : tight
                        ? 14
                        : compact
                        ? 14
                        : 20,
                  ),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: primaryText,
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: phoneCard ? 4 : (tight ? 5 : 8)),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: secondaryText,
                      fontSize: subtitleFontSize,
                      height: phoneCard ? 1.12 : 1.22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: phoneCard
                        ? 10
                        : veryTight
                        ? 8
                        : tight
                        ? 16
                        : compact
                        ? 18
                        : 26,
                  ),
                  Container(
                    width: actionSize,
                    height: actionSize,
                    decoration: BoxDecoration(
                      color: actionColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FacePainter extends CustomPainter {
  const _FacePainter({required this.positive});

  final bool positive;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AirportFeedbackColors.lightPrimaryText
      ..style = PaintingStyle.fill;
    final eyeRadius = size.width * 0.045;
    canvas.drawCircle(
      Offset(size.width * 0.36, size.height * 0.42),
      eyeRadius,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.64, size.height * 0.42),
      eyeRadius,
      paint,
    );

    final mouthPaint = Paint()
      ..color = AirportFeedbackColors.lightPrimaryText
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.055
      ..style = PaintingStyle.stroke;
    final mouthRect = Rect.fromCenter(
      center: Offset(
        size.width * 0.5,
        positive ? size.height * 0.5 : size.height * 0.72,
      ),
      width: size.width * 0.36,
      height: size.height * 0.32,
    );
    canvas.drawArc(
      mouthRect,
      positive ? 0.18 : 3.32,
      positive ? 2.78 : 2.78,
      false,
      mouthPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _FacePainter oldDelegate) =>
      oldDelegate.positive != positive;
}

class _CommentSheet extends StatefulWidget {
  const _CommentSheet({required this.initialComment});

  final String initialComment;

  @override
  State<_CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<_CommentSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialComment);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
          top: 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.feedbackCommentTitle,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              autofocus: true,
              maxLines: 4,
              maxLength: 240,
              decoration: InputDecoration(hintText: l10n.feedbackCommentHint),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(_controller.text),
              child: Text(l10n.feedbackCommentSaveButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _NegativeFeedbackPanel extends StatelessWidget {
  const _NegativeFeedbackPanel({
    required this.reasons,
    required this.selectedReasonIds,
    required this.comment,
    required this.submitting,
    required this.onBack,
    required this.onToggleReason,
    required this.onAddComment,
    required this.onSubmit,
    super.key,
  });

  final List<FeedbackReason> reasons;
  final Set<String> selectedReasonIds;
  final String comment;
  final bool submitting;
  final VoidCallback onBack;
  final ValueChanged<String> onToggleReason;
  final VoidCallback onAddComment;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark
        ? AirportFeedbackColors.darkPrimaryText
        : AirportFeedbackColors.lightPrimaryText;
    final secondaryText = isDark
        ? AirportFeedbackColors.darkSecondaryText
        : AirportFeedbackColors.lightSecondaryText;

    return LayoutBuilder(
      builder: (context, panelConstraints) {
        final phone = panelConstraints.maxWidth < 520;
        final compact =
            phone ||
            panelConstraints.maxWidth < 760 ||
            panelConstraints.maxHeight < 620;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            phone ? 14 : (compact ? 18 : 30),
            phone ? 10 : (compact ? 14 : 24),
            phone ? 14 : (compact ? 18 : 30),
            phone ? 12 : (compact ? 18 : 24),
          ),
          child: Column(
            children: [
              _StepHeader(
                activeStep: 2,
                compact: compact,
                onBack: submitting ? () {} : onBack,
              ),
              SizedBox(height: phone ? 12 : (compact ? 18 : 26)),
              Text(
                l10n.feedbackNegativeTitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: primaryText,
                  fontSize: phone ? 18 : (compact ? 21 : 27),
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: phone ? 2 : 4),
              Text(
                l10n.feedbackNegativeSubtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: primaryText,
                  fontSize: phone ? 17 : (compact ? 18 : 22),
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: phone ? 6 : 8),
              Text(
                l10n.feedbackNegativeHelper,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: secondaryText,
                  fontSize: phone ? 10.5 : (compact ? 12 : 14),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: phone ? 12 : (compact ? 18 : 24)),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1040),
                    child: reasons.isEmpty
                        ? const _EmptyReasons()
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final minTileWidth = compact ? 118.0 : 150.0;
                              final count = phone
                                  ? 4
                                  : math.max(
                                      2,
                                      math.min(
                                        5,
                                        constraints.maxWidth ~/ minTileWidth,
                                      ),
                                    );
                              return GridView.builder(
                                itemCount: reasons.length,
                                padding: EdgeInsets.zero,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: count,
                                      crossAxisSpacing: phone
                                          ? 8
                                          : (compact ? 12 : 18),
                                      mainAxisSpacing: phone
                                          ? 8
                                          : (compact ? 12 : 18),
                                      childAspectRatio: phone
                                          ? 1.02
                                          : (compact ? 1.08 : 1.14),
                                    ),
                                itemBuilder: (context, index) {
                                  final reason = reasons[index];
                                  return _ReasonTile(
                                    reason: reason,
                                    selected: selectedReasonIds.contains(
                                      reason.id,
                                    ),
                                    onTap: submitting
                                        ? null
                                        : () => onToggleReason(reason.id),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ),
              ),
              SizedBox(height: phone ? 10 : (compact ? 14 : 18)),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: _CommentFieldButton(
                  comment: comment,
                  onPressed: submitting ? null : onAddComment,
                ),
              ),
              SizedBox(height: phone ? 10 : (compact ? 14 : 18)),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: AdaniGradientButton(
                  onPressed: submitting ? null : onSubmit,
                  height: phone ? 52 : (compact ? 58 : 66),
                  radius: 12,
                  label: submitting
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          l10n.feedbackSubmitButton,
                          style: TextStyle(
                            fontSize: phone ? 14 : (compact ? 15 : 18),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                  trailingIcon: submitting
                      ? null
                      : Icon(
                          Icons.send_rounded,
                          size: phone ? 18 : (compact ? 20 : 23),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CommentFieldButton extends StatelessWidget {
  const _CommentFieldButton({required this.comment, required this.onPressed});

  final String comment;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final phone = MediaQuery.sizeOf(context).width < 520;
    final textColor = isDark
        ? AirportFeedbackColors.darkSecondaryText
        : AirportFeedbackColors.lightSecondaryText;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Ink(
          height: phone ? 46 : 54,
          padding: EdgeInsets.symmetric(horizontal: phone ? 14 : 18),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF0B2A37).withValues(alpha: 0.86)
                : const Color(0xFFF1F0FA).withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF245162) : const Color(0xFFE6E5F0),
            ),
          ),
          child: Row(
            children: [
              Icon(
                comment.isEmpty
                    ? Icons.chat_bubble_outline_rounded
                    : Icons.chat_bubble_rounded,
                color: textColor,
                size: phone ? 17 : 20,
              ),
              SizedBox(width: phone ? 9 : 12),
              Expanded(
                child: Text(
                  comment.isEmpty
                      ? l10n.feedbackCommentFieldPlaceholder
                      : comment,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontSize: phone ? 12.5 : 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReasonTile extends StatelessWidget {
  const _ReasonTile({
    required this.reason,
    required this.selected,
    required this.onTap,
  });

  final FeedbackReason reason;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = selected
        ? (isDark
              ? AirportFeedbackColors.issueSelectedDark
              : AirportFeedbackColors.issueSelectedLight)
        : (isDark
              ? AirportFeedbackColors.issueCardDark
              : AirportFeedbackColors.issueCardLight);
    final borderColor = selected
        ? (isDark
              ? AirportFeedbackColors.issueSelectedBorderDark
              : AirportFeedbackColors.issueSelectedBorderLight)
        : (isDark
              ? AirportFeedbackColors.issueCardBorderDark
              : AirportFeedbackColors.issueCardBorderLight);
    final textColor = isDark
        ? AirportFeedbackColors.darkPrimaryText
        : AirportFeedbackColors.lightPrimaryText;

    return LayoutBuilder(
      builder: (context, constraints) {
        final phoneTile =
            constraints.maxWidth < 96 || constraints.maxHeight < 92;
        final compact =
            phoneTile ||
            constraints.maxHeight < 124 ||
            constraints.maxWidth < 132;
        final graphicSize = phoneTile ? 30.0 : (compact ? 42.0 : 58.0);
        final radius = phoneTile ? 10.0 : 14.0;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(radius),
            onTap: onTap,
            child: Ink(
              padding: EdgeInsets.symmetric(
                horizontal: phoneTile ? 5 : (compact ? 8 : 12),
                vertical: phoneTile ? 5 : (compact ? 8 : 11),
              ),
              decoration: BoxDecoration(
                color: cardColor.withValues(alpha: isDark ? 0.92 : 0.96),
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: borderColor,
                  width: selected ? 1.6 : 1,
                ),
                boxShadow: isDark
                    ? const []
                    : [
                        BoxShadow(
                          color: const Color(
                            0xFF09183A,
                          ).withValues(alpha: 0.05),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _reasonGraphic(
                          size: graphicSize,
                          iconSize: phoneTile ? 20 : (compact ? 25 : 34),
                        ),
                        SizedBox(height: phoneTile ? 3 : (compact ? 6 : 10)),
                        Text(
                          reason.reason,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: textColor,
                                fontSize: phoneTile
                                    ? 8.4
                                    : (compact ? 10.5 : 12),
                                height: phoneTile ? 1.05 : 1.12,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (selected)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: borderColor,
                        size: phoneTile ? 14 : (compact ? 17 : 20),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _reasonGraphic({required double size, required double iconSize}) {
    final asset = _reasonAsset(reason.reason);
    final imageUrl = reason.imageUrl?.trim() ?? '';
    final color = _reasonColor(reason);
    final fallbackIcon = Icon(
      _reasonIcon(reason.reason),
      color: color,
      size: iconSize,
    );

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      child: asset != null
          ? Image.asset(asset, fit: BoxFit.contain)
          : imageUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => fallbackIcon,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return fallbackIcon;
                },
              ),
            )
          : fallbackIcon,
    );
  }

  String? _reasonAsset(String label) {
    final value = label.toLowerCase();
    if (value.contains('slippery') || value.contains('floor')) {
      return AirportFeedbackAssets.slipperyFloor;
    }
    if (value.contains('soap')) return AirportFeedbackAssets.noSoap;
    if (value.contains('paper')) return AirportFeedbackAssets.noToiletPaper;
    if (value.contains('mirror')) return AirportFeedbackAssets.mirrorDirty;
    if (value.contains('urinal')) return AirportFeedbackAssets.urinalDirty;
    if (value.contains('commode') || value.contains('toilet')) {
      return AirportFeedbackAssets.commodeDirty;
    }
    if (value.contains('sink')) return AirportFeedbackAssets.sinkClogged;
    if (value.contains('basin')) return AirportFeedbackAssets.washbasinDirty;
    if (value.contains('water')) return AirportFeedbackAssets.waterjetIssue;
    if (value.contains('smell') ||
        value.contains('odor') ||
        value.contains('odour')) {
      return AirportFeedbackAssets.unpleasantSmell;
    }
    if (value.contains('other')) return AirportFeedbackAssets.others;
    return null;
  }

  IconData _reasonIcon(String label) {
    final value = label.toLowerCase();
    if (value.contains('bin')) return Icons.delete_outline_rounded;
    if (value.contains('smell') || value.contains('odor')) {
      return Icons.air_rounded;
    }
    if (value.contains('basin') || value.contains('sink')) {
      return Icons.countertops_rounded;
    }
    if (value.contains('paper')) return Icons.receipt_long_rounded;
    if (value.contains('soap')) return Icons.soap_rounded;
    if (value.contains('slippery') || value.contains('floor')) {
      return Icons.warning_amber_rounded;
    }
    if (value.contains('mirror')) return Icons.crop_portrait_rounded;
    if (value.contains('commode') || value.contains('toilet')) {
      return Icons.wc_rounded;
    }
    if (value.contains('urinal')) return Icons.male_rounded;
    if (value.contains('water')) return Icons.water_drop_rounded;
    return Icons.cleaning_services_rounded;
  }

  Color _reasonColor(FeedbackReason reason) {
    return switch (reason.priority.toLowerCase()) {
      'high' => const Color(0xFFE04F4F),
      'low' => const Color(0xFF1D9A6C),
      _ => const Color(0xFF3157D5),
    };
  }
}

class _EmptyReasons extends StatelessWidget {
  const _EmptyReasons();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        context.l10n.feedbackEmptyReasonsMessage,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.black54,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ThanksPanel extends StatelessWidget {
  const _ThanksPanel({required this.positive, required this.onDone, super.key});

  final bool positive;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppLottieMessageDialog(
      animationAsset: AirportFeedbackAssets.successAnimation,
      title: l10n.feedbackThanksTitle,
      message: positive
          ? l10n.feedbackThanksPositiveSubtitle
          : l10n.feedbackThanksNegativeSubtitle,
      actionLabel: l10n.doneButton,
      onAction: onDone,
      fallbackIcon: positive ? Icons.verified_rounded : Icons.handshake_rounded,
    );
  }
}

class _LoadingShell extends StatelessWidget {
  const _LoadingShell();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ColoredBox(
      color: isDark
          ? AirportFeedbackColors.darkBackground
          : AirportFeedbackColors.lightBackground,
      child: const AppLoadingDialog(),
    );
  }
}

class _ErrorShell extends StatelessWidget {
  const _ErrorShell({
    required this.message,
    required this.onRetry,
    required this.onSignOut,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark
        ? AirportFeedbackColors.darkSurface
        : AirportFeedbackColors.lightSurface;
    final primaryText = isDark
        ? AirportFeedbackColors.darkPrimaryText
        : AirportFeedbackColors.lightPrimaryText;

    return ColoredBox(
      color: isDark
          ? AirportFeedbackColors.darkBackground
          : AirportFeedbackColors.lightBackground,
      child: Center(
        child: Container(
          width: 520,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 56),
              const SizedBox(height: 18),
              Text(
                l10n.feedbackDeviceNotReadyTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: primaryText,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onSignOut,
                      child: Text(l10n.signOutTooltip),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: onRetry,
                      child: Text(l10n.retryButton),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AirportSkylineStrip extends StatelessWidget {
  const _AirportSkylineStrip({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (!isDark) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: Image.asset(
        isDark ? AirportFeedbackAssets.darkAirportSkyline : AirportFeedbackAssets.lightAirportSkyline,
        fit: BoxFit.fill,
        alignment: Alignment.bottomCenter,
      ),
    );
  }
}
