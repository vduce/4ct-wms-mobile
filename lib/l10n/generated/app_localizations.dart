import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'4CT Washroom Ops'**
  String get appTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with the OTP sent to your registered account.'**
  String get loginSubtitle;

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
  /// **'Pending'**
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
  /// **'Needs attention'**
  String get needsAttentionButton;

  /// No description provided for @feedbackDeviceMigrationNote.
  ///
  /// In en, this message translates to:
  /// **'QR, idle timeout, weather, and feedback reason APIs are mapped in MIGRATION_PLAN.md.'**
  String get feedbackDeviceMigrationNote;
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
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
