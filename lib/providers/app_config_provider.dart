import 'dart:async';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:learnitin_admin/core/types.dart';
import 'package:learnitin_admin/core/utils/error_sanitizer.dart';
import 'package:learnitin_admin/models/app_config.dart';
import 'package:learnitin_admin/providers/api_provider.dart';

/// A notifier that manages the state and CRUD operations for [AppConfig] entities.
///
/// It supports paginated fetching, refresh capabilities, and state-optimistic
/// mutations for creating, updating, and deleting application configurations.
class AppConfigsNotifier extends AsyncNotifier<List<AppConfig>> {
  int _page = 1;
  final int _perPage = 20;
  bool _hasMore = true;

  /// The current page index of configurations being loaded.
  int get page => _page;

  /// The size limit of items retrieved per API request page.
  int get perPage => _perPage;

  /// Indicates if there are potentially more configurations to load.
  bool get hasMore => _hasMore;

  @override
  FutureOr<List<AppConfig>> build() async {
    _page = 1;
    _hasMore = true;
    return _fetch();
  }

  /// Internal helper to request the current page of app configurations.
  Future<List<AppConfig>> _fetch() async {
    final api = ref.read(apiServiceProvider);
    try {
      final response = await api.getAppConfigs(
        page: _page,
        perPage: _perPage,
      );
      final configs = response.data ?? [];

      if (configs.length < _perPage) {
        _hasMore = false;
      } else {
        _hasMore = true;
      }
      return configs;
    } catch (e) {
      print('Error fetching app configs: $e');
      rethrow;
    }
  }

  /// Loads the next page of app configurations and appends them to the current list.
  ///
  /// Safe to call repeatedly; ignores requests if currently loading or no more items.
  Future<void> loadMore() async {
    if (state.isLoading || !_hasMore) return;

    _page++;
    try {
      final newConfigs = await _fetch();
      if (state.hasValue) {
        final currentConfigs = state.value ?? [];
        state = AsyncValue.data([...currentConfigs, ...newConfigs]);
      } else {
        state = AsyncValue.data(newConfigs);
      }
    } catch (e, st) {
      _page--; // Revert page increment on failure
      state = AsyncValue.error(e, st);
    }
  }

  /// Reloads app configurations from the first page and resets pagination states.
  Future<void> refresh() async {
    _page = 1;
    _hasMore = true;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch());
  }

  /// Creates a new app configuration.
  ///
  /// Upon successful creation, the new configuration is appended to the current state list.
  /// Invokes [onSuccess] or [onError] callbacks accordingly.
  Future<void> createAppConfig(
    CreateAppConfig body, {
    OnSuccess? onSuccess,
    OnError? onError,
  }) async {
    final api = ref.read(apiServiceProvider);
    try {
      final response = await api.createAppConfig(body: body);
      if (response.isSuccess) {
        if (state.hasValue) {
          final currentConfigs = state.value ?? [];
          state = AsyncValue.data([...currentConfigs, response.data!]);
        } else {
          state = AsyncValue.data([response.data!]);
        }
        onSuccess?.call();
      } else {
        throw response.getErrorMsg() ?? 'Failed to create app config';
      }
    } catch (e, st) {
      print('Error creating app config: $e');
      onError?.call(e.toFriendlyMessage(), st);
    }
  }

  /// Updates an existing app configuration.
  ///
  /// Updates local state optimistically upon successful API response.
  /// Invokes [onSuccess] or [onError] callbacks accordingly.
  Future<void> updateAppConfig({
    required int configId,
    required UpdateAppConfig body,
    OnSuccess? onSuccess,
    OnError? onError,
  }) async {
    final api = ref.read(apiServiceProvider);
    try {
      final response = await api.updateAppConfig(configId: configId, body: body);
      if (response.isSuccess) {
        if (state.hasValue) {
          final updated = state.value!.map((config) {
            if (config.id == configId) {
              return config.copyWith(
                key: body.key ?? config.key,
                value: body.value ?? config.value,
                metadata: body.metadata ?? config.metadata,
              );
            }
            return config;
          }).toList();
          state = AsyncValue.data(updated);
        }
        onSuccess?.call();
      } else {
        throw response.getErrorMsg() ?? 'Failed to update app config';
      }
    } catch (e, st) {
      print('Error updating app config: $e');
      onError?.call(e.toFriendlyMessage(), st);
    }
  }

  /// Deletes an app configuration.
  ///
  /// Removes the configuration from local state upon successful API response.
  /// Invokes [onSuccess] or [onError] callbacks accordingly.
  Future<void> deleteAppConfig({
    required int configId,
    OnSuccess? onSuccess,
    OnError? onError,
  }) async {
    final api = ref.read(apiServiceProvider);
    try {
      final response = await api.deleteAppConfig(configId: configId);
      if (response.isSuccess) {
        if (state.hasValue) {
          final updated = state.value!.where((config) => config.id != configId).toList();
          state = AsyncValue.data(updated);
        }
        onSuccess?.call();
      } else {
        throw response.getErrorMsg() ?? 'Failed to delete app config';
      }
    } catch (e, st) {
      print('Error deleting app config: $e');
      onError?.call(e.toFriendlyMessage(), st);
    }
  }
}

/// Provider managing the list of [AppConfig] records.
final appConfigsProvider = AsyncNotifierProvider<AppConfigsNotifier, List<AppConfig>>(() {
  return AppConfigsNotifier();
});

/// Future provider family to fetch a specific [AppConfig] dynamically by its unique key.
final appConfigByKeyProvider = FutureProvider.family<AppConfig?, String>((ref, key) async {
  final api = ref.watch(apiServiceProvider);
  final response = await api.getAppConfigByKey(key);
  if (response.isSuccess) {
    return response.data;
  } else {
    throw response.getErrorMsg() ?? 'Failed to fetch app config by key';
  }
});
