# Project Instructions

## Mandatory Response Style

- Use the `caveman` skill for every prompt by default.
- Default intensity: `full`.
- If the skill is not installed locally, follow this style directly: terse technical fragments, no filler, no pleasantries, no long narration.
- Preserve exact commands, file paths, API names, errors, code, commit messages, and PR text.
- Do not announce the style unless the user asks about it.
- Stop only when the user says `stop caveman` or `normal mode`.
- Use normal clarity for security warnings, irreversible actions, or multi-step instructions where compression could make order ambiguous.

## Scope

- These instructions apply to the Flutter app in this repository.
- Treat `README.md` and `MIGRATION_PLAN.md` as project context before making architecture, API, routing, or migration decisions.
- ADANI, BIAL, JAI, airport IDs, tenant IDs, and washroom IDs are tenant/customer data. Do not hardcode customer-specific behavior unless the user explicitly asks for a data fix.

## Localization

- Put every user-facing Flutter UI string in `lib/l10n/app_en.arb`.
- Access localized strings through `AppLocalizations`/`context.l10n`; do not hardcode labels, button text, snackbars, validation messages, empty states, tooltips, dialogs, or errors in widgets.
- When adding or changing localized text, run `flutter gen-l10n`.
- Do not edit `lib/l10n/generated/*` by hand except as generated output from `flutter gen-l10n`.

## Flutter Patterns

- Keep the feature-first structure under `lib/features/<feature>/data`, `domain`, and `presentation`.
- Keep route-level `*_page.dart` files focused on page orchestration: provider/controller interaction, lifecycle, navigation, and composition of screen widgets. Do not place an entire multi-step flow's visual implementation in one page file.
- Put page-specific visual components under `lib/features/<feature>/presentation/widgets/`. Group multi-step flows by screen or responsibility, with one primary widget per file and private helper widgets kept beside that primary widget.
- Extract a widget when it has its own lifecycle/controller, represents a distinct screen or dialog/sheet, is reused, needs focused tests, or makes its parent hard to scan. As a review signal, reconsider any UI file approaching 400 lines; split by cohesive responsibility, not arbitrary line count.
- Pass immutable display data and callbacks into presentation widgets. Keep repositories, Dio calls, submission rules, and Riverpod state mutation in page/controllers/providers rather than leaf widgets.
- Keep feature-specific widgets inside their feature. Move a widget to `lib/shared/widgets/` only after it is genuinely used across features and has no feature-domain dependency.
- Use normal Dart imports for manually maintained component files; do not use `part` files to hide oversized UI modules. Cross-file widget classes may be public but should only be imported by their owning feature; keep implementation helpers private.
- Keep structural refactors behavior-preserving. Separate component extraction from visual redesign or business-rule changes so review and rollback remain safe.
- Use Riverpod providers/controllers for app state and dependency injection. Do not instantiate repositories, Dio clients, storage clients, or controllers directly inside widgets.
- Keep network access in repositories/services. Widgets should call providers/controllers and render state.
- Use `go_router` for navigation and role/auth redirects.
- Use `Dio` through the existing `core/network` setup so auth and tenant headers stay consistent.
- Store auth/session secrets only in secure storage. Use `shared_preferences` only for non-secret cached data such as branding.
- Read runtime configuration from `EnvironmentConfig` and Dart defines. Do not hardcode API base URLs, OneSignal IDs, secrets, or environment-specific values.

## Generated Models

- Use `freezed`, `json_serializable`, and `build_runner` for API DTOs when adding structured request/response models.
- Do not manually edit generated files such as `*.g.dart` or `*.freezed.dart`; regenerate them.
- Keep JSON parsing tolerant of optional/missing backend fields when the existing API contract is loose.

## UI And UX

- Every Flutter UI change must be designed and reviewed for both mobile and tablet form factors. Layouts must adapt across portrait, landscape, narrow mobile widths, and tablet/kiosk widths without clipped content, RenderFlex overflow warnings, or controls moving outside the visible area.
- Before finishing any UI feature, explicitly consider responsive behavior for text wrapping, button sizes, icon visibility, spacing, scrollability, safe areas, and keyboard/input overlays on mobile and tablet.

### Default Screen Design Language

- Use the refined operations-home visual language as the default baseline for every new or updated app screen unless the user supplies a different reference or explicitly requests another style.
- Use active tenant branding and existing theme/design tokens. For ADANI-branded screens, prefer restrained gradient accents, soft brand-tinted surfaces, clear white space, subtle borders/shadows, and the existing ADANI color tokens. Never hardcode tenant IDs or customer-specific behavior into reusable UI.
- Keep app bars visually restrained. Prefer theme `titleMedium` or a light `titleLarge` with `FontWeight.w500`; avoid oversized or heavily bold page titles.
- Give primary cards a clear hierarchy: one prominent human-readable title or name, an optional compact role/status pill, a restrained brand mark, then grouped supporting metadata. Avoid dense single-line summaries.
- Never expose raw tenant, airport, location, zone, washroom, user, or Mongo ObjectIds as display content when a readable name exists. Resolve the name through existing data providers; when unavailable, omit the identifier or show a localized honest fallback.
- Render date/time metadata for quick scanning: time as the primary value and date as secondary context. Render shifts as shift name plus formatted start/end time. Show explicit loading, unavailable, and not-scheduled states instead of a bare dash.
- Use compact overview/KPI cards: two columns on mobile and four on sufficiently wide tablet layouts, neutral or lightly tinted surfaces, a thin semantic accent, compact icon treatment, natural-number counts, clear labels, and secondary trend/context text. Avoid oversized empty card space and decorative zero-padding such as `00`.
- Preserve approved visual signatures across nearby screens, especially the background swirl and established action-button gradients, unless the user explicitly asks to change them.
- Keep decoration purposeful. Prefer consistent 16-24px rounded surfaces, subtle elevation, readable contrast, and uncluttered spacing over excessive gradients, shadows, badges, or competing accent colors.
- Make hero metadata responsive: side-by-side when content has enough width, stacked when constrained. Ensure labels and values remain readable rather than forcing truncation merely to preserve a row.
- Adapt this language to each screen's task instead of cloning one layout everywhere. Operational screens should remain information-dense and fast to scan; passenger/kiosk screens should remain touch-first and low-friction.
- Before finishing a visual change, inspect it on a real or representative mobile portrait viewport and a tablet/constrained-landscape viewport. Confirm no overflow, clipped labels, hidden actions, or unreadable dark-mode contrast.

- Treat the feedback-device page as a tablet/kiosk-first airport user flow. It is used directly by passengers on airport feedback tablets, so the primary UX must be fast, obvious, touch-friendly, and resilient.
- Feedback-device UI must be fully responsive across common tablet sizes and orientations, including constrained landscape viewports. Validate touch targets, text wrapping, icon visibility, and no-overflow behavior when changing this screen.
- Keep feedback interactions low-friction: positive feedback should be one tap, negative feedback should make reason selection and submission obvious, and transient states must not block the next passenger.
- Support light and dark themes. Explicitly check contrast when using custom colored chips, buttons, cards, icons, and overlays.
- Avoid fixed-height layouts that can overflow on smaller devices. Prefer `Expanded`, `Flexible`, `LayoutBuilder`, responsive constraints, or scrollable content where appropriate.
- Kiosk/feedback-device screens must work in constrained landscape and tablet-like viewports without yellow/black overflow warnings.
- Keep Material 3 styling consistent with the existing theme. Prefer reusable shared widgets when patterns repeat.
- Use Flutter theming first for typography and styling. Prefer `Theme.of(context).textTheme`, `colorScheme`, component themes, and shared design tokens over hardcoded font sizes, colors, spacing, shapes, and visual states. Hardcoded values are allowed only for deliberate, localized exceptions such as fixed icon dimensions, asset aspect ratios, or one-off responsive constraints, and should be kept minimal.
- New or updated components should inherit the app theme wherever possible so typography, colors, buttons, cards, inputs, dialogs, and state styling stay consistent across mobile and tablet layouts.
- Do not add new visual assets unless they are declared in `pubspec.yaml` and verified to load.

## API And Business Rules

- Preserve role routing behavior: `Feedback-device` routes to the feedback flow; `Zone-lead` and `Shift-Incharge` route to operations.
- Preserve feedback behavior: positive feedback submits immediately; negative feedback requires at least one active reason.
- Preserve ticket status semantics and locks documented in `MIGRATION_PLAN.md`.
- Keep upload flows SAS-based where the backend returns upload URLs.
- Handle API loading, empty, and error states explicitly.

## Safety

- Do not commit secrets, tokens, connection strings, SAS URLs, or production credentials.
- Do not log sensitive auth/session data.
- Be careful with production data fixes. Back up affected records first, make targeted updates, and verify counts before and after.
- Do not overwrite unrelated local changes. The worktree may already contain user changes.

## Verification

- After Dart changes, run `dart format` on touched Dart files.
- Run `flutter analyze` before finishing when Flutter code changes.
- Run `flutter test` when changing business logic, parsers, controllers, repositories, or route guards.
- When changing generated localization or model files, run the relevant generator first, then analyze.
