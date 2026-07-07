import 'package:flutter/material.dart';

import '../../../l10n/app_localizations_context.dart';

class TicketDetailPage extends StatelessWidget {
  const TicketDetailPage({required this.ticketId, super.key});

  final String ticketId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(ticketId)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: Text(l10n.ticketLockRulesTitle),
            subtitle: Text(l10n.ticketLockRulesSubtitle),
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(l10n.attachmentUploadSkeletonTitle),
            subtitle: Text(l10n.attachmentUploadSkeletonSubtitle),
          ),
        ],
      ),
    );
  }
}
