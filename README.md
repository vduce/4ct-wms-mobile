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

Per-flavor config lives in `env/*.env` (dotenv format) and is loaded with Flutter's
built-in `--dart-define-from-file` flag. Edit the file to configure a flavor:

```sh
# .vscode/launch.json already wires these up for F5 debugging.
flutter run --flavor dev  --dart-define-from-file=env/dev.env
flutter run --flavor qa   --dart-define-from-file=env/qa.env
flutter run --flavor prod --dart-define-from-file=env/prod.env

# Production scripts:
./scripts/run-prod.sh
./scripts/build-prod-android.sh
```

Env files hold these keys (all become `String.fromEnvironment`/`bool.fromEnvironment`
constants):

```sh
FLAVOR=prod
TENANT_SLUG=mial
API_BASE_URL=https://api.wms-prod.smartdigibuild.net/api/v1
PORTAL_BASE_URL=https://mial.smartdigibuild.net
FEEDBACK_WEB_URL="https://mial.smartdigibuild.net/#/auth/feedback" # optional (quote values containing #)
FEEDBACK_VIDEO_URL=...                                             # optional
ONESIGNAL_APP_ID=your-one-signal-app-id                            # required for push
ENABLE_NETWORK_LOGGING=false
```

Individual `--dart-define=KEY=VALUE` args (or `KEY=VALUE ./scripts/run-prod.sh`)
override the file, e.g.:

```sh
flutter run --flavor dev --dart-define-from-file=env/dev.env \
  --dart-define=API_BASE_URL=http://localhost:9000/api/v1
```

PROD defaults to `https://api.wms-prod.smartdigibuild.net/api/v1` and
`https://mial.smartdigibuild.net` when `FLAVOR=prod`.

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
