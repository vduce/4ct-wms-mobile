import 'package:flutter/material.dart';

import '../../../l10n/app_localizations_context.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.dashboardsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.groups_outlined),
            title: Text(l10n.washroomFootfallTitle),
            subtitle: const Text('/dashboard_washroom_occupancy'),
          ),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: Text(l10n.negativeFeedbackHeatmapTitle),
            subtitle: const Text('/negative_feedback_count_by_hour'),
          ),
          ListTile(
            leading: const Icon(Icons.speed_outlined),
            title: Text(l10n.zoneLeadResponseResolutionTitle),
            subtitle: const Text('/dashboard_admin'),
          ),
        ],
      ),
    );
  }
}
