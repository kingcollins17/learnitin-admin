import 'dart:async';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:learnitin_admin/core/types.dart';
import 'package:learnitin_admin/core/utils/error_sanitizer.dart';
import 'package:learnitin_admin/models/log_entry.dart';
import 'package:learnitin_admin/providers/api_provider.dart';

class LogsNotifier extends AsyncNotifier<List<LogEntry>> {
  int _page = 1;
  final int _perPage = 20;
  bool _hasMore = true;
  String? _level;

  int get page => _page;
  int get perPage => _perPage;
  bool get hasMore => _hasMore;
  String? get level => _level;

  @override
  FutureOr<List<LogEntry>> build() async {
    _page = 1;
    _hasMore = true;
    ref.watch(apiServiceProvider);
    return _fetch();
  }

  Future<List<LogEntry>> _fetch() async {
    final api = ref.read(apiServiceProvider);
    try {
      final response = await api.getLogs(
        page: _page,
        perPage: _perPage,
        level: _level,
      );
      final logs = response.data ?? [];

      // If we got fewer logs than requested per page, there are no more logs to load.
      if (logs.length < _perPage) {
        _hasMore = false;
      } else {
        _hasMore = true;
      }
      return logs;
    } catch (e) {
      print('Error fetching logs: $e');
      rethrow;
    }
  }

  /// Loads the next page of logs and appends them to the current list.
  Future<void> loadMore() async {
    if (state.isLoading || !_hasMore) return;

    _page++;
    try {
      final newLogs = await _fetch();
      if (state.hasValue) {
        final currentLogs = state.value ?? [];
        state = AsyncValue.data([...currentLogs, ...newLogs]);
      } else {
        state = AsyncValue.data(newLogs);
      }
    } catch (e, st) {
      _page--; // Revert page increment on failure
      state = AsyncValue.error(e, st);
    }
  }

  /// Reloads logs from the first page.
  Future<void> refresh() async {
    _page = 1;
    _hasMore = true;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch());
  }

  /// Sets the log level filter and refreshes the logs list.
  Future<void> setLevel(String? level) async {
    if (_level == level) return;
    _level = level;
    await refresh();
  }

  /// Deletes a specific log entry by its [logId] and updates the local state.
  Future<void> deleteLog(
    int logId, {
    OnSuccess? onSuccess,
    OnError? onError,
  }) async {
    final api = ref.read(apiServiceProvider);
    try {
      final response = await api.deleteLog(logId: logId);
      if (response.isSuccess) {
        if (state.hasValue) {
          final updatedLogs = state.value!.where((log) => log.id != logId).toList();
          state = AsyncValue.data(updatedLogs);
        }
        onSuccess?.call();
      } else {
        throw response.getErrorMsg() ?? 'Failed to delete log';
      }
    } catch (e, st) {
      print('Error deleting log $logId: $e');
      onError?.call(e.toFriendlyMessage(), st);
    }
  }

  /// Clears all log entries from the server and updates the local state.
  Future<void> clearAllLogs({
    OnSuccess? onSuccess,
    OnError? onError,
  }) async {
    final api = ref.read(apiServiceProvider);
    try {
      final response = await api.clearLogs();
      if (response.isSuccess) {
        _page = 1;
        _hasMore = false;
        state = const AsyncValue.data([]);
        onSuccess?.call();
        ref.invalidateSelf();
      } else {
        throw response.getErrorMsg() ?? 'Failed to clear logs';
      }
    } catch (e, st) {
      print('Error clearing logs: $e');
      onError?.call(e.toFriendlyMessage(), st);
    }
  }
}

final logsProvider = AsyncNotifierProvider<LogsNotifier, List<LogEntry>>(() {
  return LogsNotifier();
});
