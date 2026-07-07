import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations_context.dart';

class TicketsPage extends StatelessWidget {
  const TicketsPage({this.initialStatus, super.key});

  final String? initialStatus;

  @override
  Widget build(BuildContext context) {
    final status = initialStatus ?? 'Pending';
    final l10n = context.l10n;
    final statusLabel = _localizedStatus(context, status);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ticketsTitle(statusLabel))),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final id = 'TBD-${index + 1}';
          return ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            leading: const Icon(Icons.confirmation_number_outlined),
            title: Text(l10n.ticketApiMappingPendingTitle),
            subtitle: Text(l10n.ticketApiMappingPendingSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/operations/tickets/$id'),
          );
        },
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemCount: 3,
      ),
    );
  }

  String _localizedStatus(BuildContext context, String status) {
    final l10n = context.l10n;

    return switch (status) {
      'Pending' => l10n.statusPending,
      'Acknowledge' || 'Acknowledged' => l10n.statusAcknowledged,
      'Escalated' => l10n.statusEscalated,
      'Completed' => l10n.statusCompleted,
      _ => status,
    };
  }
}
