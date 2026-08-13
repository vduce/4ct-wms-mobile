// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'स्मार्ट शौचालय प्रबंधन';

  @override
  String get loginSubtitle =>
      'अपने पंजीकृत खाते पर भेजे गए ओटीपी से साइन इन करें।';

  @override
  String get poweredByLabel => 'द्वारा संचालित';

  @override
  String get emailOrUsernameLabel => 'ईमेल या उपयोगकर्ता नाम';

  @override
  String get otpLabel => '6 अंकों का ओटीपी';

  @override
  String get sendOtpButton => 'ओटीपी भेजें';

  @override
  String get verifyOtpButton => 'ओटीपी सत्यापित करें';

  @override
  String get enterEmailOrUsernameError => 'ईमेल या उपयोगकर्ता नाम दर्ज करें।';

  @override
  String get otpSentMessage => 'ओटीपी भेज दिया गया है।';

  @override
  String get enterSixDigitOtpError => '6 अंकों का ओटीपी दर्ज करें।';

  @override
  String get operationsTitle => 'संचालन';

  @override
  String get signOutTooltip => 'साइन आउट करें';

  @override
  String get openNavigationTooltip => 'नेविगेशन खोलें';

  @override
  String get notificationsTooltip => 'सूचनाएं';

  @override
  String get noNotificationsMessage => 'कोई नई सूचना नहीं है।';

  @override
  String get defaultUserName => 'उपयोगकर्ता';

  @override
  String homeGreeting(String username) {
    return 'नमस्ते $username';
  }

  @override
  String tenantAirportSummary(String tenantId, String airportId) {
    return 'टेनेंट $tenantId - हवाई अड्डा $airportId';
  }

  @override
  String get statusPending => 'नया';

  @override
  String get statusAcknowledged => 'स्वीकृत';

  @override
  String get statusEscalated => 'एस्केलेट किया गया';

  @override
  String get statusCompleted => 'पूर्ण';

  @override
  String get openDashboardsButton => 'डैशबोर्ड खोलें';

  @override
  String ticketsTitle(String status) {
    return '$status टिकट';
  }

  @override
  String get ticketApiMappingPendingTitle => 'टिकट एपीआई मैपिंग लंबित है';

  @override
  String get ticketApiMappingPendingSubtitle =>
      '/list_tickets_feedback और /update_ticket को बनाए रखें';

  @override
  String get ticketLockRulesTitle => 'सिस्टम/पूर्ण टिकट लॉक नियम';

  @override
  String get ticketLockRulesSubtitle =>
      'स्थिति परिवर्तन, टिप्पणियां और अटैचमेंट अक्षम करें।';

  @override
  String get attachmentUploadSkeletonTitle => 'अटैचमेंट अपलोड संरचना';

  @override
  String get attachmentUploadSkeletonSubtitle =>
      'कैमरा/फाइल पिकर का उपयोग करें, फिर SAS URL पर अपलोड करें।';

  @override
  String get dashboardsTitle => 'डैशबोर्ड';

  @override
  String get washroomFootfallTitle => 'शौचालय फुटफॉल';

  @override
  String get negativeFeedbackHeatmapTitle => 'नकारात्मक प्रतिक्रिया हीटमैप';

  @override
  String get zoneLeadResponseResolutionTitle =>
      'ज़ोन लीड प्रतिक्रिया और समाधान';

  @override
  String get feedbackDeviceTitle => 'प्रतिक्रिया डिवाइस';

  @override
  String washroomLabel(String washroomId) {
    return 'शौचालय $washroomId';
  }

  @override
  String get goodFeedbackButton => 'अच्छा';

  @override
  String get needsAttentionButton => 'अच्छा नहीं';

  @override
  String get feedbackDeviceMigrationNote =>
      'QR, निष्क्रियता समय-सीमा, मौसम और प्रतिक्रिया कारण एपीआई MIGRATION_PLAN.md में मैप किए गए हैं।';

  @override
  String get feedbackNoWashroomError =>
      'इस प्रतिक्रिया डिवाइस के लिए कोई शौचालय उपलब्ध नहीं है।';

  @override
  String get feedbackSubmitFailedError =>
      'प्रतिक्रिया सबमिट नहीं हो सकी। कृपया फिर प्रयास करें।';

  @override
  String get feedbackSelectIssueError => 'कृपया कम से कम एक समस्या चुनें।';

  @override
  String get feedbackKioskLabel => 'प्रतिक्रिया कियोस्क';

  @override
  String get scanLabel => 'स्कैन करें';

  @override
  String get feedbackLanguageEnglish => 'EN';

  @override
  String get feedbackLanguageHindi => 'हिन्दी';

  @override
  String get languageSelectorTooltip => 'भाषा चुनें';

  @override
  String get switchToLightModeTooltip => 'लाइट मोड पर जाएं';

  @override
  String get switchToDarkModeTooltip => 'डार्क मोड पर जाएं';

  @override
  String get languageEnglish => 'अंग्रेज़ी';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get feedbackWelcomePrefix => 'आपका स्वागत है';

  @override
  String get feedbackAirportName => 'मुंबई अंतरराष्ट्रीय हवाई अड्डा';

  @override
  String get feedbackWelcomeSubtitle =>
      'आपकी प्रतिक्रिया हमें आपके लिए\nबेहतर अनुभव बनाने में मदद करती है।';

  @override
  String get feedbackShareFeedbackTitle => 'अपनी प्रतिक्रिया साझा करें';

  @override
  String get feedbackStartSubtitle => 'शुरू करने के लिए टैप करें';

  @override
  String get feedbackTapAnywhereSubtitle =>
      'शुरू करने के लिए स्क्रीन पर कहीं भी टैप करें';

  @override
  String get feedbackTemperatureUnavailable => '--°C';

  @override
  String get feedbackQrStartLabel => 'अपने फोन से स्कैन करें';

  @override
  String get feedbackQrStartSubtitle => 'स्क्रीन छूने की आवश्यकता नहीं है';

  @override
  String get feedbackQrDialogTitle => 'प्रतिक्रिया के लिए स्कैन करें';

  @override
  String get feedbackQrDialogMessage =>
      'शौचालय पर प्रतिक्रिया देने के लिए इस QR कोड को अपने फोन से स्कैन करें।';

  @override
  String get feedbackQrDialogCloseButton => 'बंद करें';

  @override
  String get feedbackVideoLabel => 'हवाई अड्डे के अनुभव का वीडियो';

  @override
  String get feedbackVideoUnavailable => 'वीडियो उपलब्ध नहीं है';

  @override
  String get feedbackVideoPlayTooltip => 'वीडियो चलाएं';

  @override
  String get feedbackVideoPauseTooltip => 'वीडियो रोकें';

  @override
  String get metricAqiLabel => 'AQI';

  @override
  String get metricOccupancyLabel => 'उपयोग';

  @override
  String get metricCubicleOccupancyLabel => 'क्यूबिकल उपयोग';

  @override
  String get metricFootfallLabel => 'फुटफॉल';

  @override
  String get metricOdourLabel => 'गंध';

  @override
  String get metricAqiStatusGood => 'अच्छा';

  @override
  String get metricOccupancyStatusLow => 'कम';

  @override
  String get metricFootfallStatusToday => 'आज';

  @override
  String get metricOdourStatusNeutral => 'सामान्य';

  @override
  String get feedbackInsightRealTimeTitle => 'रीयल-टाइम जानकारी';

  @override
  String get feedbackInsightRealTimeSubtitle =>
      'लाइव वातावरण मेट्रिक्स एक नज़र में';

  @override
  String get feedbackInsightCleanTitle => 'स्वच्छ और विशाल';

  @override
  String get feedbackInsightCleanSubtitle =>
      'सभी यात्रियों के लिए आरामदायक सुविधाएं';

  @override
  String get feedbackInsightAccessibleTitle => 'सुलभ';

  @override
  String get feedbackInsightAccessibleSubtitle => 'बहुभाषी और उपयोग में आसान';

  @override
  String get feedbackInsightVoiceTitle => 'आपकी राय महत्वपूर्ण है';

  @override
  String get feedbackInsightVoiceSubtitle =>
      'हर दिन बेहतर बनने में हमारी मदद करें';

  @override
  String get feedbackScreensaverTitle => 'शौचालय में आपका अनुभव कैसा रहा?';

  @override
  String get feedbackScreensaverFallback =>
      'अपनी प्रतिक्रिया साझा करने के लिए टैप करें';

  @override
  String get feedbackStartButton => 'प्रतिक्रिया देने के लिए टैप करें';

  @override
  String get feedbackChoiceSatisfiedTitle => 'अच्छा';

  @override
  String get feedbackChoiceSatisfiedSubtitle => 'मेरा अनुभव बहुत अच्छा रहा';

  @override
  String get feedbackChoiceNeedsAttentionSubtitle =>
      'कुछ ऐसा है जिसे हम बेहतर कर सकते हैं';

  @override
  String get feedbackChoiceTitle => 'आज आपका अनुभव कैसा रहा?';

  @override
  String get feedbackChoiceSubtitle => 'आपकी प्रतिक्रिया हमें आगे बढ़ाती है';

  @override
  String get feedbackCommentTitle => 'टिप्पणी जोड़ें';

  @override
  String get feedbackCommentHint =>
      'हमें बताएं कि किस पर ध्यान देने की आवश्यकता है';

  @override
  String get feedbackCommentSaveButton => 'टिप्पणी सहेजें';

  @override
  String get feedbackNegativeTitle =>
      'हमें खेद है कि आपका अनुभव अच्छा नहीं रहा।';

  @override
  String get feedbackNegativeSubtitle => 'कृपया अपनी समस्या चुनें।';

  @override
  String get feedbackNegativeHelper =>
      'लागू होने वाले सभी विकल्प चुनें और फिर सबमिट पर क्लिक करें।';

  @override
  String get feedbackAddCommentButton => 'टिप्पणी जोड़ें';

  @override
  String get feedbackEditCommentButton => 'टिप्पणी संपादित करें';

  @override
  String get feedbackCommentFieldPlaceholder => 'अतिरिक्त टिप्पणियां जोड़ें...';

  @override
  String get feedbackSubmitButton => 'प्रतिक्रिया सबमिट करें';

  @override
  String get feedbackEmptyReasonsMessage =>
      'इस स्थान के लिए कोई सक्रिय प्रतिक्रिया कारण कॉन्फ़िगर नहीं किया गया है।';

  @override
  String get feedbackThanksTitle => 'आपकी प्रतिक्रिया के लिए धन्यवाद';

  @override
  String get feedbackThanksPositiveSubtitle =>
      'हमें खुशी है कि आपका अनुभव आरामदायक रहा।';

  @override
  String get feedbackThanksNegativeSubtitle =>
      'हमारी सुविधा टीम को सूचित कर दिया गया है।';

  @override
  String get doneButton => 'पूर्ण';

  @override
  String get feedbackDeviceNotReadyTitle => 'प्रतिक्रिया डिवाइस तैयार नहीं है';

  @override
  String get retryButton => 'फिर प्रयास करें';

  @override
  String get ticketHistoryTitle => 'टिकट इतिहास';

  @override
  String lastLoginLabel(String value) {
    return 'लॉगिन $value';
  }

  @override
  String activeShiftLabel(String value) {
    return 'शिफ्ट $value';
  }

  @override
  String get ticketStatusCardsTitle => 'टिकट अवलोकन';

  @override
  String get viewHistoryButton => 'इतिहास देखें';

  @override
  String get passengerFlowTitle => 'यात्री प्रवाह';

  @override
  String get supervisedUnitsTitle => 'पर्यवेक्षित शौचालय';

  @override
  String get viewAllButton => 'सभी देखें';

  @override
  String ticketDeltaFromYesterday(String delta) {
    return 'कल से $delta';
  }

  @override
  String supervisedUnitsCount(int count) {
    return '$count इकाइयां';
  }

  @override
  String cubiclesCount(int count) {
    return '$count क्यूबिकल';
  }

  @override
  String get janitorScheduleTitle => 'सफाईकर्मी कार्यक्रम';

  @override
  String janitorsAssignedCount(int count) {
    return '$count नियुक्त';
  }

  @override
  String get emptyWashroomsMessage => 'कोई पर्यवेक्षित शौचालय नियुक्त नहीं है।';

  @override
  String get emptyScheduleMessage =>
      'इस अवधि के लिए सफाईकर्मी कार्यक्रम उपलब्ध नहीं है।';

  @override
  String get emptyPassengerFlowMessage =>
      'यात्री प्रवाह के अधिकतम आंकड़े उपलब्ध नहीं हैं।';

  @override
  String get supervisorTicketsLoadFailed => 'पर्यवेक्षक टिकट लोड नहीं हो सके।';

  @override
  String get supervisedUnitsLoadFailed => 'पर्यवेक्षित शौचालय लोड नहीं हो सके।';

  @override
  String get passengerFlowLoadFailed => 'यात्री प्रवाह लोड नहीं हो सका।';

  @override
  String get noWashroomsAssignedMessage =>
      'इस उपयोगकर्ता को कोई शौचालय नियुक्त नहीं है।';

  @override
  String passengerCount(int count) {
    return '$count यात्री';
  }

  @override
  String get washroomFallback => 'शौचालय';

  @override
  String get userTicketsTitle => 'उपयोगकर्ता टिकट';

  @override
  String get systemTicketsTitle => 'सिस्टम टिकट';

  @override
  String get noTicketsForFilterMessage =>
      'वर्तमान फिल्टर से कोई टिकट मेल नहीं खाता।';

  @override
  String get noSystemTicketsMessage =>
      'इस स्थिति से कोई सिस्टम टिकट मेल नहीं खाता।';

  @override
  String get ticketCategoryFallback => 'टिकट';

  @override
  String get priorityFallback => 'सामान्य';

  @override
  String get ticketSourceUser => 'उपयोगकर्ता';

  @override
  String get ticketSourceSystem => 'सिस्टम';

  @override
  String get ticketSourceUserReported => 'उपयोगकर्ता द्वारा रिपोर्ट';

  @override
  String get ticketSourceSystemGenerated => 'सिस्टम द्वारा जनरेट';

  @override
  String get filterTicketsTooltip => 'टिकट फ़िल्टर करें';

  @override
  String get acknowledgeButton => 'स्वीकार करें';

  @override
  String get ticketAcknowledgedMessage => 'टिकट स्वीकार कर लिया गया है।';

  @override
  String get ticketAcknowledgeFailed => 'टिकट स्वीकार नहीं किया जा सका।';

  @override
  String get ticketDetailLoadFailed => 'टिकट विवरण लोड नहीं हो सका।';

  @override
  String get ticketCategoryLabel => 'श्रेणी';

  @override
  String get priorityLabel => 'प्राथमिकता';

  @override
  String get reportedAtLabel => 'रिपोर्ट का समय';

  @override
  String get assignedToLabel => 'इन्हें नियुक्त';

  @override
  String get updateTicketTitle => 'टिकट अपडेट करें';

  @override
  String get statusLabel => 'स्थिति';

  @override
  String get commentLabel => 'टिप्पणी';

  @override
  String get ticketCommentHint => 'टीम के लिए संक्षिप्त अपडेट जोड़ें';

  @override
  String get cameraButton => 'कैमरा';

  @override
  String get galleryButton => 'गैलरी';

  @override
  String get removeAttachmentTooltip => 'अटैचमेंट हटाएं';

  @override
  String get updateTicketButton => 'टिकट अपडेट करें';

  @override
  String get systemTicketLockedTitle => 'सिस्टम टिकट लॉक है';

  @override
  String get completedTicketLockedTitle => 'पूर्ण टिकट लॉक है';

  @override
  String get ticketLockedSubtitle =>
      'स्थिति परिवर्तन, टिप्पणियां और अटैचमेंट अक्षम हैं।';

  @override
  String get attachmentsTitle => 'अटैचमेंट';

  @override
  String get noAttachmentsMessage => 'कोई अटैचमेंट नहीं जोड़ा गया है।';

  @override
  String get ticketTimelineTitle => 'टिकट समयरेखा';

  @override
  String get emptyTicketTimelineMessage => 'कोई टिकट अपडेट उपलब्ध नहीं है।';

  @override
  String get attachmentPickFailed => 'चुना गया अटैचमेंट जोड़ा नहीं जा सका।';

  @override
  String get ticketUpdatedMessage => 'टिकट अपडेट कर दिया गया है।';

  @override
  String get ticketUpdateFailed => 'टिकट अपडेट नहीं किया जा सका।';

  @override
  String get exportCsvTooltip => 'CSV निर्यात करें';

  @override
  String get exportCsvButton => 'CSV निर्यात करें';

  @override
  String get ticketHistoryLoadFailed => 'टिकट इतिहास लोड नहीं हो सका।';

  @override
  String ticketHistoryResults(int count) {
    return '$count परिणाम';
  }

  @override
  String get historyFromLabel => 'से';

  @override
  String get historyToLabel => 'तक';

  @override
  String fromDateLabel(String date) {
    return '$date से';
  }

  @override
  String toDateLabel(String date) {
    return '$date तक';
  }

  @override
  String get allStatusesLabel => 'सभी';

  @override
  String get ticketSourceLabel => 'स्रोत';

  @override
  String get allSourcesLabel => 'सभी';

  @override
  String get allWashroomsLabel => 'सभी शौचालय';

  @override
  String get fromDateAfterToDateMessage =>
      'आरंभ तिथि अंतिम तिथि के बाद नहीं हो सकती।';

  @override
  String get toDateBeforeFromDateMessage =>
      'अंतिम तिथि आरंभ तिथि से पहले नहीं हो सकती।';

  @override
  String get noTicketsToExportMessage =>
      'निर्यात के लिए कोई टिकट उपलब्ध नहीं है।';

  @override
  String get ticketHistoryExportText => 'स्मार्ट वॉशरूम से CSV निर्यात';

  @override
  String get ticketHistoryExportFailed =>
      'टिकट इतिहास निर्यात नहीं किया जा सका।';

  @override
  String get notificationsTitle => 'सूचनाएं';

  @override
  String get notificationsEmptyMessage => 'अभी कोई सूचना नहीं है।';

  @override
  String get markAllReadTooltip => 'सभी को पढ़ा हुआ चिह्नित करें';

  @override
  String get clearNotificationsTooltip => 'सभी हटाएं';

  @override
  String get notificationTicketAssignedTitle => 'नया टिकट सौंपा गया';

  @override
  String notificationTicketAssignedBody(String ticketId, String washroomId) {
    return 'टिकट $ticketId को $washroomId पर आपके ध्यान की आवश्यकता है।';
  }

  @override
  String get notificationTicketEscalatedTitle => 'टिकट बढ़ाया गया';

  @override
  String notificationTicketEscalatedBody(String ticketId, String washroomId) {
    return '$washroomId पर टिकट $ticketId को बढ़ा दिया गया है।';
  }

  @override
  String get notificationTicketAcknowledgedTitle => 'टिकट स्वीकृत';

  @override
  String notificationTicketAcknowledgedBody(String ticketId) {
    return 'टिकट $ticketId स्वीकार कर लिया गया है।';
  }

  @override
  String get notificationTicketCompletedTitle => 'टिकट पूर्ण हुआ';

  @override
  String notificationTicketCompletedBody(String ticketId) {
    return 'टिकट $ticketId पूरा हो गया है।';
  }

  @override
  String get notificationFeedbackNegativeTitle =>
      'नकारात्मक प्रतिक्रिया प्राप्त हुई';

  @override
  String notificationFeedbackNegativeBody(String washroomId) {
    return 'एक यात्री ने $washroomId पर समस्या की सूचना दी है।';
  }

  @override
  String get notificationShiftReminderTitle => 'शिफ्ट अनुस्मारक';

  @override
  String notificationShiftReminderBody(String shiftLabel) {
    return 'आपकी शिफ्ट $shiftLabel शुरू होने वाली है।';
  }

  @override
  String get notificationGeneralTitle => 'नई सूचना';

  @override
  String get notificationGeneralBody => 'आपके लिए एक नया अपडेट है।';
}
