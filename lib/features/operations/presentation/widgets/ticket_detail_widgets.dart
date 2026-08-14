import 'package:flutter/material.dart';

import '../../../../core/date/date_time.dart';
import '../../../../l10n/app_localizations_context.dart';
import '../../domain/ticket_models.dart';
import 'supervisor_ui.dart';

class TicketDetailSummaryCard extends StatelessWidget {
  const TicketDetailSummaryCard({required this.ticket, super.key});

  final SupervisorTicketDetail ticket;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final compact = MediaQuery.sizeOf(context).width < 520;
    final heading = ticket.sourceRuleName.isNotEmpty
        ? ticket.sourceRuleName
        : ticket.ticketNumber.isNotEmpty
        ? ticket.ticketNumber
        : ticket.issue.isNotEmpty
        ? ticket.issue
        : ticket.category.isNotEmpty
        ? ticket.category
        : l10n.ticketCategoryFallback;
    final description = ticket.description.isNotEmpty
        ? ticket.description
        : ticket.issue != heading && ticket.issue != ticket.category
        ? ticket.issue
        : '';

    return SupervisorSurface(
      padding: EdgeInsets.zero,
      radius: 20,
      child: Stack(
        children: [
          const Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: _TicketDetailGradientRail(),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              compact ? 16 : 22,
              compact ? 14 : 18,
              compact ? 14 : 18,
              compact ? 14 : 18,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TicketDetailIconTile(
                          icon: Icons.description_outlined,
                          color: SupervisorPalette.pending,
                          size: compact ? 40 : 48,
                        ),
                        SizedBox(width: compact ? 9 : 12),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: compact ? 72 : 0),
                            child: Text(
                              heading,
                              maxLines: compact ? 3 : 2,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  (compact
                                          ? Theme.of(
                                              context,
                                            ).textTheme.titleMedium
                                          : Theme.of(
                                              context,
                                            ).textTheme.titleLarge)
                                      ?.copyWith(
                                        color: colors.onSurface,
                                        height: 1.22,
                                        fontWeight: FontWeight.w600,
                                      ),
                            ),
                          ),
                        ),
                        if (!compact) ...[
                          const SizedBox(width: 8),
                          TicketStatusBadge(status: ticket.status),
                        ],
                      ],
                    ),
                    if (compact)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: TicketStatusBadge(status: ticket.status),
                      ),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  SizedBox(height: compact ? 10 : 14),
                  _TicketDescriptionBlock(
                    description: description,
                    compact: compact,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TicketDetailInformationCard extends StatelessWidget {
  const TicketDetailInformationCard({required this.ticket, super.key});

  final SupervisorTicketDetail ticket;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final compact = MediaQuery.sizeOf(context).width < 520;
    final completedAt = ticket.completedAt;
    return SupervisorSurface(
      padding: EdgeInsets.fromLTRB(
        compact ? 14 : 18,
        compact ? 14 : 16,
        compact ? 14 : 18,
        compact ? 8 : 10,
      ),
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: compact ? 20 : 22,
              ),
              SizedBox(width: compact ? 7 : 8),
              Expanded(
                child: Text(
                  l10n.ticketInformationTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 4 : 6),
          _TicketDetailInfoRow(
            icon: Icons.meeting_room_outlined,
            color: const Color(0xFF3E73E8),
            label: l10n.washroomFallback,
            value: ticket.washroomName.isEmpty
                ? ticket.washroomId
                : ticket.washroomName,
            compact: compact,
          ),
          _TicketDetailInfoRow(
            icon: Icons.cleaning_services_outlined,
            color: SupervisorPalette.completed,
            label: l10n.ticketCategoryLabel,
            value: ticket.category.isEmpty ? '-' : ticket.category,
            compact: compact,
          ),
          _TicketDetailInfoRow(
            icon: Icons.flag_outlined,
            color: SupervisorPalette.acknowledged,
            label: l10n.priorityLabel,
            value: ticket.priority,
            trailing: TicketPriorityBadge(priority: ticket.priority),
            compact: compact,
          ),
          _TicketDetailInfoRow(
            icon: Icons.event_available_outlined,
            color: SupervisorPalette.pending,
            label: l10n.reportedAtLabel,
            value: context.formatAppDateTime(ticket.createdAt),
            compact: compact,
          ),
          if (completedAt != null)
            _TicketDetailInfoRow(
              icon: Icons.task_alt_outlined,
              color: SupervisorPalette.completed,
              label: l10n.completedAtLabel,
              value: context.formatAppDateTime(completedAt),
              compact: compact,
            ),
          _TicketDetailInfoRow(
            icon: Icons.timer_outlined,
            color: const Color(0xFFE94D83),
            label: l10n.ticketDurationLabel,
            value: formatTicketDuration(ticket.elapsedDuration),
            compact: compact,
          ),
          if (ticket.assignedTo.isNotEmpty)
            _TicketDetailInfoRow(
              icon: Icons.person_outline_rounded,
              color: SupervisorPalette.pending,
              label: l10n.assignedToLabel,
              value: ticket.assignedTo,
              isLast: true,
              compact: compact,
            ),
        ],
      ),
    );
  }
}

class _TicketDescriptionBlock extends StatelessWidget {
  const _TicketDescriptionBlock({
    required this.description,
    required this.compact,
  });

  final String description;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.primary.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          compact ? 11 : 14,
          compact ? 10 : 12,
          compact ? 11 : 14,
          compact ? 10 : 12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.subject_outlined,
              color: colors.primary,
              size: compact ? 17 : 19,
            ),
            SizedBox(width: compact ? 8 : 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.ticketDescriptionLabel,
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: colors.primary),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    softWrap: true,
                    style:
                        (compact
                                ? Theme.of(context).textTheme.bodyMedium
                                : Theme.of(context).textTheme.bodyLarge)
                            ?.copyWith(color: colors.onSurface, height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TicketDetailActionPanel extends StatelessWidget {
  const TicketDetailActionPanel({
    required this.selectedStatus,
    required this.commentController,
    required this.attachments,
    required this.submitting,
    required this.onStatusChanged,
    required this.onCamera,
    required this.onGallery,
    required this.onRemoveAttachment,
    required this.onSubmit,
    super.key,
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
    final colors = Theme.of(context).colorScheme;
    final compact = MediaQuery.sizeOf(context).width < 520;
    final inputDecorationTheme = Theme.of(context).inputDecorationTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.updateTicketTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: compact ? 12 : 14),
        SupervisorSurface(
          padding: EdgeInsets.fromLTRB(
            compact ? 12 : 16,
            compact ? 14 : 18,
            compact ? 12 : 16,
            compact ? 14 : 18,
          ),
          radius: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.statusLabel,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<SupervisorTicketStatus>(
                initialValue: selectedStatus,
                isExpanded: true,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: compact ? 12 : 14,
                    vertical: compact ? 10 : 12,
                  ),
                  border: inputDecorationTheme.border,
                  enabledBorder: inputDecorationTheme.enabledBorder,
                  focusedBorder: inputDecorationTheme.enabledBorder,
                  disabledBorder: inputDecorationTheme.disabledBorder,
                  errorBorder: inputDecorationTheme.errorBorder,
                  focusedErrorBorder: inputDecorationTheme.focusedErrorBorder,
                ),
                icon: Icon(
                  Icons.expand_more_rounded,
                  size: compact ? 20 : 22,
                  color: colors.onSurfaceVariant,
                ),
                selectedItemBuilder: (context) => [
                  for (final status in SupervisorTicketStatus.values)
                    _StatusMenuItem(status: status),
                ],
                items: SupervisorTicketStatus.values
                    .map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: _StatusMenuItem(status: status),
                      ),
                    )
                    .toList(),
                onChanged: submitting
                    ? null
                    : (status) {
                        if (status != null) onStatusChanged(status);
                      },
              ),
              SizedBox(height: compact ? 16 : 20),
              Text(
                l10n.commentLabel,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: commentController,
                enabled: !submitting,
                minLines: compact ? 3 : 4,
                maxLines: 6,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: l10n.ticketCommentHint,
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: colors.surface,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: submitting ? null : onCamera,
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: Text(l10n.cameraButton),
                  ),
                  OutlinedButton.icon(
                    onPressed: submitting ? null : onGallery,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(l10n.galleryButton),
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
              SizedBox(height: compact ? 12 : 16),
              SizedBox(
                width: double.infinity,
                child: SupervisorGradientButton(
                  label: l10n.updateTicketButton,
                  onPressed: submitting ? null : onSubmit,
                  icon: Icons.save_outlined,
                  loading: submitting,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TicketDetailLockNotice extends StatelessWidget {
  const TicketDetailLockNotice({required this.systemGenerated, super.key});

  final bool systemGenerated;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SupervisorSurface(
      padding: EdgeInsets.zero,
      radius: 20,
      child: Stack(
        children: [
          const Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: _TicketDetailGradientRail(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 16, 18, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _TicketDetailIconTile(
                  icon: Icons.lock_outline_rounded,
                  color: SupervisorPalette.acknowledged,
                  size: 44,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        systemGenerated
                            ? l10n.systemTicketLockedTitle
                            : l10n.completedTicketLockedTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(l10n.ticketLockedSubtitle),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TicketDetailAttachmentsCard extends StatelessWidget {
  const TicketDetailAttachmentsCard({required this.attachments, super.key});

  final List<SupervisorTicketAttachment> attachments;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SupervisorSurface(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.attachmentsTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (attachments.isEmpty)
            Text(l10n.noAttachmentsMessage)
          else
            ...attachments.map(
              (attachment) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const _TicketDetailIconTile(
                  icon: Icons.image_outlined,
                  color: SupervisorPalette.pending,
                  size: 40,
                ),
                title: Text(attachment.name),
                subtitle: attachment.url.isEmpty ? null : Text(attachment.url),
              ),
            ),
        ],
      ),
    );
  }
}

class TicketDetailTimelineSection extends StatelessWidget {
  const TicketDetailTimelineSection({required this.logs, super.key});

  final List<SupervisorTicketLog> logs;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.ticketTimelineTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        if (logs.isEmpty)
          SupervisorStatePanel(
            icon: Icons.timeline_rounded,
            message: l10n.emptyTicketTimelineMessage,
          )
        else
          SupervisorSurface(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 4),
            radius: 20,
            child: Column(
              children: [
                for (var index = 0; index < logs.length; index++)
                  _TicketDetailTimelineTile(
                    log: logs[index],
                    isLast: index == logs.length - 1,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TicketDetailGradientRail extends StatelessWidget {
  const _TicketDetailGradientRail();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 7,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: SupervisorPalette.actionGradient.colors,
            stops: SupervisorPalette.actionGradient.stops,
          ),
        ),
      ),
    );
  }
}

class _TicketDetailIconTile extends StatelessWidget {
  const _TicketDetailIconTile({
    required this.icon,
    required this.color,
    this.size = 50,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(size >= 50 ? 14 : 12),
      ),
      child: Icon(icon, color: color, size: size >= 50 ? 25 : 18),
    );
  }
}

class _TicketDetailInfoRow extends StatelessWidget {
  const _TicketDetailInfoRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.trailing,
    this.isLast = false,
    this.compact = false,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final Widget? trailing;
  final bool isLast;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(top: compact ? 8 : 12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TicketDetailIconTile(
                icon: icon,
                color: color,
                size: compact ? 38 : 48,
              ),
              SizedBox(width: compact ? 10 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      softWrap: true,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: colors.onSurface,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          ),
          if (!isLast) ...[
            SizedBox(height: compact ? 8 : 12),
            Divider(height: 1, color: colors.outlineVariant),
          ],
        ],
      ),
    );
  }
}

class _StatusMenuItem extends StatelessWidget {
  const _StatusMenuItem({required this.status});

  final SupervisorTicketStatus status;

  @override
  Widget build(BuildContext context) {
    final color = SupervisorPalette.status(status);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(ticketStatusIcon(status), color: color, size: 17),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            ticketStatusLabel(context, status),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _TicketDetailTimelineTile extends StatelessWidget {
  const _TicketDetailTimelineTile({required this.log, required this.isLast});

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
              padding: EdgeInsets.only(bottom: isLast ? 14 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.status.isEmpty ? '-' : log.status,
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall?.copyWith(color: color),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.formatAppDateTime(log.timestamp),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (log.comment.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _TicketTimelineCommentBlock(
                      comment: log.comment,
                      color: color,
                    ),
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

class _TicketTimelineCommentBlock extends StatelessWidget {
  const _TicketTimelineCommentBlock({
    required this.comment,
    required this.color,
  });

  final String comment;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notes_outlined, color: color, size: 15),
                const SizedBox(width: 6),
                Text(
                  context.l10n.commentLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: color),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              comment,
              softWrap: true,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.onSurface,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String formatTicketDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours == 0) return '${minutes}m';
  return '${hours}h ${minutes}m';
}

String _humanSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  final kilobytes = bytes / 1024;
  if (kilobytes < 1024) return '${kilobytes.toStringAsFixed(1)} KB';
  return '${(kilobytes / 1024).toStringAsFixed(1)} MB';
}
