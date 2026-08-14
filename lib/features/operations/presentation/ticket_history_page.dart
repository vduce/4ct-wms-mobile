import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/date/date_time.dart';
import '../../../l10n/app_localizations_context.dart';
import '../../../shared/widgets/app_loading_dialog.dart';
import '../data/operations_repository.dart';
import '../domain/ticket_models.dart';
import 'widgets/supervisor_ui.dart';
import 'widgets/ticket_history_filters.dart';
import 'widgets/ticket_history_row.dart';

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
          title: Text(
            context.l10n.ticketHistoryTitle,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      onRefresh: () async {
        final query = TicketHistoryQuery(fromDate: _fromDate, toDate: _toDate);
        ref.invalidate(ticketHistoryProvider(query));
        await ref.read(ticketHistoryProvider(query).future);
      },
      children: [
        TicketHistoryFilters(
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
          displayDate: (date) => _displayDate(context, date),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.ticketHistoryResults(filtered.length),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            SizedBox(
              width: 138,
              child: SupervisorOutlinedButton(
                label: l10n.exportCsvButton,
                icon: Icons.download_rounded,
                loading: _exporting,
                height: 44,
                onPressed: _exporting ? null : () => _exportCsv(filtered),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (filtered.isEmpty)
          SupervisorDottedStatePanel(
            icon: Icons.manage_search_rounded,
            message: l10n.noTicketsForFilterMessage,
          )
        else
          for (final ticket in filtered)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SupervisorSurface(
                padding: EdgeInsets.zero,
                radius: 16,
                onTap: () => context.go('/operations/tickets/${ticket.id}'),
                child: TicketHistoryRow(ticket: ticket),
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
        context.formatAppDateTime(ticket.createdAt),
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

String _displayDate(BuildContext context, String date) {
  final parsed = DateTime.tryParse(date);
  return parsed == null ? date : context.formatAppCalendarDate(parsed);
}
