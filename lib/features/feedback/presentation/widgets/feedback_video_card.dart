import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../l10n/app_localizations_context.dart';

class FeedbackVideoCard extends StatefulWidget {
  const FeedbackVideoCard({
    required this.videoUrl,
    required this.compact,
    super.key,
  });

  final String videoUrl;
  final bool compact;

  @override
  State<FeedbackVideoCard> createState() => _FeedbackVideoCardState();
}

class _FeedbackVideoCardState extends State<FeedbackVideoCard> {
  static const _brightnessFilter = ColorFilter.matrix([
    1.10,
    0,
    0,
    0,
    8,
    0,
    1.10,
    0,
    0,
    8,
    0,
    0,
    1.10,
    0,
    8,
    0,
    0,
    0,
    1,
    0,
  ]);

  VideoPlayerController? _controller;
  bool _hasPlaybackError = false;

  @override
  void initState() {
    super.initState();
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );
    _controller = controller;
    unawaited(_initializeController(controller));
  }

  Future<void> _initializeController(VideoPlayerController controller) async {
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.play();
      if (mounted && identical(_controller, controller)) setState(() {});
    } catch (_) {
      if (mounted && identical(_controller, controller)) {
        setState(() => _hasPlaybackError = true);
      }
    }
  }

  @override
  void dispose() {
    final controller = _controller;
    _controller = null;
    if (controller != null) unawaited(controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = _controller;
    final value = controller?.value;
    final initialized = value?.isInitialized ?? false;
    final showFallback = _hasPlaybackError || (value?.hasError ?? false);
    final aspectRatio = initialized && value!.aspectRatio > 0
        ? value.aspectRatio
        : 16 / 9;

    return Semantics(
      label: l10n.feedbackVideoLabel,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.compact ? 18 : 24),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF314765)
                    : const Color(0xFFE2E4EF),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (initialized && !showFallback)
                  ColorFiltered(
                    colorFilter: _brightnessFilter,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: value!.size.width,
                        height: value.size.height,
                        child: VideoPlayer(controller!),
                      ),
                    ),
                  )
                else
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF101A36), Color(0xFF02050D)],
                      ),
                    ),
                  ),
                if (showFallback || !initialized)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            showFallback
                                ? Icons.videocam_off_outlined
                                : Icons.hourglass_top_rounded,
                            color: Colors.white.withValues(alpha: 0.82),
                            size: widget.compact ? 28 : 36,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            showFallback
                                ? l10n.feedbackVideoUnavailable
                                : l10n.feedbackVideoLabel,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.82),
                              fontSize: widget.compact ? 11 : 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
