import 'package:flutter_test/flutter_test.dart';
import 'package:washroom_ops/features/feedback/domain/public_feedback_url.dart';

void main() {
  group('buildPublicFeedbackUrl', () {
    const washroomId = '507f1f77bcf86cd799439011';

    test('builds the scoped portal route and removes legacy URL data', () {
      final result = buildPublicFeedbackUrl(
        baseUrl:
            'https://portal.example.com/#/auth/feedback?tenantId=tenant&userId=user',
        washroomId: washroomId,
      );

      expect(result, 'https://portal.example.com/feedback/$washroomId');
    });

    test('preserves a configured portal port', () {
      final result = buildPublicFeedbackUrl(
        baseUrl: 'http://localhost:3000/legacy',
        washroomId: washroomId,
      );

      expect(result, 'http://localhost:3000/feedback/$washroomId');
    });

    test('rejects an invalid washroom identifier', () {
      final result = buildPublicFeedbackUrl(
        baseUrl: 'https://portal.example.com',
        washroomId: 'not-a-washroom',
      );

      expect(result, isNull);
    });

    test('rejects a non-http portal URL', () {
      final result = buildPublicFeedbackUrl(
        baseUrl: 'javascript:alert(1)',
        washroomId: washroomId,
      );

      expect(result, isNull);
    });
  });
}
