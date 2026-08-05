// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Smart Washroom Management';

  @override
  String get loginSubtitle =>
      'Sign in with the OTP sent to your registered account.';

  @override
  String get poweredByLabel => 'Powered by';

  @override
  String get emailOrUsernameLabel => 'Email or username';

  @override
  String get otpLabel => '6 digit OTP';

  @override
  String get sendOtpButton => 'Send OTP';

  @override
  String get verifyOtpButton => 'Verify OTP';

  @override
  String get enterEmailOrUsernameError => 'Enter email or username.';

  @override
  String get otpSentMessage => 'OTP sent.';

  @override
  String get enterSixDigitOtpError => 'Enter a 6 digit OTP.';

  @override
  String get operationsTitle => 'Operations';

  @override
  String get signOutTooltip => 'Sign out';

  @override
  String get openNavigationTooltip => 'Open navigation';

  @override
  String get notificationsTooltip => 'Notifications';

  @override
  String get noNotificationsMessage => 'No new notifications.';

  @override
  String get defaultUserName => 'User';

  @override
  String homeGreeting(String username) {
    return 'Hi $username';
  }

  @override
  String tenantAirportSummary(String tenantId, String airportId) {
    return 'Tenant $tenantId - Airport $airportId';
  }

  @override
  String get statusPending => 'New';

  @override
  String get statusAcknowledged => 'Acknowledged';

  @override
  String get statusEscalated => 'Escalated';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get openDashboardsButton => 'Open dashboards';

  @override
  String ticketsTitle(String status) {
    return '$status tickets';
  }

  @override
  String get ticketApiMappingPendingTitle => 'Ticket API mapping pending';

  @override
  String get ticketApiMappingPendingSubtitle =>
      'Preserve /list_tickets_feedback and /update_ticket';

  @override
  String get ticketLockRulesTitle => 'System/completed ticket lock rules';

  @override
  String get ticketLockRulesSubtitle =>
      'Disable status changes, comments, and attachments.';

  @override
  String get attachmentUploadSkeletonTitle => 'Attachment upload skeleton';

  @override
  String get attachmentUploadSkeletonSubtitle =>
      'Use camera/file picker, then upload to SAS URLs.';

  @override
  String get dashboardsTitle => 'Dashboards';

  @override
  String get washroomFootfallTitle => 'Washroom footfall';

  @override
  String get negativeFeedbackHeatmapTitle => 'Negative feedback heatmap';

  @override
  String get zoneLeadResponseResolutionTitle =>
      'Zone lead response and resolution';

  @override
  String get feedbackDeviceTitle => 'Feedback device';

  @override
  String washroomLabel(String washroomId) {
    return 'Washroom $washroomId';
  }

  @override
  String get goodFeedbackButton => 'Good';

  @override
  String get needsAttentionButton => 'Not Good';

  @override
  String get feedbackDeviceMigrationNote =>
      'QR, idle timeout, weather, and feedback reason APIs are mapped in MIGRATION_PLAN.md.';

  @override
  String get feedbackNoWashroomError =>
      'No washroom is available for this feedback device.';

  @override
  String get feedbackSubmitFailedError =>
      'Could not submit feedback. Please try again.';

  @override
  String get feedbackSelectIssueError => 'Please select at least one issue.';

  @override
  String get feedbackKioskLabel => 'Feedback kiosk';

  @override
  String get scanLabel => 'Scan';

  @override
  String get feedbackLanguageEnglish => 'EN';

  @override
  String get feedbackLanguageHindi => 'HI';

  @override
  String get languageSelectorTooltip => 'Choose language';

  @override
  String get switchToLightModeTooltip => 'Switch to light mode';

  @override
  String get switchToDarkModeTooltip => 'Switch to dark mode';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'Hindi';

  @override
  String get feedbackWelcomePrefix => 'Welcome to';

  @override
  String get feedbackAirportName => 'Mumbai International Airport';

  @override
  String get feedbackWelcomeSubtitle =>
      'Your feedback helps us create\na better experience for you.';

  @override
  String get feedbackShareFeedbackTitle => 'Share Your Feedback';

  @override
  String get feedbackStartSubtitle => 'Tap to get started';

  @override
  String get feedbackTapAnywhereSubtitle =>
      'Tap anywhere on screen to get started';

  @override
  String get feedbackTemperatureUnavailable => '--°C';

  @override
  String get feedbackQrStartLabel => 'Scan with your phone';

  @override
  String get feedbackQrStartSubtitle => 'No need to touch the screen';

  @override
  String get feedbackQrDialogTitle => 'Scan for Feedback';

  @override
  String get feedbackQrDialogMessage =>
      'Scan this QR code with your phone to open restroom feedback.';

  @override
  String get feedbackQrDialogCloseButton => 'Close';

  @override
  String get feedbackVideoLabel => 'Airport experience video';

  @override
  String get feedbackVideoUnavailable => 'Video unavailable';

  @override
  String get feedbackVideoPlayTooltip => 'Play video';

  @override
  String get feedbackVideoPauseTooltip => 'Pause video';

  @override
  String get metricAqiLabel => 'AQI';

  @override
  String get metricOccupancyLabel => 'Occupancy';

  @override
  String get metricCubicleOccupancyLabel => 'Cubicle Occupancy';

  @override
  String get metricFootfallLabel => 'Footfall';

  @override
  String get metricOdourLabel => 'Odor';

  @override
  String get metricAqiStatusGood => 'Good';

  @override
  String get metricOccupancyStatusLow => 'Low';

  @override
  String get metricFootfallStatusToday => 'Today';

  @override
  String get metricOdourStatusNeutral => 'Neutral';

  @override
  String get feedbackInsightRealTimeTitle => 'Real-time Insights';

  @override
  String get feedbackInsightRealTimeSubtitle =>
      'Live environment metrics upfront';

  @override
  String get feedbackInsightCleanTitle => 'Clean & Spacious';

  @override
  String get feedbackInsightCleanSubtitle =>
      'Comfortable facilities for all travelers';

  @override
  String get feedbackInsightAccessibleTitle => 'Accessible';

  @override
  String get feedbackInsightAccessibleSubtitle => 'Multi-lingual & easy to use';

  @override
  String get feedbackInsightVoiceTitle => 'Your Voice Matters';

  @override
  String get feedbackInsightVoiceSubtitle => 'Help us improve every day';

  @override
  String get feedbackScreensaverTitle => 'How was your washroom experience?';

  @override
  String get feedbackScreensaverFallback => 'Tap to share your feedback';

  @override
  String get feedbackStartButton => 'Tap to give feedback';

  @override
  String get feedbackChoiceSatisfiedTitle => 'Good';

  @override
  String get feedbackChoiceSatisfiedSubtitle => 'I had a great experience';

  @override
  String get feedbackChoiceNeedsAttentionSubtitle =>
      'There is something we can improve';

  @override
  String get feedbackChoiceTitle => 'How was your experience today?';

  @override
  String get feedbackChoiceSubtitle => 'Your feedback keeps us going';

  @override
  String get feedbackCommentTitle => 'Add a comment';

  @override
  String get feedbackCommentHint => 'Tell us what needs attention';

  @override
  String get feedbackCommentSaveButton => 'Save comment';

  @override
  String get feedbackNegativeTitle => 'We\'re sorry to hear that.';

  @override
  String get feedbackNegativeSubtitle => 'Please select the issue you faced.';

  @override
  String get feedbackNegativeHelper =>
      'Select all that apply and click on Submit once selected.';

  @override
  String get feedbackAddCommentButton => 'Add comment';

  @override
  String get feedbackEditCommentButton => 'Edit comment';

  @override
  String get feedbackCommentFieldPlaceholder => 'Add additional comments...';

  @override
  String get feedbackSubmitButton => 'SUBMIT FEEDBACK';

  @override
  String get feedbackEmptyReasonsMessage =>
      'No active feedback reasons are configured for this location.';

  @override
  String get feedbackThanksTitle => 'Thank you for your feedback';

  @override
  String get feedbackThanksPositiveSubtitle =>
      'We are glad your experience was comfortable.';

  @override
  String get feedbackThanksNegativeSubtitle =>
      'Our facility team has been notified.';

  @override
  String get doneButton => 'Done';

  @override
  String get feedbackDeviceNotReadyTitle => 'Feedback device is not ready';

  @override
  String get retryButton => 'Retry';

  @override
  String get ticketHistoryTitle => 'Ticket history';

  @override
  String lastLoginLabel(String value) {
    return 'Login $value';
  }

  @override
  String activeShiftLabel(String value) {
    return 'Shift $value';
  }

  @override
  String get ticketStatusCardsTitle => 'Ticket overview';

  @override
  String get viewHistoryButton => 'View history';

  @override
  String get passengerFlowTitle => 'Passenger flow';

  @override
  String get supervisedUnitsTitle => 'Supervised washrooms';

  @override
  String get viewAllButton => 'View all';

  @override
  String ticketDeltaFromYesterday(String delta) {
    return '$delta from yesterday';
  }

  @override
  String supervisedUnitsCount(int count) {
    return '$count units';
  }

  @override
  String cubiclesCount(int count) {
    return '$count cubicles';
  }

  @override
  String get janitorScheduleTitle => 'Janitor schedule';

  @override
  String janitorsAssignedCount(int count) {
    return '$count assigned';
  }

  @override
  String get emptyWashroomsMessage => 'No supervised washrooms are assigned.';

  @override
  String get emptyScheduleMessage =>
      'No janitor schedule is available for this window.';

  @override
  String get emptyPassengerFlowMessage =>
      'No passenger flow peaks are available.';

  @override
  String get supervisorTicketsLoadFailed =>
      'Could not load supervisor tickets.';

  @override
  String get supervisedUnitsLoadFailed =>
      'Could not load supervised washrooms.';

  @override
  String get passengerFlowLoadFailed => 'Could not load passenger flow.';

  @override
  String get noWashroomsAssignedMessage =>
      'No washrooms are assigned to this user.';

  @override
  String passengerCount(int count) {
    return '$count passengers';
  }

  @override
  String get washroomFallback => 'Washroom';

  @override
  String get userTicketsTitle => 'User tickets';

  @override
  String get systemTicketsTitle => 'System tickets';

  @override
  String get noTicketsForFilterMessage =>
      'No tickets match the current filters.';

  @override
  String get noSystemTicketsMessage => 'No system tickets match this status.';

  @override
  String get ticketCategoryFallback => 'Ticket';

  @override
  String get priorityFallback => 'Normal';

  @override
  String get ticketSourceUser => 'User';

  @override
  String get ticketSourceSystem => 'System';

  @override
  String get ticketSourceUserReported => 'User reported';

  @override
  String get ticketSourceSystemGenerated => 'System generated';

  @override
  String get filterTicketsTooltip => 'Filter tickets';

  @override
  String get acknowledgeButton => 'Acknowledge';

  @override
  String get ticketAcknowledgedMessage => 'Ticket acknowledged.';

  @override
  String get ticketAcknowledgeFailed => 'Could not acknowledge ticket.';

  @override
  String get ticketDetailLoadFailed => 'Could not load ticket details.';

  @override
  String get ticketCategoryLabel => 'Category';

  @override
  String get priorityLabel => 'Priority';

  @override
  String get reportedAtLabel => 'Reported at';

  @override
  String get assignedToLabel => 'Assigned to';

  @override
  String get updateTicketTitle => 'Update ticket';

  @override
  String get statusLabel => 'Status';

  @override
  String get commentLabel => 'Comment';

  @override
  String get ticketCommentHint => 'Add a concise update for the team';

  @override
  String get cameraButton => 'Camera';

  @override
  String get galleryButton => 'Gallery';

  @override
  String get removeAttachmentTooltip => 'Remove attachment';

  @override
  String get updateTicketButton => 'Update ticket';

  @override
  String get systemTicketLockedTitle => 'System ticket locked';

  @override
  String get completedTicketLockedTitle => 'Completed ticket locked';

  @override
  String get ticketLockedSubtitle =>
      'Status changes, comments, and attachments are disabled.';

  @override
  String get attachmentsTitle => 'Attachments';

  @override
  String get noAttachmentsMessage => 'No attachments have been added.';

  @override
  String get ticketTimelineTitle => 'Ticket timeline';

  @override
  String get emptyTicketTimelineMessage => 'No ticket updates are available.';

  @override
  String get attachmentPickFailed => 'Could not add the selected attachment.';

  @override
  String get ticketUpdatedMessage => 'Ticket updated.';

  @override
  String get ticketUpdateFailed => 'Could not update ticket.';

  @override
  String get exportCsvTooltip => 'Export CSV';

  @override
  String get exportCsvButton => 'Export CSV';

  @override
  String get ticketHistoryLoadFailed => 'Could not load ticket history.';

  @override
  String ticketHistoryResults(int count) {
    return '$count results';
  }

  @override
  String get historyFromLabel => 'From';

  @override
  String get historyToLabel => 'To';

  @override
  String fromDateLabel(String date) {
    return 'From $date';
  }

  @override
  String toDateLabel(String date) {
    return 'To $date';
  }

  @override
  String get allStatusesLabel => 'All';

  @override
  String get ticketSourceLabel => 'Source';

  @override
  String get allSourcesLabel => 'All';

  @override
  String get allWashroomsLabel => 'All washrooms';

  @override
  String get fromDateAfterToDateMessage => 'From date cannot be after To date.';

  @override
  String get toDateBeforeFromDateMessage =>
      'To date cannot be before From date.';

  @override
  String get noTicketsToExportMessage => 'No tickets are available to export.';

  @override
  String get ticketHistoryExportText => 'CSV export from Smart Washroom';

  @override
  String get ticketHistoryExportFailed => 'Could not export ticket history.';
}
