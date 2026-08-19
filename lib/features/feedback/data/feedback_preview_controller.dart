import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final feedbackPreviewWashroomIdProvider =
    NotifierProvider<FeedbackPreviewWashroomController, String?>(
      FeedbackPreviewWashroomController.new,
    );

class FeedbackPreviewWashroomController extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? washroomId) {
    if (!kDebugMode) return;
    final normalized = washroomId?.trim();
    state = normalized == null || normalized.isEmpty ? null : normalized;
  }
}
