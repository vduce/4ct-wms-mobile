class WashroomHierarchy {
  const WashroomHierarchy({
    required this.tenantId,
    required this.airportId,
    required this.terminalId,
    required this.zoneId,
    required this.washroomId,
  });

  final String tenantId;
  final String airportId;
  final String terminalId;
  final String zoneId;
  final String washroomId;
}

enum TicketStatus { pending, acknowledge, escalated, completed }

enum WashroomType { male, female, handicapped, unisex, unknown }
