import 'package:flutter_test/flutter_test.dart';

import 'package:washroom_ops/core/date/date_time.dart';

void main() {
  setUpAll(initializeAppDateAndTime);

  test('parses UTC backend timestamps and preserves the instant', () {
    final value = parseBackendUtcDate('2026-08-14T12:30:00.000Z');

    expect(value?.toUtc(), DateTime.utc(2026, 8, 14, 12, 30));
  });

  test('formats an instant with configured date, time, and IANA timezone', () {
    final formatter = AppDateTimeFormatter(
      const AppDateTimeSettings(
        timeZone: 'Asia/Kolkata',
        locale: 'en-IN',
        dateFormat: 'DD.MM.YYYY',
        timeFormat: '24-hour',
      ),
    );

    expect(
      formatter.formatDateTime(DateTime.utc(2026, 8, 14, 12, 30)),
      '14.08.2026 18:00',
    );
  });

  test('maps supported 12-hour backend settings to an intl pattern', () {
    final settings = AppDateTimeSettings.fromJson({
      'timezone': 'UTC',
      'locale': 'en',
      'dateFormat': 'MM/DD/YYYY',
      'timeFormat': '12-hour',
    });
    final formatter = AppDateTimeFormatter(settings);

    expect(
      formatter.formatDateTime(DateTime.utc(2026, 8, 14, 7, 5)),
      '08/14/2026 07:05 AM',
    );
  });

  test('falls back for unsupported patterns and invalid timezones', () {
    final settings = AppDateTimeSettings.fromJson({
      'timezone': 'Invalid/Timezone',
      'dateFormat': 'free-form',
      'timeFormat': 'seconds-since-midnight',
    });
    final formatter = AppDateTimeFormatter(settings);

    expect(settings.dateFormat, 'DD.MM.YYYY');
    expect(settings.timeFormat, '24-hour');
    expect(
      formatter.formatDateTime(DateTime.utc(2026, 8, 14, 12, 30)),
      '14.08.2026 12:30',
    );
  });

  test('returns a placeholder for missing or invalid backend timestamps', () {
    expect(parseBackendUtcDate('not-a-date'), isNull);
    expect(AppDateTimeFormatter.fallback.formatDateTime(null), '-');
  });
}
