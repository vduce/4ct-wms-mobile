class FeedbackReason {
  const FeedbackReason({
    required this.id,
    required this.reason,
    required this.imageUrl,
    required this.isActive,
  });

  final String id;
  final String reason;
  final String imageUrl;
  final bool isActive;
}
