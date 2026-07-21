import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations_context.dart';
import '../../../shared/widgets/app_loading_dialog.dart';
import '../data/operations_repository.dart';
import '../domain/ticket_models.dart';
import 'widgets/supervisor_ui.dart';

class TicketDetailPage extends ConsumerStatefulWidget {
  const TicketDetailPage({required this.ticketId, super.key});

  final String ticketId;

  @override
  ConsumerState<TicketDetailPage> createState() => _TicketDetailPageState();
}

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
    final detailState = ref.watch(ticketDetailProvider(widget.ticketId));

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
          title: Text(_title(detailState.asData?.value)),
        ),
        body: detailState.when(
          data: _buildDetail,
          loading: () => const AppLoadingDialog(),
          error: (error, _) => SupervisorScrollableBody(
            children: [
              SupervisorStatePanel(
                icon: Icons.error_outline_rounded,
                message: context.l10n.ticketDetailLoadFailed,
                actionLabel: context.l10n.retryButton,
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
    final l10n = context.l10n;
    _selectedStatus ??= ticket.status;

    return SupervisorScrollableBody(
      maxWidth: 920,
      onRefresh: () async {
        ref.invalidate(ticketDetailProvider(widget.ticketId));
        await ref.read(ticketDetailProvider(widget.ticketId).future);
      },
      children: [
        _SummaryCard(ticket: ticket),
        const SizedBox(height: 14),
        if (ticket.isLocked)
          _LockNotice(systemGenerated: ticket.isSystemGenerated)
        else
          _ActionPanel(
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
        const SizedBox(height: 14),
        _AttachmentsCard(attachments: ticket.attachments),
        const SizedBox(height: 18),
        SupervisorSectionHeader(title: l10n.ticketTimelineTitle),
        const SizedBox(height: 8),
        if (ticket.logs.isEmpty)
          SupervisorStatePanel(
            icon: Icons.timeline_rounded,
            message: l10n.emptyTicketTimelineMessage,
          )
        else
          SupervisorSurface(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                for (var index = 0; index < ticket.logs.length; index++)
                  _TimelineTile(
                    log: ticket.logs[index],
                    isLast: index == ticket.logs.length - 1,
                  ),
              ],
            ),
          ),
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
    if (_selectedStatus == null) return;
    setState(() => _submitting = true);
    try {
      await ref
          .read(operationsRepositoryProvider)
          .updateTicket(
            ticketId: ticket.id,
            status: _selectedStatus!,
            comment: _commentController.text,
            attachments: _attachments,
          );
      ref
        ..invalidate(ticketDetailProvider(widget.ticketId))
        ..invalidate(todaysSupervisorTicketsProvider);
      if (!mounted) return;
      setState(() {
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.ticket});

  final SupervisorTicketDetail ticket;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SupervisorSurface(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ticket.issue.isEmpty
                      ? l10n.ticketCategoryFallback
                      : ticket.issue,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              TicketStatusBadge(status: ticket.status),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth >= 620
                  ? (constraints.maxWidth - 16) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  SizedBox(
                    width: itemWidth,
                    child: _DetailRow(
                      icon: Icons.meeting_room_rounded,
                      label: l10n.washroomFallback,
                      value: ticket.washroomName.isEmpty
                          ? ticket.washroomId
                          : ticket.washroomName,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _DetailRow(
                      icon: Icons.category_rounded,
                      label: l10n.ticketCategoryLabel,
                      value: ticket.category.isEmpty ? '-' : ticket.category,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _DetailRow(
                      icon: Icons.flag_rounded,
                      label: l10n.priorityLabel,
                      value: ticket.priority,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _DetailRow(
                      icon: Icons.schedule_rounded,
                      label: l10n.reportedAtLabel,
                      value: DateFormat(
                        'dd/MM/yy | hh:mm a',
                      ).format(ticket.createdAt),
                    ),
                  ),
                  if (ticket.assignedTo.isNotEmpty)
                    SizedBox(
                      width: itemWidth,
                      child: _DetailRow(
                        icon: Icons.person_rounded,
                        label: l10n.assignedToLabel,
                        value: ticket.assignedTo,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({
    required this.selectedStatus,
    required this.commentController,
    required this.attachments,
    required this.submitting,
    required this.onStatusChanged,
    required this.onCamera,
    required this.onGallery,
    required this.onRemoveAttachment,
    required this.onSubmit,
  });

  final SupervisorTicketStatus selectedStatus;
  final TextEditingController commentController;
  final List<LocalTicketAttachment> attachments;
  final bool submitting;
  final ValueChanged<SupervisorTicketStatus> onStatusChanged;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final ValueChanged<int> onRemoveAttachment;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SupervisorSectionHeader(title: l10n.updateTicketTitle),
        const SizedBox(height: 8),
        SupervisorSurface(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<SupervisorTicketStatus>(
                initialValue: selectedStatus,
                decoration: InputDecoration(labelText: l10n.statusLabel),
                items: SupervisorTicketStatus.values
                    .map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(ticketStatusLabel(context, status)),
                      ),
                    )
                    .toList(),
                onChanged: submitting
                    ? null
                    : (status) {
                        if (status != null) onStatusChanged(status);
                      },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentController,
                enabled: !submitting,
                minLines: 3,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: l10n.commentLabel,
                  hintText: l10n.ticketCommentHint,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: submitting ? null : onCamera,
                      icon: const Icon(Icons.photo_camera_rounded),
                      label: Text(l10n.cameraButton),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: submitting ? null : onGallery,
                      icon: const Icon(Icons.photo_library_rounded),
                      label: Text(l10n.galleryButton),
                    ),
                  ),
                ],
              ),
              if (attachments.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...attachments.asMap().entries.map(
                  (entry) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.attach_file_rounded),
                    title: Text(entry.value.name),
                    subtitle: Text(_humanSize(entry.value.sizeBytes)),
                    trailing: IconButton(
                      tooltip: l10n.removeAttachmentTooltip,
                      onPressed: submitting
                          ? null
                          : () => onRemoveAttachment(entry.key),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              SupervisorGradientButton(
                label: l10n.updateTicketButton,
                onPressed: submitting ? null : onSubmit,
                icon: Icons.save_rounded,
                loading: submitting,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LockNotice extends StatelessWidget {
  const _LockNotice({required this.systemGenerated});

  final bool systemGenerated;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SupervisorSurface(
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: const Icon(Icons.lock_outline_rounded),
        title: Text(
          systemGenerated
              ? l10n.systemTicketLockedTitle
              : l10n.completedTicketLockedTitle,
        ),
        subtitle: Text(l10n.ticketLockedSubtitle),
      ),
    );
  }
}

class _AttachmentsCard extends StatelessWidget {
  const _AttachmentsCard({required this.attachments});

  final List<SupervisorTicketAttachment> attachments;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SupervisorSurface(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.attachmentsTitle,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          if (attachments.isEmpty)
            Text(l10n.noAttachmentsMessage)
          else
            ...attachments.map(
              (attachment) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.image_outlined),
                title: Text(attachment.name),
                subtitle: attachment.url.isEmpty ? null : Text(attachment.url),
              ),
            ),
        ],
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.log, required this.isLast});

  final SupervisorTicketLog log;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final status = normalizeTicketStatus(log.status);
    final color = SupervisorPalette.status(status);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                TicketStatusDot(status: status, icon: ticketStatusIcon(status)),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      color: color.withValues(alpha: 0.35),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.status.isEmpty ? '-' : log.status,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(DateFormat('dd/MM/yy | hh:mm a').format(log.timestamp)),
                  if (log.comment.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(log.comment),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelMedium),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
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

String _humanSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
  return '${(kb / 1024).toStringAsFixed(1)} MB';
}
