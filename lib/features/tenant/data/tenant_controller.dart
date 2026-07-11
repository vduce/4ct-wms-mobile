import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/environment_config.dart';
import '../domain/tenant_models.dart';
import 'tenant_repository.dart';

final tenantControllerProvider =
    NotifierProvider<TenantController, TenantState>(TenantController.new);

final activeTenantProvider = Provider<TenantContext?>(
  (ref) => ref.watch(tenantControllerProvider).context,
);

class TenantController extends Notifier<TenantState> {
  @override
  TenantState build() => TenantState.initial();

  Future<void> restoreCachedBranding() async {
    final repository = ref.read(tenantRepositoryProvider);
    final cached = await repository.readCachedBranding();
    if (cached != null) {
      state = state.copyWith(branding: cached);
    }

    final tenantSlug = ref.read(environmentConfigProvider).tenantSlug.trim();
    if (tenantSlug.isEmpty) return;

    try {
      final branding = await repository.fetchBrandingBySlug(tenantSlug);
      state = state.copyWith(branding: branding);
    } catch (_) {
      // Cached/default branding is already available; login should not depend on branding.
    }
  }

  Future<void> setContext(TenantContext context) async {
    state = state.copyWith(context: context, isLoading: true);
    try {
      final branding = await ref
          .read(tenantRepositoryProvider)
          .fetchBranding(context);
      state = state.copyWith(branding: branding, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void clear() => state = TenantState.initial();
}
