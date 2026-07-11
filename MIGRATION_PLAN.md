# Migration Plan

## Phase 1: Ionic App Findings

### Feature List

- OTP sign-in and session restore
- Role routing for `Feedback-device`, `Zone-lead`, and `Shift-Incharge`
- Feedback-device screensaver with washroom metrics, QR URL, and idle tap navigation
- Positive feedback submission
- Negative feedback reasons and submission
- Supervisor home dashboard with ticket counters, supervised washrooms, janitor roster, and passenger peak flow
- Ticket list grouped by status and user/system source
- Ticket detail with status updates, comments, camera/file attachments, and SAS URL upload
- Ticket history with date/status/source/washroom filters and CSV export/share
- Profile and password reset
- Dashboards for footfall, negative feedback heatmap, and zone-lead response/resolution time
- Capacitor push token registration

### User Journeys

- User enters username/email, requests OTP, verifies OTP, then lands by role.
- Feedback device opens landscape screensaver, polls washroom metrics, shows QR, and taps through to feedback.
- Positive feedback posts immediately; negative feedback loads active reasons, requires at least one reason, then posts.
- Supervisor opens home, sees ticket counts and daily roster data, drills into ticket status lists.
- Pending user tickets can be acknowledged quickly; system or completed tickets are locked.
- Ticket update can include generated attachment names and upload blobs to returned SAS URLs.
- Ticket history can be filtered by date/status/source/washroom and exported to CSV.

### API Usage Summary

- Base URL in Ionic: `https://fourcorners-washroom-bial-prod.azurewebsites.net/api`
- `POST /otp_generator`
- `POST /check_otp`
- `POST /update_push_notification_token`
- `PUT /update_password`
- `GET /webapp/profile`
- `POST /login` for feedback-device logout re-auth
- `GET /user_screensaver_page`
- `GET /list_feedback_reasons`
- `POST /create_feedback`
- `GET /get_washroom`
- `GET /get_day_roster_by_washrooms`
- `POST /peak_footfall`
- `GET /list_tickets_feedback`
- `GET /get_ticket_by_id`
- `PUT /update_ticket`
- `GET /dashboard_washroom_occupancy`
- `GET /negative_feedback_count_by_hour`
- `GET /dashboard_admin`
- External: OpenWeather fetch is hardcoded in Ionic and should move to backend/config if still required.

### Auth And Session Flow

- Ionic stores `authToken`, `user_id`, `tenant_id`, `airport_id`, `username`, `role`, `email`, `lastLogin`, `washroomIds`, and `webappUrl`.
- Flutter stores secrets and session identifiers in secure storage.
- New WMS API auth uses `/auth/request-otp`, `/auth/verify-otp`, `/auth/login-password`, and `/auth/refresh`.
- Flutter now stores both access and refresh tokens and parses user/role/tenant/location/washroom scope from the JWT payload.
- Role support found: `Feedback-device`, `Zone-lead`, `Shift-Incharge`.

### Tenant/Airport Flow

- Login response provides tenant and airport IDs.
- Washrooms are scoped from `washroomIds`.
- No tenant discovery, airport selection, terminal selection, zone selection, or branding API exists in the Ionic mobile code.
- Flutter can resolve pre-auth tenant branding from `/tenants/branding/:slug` when `TENANT_SLUG` is configured.
- Flutter refreshes authenticated tenant branding from the new `/tenants/me` API and caches it locally.

### Storage Usage

- Ionic uses browser `localStorage`.
- Flutter uses `flutter_secure_storage` for auth/session and `shared_preferences` for cached non-secret branding.

### Native Plugin Usage

- Capacitor Push Notifications
- Camera
- Filesystem
- Share
- Screen Orientation
- Browser/Haptics/Keyboard/Status Bar dependencies are present; direct usage is limited in inspected code.

### Push Notification Usage

- Ionic registers with Capacitor Push Notifications, stores `NotiToken`, and sends it to `/update_push_notification_token`.
- Flutter uses OneSignal through `NotificationService`; App ID comes from environment config.

### Business Rules And Validations

- OTP must be 6 digits.
- OTP resend has 60 second cooldown and max 3 attempts in Ionic.
- Password update requires all fields, new password length >= 8, confirmation match, and new password different from old.
- Feedback requires user ID and washroom ID.
- Negative feedback requires at least one reason and filters inactive reasons.
- Ticket statuses normalize `Pending`, `Acknowledge`, `Escalated`, `Completed`; history also maps approval/closed values to completed.
- User-generated pending tickets can be acknowledged from list.
- System-generated and completed tickets are locked for actions.
- Attachments are named `attachment_<timestamp>.<ext>`.
- Date ranges are built at local day boundaries and sent as ISO strings.

### Risks And TBDs

- Tenant configuration endpoint is not present in Ionic mobile code.
- Refresh token contract is unknown.
- Exact terminal/zone hierarchy endpoints are not present in mobile code.
- Weather API key/location are hardcoded in Ionic; this should not ship in Flutter.
- iOS dev/qa/prod schemes and bundle suffixes are not yet created.
- Existing backend appears airport-specific by URL; multi-tenant base URL strategy needs backend confirmation.

## Phase 2: Target Flutter Architecture

### Recommended Packages

- `flutter_riverpod`: app/session/tenant state and dependency injection
- `riverpod_generator`: generated providers where useful
- `go_router`: declarative routing and auth redirects
- `dio`: API client and interceptors
- `freezed_annotation`, `json_annotation`, `build_runner`, `freezed`, `json_serializable`: immutable DTOs and API JSON models
- `flutter_secure_storage`: auth/session secrets
- `shared_preferences`: cached branding/config fallback
- `onesignal_flutter`: push notifications
- `image_picker`: ticket photo capture; general file picking is TBD because current `file_picker` and `share_plus` constraints conflict
- `path_provider`, `share_plus`: ticket CSV export/share
- `permission_handler`: native permission flows
- `connectivity_plus`: future offline-aware sync decisions
- `logger`: structured local logging

### Architecture

- `core/config`: flavor and environment config
- `core/network`: Dio, interceptors, API errors
- `core/storage`: secure storage and cache abstractions
- `features/auth`: OTP, session, password reset
- `features/tenant`: tenant context, branding, feature flags
- `features/operations`: washroom hierarchy, roster, tickets
- `features/feedback`: feedback device, reasons, submissions
- `features/dashboard`: chart data modules
- `features/notifications`: OneSignal service and deep-link routing

### Migration Strategy

1. Keep current scaffold compiling and route-complete.
2. Add generated DTOs per backend endpoint, one feature at a time.
3. Implement auth/session fully, then feedback-device flow because it is role-critical.
4. Implement supervisor home and ticket list/detail next, including attachment upload.
5. Add dashboard modules after core operations are stable.
6. Replace hardcoded tenant assumptions with backend tenant config once available.
7. Add widget/unit tests around validators, session restore, route redirects, and ticket status rules.
