import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../l10n/app_localizations_context.dart';
import '../../../shared/widgets/app_loading_dialog.dart';
import '../data/operations_repository.dart';
import '../domain/ticket_models.dart';
import 'widgets/supervisor_ui.dart';

class TicketHistoryPage extends ConsumerStatefulWidget {
  const TicketHistoryPage({super.key});

  @override
  ConsumerState<TicketHistoryPage> createState() => _TicketHistoryPageState();
}

class _TicketHistoryPageState extends ConsumerState<TicketHistoryPage> {
  late String _fromDate;
  late String _toDate;
  SupervisorTicketStatus? _statusFilter;
  TicketSource? _sourceFilter;
  String? _washroomFilter;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _toDate = dateKey(now);
    _fromDate = dateKey(now.subtract(const Duration(days: 7)));
  }

  @override
  Widget build(BuildContext context) {
    final query = TicketHistoryQuery(fromDate: _fromDate, toDate: _toDate);
    final historyState = ref.watch(ticketHistoryProvider(query));
    final history = historyState.asData?.value;

    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _goBack();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: _goBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: Text(context.l10n.ticketHistoryTitle),
          actions: [
            IconButton(
              tooltip: context.l10n.exportCsvTooltip,
              onPressed: _exporting || history == null
                  ? null
                  : () => _exportCsv(_filtered(history.tickets)),
              icon: _exporting
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.ios_share_rounded),
            ),
          ],
        ),
        body: historyState.when(
          data: _buildHistory,
          loading: () => const AppLoadingDialog(),
          error: (error, _) => SupervisorScrollableBody(
            children: [
              SupervisorStatePanel(
                icon: Icons.error_outline_rounded,
                message: context.l10n.ticketHistoryLoadFailed,
                actionLabel: context.l10n.retryButton,
                onAction: () => ref.invalidate(ticketHistoryProvider(query)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go('/operations/home');
  }

  Widget _buildHistory(SupervisorTicketList data) {
    final l10n = context.l10n;
    final filtered = _filtered(data.tickets);
    final washroomOptions =
        data.tickets
            .fold<Map<String, String>>({}, (map, ticket) {
              if (ticket.washroomId.isNotEmpty) {
                map[ticket.washroomId] = ticket.washroomLabel;
              }
              return map;
            })
            .entries
            .toList()
          ..sort((a, b) => a.value.compareTo(b.value));

    return SupervisorScrollableBody(
      onRefresh: () async {
        final query = TicketHistoryQuery(fromDate: _fromDate, toDate: _toDate);
        ref.invalidate(ticketHistoryProvider(query));
        await ref.read(ticketHistoryProvider(query).future);
      },
      children: [
        _FilterCard(
          fromDate: _fromDate,
          toDate: _toDate,
          statusFilter: _statusFilter,
          sourceFilter: _sourceFilter,
          washroomFilter: _washroomFilter,
          washroomOptions: washroomOptions,
          onPickFrom: () => _pickDate(isFrom: true),
          onPickTo: () => _pickDate(isFrom: false),
          onStatusChanged: (status) => setState(() => _statusFilter = status),
          onSourceChanged: (source) => setState(() => _sourceFilter = source),
          onWashroomChanged: (washroom) =>
              setState(() => _washroomFilter = washroom),
        ),
        const SizedBox(height: 14),
        SupervisorSectionHeader(
          title: l10n.ticketHistoryResults(filtered.length),
          trailing: OutlinedButton.icon(
            onPressed: _exporting ? null : () => _exportCsv(filtered),
            icon: const Icon(Icons.download_rounded, size: 18),
            label: Text(l10n.exportCsvButton),
          ),
        ),
        const SizedBox(height: 8),
        if (filtered.isEmpty)
          SupervisorStatePanel(
            icon: Icons.manage_search_rounded,
            message: l10n.noTicketsForFilterMessage,
          )
        else
          SupervisorSurface(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var index = 0; index < filtered.length; index++) ...[
                  _HistoryTicketRow(
                    ticket: filtered[index],
                    onTap: () =>
                        context.go('/operations/tickets/${filtered[index].id}'),
                  ),
                  if (index < filtered.length - 1)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                ],
              ],
            ),
          ),
      ],
    );
  }

  List<SupervisorTicket> _filtered(List<SupervisorTicket> tickets) {
    final result = tickets.where((ticket) {
      final statusOk = _statusFilter == null || ticket.status == _statusFilter;
      final sourceOk = _sourceFilter == null || ticket.source == _sourceFilter;
      final washroomOk =
          _washroomFilter == null || ticket.washroomId == _washroomFilter;
      return statusOk && sourceOk && washroomOk;
    }).toList();
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final fromAfterToMessage = context.l10n.fromDateAfterToDateMessage;
    final toBeforeFromMessage = context.l10n.toDateBeforeFromDateMessage;
    final initial =
        DateTime.tryParse(isFrom ? _fromDate : _toDate) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked == null) return;
    final next = dateKey(picked);
    if (isFrom && next.compareTo(_toDate) > 0) {
      _showSnack(fromAfterToMessage);
      return;
    }
    if (!isFrom && next.compareTo(_fromDate) < 0) {
      _showSnack(toBeforeFromMessage);
      return;
    }
    setState(() {
      if (isFrom) {
        _fromDate = next;
      } else {
        _toDate = next;
      }
    });
  }

  Future<void> _exportCsv(List<SupervisorTicket> tickets) async {
    final l10n = context.l10n;
    if (tickets.isEmpty) {
      _showSnack(l10n.noTicketsToExportMessage);
      return;
    }
    setState(() => _exporting = true);
    try {
      final csv = _buildCsv(context, tickets);
      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/ticket-history_${_fromDate}_to_$_toDate.csv',
      );
      await file.writeAsString(csv);
      await SharePlus.instance.share(
        ShareParams(
          title: l10n.ticketHistoryTitle,
          text: l10n.ticketHistoryExportText,
          files: [XFile(file.path, mimeType: 'text/csv')],
        ),
      );
    } catch (_) {
      _showSnack(l10n.ticketHistoryExportFailed);
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _HistoryTicketRow extends StatelessWidget {
  const _HistoryTicketRow({required this.ticket, required this.onTap});

  final SupervisorTicket ticket;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            TicketStatusDot(status: ticket.status),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket.category.isEmpty
                        ? l10n.ticketCategoryFallback
                        : ticket.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${ticket.washroomLabel}  ·  ${ticket.shortId}  ·  ${ticketStatusLabel(context, ticket.status)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${_formatTicketTime(ticket.createdAt)}  ·  ${ticket.source == TicketSource.system ? l10n.ticketSourceSystem : l10n.ticketSourceUser}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TicketPriorityBadge(priority: ticket.priority),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, color: colors.primary),
          ],
        ),
      ),
    );
  }
}

class _FilterCard extends StatelessWidget {
  const _FilterCard({
    required this.fromDate,
    required this.toDate,
    required this.statusFilter,
    required this.sourceFilter,
    required this.washroomFilter,
    required this.washroomOptions,
    required this.onPickFrom,
    required this.onPickTo,
    required this.onStatusChanged,
    required this.onSourceChanged,
    required this.onWashroomChanged,
  });

  final String fromDate;
  final String toDate;
  final SupervisorTicketStatus? statusFilter;
  final TicketSource? sourceFilter;
  final String? washroomFilter;
  final List<MapEntry<String, String>> washroomOptions;
  final VoidCallback onPickFrom;
  final VoidCallback onPickTo;
  final ValueChanged<SupervisorTicketStatus?> onStatusChanged;
  final ValueChanged<TicketSource?> onSourceChanged;
  final ValueChanged<String?> onWashroomChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 860;
        final dateFields = [
          Expanded(
            child: _DateFilterField(
              label: l10n.historyFromLabel,
              value: _displayDate(fromDate),
              onTap: onPickFrom,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _DateFilterField(
              label: l10n.historyToLabel,
              value: _displayDate(toDate),
              onTap: onPickTo,
            ),
          ),
        ];

        final status = SupervisorSurface(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.statusLabel,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  SupervisorFilterPill(
                    label: l10n.allStatusesLabel,
                    selected: statusFilter == null,
                    onPressed: () => onStatusChanged(null),
                  ),
                  for (final item in SupervisorTicketStatus.values)
                    SupervisorFilterPill(
                      label: ticketStatusLabel(context, item),
                      selected: statusFilter == item,
                      onPressed: () => onStatusChanged(item),
                    ),
                ],
              ),
            ],
          ),
        );
        final source = SupervisorSurface(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.ticketSourceLabel,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  SupervisorFilterPill(
                    label: l10n.allSourcesLabel,
                    selected: sourceFilter == null,
                    onPressed: () => onSourceChanged(null),
                  ),
                  SupervisorFilterPill(
                    label: l10n.ticketSourceUser,
                    selected: sourceFilter == TicketSource.user,
                    onPressed: () => onSourceChanged(TicketSource.user),
                  ),
                  SupervisorFilterPill(
                    label: l10n.ticketSourceSystem,
                    selected: sourceFilter == TicketSource.system,
                    onPressed: () => onSourceChanged(TicketSource.system),
                  ),
                ],
              ),
            ],
          ),
        );
        final washroom = SupervisorSurface(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: DropdownButtonFormField<String?>(
            initialValue: washroomFilter,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n.washroomFallback,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              fillColor: Colors.transparent,
            ),
            items: [
              DropdownMenuItem(
                value: null,
                child: Text(l10n.allWashroomsLabel),
              ),
              for (final item in washroomOptions)
                DropdownMenuItem(value: item.key, child: Text(item.value)),
            ],
            onChanged: onWashroomChanged,
          ),
        );

        return Column(
          children: [
            Row(children: dateFields),
            const SizedBox(height: 12),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: status),
                  const SizedBox(width: 12),
                  Expanded(child: source),
                  const SizedBox(width: 12),
                  Expanded(child: washroom),
                ],
              )
            else ...[
              status,
              const SizedBox(height: 10),
              source,
              const SizedBox(height: 10),
              washroom,
            ],
          ],
        );
      },
    );
  }
}

class _DateFilterField extends StatelessWidget {
  const _DateFilterField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SupervisorSurface(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          Icon(Icons.calendar_today_rounded, color: colors.primary, size: 20),
        ],
      ),
    );
  }
}

String _buildCsv(BuildContext context, List<SupervisorTicket> tickets) {
  final rows = [
    [
      'Ticket ID',
      'Short ID',
      'Status',
      'Priority',
      'Source',
      'Category',
      'Description',
      'Washroom',
      'Created At',
      'Last Log',
      'Last Comment',
    ],
    ...tickets.map((ticket) {
      final lastLog = ticket.logs.isEmpty ? null : ticket.logs.last;
      return [
        ticket.id,
        ticket.shortId,
        ticketStatusLabel(context, ticket.status),
        ticket.priority,
        ticket.source == TicketSource.system
            ? context.l10n.ticketSourceSystem
            : context.l10n.ticketSourceUser,
        ticket.category,
        ticket.description,
        ticket.washroomLabel,
        _formatTicketTime(ticket.createdAt),
        lastLog?.status ?? '',
        lastLog?.comment ?? '',
      ];
    }),
  ];
  return rows.map((row) => row.map(_csvCell).join(',')).join('\r\n');
}

String _csvCell(String value) {
  final escaped = value.replaceAll('"', '""');
  return '"$escaped"';
}

String _formatTicketTime(DateTime date) {
  return DateFormat('dd/MM/yy | hh:mm a').format(date);
}

String _displayDate(String date) {
  final parsed = DateTime.tryParse(date);
  return parsed == null ? date : DateFormat('dd MMM yyyy').format(parsed);
}
