String? buildPublicFeedbackUrl({
  required String baseUrl,
  required String washroomId,
}) {
  final normalizedWashroomId = washroomId.trim();
  if (!RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(normalizedWashroomId)) {
    return null;
  }

  final uri = Uri.tryParse(baseUrl.trim());
  if (uri == null ||
      !uri.hasScheme ||
      !uri.hasAuthority ||
      (uri.scheme != 'https' && uri.scheme != 'http')) {
    return null;
  }

  return Uri(
    scheme: uri.scheme,
    host: uri.host,
    port: uri.hasPort ? uri.port : null,
    pathSegments: ['feedback', normalizedWashroomId],
  ).toString();
}
