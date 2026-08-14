import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../l10n/app_localizations_context.dart';
import '../../../shared/widgets/app_loading_dialog.dart';
import '../data/operations_repository.dart';
import '../domain/ticket_models.dart';
import 'widgets/supervisor_ui.dart';
import 'widgets/ticket_detail_widgets.dart';

class TicketDetailPage extends ConsumerStatefulWidget {
  const TicketDetailPage({required this.ticketId, super.key});

  final String ticketId;

  @override
  ConsumerState<TicketDetailPage> createState() => _TicketDetailPageState();
}

enum _TicketDetailAction { refresh }

class _TicketDetailPageState extends ConsumerState<TicketDetailPage> {
  final _commentController = TextEditingController();
  final _picker = ImagePicker();
  final List<LocalTicketAttachment> _attachments = [];
  SupervisorTicketStatus? _selectedStatus;
  bool _submitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final detailState = ref.watch(ticketDetailProvider(widget.ticketId));
    final ticketNumber = _title(detailState.asData?.value);

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
          title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.ticketDetailsTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                ticketNumber,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            PopupMenuButton<_TicketDetailAction>(
              tooltip: l10n.ticketDetailMoreTooltip,
              onSelected: (action) {
                switch (action) {
                  case _TicketDetailAction.refresh:
                    ref.invalidate(ticketDetailProvider(widget.ticketId));
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _TicketDetailAction.refresh,
                  child: Text(l10n.ticketDetailRefreshAction),
                ),
              ],
              icon: const Icon(Icons.more_vert_rounded),
            ),
          ],
        ),
        body: detailState.when(
          data: _buildDetail,
          loading: () => const AppLoadingDialog(),
          error: (error, _) => SupervisorScrollableBody(
            children: [
              SupervisorStatePanel(
                icon: Icons.error_outline_rounded,
                message: l10n.ticketDetailLoadFailed,
                actionLabel: l10n.retryButton,
                onAction: () =>
                    ref.invalidate(ticketDetailProvider(widget.ticketId)),
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
    context.go('/operations/tickets');
  }

  Widget _buildDetail(SupervisorTicketDetail ticket) {
    _selectedStatus ??= ticket.status;

    return SupervisorScrollableBody(
      maxWidth: 920,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
      onRefresh: () async {
        ref.invalidate(ticketDetailProvider(widget.ticketId));
        await ref.read(ticketDetailProvider(widget.ticketId).future);
      },
      children: [
        TicketDetailSummaryCard(ticket: ticket),
        const SizedBox(height: 12),
        TicketDetailInformationCard(ticket: ticket),
        const SizedBox(height: 20),
        if (ticket.isLocked)
          TicketDetailLockNotice(systemGenerated: ticket.isSystemGenerated)
        else
          TicketDetailActionPanel(
            selectedStatus: _selectedStatus!,
            commentController: _commentController,
            attachments: _attachments,
            submitting: _submitting,
            onStatusChanged: (status) =>
                setState(() => _selectedStatus = status),
            onCamera: () => _pickImage(ImageSource.camera),
            onGallery: () => _pickImage(ImageSource.gallery),
            onRemoveAttachment: (index) =>
                setState(() => _attachments.removeAt(index)),
            onSubmit: () => _submit(ticket),
          ),
        const SizedBox(height: 20),
        TicketDetailAttachmentsCard(attachments: ticket.attachments),
        const SizedBox(height: 22),
        TicketDetailTimelineSection(logs: ticket.logs),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _picker.pickImage(
        source: source,
        imageQuality: 72,
        maxWidth: 2200,
      );
      if (image == null) return;
      final length = await image.length();
      final mimeType = image.mimeType ?? 'image/jpeg';
      final extension = _extensionFor(image.name, mimeType);
      final name =
          'attachment_${DateTime.now().millisecondsSinceEpoch}.$extension';
      if (!mounted) return;
      setState(() {
        _attachments.add(
          LocalTicketAttachment(
            name: name,
            path: image.path,
            mimeType: mimeType,
            sizeBytes: length,
          ),
        );
      });
    } catch (_) {
      if (!mounted) return;
      _showSnack(context.l10n.attachmentPickFailed);
    }
  }

  Future<void> _submit(SupervisorTicketDetail ticket) async {
    final requestedStatus = _selectedStatus;
    if (requestedStatus == null) return;
    setState(() => _submitting = true);
    try {
      await ref
          .read(operationsRepositoryProvider)
          .updateTicket(
            ticketId: ticket.id,
            status: requestedStatus,
            comment: _commentController.text,
            attachments: _attachments,
          );
      ref
        ..invalidate(ticketDetailProvider(widget.ticketId))
        ..invalidate(todaysSupervisorTicketsProvider);
      final updatedTicket = await ref.read(
        ticketDetailProvider(widget.ticketId).future,
      );
      if (!mounted) return;
      setState(() {
        _selectedStatus = updatedTicket.status;
        _attachments.clear();
        _commentController.clear();
      });
      _showSnack(context.l10n.ticketUpdatedMessage);
    } catch (_) {
      _showSnack(context.l10n.ticketUpdateFailed);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _title(SupervisorTicketDetail? ticket) {
    if (ticket == null) return widget.ticketId;
    if (ticket.ticketNumber.isNotEmpty) return ticket.ticketNumber;
    if (ticket.id.isEmpty) return widget.ticketId;
    final start = ticket.id.length > 4 ? ticket.id.length - 4 : 0;
    return 'ID-${ticket.id.substring(start).toUpperCase()}';
  }
}

String _extensionFor(String fileName, String mimeType) {
  final dot = fileName.lastIndexOf('.');
  if (dot >= 0 && dot < fileName.length - 1) return fileName.substring(dot + 1);
  return switch (mimeType.toLowerCase()) {
    'image/png' => 'png',
    'image/webp' => 'webp',
    'image/heic' => 'heic',
    'image/heif' => 'heif',
    _ => 'jpg',
  };
}
