import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations_context.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../auth/data/session_controller.dart';

class OperationsHomePage extends ConsumerWidget {
  const OperationsHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionControllerProvider).session;
    final username = session?.username.isNotEmpty == true
        ? session!.username
        : l10n.defaultUserName;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.operationsTitle),
        actions: [
          IconButton(
            tooltip: l10n.signOutTooltip,
            onPressed: () =>
                ref.read(sessionControllerProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.homeGreeting(username),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.tenantAirportSummary(
              session?.tenantId ?? '-',
              session?.airportId ?? '-',
            ),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: MediaQuery.sizeOf(context).width > 620 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: [
              StatCard(
                label: l10n.statusPending,
                value: '0',
                icon: Icons.pending_actions,
                onTap: () => context.go('/operations/tickets?status=Pending'),
              ),
              StatCard(
                label: l10n.statusAcknowledged,
                value: '0',
                icon: Icons.fact_check,
                onTap: () =>
                    context.go('/operations/tickets?status=Acknowledge'),
              ),
              StatCard(
                label: l10n.statusEscalated,
                value: '0',
                icon: Icons.priority_high,
                onTap: () => context.go('/operations/tickets?status=Escalated'),
              ),
              StatCard(
                label: l10n.statusCompleted,
                value: '0',
                icon: Icons.check_circle_outline,
                onTap: () => context.go('/operations/tickets?status=Completed'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => context.go('/operations/dashboard'),
            icon: const Icon(Icons.bar_chart),
            label: Text(l10n.openDashboardsButton),
          ),
        ],
      ),
    );
  }
}
