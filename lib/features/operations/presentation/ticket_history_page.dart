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
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(ticketHistoryProvider(query));
            await ref.read(ticketHistoryProvider(query).future);
          },
          child: historyState.when(
            data: _buildHistory,
            loading: () => const AppLoadingDialog(),
            error: (error, _) => ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _StatePanel(
                  icon: Icons.error_outline_rounded,
                  message: context.l10n.ticketHistoryLoadFailed,
                  actionLabel: context.l10n.retryButton,
                  onAction: () => ref.invalidate(ticketHistoryProvider(query)),
                ),
              ],
            ),
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

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.ticketHistoryResults(filtered.length),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            TextButton.icon(
              onPressed: _exporting ? null : () => _exportCsv(filtered),
              icon: const Icon(Icons.ios_share_rounded),
              label: Text(l10n.exportCsvButton),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (filtered.isEmpty)
          _StatePanel(
            icon: Icons.manage_search_rounded,
            message: l10n.noTicketsForFilterMessage,
          )
        else
          ...filtered.map(
            (ticket) => Card(
              child: ListTile(
                leading: Icon(
                  ticket.source == TicketSource.system
                      ? Icons.memory_rounded
                      : Icons.confirmation_number_outlined,
                ),
                title: Text(
                  ticket.category.isEmpty
                      ? l10n.ticketCategoryFallback
                      : ticket.category,
                ),
                subtitle: Text(
                  '${ticket.washroomLabel}\n${_statusLabel(context, ticket.status)} · ${_formatTicketTime(ticket.createdAt)}',
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.go('/operations/tickets/${ticket.id}'),
              ),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: onPickFrom,
                  icon: const Icon(Icons.event_rounded),
                  label: Text(l10n.fromDateLabel(fromDate)),
                ),
                OutlinedButton.icon(
                  onPressed: onPickTo,
                  icon: const Icon(Icons.event_available_rounded),
                  label: Text(l10n.toDateLabel(toDate)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<SupervisorTicketStatus?>(
              initialValue: statusFilter,
              decoration: InputDecoration(labelText: l10n.statusLabel),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(l10n.allStatusesLabel),
                ),
                for (final status in SupervisorTicketStatus.values)
                  DropdownMenuItem(
                    value: status,
                    child: Text(_statusLabel(context, status)),
                  ),
              ],
              onChanged: onStatusChanged,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<TicketSource?>(
              initialValue: sourceFilter,
              decoration: InputDecoration(labelText: l10n.ticketSourceLabel),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(l10n.allSourcesLabel),
                ),
                DropdownMenuItem(
                  value: TicketSource.user,
                  child: Text(l10n.ticketSourceUser),
                ),
                DropdownMenuItem(
                  value: TicketSource.system,
                  child: Text(l10n.ticketSourceSystem),
                ),
              ],
              onChanged: onSourceChanged,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: washroomFilter,
              decoration: InputDecoration(labelText: l10n.washroomFallback),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(l10n.allWashroomsLabel),
                ),
                for (final washroom in washroomOptions)
                  DropdownMenuItem(
                    value: washroom.key,
                    child: Text(washroom.value),
                  ),
              ],
              onChanged: onWashroomChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatePanel extends StatelessWidget {
  const _StatePanel({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(icon, size: 34),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
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
        _statusLabel(context, ticket.status),
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

String _statusLabel(BuildContext context, SupervisorTicketStatus status) {
  final l10n = context.l10n;
  return switch (status) {
    SupervisorTicketStatus.pending => l10n.statusPending,
    SupervisorTicketStatus.acknowledge => l10n.statusAcknowledged,
    SupervisorTicketStatus.escalated => l10n.statusEscalated,
    SupervisorTicketStatus.completed => l10n.statusCompleted,
  };
}

String _formatTicketTime(DateTime date) {
  return DateFormat('dd/MM/yy | hh:mm a').format(date);
}
