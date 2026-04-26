import 'dart:convert';
import 'dart:js_interop';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../core/utils/utils.dart';

part 'local_storage_provider.freezed.dart';
part 'local_storage_provider.g.dart';

// ── Browser localStorage JS bindings ────────────────────────────────────────
@JS('window.localStorage.getItem')
external JSString? _jsGetItem(JSString key);

@JS('window.localStorage.setItem')
external void _jsSetItem(JSString key, JSString value);

@JS('window.localStorage.removeItem')
external void _jsRemoveItem(JSString key);

/// Thin wrapper around the browser's native localStorage API.
class BrowserStorage {
  static String? getItem(String key) => _jsGetItem(key.toJS)?.toDart;
  static void setItem(String key, String value) => _jsSetItem(key.toJS, value.toJS);
  static void removeItem(String key) => _jsRemoveItem(key.toJS);
}

// ── State ───────────────────────────────────────────────────────────────────
@freezed
abstract class LocalStoreState with _$LocalStoreState {
  const factory LocalStoreState({
    String? accessToken,
  }) = _LocalStoreState;

  factory LocalStoreState.fromJson(Map<String, dynamic> json) => _$LocalStoreStateFromJson(json);
}

// ── Provider (synchronous — no async init needed for localStorage) ──────────
final localStorageProvider = NotifierProvider<LocalStorageNotifier, LocalStoreState>(LocalStorageNotifier.new);

class LocalStorageNotifier extends Notifier<LocalStoreState> {
  static const _storageKey = 'local_store';

  @override
  LocalStoreState build() {
    final data = BrowserStorage.getItem(_storageKey);
    if (data != null) {
      try {
        return LocalStoreState.fromJson(jsonDecode(data));
      } catch (e) {
        return const LocalStoreState();
      }
    }
    return const LocalStoreState();
  }

  void save({String? accessToken}) {
    try {
      final newState = state.copyWith(
        accessToken: accessToken,
      );
      state = newState;
      BrowserStorage.setItem(_storageKey, jsonEncode(newState.toJson()));
    } catch (e, st) {
      final formatted = {'error': e, 'trace': st.toString()};
      formatted.debugLog();
      rethrow;
    }
  }

  void clear() {
    state = const LocalStoreState();
    BrowserStorage.removeItem(_storageKey);
  }
}
