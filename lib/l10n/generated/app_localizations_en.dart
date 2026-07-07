// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => '4CT Washroom Ops';

  @override
  String get loginSubtitle =>
      'Sign in with the OTP sent to your registered account.';

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
  String get statusPending => 'Pending';

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
  String get needsAttentionButton => 'Needs attention';

  @override
  String get feedbackDeviceMigrationNote =>
      'QR, idle timeout, weather, and feedback reason APIs are mapped in MIGRATION_PLAN.md.';
}
