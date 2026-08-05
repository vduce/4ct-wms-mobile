import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations_context.dart';
import '../../../../shared/widgets/app_gradient_button.dart';

class FeedbackCommentSheet extends StatefulWidget {
  const FeedbackCommentSheet({
    required this.initialComment,
    required this.onActivity,
    super.key,
  });

  final String initialComment;
  final VoidCallback onActivity;

  @override
  State<FeedbackCommentSheet> createState() => _FeedbackCommentSheetState();
}

class _FeedbackCommentSheetState extends State<FeedbackCommentSheet> {
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

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => widget.onActivity(),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
            top: 8,
          ),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.feedbackCommentTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  maxLines: 4,
                  maxLength: 240,
                  onChanged: (_) => widget.onActivity(),
                  onTapOutside: (_) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  decoration: InputDecoration(
                    hintText: l10n.feedbackCommentHint,
                  ),
                ),
                const SizedBox(height: 16),
                AppGradientButton(
                  onPressed: () => Navigator.of(context).pop(_controller.text),
                  label: Text(l10n.feedbackCommentSaveButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
