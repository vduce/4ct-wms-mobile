import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations_context.dart';
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
            brandingName: branding.appName,
            logoUrl: branding.logoUrl,
            washroom: data.washroom,
            metrics: data.metrics,
            onSignOut: () =>
                ref.read(sessionControllerProvider.notifier).signOut(),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: switch (_step) {
                _FeedbackStep.screensaver => _ScreensaverPanel(
                  key: const ValueKey('screensaver'),
                  washroom: data.washroom,
                  metrics: data.metrics,
                  onStart: _showChoice,
                ),
                _FeedbackStep.choice => _ChoicePanel(
                  key: const ValueKey('choice'),
                  submitting: _submitting,
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
  const _KioskScaffold({
    required this.brandingName,
    required this.logoUrl,
    required this.washroom,
    required this.metrics,
    required this.onSignOut,
    required this.child,
  });

  final String brandingName;
  final String? logoUrl;
  final FeedbackWashroom? washroom;
  final FeedbackMetrics metrics;
  final VoidCallback onSignOut;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 760 || size.height < 720;
    final tablet = size.shortestSide >= 600;
    final horizontalPadding = compact ? 16.0 : (tablet ? 28.0 : 32.0);
    final verticalPadding = compact ? 12.0 : 24.0;
    final sectionGap = compact ? 12.0 : 22.0;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF06121F), Color(0xFF142B38), Color(0xFF102019)],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _KioskBackgroundPainter()),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                verticalPadding,
                horizontalPadding,
                verticalPadding,
              ),
              child: Column(
                children: [
                  _TopBar(
                    brandingName: brandingName,
                    logoUrl: logoUrl,
                    washroom: washroom,
                    onSignOut: onSignOut,
                    compact: compact,
                  ),
                  SizedBox(height: sectionGap),
                  _MetricStrip(metrics: metrics, compact: compact),
                  SizedBox(height: compact ? 14 : sectionGap + 2),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.brandingName,
    required this.logoUrl,
    required this.washroom,
    required this.onSignOut,
    required this.compact,
  });

  final String brandingName;
  final String? logoUrl;
  final FeedbackWashroom? washroom;
  final VoidCallback onSignOut;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final logoSize = compact ? 58.0 : 68.0;

    return Row(
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          padding: EdgeInsets.all(compact ? 8 : 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(compact ? 16 : 18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: logoUrl == null || logoUrl!.trim().isEmpty
              ? Icon(
                  Icons.local_airport_rounded,
                  color: const Color(0xFF102019),
                  size: compact ? 30 : 34,
                )
              : Image.network(logoUrl!, fit: BoxFit.contain),
        ),
        SizedBox(width: compact ? 12 : 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                brandingName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                washroom == null
                    ? l10n.feedbackKioskLabel
                    : '${washroom!.name}${washroom!.code.isEmpty ? '' : ' · ${washroom!.code}'}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.74),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: compact ? 10 : 12),
        _QrBadge(compact: compact),
        SizedBox(width: compact ? 10 : 12),
        IconButton.filledTonal(
          tooltip: l10n.signOutTooltip,
          onPressed: onSignOut,
          icon: const Icon(Icons.logout_rounded),
        ),
      ],
    );
  }
}

class _QrBadge extends StatelessWidget {
  const _QrBadge({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 14,
        vertical: compact ? 9 : 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(compact ? 16 : 18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.36)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.qr_code_2_rounded,
            color: const Color(0xFF102019),
            size: compact ? 24 : 28,
          ),
          SizedBox(width: compact ? 6 : 8),
          Text(
            l10n.scanLabel,
            style: const TextStyle(
              color: Color(0xFF102019),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricStrip extends StatelessWidget {
  const _MetricStrip({required this.metrics, required this.compact});

  final FeedbackMetrics metrics;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      _MetricItem(
        l10n.metricAqiLabel,
        _formatNumber(metrics.aqi),
        Icons.eco_rounded,
      ),
      _MetricItem(
        l10n.metricOccupancyLabel,
        metrics.occupancyLabel,
        Icons.meeting_room_rounded,
      ),
      _MetricItem(
        l10n.metricFootfallLabel,
        '${metrics.footfall ?? '-'}',
        Icons.directions_walk,
      ),
      _MetricItem(
        l10n.metricOdourLabel,
        _formatNumber(metrics.odour),
        Icons.air_rounded,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = compact ? 154.0 : 168.0;
        final gap = compact ? 10.0 : 12.0;
        final requiredWidth =
            (items.length * tileWidth) + ((items.length - 1) * gap);
        final canFit = constraints.maxWidth >= requiredWidth;

        return SizedBox(
          height: compact ? 76 : 92,
          child: canFit
              ? Row(
                  children: [
                    for (var index = 0; index < items.length; index++) ...[
                      if (index > 0) SizedBox(width: gap),
                      Expanded(
                        child: _MetricTile(
                          item: items[index],
                          compact: compact,
                        ),
                      ),
                    ],
                  ],
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  separatorBuilder: (_, _) => SizedBox(width: gap),
                  itemBuilder: (context, index) => _MetricTile(
                    item: items[index],
                    compact: compact,
                    width: tileWidth,
                  ),
                ),
        );
      },
    );
  }

  String _formatNumber(num? value) {
    if (value == null) return '-';
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }
}

class _MetricItem {
  const _MetricItem(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.item, required this.compact, this.width});

  final _MetricItem item;
  final bool compact;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 14 : 16,
          vertical: compact ? 10 : 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Row(
          children: [
            Icon(
              item.icon,
              color: const Color(0xFF95F3D1),
              size: compact ? 24 : 28,
            ),
            SizedBox(width: compact ? 10 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.68),
                      fontWeight: FontWeight.w700,
                      fontSize: compact ? 11 : 12,
                    ),
                  ),
                  Text(
                    item.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: compact ? 20 : 22,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScreensaverPanel extends StatelessWidget {
  const _ScreensaverPanel({
    required this.washroom,
    required this.metrics,
    required this.onStart,
    super.key,
  });

  final FeedbackWashroom? washroom;
  final FeedbackMetrics metrics;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return LayoutBuilder(
      builder: (context, constraints) {
        final shortHeight = constraints.maxHeight < 520;
        final buttonWidth = math.min(320.0, constraints.maxWidth);

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.clean_hands_rounded,
                  color: const Color(0xFF95F3D1),
                  size: shortHeight ? 68 : 86,
                ),
                SizedBox(height: shortHeight ? 18 : 24),
                Text(
                  l10n.feedbackScreensaverTitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontSize: shortHeight ? 30 : null,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: shortHeight ? 10 : 14),
                Text(
                  washroom?.name ?? l10n.feedbackScreensaverFallback,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.74),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: shortHeight ? 28 : 42),
                FilledButton.icon(
                  onPressed: onStart,
                  icon: const Icon(Icons.touch_app_rounded),
                  label: Text(l10n.feedbackStartButton),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF95F3D1),
                    foregroundColor: const Color(0xFF06251A),
                    minimumSize: Size(buttonWidth, shortHeight ? 58 : 64),
                    textStyle: TextStyle(
                      fontSize: shortHeight ? 18 : 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ChoicePanel extends StatelessWidget {
  const _ChoicePanel({
    required this.submitting,
    required this.onPositive,
    required this.onNegative,
    super.key,
  });

  final bool submitting;
  final VoidCallback onPositive;
  final VoidCallback onNegative;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 720;
        final shortHeight = constraints.maxHeight < 560;
        final buttonHeight = stacked
            ? (shortHeight ? 350.0 : 430.0)
            : (shortHeight ? 230.0 : 280.0);
        final children = [
          Expanded(
            child: _FeedbackChoiceButton(
              title: l10n.feedbackChoiceSatisfiedTitle,
              subtitle: l10n.feedbackChoiceSatisfiedSubtitle,
              icon: Icons.thumb_up_alt_rounded,
              color: const Color(0xFF1BBF74),
              onTap: submitting ? null : onPositive,
            ),
          ),
          SizedBox(width: stacked ? 0 : 20, height: stacked ? 16 : 0),
          Expanded(
            child: _FeedbackChoiceButton(
              title: l10n.needsAttentionButton,
              subtitle: l10n.feedbackChoiceNeedsAttentionSubtitle,
              icon: Icons.report_problem_rounded,
              color: const Color(0xFFE04F4F),
              onTap: submitting ? null : onNegative,
            ),
          ),
        ];

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1040),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.feedbackChoiceTitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontSize: shortHeight ? 30 : null,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: shortHeight ? 8 : 12),
                Text(
                  l10n.feedbackChoiceSubtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: shortHeight ? 24 : 36),
                Flexible(
                  child: SizedBox(
                    height: buttonHeight,
                    child: stacked
                        ? Column(children: children)
                        : Row(children: children),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FeedbackChoiceButton extends StatelessWidget {
  const _FeedbackChoiceButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxHeight < 240 || constraints.maxWidth < 430;
        final radius = compact ? 24.0 : 28.0;
        final iconBox = compact ? 82.0 : 104.0;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(radius),
            onTap: onTap,
            child: Ink(
              padding: EdgeInsets.all(compact ? 22 : 28),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(radius),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: iconBox,
                    height: iconBox,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: compact ? 46 : 58,
                    ),
                  ),
                  SizedBox(width: compact ? 18 : 24),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontSize: compact ? 24 : null,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        SizedBox(height: compact ? 6 : 8),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.86),
                                fontSize: compact ? 15 : null,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
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

    return LayoutBuilder(
      builder: (context, panelConstraints) {
        final compact =
            panelConstraints.maxWidth < 700 || panelConstraints.maxHeight < 520;
        final stackActions = panelConstraints.maxWidth < 560;
        final radius = compact ? 24.0 : 28.0;
        final padding = compact ? 18.0 : 24.0;
        final actionHeight = compact ? 52.0 : 56.0;

        final commentButton = OutlinedButton.icon(
          onPressed: submitting ? null : onAddComment,
          icon: Icon(
            comment.isEmpty
                ? Icons.add_comment_outlined
                : Icons.mode_comment_rounded,
          ),
          label: Text(
            comment.isEmpty
                ? l10n.feedbackAddCommentButton
                : l10n.feedbackEditCommentButton,
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: Size.fromHeight(actionHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
        final submitButton = FilledButton.icon(
          onPressed: submitting ? null : onSubmit,
          icon: submitting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send_rounded),
          label: Text(l10n.feedbackSubmitButton),
          style: FilledButton.styleFrom(
            minimumSize: Size.fromHeight(actionHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );

        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: submitting ? null : onBack,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    SizedBox(width: compact ? 12 : 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.feedbackNegativeTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontSize: compact ? 22 : null,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          Text(
                            l10n.feedbackNegativeSubtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: compact ? 16 : 20),
                Expanded(
                  child: reasons.isEmpty
                      ? const _EmptyReasons()
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final minTileWidth = compact ? 160.0 : 190.0;
                            final count = math.max(
                              2,
                              math.min(4, constraints.maxWidth ~/ minTileWidth),
                            );
                            return GridView.builder(
                              itemCount: reasons.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: count,
                                    crossAxisSpacing: compact ? 12 : 14,
                                    mainAxisSpacing: compact ? 12 : 14,
                                    childAspectRatio: compact ? 1.04 : 1.18,
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
                SizedBox(height: compact ? 14 : 18),
                if (stackActions)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      commentButton,
                      const SizedBox(height: 12),
                      submitButton,
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(child: commentButton),
                      const SizedBox(width: 14),
                      Expanded(child: submitButton),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
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
    final color = _reasonColor(reason);

    return LayoutBuilder(
      builder: (context, constraints) {
        final veryCompact =
            constraints.maxHeight < 145 || constraints.maxWidth < 150;
        final compact = veryCompact || constraints.maxHeight < 165;
        final radius = veryCompact ? 18.0 : (compact ? 20.0 : 22.0);
        final graphicSize = veryCompact ? 42.0 : (compact ? 52.0 : 64.0);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(radius),
            onTap: onTap,
            child: Ink(
              padding: EdgeInsets.all(veryCompact ? 8 : (compact ? 12 : 16)),
              decoration: BoxDecoration(
                color: selected
                    ? color.withValues(alpha: 0.12)
                    : const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: selected ? color : const Color(0xFFE1E5EA),
                  width: selected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _reasonGraphic(
                    color: color,
                    size: graphicSize,
                    iconSize: veryCompact ? 26 : (compact ? 32 : 38),
                  ),
                  SizedBox(height: veryCompact ? 4 : (compact ? 8 : 12)),
                  Text(
                    reason.reason,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: veryCompact ? 12 : (compact ? 14 : null),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: veryCompact ? 4 : (compact ? 6 : 8)),
                  SizedBox(
                    height: veryCompact ? 18 : (compact ? 20 : 24),
                    child: AnimatedOpacity(
                      opacity: selected ? 1 : 0,
                      duration: const Duration(milliseconds: 160),
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: color,
                        size: veryCompact ? 18 : (compact ? 20 : 24),
                      ),
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

  Widget _reasonGraphic({
    required Color color,
    required double size,
    required double iconSize,
  }) {
    final imageUrl = reason.imageUrl?.trim() ?? '';
    final fallbackIcon = Icon(
      _reasonIcon(reason.reason),
      color: color,
      size: iconSize,
    );

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(imageUrl.isEmpty ? 0 : 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: imageUrl.isEmpty
          ? fallbackIcon
          : ClipRRect(
              borderRadius: BorderRadius.circular(size / 3),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => fallbackIcon,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return fallbackIcon;
                },
              ),
            ),
    );
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

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Color(0x55000000),
                blurRadius: 40,
                offset: Offset(0, 20),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 52),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  positive ? Icons.verified_rounded : Icons.handshake_rounded,
                  color: positive
                      ? const Color(0xFF1BBF74)
                      : const Color(0xFF3157D5),
                  size: 88,
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.feedbackThanksTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  positive
                      ? l10n.feedbackThanksPositiveSubtitle
                      : l10n.feedbackThanksNegativeSubtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.black54,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 28),
                TextButton(onPressed: onDone, child: Text(l10n.doneButton)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingShell extends StatelessWidget {
  const _LoadingShell();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF06121F),
      child: Center(child: CircularProgressIndicator()),
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

    return ColoredBox(
      color: const Color(0xFF06121F),
      child: Center(
        child: Container(
          width: 520,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
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

class _KioskBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    for (var i = 0; i < 7; i++) {
      final y = size.height * (0.18 + i * 0.12);
      canvas.drawLine(Offset(0, y), Offset(size.width, y - 90), paint);
    }

    final accent = Paint()
      ..color = const Color(0xFF95F3D1).withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    final path = Path()
      ..moveTo(size.width * 0.08, size.height * 0.88)
      ..lineTo(size.width * 0.36, size.height * 0.78)
      ..lineTo(size.width * 0.62, size.height * 0.86)
      ..lineTo(size.width * 0.92, size.height * 0.72);
    canvas.drawPath(path, accent);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
