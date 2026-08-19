import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/locale_controller.dart';
import '../../../app/theme/theme_mode_controller.dart';
import '../../../core/config/environment_config.dart';
import '../../../l10n/app_localizations_context.dart';
import '../../auth/data/session_controller.dart';
import '../../tenant/data/tenant_controller.dart';
import '../data/feedback_preview_controller.dart';
import '../data/feedback_repository.dart';
import '../domain/feedback_models.dart';
import '../domain/public_feedback_url.dart';
import 'widgets/feedback_admin_exit_control.dart';
import 'widgets/feedback_choice_panel.dart';
import 'widgets/feedback_comment_sheet.dart';
import 'widgets/feedback_debug_washroom_control.dart';
import 'widgets/feedback_kiosk_shell.dart';
import 'widgets/feedback_negative_panel.dart';
import 'widgets/feedback_screensaver_panel.dart';
import 'widgets/feedback_thanks_panel.dart';
import 'widgets/feedback_qr.dart';

enum _FeedbackStep { screensaver, choice, negative, thanks }

class FeedbackDevicePage extends ConsumerStatefulWidget {
  const FeedbackDevicePage({super.key});

  @override
  ConsumerState<FeedbackDevicePage> createState() => _FeedbackDevicePageState();
}

class _FeedbackDevicePageState extends ConsumerState<FeedbackDevicePage> {
  static const _idleDuration = Duration(seconds: 60);
  static const _preferenceResetDuration = Duration(seconds: 30);
  static const _thanksDuration = Duration(seconds: 3);
  static const _debugFooterClearance = 64.0;

  final Set<String> _selectedReasonIds = <String>{};
  Timer? _idleTimer;
  Timer? _preferenceResetTimer;
  Timer? _thanksTimer;
  _FeedbackStep _step = _FeedbackStep.screensaver;
  bool _submitting = false;
  bool _lastFeedbackPositive = true;
  String _comment = '';

  @override
  void initState() {
    super.initState();
    _startIdleTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncPreferenceResetTimer();
    });
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _preferenceResetTimer?.cancel();
    _thanksTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedbackDeviceStateProvider);
    final previewWashroomId = kDebugMode
        ? ref.watch(feedbackPreviewWashroomIdProvider)
        : null;
    final branding = ref.watch(tenantControllerProvider).branding;
    final environment = ref.watch(environmentConfigProvider);
    ref.listen<Locale?>(localeControllerProvider, (_, _) {
      _syncPreferenceResetTimer();
    });
    ref.listen<ThemeMode?>(themeModeControllerProvider, (_, _) {
      _syncPreferenceResetTimer();
    });

    return Scaffold(
      // Keep kiosk content at full height while the modal comment sheet
      // handles keyboard insets on its own route.
      resizeToAvoidBottomInset: false,
      body: state.when(
        data: (data) => Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) => _recordUserActivity(),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _handleGlobalTap,
            child: FeedbackKioskScaffold(
              adminControl: _step == _FeedbackStep.screensaver
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (kDebugMode) ...[
                          FeedbackDebugWashroomControl(
                            washroomName: data.washroom?.name,
                            onPressed: () => _openDebugWashroomSelector(
                              data,
                              previewWashroomId,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        FeedbackAdminExitControl(
                          onPressed: _confirmAdminSignOut,
                        ),
                      ],
                    )
                  : null,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: switch (_step) {
                  _FeedbackStep.screensaver => FeedbackScreensaverPanel(
                    key: const ValueKey('screensaver'),
                    brandingName: branding.appName,
                    videoUrl: environment.feedbackVideoUrl,
                    metrics: data.metrics,
                    temperatureCelsius: data.metrics.temperatureCelsius,
                    feedbackQrUrl: _feedbackQrUrl(data.washroom),
                    bottomContentPadding: kDebugMode
                        ? _debugFooterClearance
                        : 0,
                    onShowQr: () => _openQrDialog(data.washroom),
                    onStart: _showChoice,
                  ),
                  _FeedbackStep.choice => FeedbackChoicePanel(
                    key: const ValueKey('choice'),
                    submitting: _submitting,
                    onBack: _resetToScreensaver,
                    onPositive: () => _submitPositive(data),
                    onNegative: _showNegative,
                  ),
                  _FeedbackStep.negative => FeedbackNegativePanel(
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
                  _FeedbackStep.thanks => FeedbackThanksPanel(
                    key: const ValueKey('thanks'),
                    positive: _lastFeedbackPositive,
                    onDone: _resetToScreensaver,
                  ),
                },
              ),
            ),
          ),
        ),
        loading: () => const FeedbackLoadingShell(),
        error: (error, _) => FeedbackErrorShell(
          message: error.toString(),
          onRetry: () => ref.invalidate(feedbackDeviceStateProvider),
          onSignOut: _confirmAdminSignOut,
        ),
      ),
    );
  }

  void _handleGlobalTap() {
    if (_step == _FeedbackStep.screensaver) {
      _showChoice();
    }
  }

  void _recordUserActivity() {
    _startIdleTimer();
    _syncPreferenceResetTimer();
  }

  void _syncPreferenceResetTimer() {
    _preferenceResetTimer?.cancel();
    final locale = ref.read(localeControllerProvider);
    final themeMode = ref.read(themeModeControllerProvider);
    final effectiveLanguageCode =
        locale?.languageCode ?? Localizations.localeOf(context).languageCode;
    final usesDarkTheme =
        themeMode == ThemeMode.dark ||
        (themeMode == null && Theme.of(context).brightness == Brightness.dark);
    final usesDefaultPreferences =
        effectiveLanguageCode == 'en' && usesDarkTheme;
    if (usesDefaultPreferences) {
      _preferenceResetTimer = null;
      return;
    }

    _preferenceResetTimer = Timer(
      _preferenceResetDuration,
      _resetDefaultPreferences,
    );
  }

  void _resetDefaultPreferences() {
    _preferenceResetTimer = null;
    if (!mounted) return;
    unawaited(
      Future.wait([
        ref
            .read(localeControllerProvider.notifier)
            .setLocale(const Locale('en')),
        ref
            .read(themeModeControllerProvider.notifier)
            .setThemeMode(ThemeMode.dark),
      ]),
    );
  }

  String? _feedbackQrUrl(FeedbackWashroom? washroom) {
    final session = ref.read(sessionControllerProvider).session;
    if (session == null || washroom == null) return null;
    final environment = ref.read(environmentConfigProvider);
    return buildPublicFeedbackUrl(
      baseUrl: environment.feedbackWebUrl,
      washroomId: washroom.id,
    );
  }

  void _openQrDialog(FeedbackWashroom? washroom) {
    final qrUrl = _feedbackQrUrl(washroom);
    if (qrUrl == null) return;
    _startIdleTimer();
    showDialog<void>(
      context: context,
      builder: (context) =>
          FeedbackQrDialog(qrUrl: qrUrl, onActivity: _recordUserActivity),
    );
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
      builder: (context) => FeedbackCommentSheet(
        initialComment: _comment,
        onActivity: _recordUserActivity,
      ),
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

  Future<void> _confirmAdminSignOut() async {
    final confirmed = await showFeedbackAdminExitDialog(context);
    if (!mounted || !confirmed) return;
    await ref.read(sessionControllerProvider.notifier).signOut();
  }

  Future<void> _openDebugWashroomSelector(
    FeedbackDeviceState data,
    String? previewWashroomId,
  ) async {
    if (!kDebugMode) return;
    final session = ref.read(sessionControllerProvider).session;
    final assignedWashroomId = session == null || session.washroomIds.isEmpty
        ? null
        : session.washroomIds.first;
    await showFeedbackDebugWashroomSheet(
      context: context,
      washrooms: data.availableWashrooms,
      selectedWashroomId: previewWashroomId,
      assignedWashroomId: assignedWashroomId,
      onSelected: (washroomId) {
        ref.read(feedbackPreviewWashroomIdProvider.notifier).select(washroomId);
        _resetToScreensaver();
      },
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
