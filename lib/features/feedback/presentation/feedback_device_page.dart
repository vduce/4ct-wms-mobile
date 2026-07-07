import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations_context.dart';
import '../../auth/data/session_controller.dart';

class FeedbackDevicePage extends ConsumerWidget {
  const FeedbackDevicePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionControllerProvider).session;
    final washroomId = session?.washroomIds.isNotEmpty == true
        ? session!.washroomIds.first
        : '-';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.feedbackDeviceTitle),
        actions: [
          IconButton(
            tooltip: l10n.signOutTooltip,
            icon: const Icon(Icons.logout),
            onPressed: () =>
                ref.read(sessionControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.washroomLabel(washroomId),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.thumb_up_alt_outlined),
                      label: Text(l10n.goodFeedbackButton),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.report_problem_outlined),
                      label: Text(l10n.needsAttentionButton),
                    ),
                  ),
                ],
              ),
            ),
            Text(l10n.feedbackDeviceMigrationNote),
          ],
        ),
      ),
    );
  }
}
