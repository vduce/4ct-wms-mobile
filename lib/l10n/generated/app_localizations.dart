import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Washroom Management'**
  String get appTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with the OTP sent to your registered account.'**
  String get loginSubtitle;

  /// No description provided for @poweredByLabel.
  ///
  /// In en, this message translates to:
  /// **'Powered by'**
  String get poweredByLabel;

  /// No description provided for @emailOrUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Email or username'**
  String get emailOrUsernameLabel;

  /// No description provided for @otpLabel.
  ///
  /// In en, this message translates to:
  /// **'6 digit OTP'**
  String get otpLabel;

  /// No description provided for @sendOtpButton.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtpButton;

  /// No description provided for @verifyOtpButton.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtpButton;

  /// No description provided for @enterEmailOrUsernameError.
  ///
  /// In en, this message translates to:
  /// **'Enter email or username.'**
  String get enterEmailOrUsernameError;

  /// No description provided for @otpSentMessage.
  ///
  /// In en, this message translates to:
  /// **'OTP sent.'**
  String get otpSentMessage;

  /// No description provided for @enterSixDigitOtpError.
  ///
  /// In en, this message translates to:
  /// **'Enter a 6 digit OTP.'**
  String get enterSixDigitOtpError;

  /// No description provided for @operationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get operationsTitle;

  /// No description provided for @signOutTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOutTooltip;

  /// No description provided for @openNavigationTooltip.
  ///
  /// In en, this message translates to:
  /// **'Open navigation'**
  String get openNavigationTooltip;

  /// No description provided for @notificationsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTooltip;

  /// No description provided for @noNotificationsMessage.
  ///
  /// In en, this message translates to:
  /// **'No new notifications.'**
  String get noNotificationsMessage;

  /// No description provided for @defaultUserName.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get defaultUserName;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi {username}'**
  String homeGreeting(String username);

  /// No description provided for @tenantAirportSummary.
  ///
  /// In en, this message translates to:
  /// **'Tenant {tenantId} - Airport {airportId}'**
  String tenantAirportSummary(String tenantId, String airportId);

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get statusPending;

  /// No description provided for @statusAcknowledged.
  ///
  /// In en, this message translates to:
  /// **'Acknowledged'**
  String get statusAcknowledged;

  /// No description provided for @statusEscalated.
  ///
  /// In en, this message translates to:
  /// **'Escalated'**
  String get statusEscalated;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @openDashboardsButton.
  ///
  /// In en, this message translates to:
  /// **'Open dashboards'**
  String get openDashboardsButton;

  /// No description provided for @ticketsTitle.
  ///
  /// In en, this message translates to:
  /// **'{status} tickets'**
  String ticketsTitle(String status);

  /// No description provided for @ticketApiMappingPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Ticket API mapping pending'**
  String get ticketApiMappingPendingTitle;

  /// No description provided for @ticketApiMappingPendingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Preserve /list_tickets_feedback and /update_ticket'**
  String get ticketApiMappingPendingSubtitle;

  /// No description provided for @ticketLockRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'System/completed ticket lock rules'**
  String get ticketLockRulesTitle;

  /// No description provided for @ticketLockRulesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Disable status changes, comments, and attachments.'**
  String get ticketLockRulesSubtitle;

  /// No description provided for @attachmentUploadSkeletonTitle.
  ///
  /// In en, this message translates to:
  /// **'Attachment upload skeleton'**
  String get attachmentUploadSkeletonTitle;

  /// No description provided for @attachmentUploadSkeletonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use camera/file picker, then upload to SAS URLs.'**
  String get attachmentUploadSkeletonSubtitle;

  /// No description provided for @dashboardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboards'**
  String get dashboardsTitle;

  /// No description provided for @washroomFootfallTitle.
  ///
  /// In en, this message translates to:
  /// **'Washroom footfall'**
  String get washroomFootfallTitle;

  /// No description provided for @negativeFeedbackHeatmapTitle.
  ///
  /// In en, this message translates to:
  /// **'Negative feedback heatmap'**
  String get negativeFeedbackHeatmapTitle;

  /// No description provided for @zoneLeadResponseResolutionTitle.
  ///
  /// In en, this message translates to:
  /// **'Zone lead response and resolution'**
  String get zoneLeadResponseResolutionTitle;

  /// No description provided for @feedbackDeviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Feedback device'**
  String get feedbackDeviceTitle;

  /// No description provided for @washroomLabel.
  ///
  /// In en, this message translates to:
  /// **'Washroom {washroomId}'**
  String washroomLabel(String washroomId);

  /// No description provided for @goodFeedbackButton.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get goodFeedbackButton;

  /// No description provided for @needsAttentionButton.
  ///
  /// In en, this message translates to:
  /// **'Not Good'**
  String get needsAttentionButton;

  /// No description provided for @feedbackDeviceMigrationNote.
  ///
  /// In en, this message translates to:
  /// **'QR, idle timeout, weather, and feedback reason APIs are mapped in MIGRATION_PLAN.md.'**
  String get feedbackDeviceMigrationNote;

  /// No description provided for @feedbackNoWashroomError.
  ///
  /// In en, this message translates to:
  /// **'No washroom is available for this feedback device.'**
  String get feedbackNoWashroomError;

  /// No description provided for @feedbackSubmitFailedError.
  ///
  /// In en, this message translates to:
  /// **'Could not submit feedback. Please try again.'**
  String get feedbackSubmitFailedError;

  /// No description provided for @feedbackSelectIssueError.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one issue.'**
  String get feedbackSelectIssueError;

  /// No description provided for @feedbackKioskLabel.
  ///
  /// In en, this message translates to:
  /// **'Feedback kiosk'**
  String get feedbackKioskLabel;

  /// No description provided for @scanLabel.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scanLabel;

  /// No description provided for @feedbackLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'EN'**
  String get feedbackLanguageEnglish;

  /// No description provided for @feedbackLanguageHindi.
  ///
  /// In en, this message translates to:
  /// **'HI'**
  String get feedbackLanguageHindi;

  /// No description provided for @languageSelectorTooltip.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get languageSelectorTooltip;

  /// No description provided for @switchToLightModeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Switch to light mode'**
  String get switchToLightModeTooltip;

  /// No description provided for @switchToDarkModeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Switch to dark mode'**
  String get switchToDarkModeTooltip;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageHindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get languageHindi;

  /// No description provided for @feedbackWelcomePrefix.
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get feedbackWelcomePrefix;

  /// No description provided for @feedbackAirportName.
  ///
  /// In en, this message translates to:
  /// **'Mumbai International Airport'**
  String get feedbackAirportName;

  /// No description provided for @feedbackWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your feedback helps us create\na better experience for you.'**
  String get feedbackWelcomeSubtitle;

  /// No description provided for @feedbackShareFeedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Share Your Feedback'**
  String get feedbackShareFeedbackTitle;

  /// No description provided for @feedbackStartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap to get started'**
  String get feedbackStartSubtitle;

  /// No description provided for @feedbackTapAnywhereSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere on screen to get started'**
  String get feedbackTapAnywhereSubtitle;

  /// No description provided for @feedbackTemperatureUnavailable.
  ///
  /// In en, this message translates to:
  /// **'--°C'**
  String get feedbackTemperatureUnavailable;

  /// No description provided for @feedbackQrStartLabel.
  ///
  /// In en, this message translates to:
  /// **'Scan with your phone'**
  String get feedbackQrStartLabel;

  /// No description provided for @feedbackQrStartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No need to touch the screen'**
  String get feedbackQrStartSubtitle;

  /// No description provided for @feedbackQrDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan for Feedback'**
  String get feedbackQrDialogTitle;

  /// No description provided for @feedbackQrDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Scan this QR code with your phone to open restroom feedback.'**
  String get feedbackQrDialogMessage;

  /// No description provided for @feedbackQrDialogCloseButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get feedbackQrDialogCloseButton;

  /// No description provided for @feedbackVideoLabel.
  ///
  /// In en, this message translates to:
  /// **'Airport experience video'**
  String get feedbackVideoLabel;

  /// No description provided for @feedbackVideoUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Video unavailable'**
  String get feedbackVideoUnavailable;

  /// No description provided for @feedbackVideoPlayTooltip.
  ///
  /// In en, this message translates to:
  /// **'Play video'**
  String get feedbackVideoPlayTooltip;

  /// No description provided for @feedbackVideoPauseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Pause video'**
  String get feedbackVideoPauseTooltip;

  /// No description provided for @metricAqiLabel.
  ///
  /// In en, this message translates to:
  /// **'AQI'**
  String get metricAqiLabel;

  /// No description provided for @metricOccupancyLabel.
  ///
  /// In en, this message translates to:
  /// **'Occupancy'**
  String get metricOccupancyLabel;

  /// No description provided for @metricCubicleOccupancyLabel.
  ///
  /// In en, this message translates to:
  /// **'Cubicle Occupancy'**
  String get metricCubicleOccupancyLabel;

  /// No description provided for @metricFootfallLabel.
  ///
  /// In en, this message translates to:
  /// **'Footfall'**
  String get metricFootfallLabel;

  /// No description provided for @metricOdourLabel.
  ///
  /// In en, this message translates to:
  /// **'Odor'**
  String get metricOdourLabel;

  /// No description provided for @metricAqiStatusGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get metricAqiStatusGood;

  /// No description provided for @metricOccupancyStatusLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get metricOccupancyStatusLow;

  /// No description provided for @metricFootfallStatusToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get metricFootfallStatusToday;

  /// No description provided for @metricOdourStatusNeutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get metricOdourStatusNeutral;

  /// No description provided for @feedbackInsightRealTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Real-time Insights'**
  String get feedbackInsightRealTimeTitle;

  /// No description provided for @feedbackInsightRealTimeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Live environment metrics upfront'**
  String get feedbackInsightRealTimeSubtitle;

  /// No description provided for @feedbackInsightCleanTitle.
  ///
  /// In en, this message translates to:
  /// **'Clean & Spacious'**
  String get feedbackInsightCleanTitle;

  /// No description provided for @feedbackInsightCleanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Comfortable facilities for all travelers'**
  String get feedbackInsightCleanSubtitle;

  /// No description provided for @feedbackInsightAccessibleTitle.
  ///
  /// In en, this message translates to:
  /// **'Accessible'**
  String get feedbackInsightAccessibleTitle;

  /// No description provided for @feedbackInsightAccessibleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Multi-lingual & easy to use'**
  String get feedbackInsightAccessibleSubtitle;

  /// No description provided for @feedbackInsightVoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Voice Matters'**
  String get feedbackInsightVoiceTitle;

  /// No description provided for @feedbackInsightVoiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help us improve every day'**
  String get feedbackInsightVoiceSubtitle;

  /// No description provided for @feedbackScreensaverTitle.
  ///
  /// In en, this message translates to:
  /// **'How was your washroom experience?'**
  String get feedbackScreensaverTitle;

  /// No description provided for @feedbackScreensaverFallback.
  ///
  /// In en, this message translates to:
  /// **'Tap to share your feedback'**
  String get feedbackScreensaverFallback;

  /// No description provided for @feedbackStartButton.
  ///
  /// In en, this message translates to:
  /// **'Tap to give feedback'**
  String get feedbackStartButton;

  /// No description provided for @feedbackChoiceSatisfiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get feedbackChoiceSatisfiedTitle;

  /// No description provided for @feedbackChoiceSatisfiedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'I had a great experience'**
  String get feedbackChoiceSatisfiedSubtitle;

  /// No description provided for @feedbackChoiceNeedsAttentionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'There is something we can improve'**
  String get feedbackChoiceNeedsAttentionSubtitle;

  /// No description provided for @feedbackChoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'How was your experience today?'**
  String get feedbackChoiceTitle;

  /// No description provided for @feedbackChoiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your feedback keeps us going'**
  String get feedbackChoiceSubtitle;

  /// No description provided for @feedbackCommentTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a comment'**
  String get feedbackCommentTitle;

  /// No description provided for @feedbackCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us what needs attention'**
  String get feedbackCommentHint;

  /// No description provided for @feedbackCommentSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save comment'**
  String get feedbackCommentSaveButton;

  /// No description provided for @feedbackNegativeTitle.
  ///
  /// In en, this message translates to:
  /// **'We\'re sorry to hear that.'**
  String get feedbackNegativeTitle;

  /// No description provided for @feedbackNegativeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please select the issue you faced.'**
  String get feedbackNegativeSubtitle;

  /// No description provided for @feedbackNegativeHelper.
  ///
  /// In en, this message translates to:
  /// **'Select all that apply and click on Submit once selected.'**
  String get feedbackNegativeHelper;

  /// No description provided for @feedbackAddCommentButton.
  ///
  /// In en, this message translates to:
  /// **'Add comment'**
  String get feedbackAddCommentButton;

  /// No description provided for @feedbackEditCommentButton.
  ///
  /// In en, this message translates to:
  /// **'Edit comment'**
  String get feedbackEditCommentButton;

  /// No description provided for @feedbackCommentFieldPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Add additional comments...'**
  String get feedbackCommentFieldPlaceholder;

  /// No description provided for @feedbackSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'SUBMIT FEEDBACK'**
  String get feedbackSubmitButton;

  /// No description provided for @feedbackEmptyReasonsMessage.
  ///
  /// In en, this message translates to:
  /// **'No active feedback reasons are configured for this location.'**
  String get feedbackEmptyReasonsMessage;

  /// No description provided for @feedbackThanksTitle.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback'**
  String get feedbackThanksTitle;

  /// No description provided for @feedbackThanksPositiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We are glad your experience was comfortable.'**
  String get feedbackThanksPositiveSubtitle;

  /// No description provided for @feedbackThanksNegativeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Our facility team has been notified.'**
  String get feedbackThanksNegativeSubtitle;

  /// No description provided for @doneButton.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneButton;

  /// No description provided for @feedbackDeviceNotReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Feedback device is not ready'**
  String get feedbackDeviceNotReadyTitle;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @ticketHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Ticket history'**
  String get ticketHistoryTitle;

  /// No description provided for @lastLoginLabel.
  ///
  /// In en, this message translates to:
  /// **'Login {value}'**
  String lastLoginLabel(String value);

  /// No description provided for @activeShiftLabel.
  ///
  /// In en, this message translates to:
  /// **'Shift {value}'**
  String activeShiftLabel(String value);

  /// No description provided for @ticketStatusCardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Ticket overview'**
  String get ticketStatusCardsTitle;

  /// No description provided for @viewHistoryButton.
  ///
  /// In en, this message translates to:
  /// **'View history'**
  String get viewHistoryButton;

  /// No description provided for @passengerFlowTitle.
  ///
  /// In en, this message translates to:
  /// **'Passenger flow'**
  String get passengerFlowTitle;

  /// No description provided for @supervisedUnitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Supervised washrooms'**
  String get supervisedUnitsTitle;

  /// No description provided for @viewAllButton.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAllButton;

  /// No description provided for @ticketDeltaFromYesterday.
  ///
  /// In en, this message translates to:
  /// **'{delta} from yesterday'**
  String ticketDeltaFromYesterday(String delta);

  /// No description provided for @supervisedUnitsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} units'**
  String supervisedUnitsCount(int count);

  /// No description provided for @cubiclesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} cubicles'**
  String cubiclesCount(int count);

  /// No description provided for @janitorScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Janitor schedule'**
  String get janitorScheduleTitle;

  /// No description provided for @janitorsAssignedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} assigned'**
  String janitorsAssignedCount(int count);

  /// No description provided for @emptyWashroomsMessage.
  ///
  /// In en, this message translates to:
  /// **'No supervised washrooms are assigned.'**
  String get emptyWashroomsMessage;

  /// No description provided for @emptyScheduleMessage.
  ///
  /// In en, this message translates to:
  /// **'No janitor schedule is available for this window.'**
  String get emptyScheduleMessage;

  /// No description provided for @emptyPassengerFlowMessage.
  ///
  /// In en, this message translates to:
  /// **'No passenger flow peaks are available.'**
  String get emptyPassengerFlowMessage;

  /// No description provided for @supervisorTicketsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load supervisor tickets.'**
  String get supervisorTicketsLoadFailed;

  /// No description provided for @supervisedUnitsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load supervised washrooms.'**
  String get supervisedUnitsLoadFailed;

  /// No description provided for @passengerFlowLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load passenger flow.'**
  String get passengerFlowLoadFailed;

  /// No description provided for @noWashroomsAssignedMessage.
  ///
  /// In en, this message translates to:
  /// **'No washrooms are assigned to this user.'**
  String get noWashroomsAssignedMessage;

  /// No description provided for @passengerCount.
  ///
  /// In en, this message translates to:
  /// **'{count} passengers'**
  String passengerCount(int count);

  /// No description provided for @washroomFallback.
  ///
  /// In en, this message translates to:
  /// **'Washroom'**
  String get washroomFallback;

  /// No description provided for @userTicketsTitle.
  ///
  /// In en, this message translates to:
  /// **'User tickets'**
  String get userTicketsTitle;

  /// No description provided for @systemTicketsTitle.
  ///
  /// In en, this message translates to:
  /// **'System tickets'**
  String get systemTicketsTitle;

  /// No description provided for @noTicketsForFilterMessage.
  ///
  /// In en, this message translates to:
  /// **'No tickets match the current filters.'**
  String get noTicketsForFilterMessage;

  /// No description provided for @noSystemTicketsMessage.
  ///
  /// In en, this message translates to:
  /// **'No system tickets match this status.'**
  String get noSystemTicketsMessage;

  /// No description provided for @ticketCategoryFallback.
  ///
  /// In en, this message translates to:
  /// **'Ticket'**
  String get ticketCategoryFallback;

  /// No description provided for @priorityFallback.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get priorityFallback;

  /// No description provided for @ticketSourceUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get ticketSourceUser;

  /// No description provided for @ticketSourceSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get ticketSourceSystem;

  /// No description provided for @ticketSourceUserReported.
  ///
  /// In en, this message translates to:
  /// **'User reported'**
  String get ticketSourceUserReported;

  /// No description provided for @ticketSourceSystemGenerated.
  ///
  /// In en, this message translates to:
  /// **'System generated'**
  String get ticketSourceSystemGenerated;

  /// No description provided for @filterTicketsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filter tickets'**
  String get filterTicketsTooltip;

  /// No description provided for @acknowledgeButton.
  ///
  /// In en, this message translates to:
  /// **'Acknowledge'**
  String get acknowledgeButton;

  /// No description provided for @ticketAcknowledgedMessage.
  ///
  /// In en, this message translates to:
  /// **'Ticket acknowledged.'**
  String get ticketAcknowledgedMessage;

  /// No description provided for @ticketAcknowledgeFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not acknowledge ticket.'**
  String get ticketAcknowledgeFailed;

  /// No description provided for @ticketDetailLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load ticket details.'**
  String get ticketDetailLoadFailed;

  /// No description provided for @ticketDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Ticket Details'**
  String get ticketDetailsTitle;

  /// No description provided for @ticketDetailMoreTooltip.
  ///
  /// In en, this message translates to:
  /// **'More ticket actions'**
  String get ticketDetailMoreTooltip;

  /// No description provided for @ticketDetailRefreshAction.
  ///
  /// In en, this message translates to:
  /// **'Refresh ticket'**
  String get ticketDetailRefreshAction;

  /// No description provided for @ticketDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get ticketDescriptionLabel;

  /// No description provided for @ticketInformationTitle.
  ///
  /// In en, this message translates to:
  /// **'Ticket information'**
  String get ticketInformationTitle;

  /// No description provided for @ticketCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get ticketCategoryLabel;

  /// No description provided for @priorityLabel.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priorityLabel;

  /// No description provided for @reportedAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Reported at'**
  String get reportedAtLabel;

  /// No description provided for @completedAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed at'**
  String get completedAtLabel;

  /// No description provided for @ticketDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Ticket duration'**
  String get ticketDurationLabel;

  /// No description provided for @assignedToLabel.
  ///
  /// In en, this message translates to:
  /// **'Assigned to'**
  String get assignedToLabel;

  /// No description provided for @updateTicketTitle.
  ///
  /// In en, this message translates to:
  /// **'Update ticket'**
  String get updateTicketTitle;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @commentLabel.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get commentLabel;

  /// No description provided for @ticketCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Add a concise update for the team'**
  String get ticketCommentHint;

  /// No description provided for @cameraButton.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get cameraButton;

  /// No description provided for @galleryButton.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get galleryButton;

  /// No description provided for @removeAttachmentTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove attachment'**
  String get removeAttachmentTooltip;

  /// No description provided for @updateTicketButton.
  ///
  /// In en, this message translates to:
  /// **'Update ticket'**
  String get updateTicketButton;

  /// No description provided for @systemTicketLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'System ticket locked'**
  String get systemTicketLockedTitle;

  /// No description provided for @completedTicketLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Completed ticket locked'**
  String get completedTicketLockedTitle;

  /// No description provided for @ticketLockedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Status changes, comments, and attachments are disabled.'**
  String get ticketLockedSubtitle;

  /// No description provided for @attachmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachmentsTitle;

  /// No description provided for @noAttachmentsMessage.
  ///
  /// In en, this message translates to:
  /// **'No attachments have been added.'**
  String get noAttachmentsMessage;

  /// No description provided for @ticketTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Ticket timeline'**
  String get ticketTimelineTitle;

  /// No description provided for @emptyTicketTimelineMessage.
  ///
  /// In en, this message translates to:
  /// **'No ticket updates are available.'**
  String get emptyTicketTimelineMessage;

  /// No description provided for @attachmentPickFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not add the selected attachment.'**
  String get attachmentPickFailed;

  /// No description provided for @ticketUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Ticket updated.'**
  String get ticketUpdatedMessage;

  /// No description provided for @ticketUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update ticket.'**
  String get ticketUpdateFailed;

  /// No description provided for @exportCsvTooltip.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsvTooltip;

  /// No description provided for @exportCsvButton.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsvButton;

  /// No description provided for @ticketHistoryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load ticket history.'**
  String get ticketHistoryLoadFailed;

  /// No description provided for @ticketHistoryResults.
  ///
  /// In en, this message translates to:
  /// **'{count} results'**
  String ticketHistoryResults(int count);

  /// No description provided for @historyFromLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get historyFromLabel;

  /// No description provided for @historyToLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get historyToLabel;

  /// No description provided for @fromDateLabel.
  ///
  /// In en, this message translates to:
  /// **'From {date}'**
  String fromDateLabel(String date);

  /// No description provided for @toDateLabel.
  ///
  /// In en, this message translates to:
  /// **'To {date}'**
  String toDateLabel(String date);

  /// No description provided for @allStatusesLabel.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allStatusesLabel;

  /// No description provided for @ticketSourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get ticketSourceLabel;

  /// No description provided for @allSourcesLabel.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allSourcesLabel;

  /// No description provided for @allWashroomsLabel.
  ///
  /// In en, this message translates to:
  /// **'All washrooms'**
  String get allWashroomsLabel;

  /// No description provided for @fromDateAfterToDateMessage.
  ///
  /// In en, this message translates to:
  /// **'From date cannot be after To date.'**
  String get fromDateAfterToDateMessage;

  /// No description provided for @toDateBeforeFromDateMessage.
  ///
  /// In en, this message translates to:
  /// **'To date cannot be before From date.'**
  String get toDateBeforeFromDateMessage;

  /// No description provided for @noTicketsToExportMessage.
  ///
  /// In en, this message translates to:
  /// **'No tickets are available to export.'**
  String get noTicketsToExportMessage;

  /// No description provided for @ticketHistoryExportText.
  ///
  /// In en, this message translates to:
  /// **'CSV export from Smart Washroom'**
  String get ticketHistoryExportText;

  /// No description provided for @ticketHistoryExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not export ticket history.'**
  String get ticketHistoryExportFailed;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get notificationsEmptyMessage;

  /// No description provided for @markAllReadTooltip.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllReadTooltip;

  /// No description provided for @clearNotificationsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearNotificationsTooltip;

  /// No description provided for @notificationTicketAssignedTitle.
  ///
  /// In en, this message translates to:
  /// **'New ticket assigned'**
  String get notificationTicketAssignedTitle;

  /// No description provided for @notificationTicketAssignedBody.
  ///
  /// In en, this message translates to:
  /// **'Ticket {ticketId} needs your attention at {washroomId}.'**
  String notificationTicketAssignedBody(String ticketId, String washroomId);

  /// No description provided for @notificationTicketEscalatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Ticket escalated'**
  String get notificationTicketEscalatedTitle;

  /// No description provided for @notificationTicketEscalatedBody.
  ///
  /// In en, this message translates to:
  /// **'Ticket {ticketId} at {washroomId} has been escalated.'**
  String notificationTicketEscalatedBody(String ticketId, String washroomId);

  /// No description provided for @notificationTicketAcknowledgedTitle.
  ///
  /// In en, this message translates to:
  /// **'Ticket acknowledged'**
  String get notificationTicketAcknowledgedTitle;

  /// No description provided for @notificationTicketAcknowledgedBody.
  ///
  /// In en, this message translates to:
  /// **'Ticket {ticketId} has been acknowledged.'**
  String notificationTicketAcknowledgedBody(String ticketId);

  /// No description provided for @notificationTicketCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Ticket completed'**
  String get notificationTicketCompletedTitle;

  /// No description provided for @notificationTicketCompletedBody.
  ///
  /// In en, this message translates to:
  /// **'Ticket {ticketId} has been completed.'**
  String notificationTicketCompletedBody(String ticketId);

  /// No description provided for @notificationFeedbackNegativeTitle.
  ///
  /// In en, this message translates to:
  /// **'Negative feedback received'**
  String get notificationFeedbackNegativeTitle;

  /// No description provided for @notificationFeedbackNegativeBody.
  ///
  /// In en, this message translates to:
  /// **'A passenger reported an issue at {washroomId}.'**
  String notificationFeedbackNegativeBody(String washroomId);

  /// No description provided for @notificationShiftReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Shift reminder'**
  String get notificationShiftReminderTitle;

  /// No description provided for @notificationShiftReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Your shift {shiftLabel} is about to start.'**
  String notificationShiftReminderBody(String shiftLabel);

  /// No description provided for @notificationGeneralTitle.
  ///
  /// In en, this message translates to:
  /// **'New notification'**
  String get notificationGeneralTitle;

  /// No description provided for @notificationGeneralBody.
  ///
  /// In en, this message translates to:
  /// **'You have a new update.'**
  String get notificationGeneralBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
