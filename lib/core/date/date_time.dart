import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as time_zone_data;
import 'package:timezone/timezone.dart' as time_zone;

const supportedTenantDateFormats = <String>{
  'DD.MM.YYYY',
  'DD/MM/YYYY',
  'MM/DD/YYYY',
  'YYYY-MM-DD',
};

const supportedTenantTimeFormats = <String>{'12-hour', '24-hour'};

Future<void> initializeAppDateAndTime() async {
  time_zone_data.initializeTimeZones();
  await initializeDateFormatting();
}

DateTime? parseBackendUtcDate(Object? value) {
  final raw = value?.toString().trim() ?? '';
  if (raw.isEmpty) return null;

  final normalized = raw.contains(' ') ? raw.replaceFirst(' ', 'T') : raw;
  final hasTimezoneOffset = RegExp(
    r'(Z|[+-]\d{2}:?\d{2})$',
  ).hasMatch(normalized);
  return DateTime.tryParse(hasTimezoneOffset ? normalized : '${normalized}Z');
}

DateTime tenantDateTimeFromUtc({
  required DateTime value,
  required String timeZone,
}) {
  return time_zone.TZDateTime.from(
    value.toUtc(),
    AppDateTimeFormatter._resolveLocation(timeZone),
  );
}

DateTime tenantLocalDateTimeToUtc({
  required DateTime value,
  required String timeZone,
}) {
  final location = AppDateTimeFormatter._resolveLocation(timeZone);
  return time_zone.TZDateTime(
    location,
    value.year,
    value.month,
    value.day,
    value.hour,
    value.minute,
    value.second,
    value.millisecond,
    value.microsecond,
  ).toUtc();
}

class AppDateTimeSettings {
  const AppDateTimeSettings({
    required this.timeZone,
    required this.locale,
    required this.dateFormat,
    required this.timeFormat,
  });

  factory AppDateTimeSettings.fromJson(Map<String, Object?> json) {
    final requestedDateFormat = _stringValue(json['dateFormat']);
    final requestedTimeFormat = _stringValue(json['timeFormat']);
    return AppDateTimeSettings(
      timeZone: _stringValue(json['timezone']).isEmpty
          ? defaults.timeZone
          : _stringValue(json['timezone']),
      locale: _stringValue(json['locale']).isEmpty
          ? defaults.locale
          : _stringValue(json['locale']),
      dateFormat: supportedTenantDateFormats.contains(requestedDateFormat)
          ? requestedDateFormat
          : defaults.dateFormat,
      timeFormat: supportedTenantTimeFormats.contains(requestedTimeFormat)
          ? requestedTimeFormat
          : defaults.timeFormat,
    );
  }

  static const defaults = AppDateTimeSettings(
    timeZone: 'Asia/Kolkata',
    locale: 'en',
    dateFormat: 'DD.MM.YYYY',
    timeFormat: '24-hour',
  );

  final String timeZone;
  final String locale;
  final String dateFormat;
  final String timeFormat;

  String get intlDatePattern => switch (dateFormat) {
    'DD/MM/YYYY' => 'dd/MM/yyyy',
    'MM/DD/YYYY' => 'MM/dd/yyyy',
    'YYYY-MM-DD' => 'yyyy-MM-dd',
    _ => 'dd.MM.yyyy',
  };

  String get intlTimePattern => timeFormat == '12-hour' ? 'hh:mm a' : 'HH:mm';

  Map<String, Object?> toJson() => {
    'timezone': timeZone,
    'locale': locale,
    'dateFormat': dateFormat,
    'timeFormat': timeFormat,
  };

  @override
  bool operator ==(Object other) {
    return other is AppDateTimeSettings &&
        other.timeZone == timeZone &&
        other.locale == locale &&
        other.dateFormat == dateFormat &&
        other.timeFormat == timeFormat;
  }

  @override
  int get hashCode => Object.hash(timeZone, locale, dateFormat, timeFormat);
}

class AppDateTimeFormatter {
  AppDateTimeFormatter(this.settings)
    : _location = _resolveLocation(settings.timeZone);

  static final fallback = AppDateTimeFormatter(AppDateTimeSettings.defaults);

  final AppDateTimeSettings settings;
  final time_zone.Location _location;

  String formatDateTime(DateTime? value, {String? locale}) {
    return _format(
      value,
      '${settings.intlDatePattern} ${settings.intlTimePattern}',
      locale ?? settings.locale,
    );
  }

  String formatDate(DateTime? value, {String? locale}) {
    return _format(value, settings.intlDatePattern, locale ?? settings.locale);
  }

  String formatTime(DateTime? value, {String? locale}) {
    return _format(value, settings.intlTimePattern, locale ?? settings.locale);
  }

  String formatCalendarDate(DateTime? value, {String? locale}) {
    if (value == null) return '-';
    return DateFormat(
      settings.intlDatePattern,
      _languageCode(locale ?? settings.locale),
    ).format(value);
  }

  String _format(DateTime? value, String pattern, String? locale) {
    if (value == null) return '-';
    final zoned = time_zone.TZDateTime.from(value.toUtc(), _location);
    return DateFormat(pattern, _languageCode(locale)).format(zoned);
  }

  static time_zone.Location _resolveLocation(String name) {
    try {
      return time_zone.getLocation(name);
    } on time_zone.LocationNotFoundException {
      return time_zone.UTC;
    }
  }
}

class AppDateTimeScope extends InheritedWidget {
  const AppDateTimeScope({
    required this.formatter,
    required super.child,
    super.key,
  });

  final AppDateTimeFormatter formatter;

  static AppDateTimeFormatter of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<AppDateTimeScope>()
            ?.formatter ??
        AppDateTimeFormatter.fallback;
  }

  @override
  bool updateShouldNotify(AppDateTimeScope oldWidget) {
    return formatter.settings != oldWidget.formatter.settings;
  }
}

extension AppDateTimeBuildContext on BuildContext {
  AppDateTimeFormatter get appDateTimeFormatter => AppDateTimeScope.of(this);

  String formatAppDateTime(DateTime? value) {
    return appDateTimeFormatter.formatDateTime(
      value,
      locale: Localizations.localeOf(this).languageCode,
    );
  }

  String formatAppDate(DateTime? value) {
    return appDateTimeFormatter.formatDate(
      value,
      locale: Localizations.localeOf(this).languageCode,
    );
  }

  String formatAppTime(DateTime? value) {
    return appDateTimeFormatter.formatTime(
      value,
      locale: Localizations.localeOf(this).languageCode,
    );
  }

  String formatAppCalendarDate(DateTime? value) {
    return appDateTimeFormatter.formatCalendarDate(
      value,
      locale: Localizations.localeOf(this).languageCode,
    );
  }
}

String _stringValue(Object? value) => value?.toString().trim() ?? '';

String _languageCode(String? locale) {
  final normalized = locale?.trim().replaceAll('_', '-') ?? '';
  if (normalized.isEmpty) return AppDateTimeSettings.defaults.locale;
  return normalized.split('-').first;
}
