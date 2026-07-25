import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/adani_design_tokens.dart';
import '../../../l10n/app_localizations_context.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/app_loading_dialog.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../auth/data/session_controller.dart';
import '../../tenant/data/tenant_controller.dart';
import '../data/operations_repository.dart';
import '../domain/ticket_models.dart';
import 'widgets/supervisor_ui.dart';

class OperationsHomePage extends ConsumerStatefulWidget {
  const OperationsHomePage({super.key});

  @override
  ConsumerState<OperationsHomePage> createState() => _OperationsHomePageState();
}

class _OperationsHomePageState extends ConsumerState<OperationsHomePage> {
  bool _loadingPeaks = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final session = ref.watch(sessionControllerProvider).session;
    final username = session?.username.isNotEmpty == true
        ? session!.username
        : l10n.defaultUserName;
    final ticketState = ref.watch(todaysSupervisorTicketsProvider);
    final washroomState = ref.watch(supervisedWashroomsProvider);
    final tenantContext = ref.watch(tenantControllerProvider).context;
    final locationSummary = [
      session?.airportId,
      tenantContext?.terminalId,
      tenantContext?.zoneId,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).join(' · ');

    return Scaffold(
      drawer: const _OperationsDrawer(),
      appBar: AppBar(
        leadingWidth: 72,
        leading: Builder(
          builder: (context) => IconButton(
            tooltip: l10n.openNavigationTooltip,
            onPressed: Scaffold.of(context).openDrawer,
            icon: const Icon(Icons.menu_rounded, size: 30),
          ),
        ),
        titleSpacing: 0,
        title: Text(
          l10n.operationsTitle,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            tooltip: l10n.notificationsTooltip,
            onPressed: () => _showSnack(l10n.noNotificationsMessage),
            icon: const _NotificationIcon(),
          ),
          IconButton(
            tooltip: l10n.signOutTooltip,
            onPressed: () =>
                ref.read(sessionControllerProvider.notifier).signOut(),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SupervisorScrollableBody(
        onRefresh: () async {
          ref.invalidate(todaysSupervisorTicketsProvider);
          ref.invalidate(supervisedWashroomsProvider);
          await ref.read(todaysSupervisorTicketsProvider.future);
        },
        children: [
          _HeroPanel(
            username: username,
            role: session?.roleDisplayName ?? session?.role ?? '',
            tenantSummary: locationSummary,
            lastLogin: _formatDateTime(session?.lastLogin),
            shiftLabel: ticketState.asData?.value.shiftLabel ?? '-',
          ),
          const SizedBox(height: 18),
          ticketState.when(
            data: (data) => _TicketStatsGrid(data: data),
            loading: () => const _LoadingPanel(),
            error: (error, _) => SupervisorStatePanel(
              icon: Icons.error_outline_rounded,
              message: l10n.supervisorTicketsLoadFailed,
              actionLabel: l10n.retryButton,
              onAction: () => ref.invalidate(todaysSupervisorTicketsProvider),
            ),
          ),
          const SizedBox(height: 16),
          _QuickActions(
            loadingPeaks: _loadingPeaks,
            onOpenHistory: () => context.go('/operations/ticket-history'),
            onOpenPassengerFlow: () => _openPassengerFlow(context),
          ),
          const SizedBox(height: 18),
          washroomState.when(
            data: (washrooms) => _WashroomSection(washrooms: washrooms),
            loading: () => const _LoadingPanel(),
            error: (error, _) => SupervisorStatePanel(
              icon: Icons.error_outline_rounded,
              message: l10n.supervisedUnitsLoadFailed,
              actionLabel: l10n.retryButton,
              onAction: () => ref.invalidate(supervisedWashroomsProvider),
            ),
          ),
          const SizedBox(height: 18),
          ticketState.when(
            data: (data) => _RosterSection(rosters: data.rosters),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Future<void> _openPassengerFlow(BuildContext context) async {
    final l10n = context.l10n;
    final session = ref.read(sessionControllerProvider).session;
    if (session == null || session.washroomIds.isEmpty) {
      _showSnack(l10n.noWashroomsAssignedMessage);
      return;
    }
    setState(() => _loadingPeaks = true);
    try {
      final peaks = await ref
          .read(operationsRepositoryProvider)
          .fetchPassengerPeaks(
            washroomIds: session.washroomIds,
            range: DateRange(
              start: DateTime.now().subtract(const Duration(days: 7)),
              end: DateTime.now(),
            ),
          );
      if (!context.mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (context) => _PassengerFlowSheet(peaks: peaks),
      );
    } catch (_) {
      _showSnack(l10n.passengerFlowLoadFailed);
    } finally {
      if (mounted) setState(() => _loadingPeaks = false);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.notifications_none_rounded, size: 28),
        Positioned(
          top: 1,
          right: 1,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AdaniColors.error,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

class _OperationsDrawer extends ConsumerWidget {
  const _OperationsDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 18),
            const _BrandTile(size: 54),
            const SizedBox(height: 28),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: Text(l10n.operationsTitle),
              selected: true,
              onTap: () {
                Navigator.of(context).pop();
                context.go('/operations/home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.history_rounded),
              title: Text(l10n.ticketHistoryTitle),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/operations/ticket-history');
              },
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: Text(l10n.dashboardsTitle),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/operations/dashboard');
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout_rounded),
              title: Text(l10n.signOutTooltip),
              onTap: () {
                Navigator.of(context).pop();
                ref.read(sessionControllerProvider.notifier).signOut();
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.username,
    required this.role,
    required this.tenantSummary,
    required this.lastLogin,
    required this.shiftLabel,
  });

  final String username;
  final String role;
  final String tenantSummary;
  final String lastLogin;
  final String shiftLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return SupervisorSurface(
      padding: EdgeInsets.zero,
      radius: 16,
      color: isDark ? AdaniColors.darkHero : AdaniColors.lightHero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 700;
          final summary = [
            if (role.trim().isNotEmpty) role.trim(),
            if (tenantSummary.trim().isNotEmpty) tenantSummary.trim(),
          ].join(' · ');
          return Stack(
            clipBehavior: Clip.antiAlias,
            children: [
              Positioned(
                top: isWide ? -80 : -54,
                right: isWide ? -38 : -64,
                child: Container(
                  width: isWide ? 260 : 178,
                  height: isWide ? 260 : 178,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        (isDark
                                ? AdaniColors.darkHeroAccent
                                : AdaniColors.lightHeroAccent)
                            .withValues(alpha: isDark ? 0.55 : 0.66),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 30 : 18,
                  vertical: isWide ? 26 : 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.homeGreeting(username),
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: colors.primary,
                                  fontSize: isWide ? null : 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: isWide ? 7 : 4),
                              Text(
                                summary,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    (isWide
                                            ? theme.textTheme.bodyMedium
                                            : theme.textTheme.bodySmall)
                                        ?.copyWith(
                                          color: colors.onSurfaceVariant,
                                        ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        _BrandTile(size: isWide ? 86 : 64),
                      ],
                    ),
                    SizedBox(height: isWide ? 24 : 16),
                    if (isWide)
                      Row(
                        children: [
                          Flexible(
                            child: _InfoChip(
                              icon: Icons.login_rounded,
                              label: l10n.lastLoginLabel(lastLogin),
                            ),
                          ),
                          const SizedBox(width: 34),
                          Flexible(
                            child: _InfoChip(
                              icon: Icons.schedule_rounded,
                              label: l10n.activeShiftLabel(shiftLabel),
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoChip(
                            icon: Icons.login_rounded,
                            label: l10n.lastLoginLabel(lastLogin),
                          ),
                          const SizedBox(height: 8),
                          _InfoChip(
                            icon: Icons.schedule_rounded,
                            label: l10n.activeShiftLabel(shiftLabel),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BrandTile extends StatelessWidget {
  const _BrandTile({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AdaniGradients.action,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: AdaniColors.purpleBright.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: AdaniBrandMark(size: size),
    );
  }
}

class _TicketStatsGrid extends StatelessWidget {
  const _TicketStatsGrid({required this.data});

  final SupervisorTicketList data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final counts = data.counts;
    final deltas = data.countDeltasFromYesterday();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SupervisorSectionHeader(title: l10n.ticketStatusCardsTitle),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 760;
            return GridView.count(
              crossAxisCount: isWide ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: isWide ? 150 : 142,
              children: [
                StatCard(
                  label: l10n.statusPending,
                  value: _twoDigits(
                    counts[SupervisorTicketStatus.pending] ?? 0,
                  ),
                  icon: ticketStatusIcon(SupervisorTicketStatus.pending),
                  accentColor: SupervisorPalette.pending,
                  changeText: _deltaLabel(
                    context,
                    deltas[SupervisorTicketStatus.pending] ?? 0,
                  ),
                  changeColor: _deltaColor(
                    SupervisorTicketStatus.pending,
                    deltas[SupervisorTicketStatus.pending] ?? 0,
                  ),
                  onTap: () => context.go('/operations/tickets?status=Pending'),
                ),
                StatCard(
                  label: l10n.statusAcknowledged,
                  value: _twoDigits(
                    counts[SupervisorTicketStatus.acknowledge] ?? 0,
                  ),
                  icon: ticketStatusIcon(SupervisorTicketStatus.acknowledge),
                  accentColor: SupervisorPalette.acknowledged,
                  changeText: _deltaLabel(
                    context,
                    deltas[SupervisorTicketStatus.acknowledge] ?? 0,
                  ),
                  changeColor: _deltaColor(
                    SupervisorTicketStatus.acknowledge,
                    deltas[SupervisorTicketStatus.acknowledge] ?? 0,
                  ),
                  onTap: () =>
                      context.go('/operations/tickets?status=Acknowledge'),
                ),
                StatCard(
                  label: l10n.statusEscalated,
                  value: _twoDigits(
                    counts[SupervisorTicketStatus.escalated] ?? 0,
                  ),
                  icon: ticketStatusIcon(SupervisorTicketStatus.escalated),
                  accentColor: SupervisorPalette.escalated,
                  changeText: _deltaLabel(
                    context,
                    deltas[SupervisorTicketStatus.escalated] ?? 0,
                  ),
                  changeColor: _deltaColor(
                    SupervisorTicketStatus.escalated,
                    deltas[SupervisorTicketStatus.escalated] ?? 0,
                  ),
                  onTap: () =>
                      context.go('/operations/tickets?status=Escalated'),
                ),
                StatCard(
                  label: l10n.statusCompleted,
                  value: _twoDigits(
                    counts[SupervisorTicketStatus.completed] ?? 0,
                  ),
                  icon: ticketStatusIcon(SupervisorTicketStatus.completed),
                  accentColor: SupervisorPalette.completed,
                  changeText: _deltaLabel(
                    context,
                    deltas[SupervisorTicketStatus.completed] ?? 0,
                  ),
                  changeColor: _deltaColor(
                    SupervisorTicketStatus.completed,
                    deltas[SupervisorTicketStatus.completed] ?? 0,
                  ),
                  onTap: () =>
                      context.go('/operations/tickets?status=Completed'),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.loadingPeaks,
    required this.onOpenHistory,
    required this.onOpenPassengerFlow,
  });

  final bool loadingPeaks;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenPassengerFlow;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final historyButton = SupervisorGradientButton(
      label: l10n.viewHistoryButton,
      onPressed: onOpenHistory,
      icon: Icons.history_rounded,
    );
    final passengerButton = SupervisorOutlinedButton(
      label: l10n.passengerFlowTitle,
      onPressed: loadingPeaks ? null : onOpenPassengerFlow,
      icon: Icons.groups_outlined,
      loading: loadingPeaks,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 700) {
          return Row(
            children: [
              Expanded(child: historyButton),
              const SizedBox(width: 18),
              Expanded(child: passengerButton),
            ],
          );
        }
        return Column(
          children: [
            historyButton,
            const SizedBox(height: 12),
            passengerButton,
          ],
        );
      },
    );
  }
}

class _WashroomSection extends StatelessWidget {
  const _WashroomSection({required this.washrooms});

  final List<SupervisorWashroom> washrooms;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SupervisorSectionHeader(
          title: l10n.supervisedUnitsTitle,
          trailing: TextButton(
            onPressed: () => _showAllWashrooms(context),
            child: Text(l10n.viewAllButton),
          ),
        ),
        const SizedBox(height: 8),
        if (washrooms.isEmpty)
          _WashroomEmptyState(message: l10n.emptyWashroomsMessage)
        else
          ...washrooms.map((washroom) => _WashroomTile(washroom: washroom)),
      ],
    );
  }

  Future<void> _showAllWashrooms(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.supervisedUnitsTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (washrooms.isEmpty)
                _WashroomEmptyState(message: context.l10n.emptyWashroomsMessage)
              else
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: washrooms
                        .map((washroom) => _WashroomTile(washroom: washroom))
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WashroomEmptyState extends StatelessWidget {
  const _WashroomEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = colors.primary.withValues(alpha: isDark ? 0.34 : 0.24);
    return CustomPaint(
      foregroundPainter: _DottedRoundedBorderPainter(
        color: borderColor,
        radius: 16,
      ),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 82),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: colors.surface.withValues(alpha: isDark ? 0.84 : 0.94),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 21,
              color: colors.onSurfaceVariant.withValues(alpha: 0.65),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant.withValues(alpha: 0.72),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DottedRoundedBorderPainter extends CustomPainter {
  const _DottedRoundedBorderPainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    const dotRadius = 1.0;
    const dotSpacing = 5.0;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(radius),
        ).deflate(dotRadius),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (final metric in path.computeMetrics()) {
      for (
        var distance = 0.0;
        distance < metric.length;
        distance += dotSpacing
      ) {
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          canvas.drawCircle(tangent.position, dotRadius, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_DottedRoundedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}

class _WashroomTile extends StatelessWidget {
  const _WashroomTile({required this.washroom});

  final SupervisorWashroom washroom;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SupervisorSurface(
        padding: EdgeInsets.zero,
        child: ListTile(
          leading: Icon(_washroomIcon(washroom.type)),
          title: Text(washroom.name),
          subtitle: Text(
            [
              if (washroom.code.isNotEmpty) washroom.code,
              l10n.cubiclesCount(washroom.cubicleCount),
            ].join(' · '),
          ),
        ),
      ),
    );
  }
}

class _RosterSection extends StatelessWidget {
  const _RosterSection({required this.rosters});

  final List<SupervisorRoster> rosters;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final uniqueJanitors = rosters
        .map((item) => item.janitorId)
        .where((id) => id.isNotEmpty)
        .toSet()
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SupervisorSectionHeader(
          title: l10n.janitorScheduleTitle,
          trailing: Text(l10n.janitorsAssignedCount(uniqueJanitors)),
        ),
        const SizedBox(height: 10),
        if (rosters.isEmpty)
          SupervisorStatePanel(
            icon: Icons.info_outline_rounded,
            message: l10n.emptyScheduleMessage,
            compact: true,
          )
        else
          ...rosters.map((roster) => _RosterTile(roster: roster)),
      ],
    );
  }
}

class _RosterTile extends StatelessWidget {
  const _RosterTile({required this.roster});

  final SupervisorRoster roster;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SupervisorSurface(
        padding: EdgeInsets.zero,
        child: ListTile(
          leading: const Icon(Icons.cleaning_services_rounded),
          title: Text(roster.janitorName),
          subtitle: Text(
            '${roster.washroomName.isEmpty ? l10n.washroomFallback : roster.washroomName} · ${roster.shift}',
          ),
          trailing: Text(_shiftTime(roster)),
        ),
      ),
    );
  }
}

class _PassengerFlowSheet extends StatelessWidget {
  const _PassengerFlowSheet({required this.peaks});

  final List<PassengerPeak> peaks;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.passengerFlowTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (peaks.isEmpty)
            SupervisorStatePanel(
              icon: Icons.info_outline_rounded,
              message: l10n.emptyPassengerFlowMessage,
              compact: true,
            )
          else
            ...peaks.map(
              (peak) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.trending_up_rounded),
                title: Text(l10n.passengerCount(peak.count)),
                subtitle: Text(
                  peak.hourRange.isEmpty ? peak.hour : peak.hourRange,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: colors.primary),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return const SupervisorSurface(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: AppLoadingIndicator(size: 88)),
      ),
    );
  }
}

String _formatDateTime(DateTime? date) {
  if (date == null) return '-';
  return DateFormat('dd MMM yyyy, h:mm a').format(date);
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

String _deltaLabel(BuildContext context, int delta) {
  final signedDelta = delta >= 0 ? '+$delta' : '$delta';
  return context.l10n.ticketDeltaFromYesterday(signedDelta);
}

Color _deltaColor(SupervisorTicketStatus status, int delta) {
  if (delta < 0) return AdaniColors.error;
  if (status == SupervisorTicketStatus.escalated) return AdaniColors.warning;
  return AdaniColors.success;
}

String _shiftTime(SupervisorRoster roster) {
  if (roster.shiftStart == null || roster.shiftEnd == null) return '-';
  final format = DateFormat.jm();
  return '${format.format(roster.shiftStart!)} - ${format.format(roster.shiftEnd!)}';
}

IconData _washroomIcon(SupervisorWashroomType type) {
  return switch (type) {
    SupervisorWashroomType.female => Icons.woman_rounded,
    SupervisorWashroomType.handicapped => Icons.accessible_forward_rounded,
    SupervisorWashroomType.unisex => Icons.wc_rounded,
    SupervisorWashroomType.male => Icons.man_rounded,
    SupervisorWashroomType.unknown => Icons.meeting_room_rounded,
  };
}
