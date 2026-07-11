# 4CT Washroom Ops

Multi-tenant Flutter rebuild of the existing Ionic/Capacitor washroom operations app.

## Product Identity

- App name: `4CT Washroom Ops`
- Android application ID: `com.fourct.washroomops`
- iOS bundle ID: `com.fourct.washroomops`
- Product model: one shared 4CT platform for multiple tenants, airports, terminals, zones, and washrooms.
- ADANI/BIAL/JAI are treated as tenant/customer data, not app-specific logic.

## Stack

- Flutter stable, Material 3
- Feature-first clean architecture
- Riverpod for dependency injection and state
- go_router for routing and auth redirects
- Dio with auth and tenant interceptors
- flutter_secure_storage for session/token data
- shared_preferences for non-secret cached tenant branding
- OneSignal isolated in `NotificationService`
- Freezed/json_serializable/build_runner installed for generated immutable DTOs as modules are filled in

## Structure

```text
lib/
  app/
    app.dart
    router/
    theme/
  core/
    config/
    errors/
    logging/
    network/
    storage/
  features/
    auth/
    dashboard/
    feedback/
    notifications/
    operations/
    tenant/
  shared/
    widgets/
```

## Configuration

Environment config is centralized in `EnvironmentConfig` and read from Dart defines.

```sh
flutter run --flavor dev --dart-define=FLAVOR=dev
flutter run --flavor qa --dart-define=FLAVOR=qa
flutter run --flavor prod --dart-define=FLAVOR=prod
```

Optional defines:

```sh
--dart-define=API_BASE_URL=https://example.com/api/v1
--dart-define=TENANT_SLUG=tenant-slug
--dart-define=ONESIGNAL_APP_ID=your-app-id
--dart-define=ENABLE_NETWORK_LOGGING=false
```

Android flavors are configured in `android/app/build.gradle.kts`.
Prod uses `com.fourct.washroomops`; dev and qa add `.dev` and `.qa` suffixes so they can be installed alongside prod. iOS currently uses the prod bundle ID and should get separate Xcode schemes before store/TestFlight distribution.

## Implemented Skeleton

- OTP auth repository for `/auth/request-otp` and `/auth/verify-otp`
- JWT-backed session parsing with access and refresh token persistence
- 401 refresh retry through `/auth/refresh`
- Secure session persistence and restore
- Role-based route redirect:
  - `Feedback-device` -> feedback device flow
  - `Zone-lead` / `Shift-Incharge` -> operations flow
- Tenant context provider with tenant/airport/washroom IDs
- Cached dynamic branding from `/tenants/branding/:slug` before auth when `TENANT_SLUG` is configured
- Authenticated branding refresh from `/tenants/me` after login
- Dio interceptor for `Authorization`, `X-Tenant-Id`, `X-Location-Id`, `X-Airport-Id`, `X-Terminal-Id`, and `X-Zone-Id`
- OneSignal initialization service with foreground/open handling hooks
- Placeholder operations, ticket, dashboard, and feedback screens ready for API-backed modules

## Verification

```sh
flutter pub get
flutter analyze
flutter test
```
