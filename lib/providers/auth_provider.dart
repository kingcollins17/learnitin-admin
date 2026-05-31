import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:learnitin_admin/core/types.dart';
import 'package:learnitin_admin/core/utils/utils.dart';
import 'package:learnitin_admin/providers/api_provider.dart';
import 'package:learnitin_admin/providers/local_storage_provider.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, String?>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<String?> {
  LocalStorageNotifier? _localStorage;

  @override
  Future<String?> build() async {
    // Provide reference to local storage notifier
    _localStorage = ref.read(localStorageProvider.notifier);

    // Watch local storage for reactive updates
    final localStore = ref.watch(localStorageProvider);
    return localStore.accessToken;
  }

  Future<void> login(
    String email,
    String password, {
    OnSuccess? onSuccess,
    OnError? onError,
  }) async {
    final apiService = ref.read(apiServiceProvider);

    try {
      final response = await apiService.login(
        username: email,
        password: password,
      );
      if (response.accessToken == null) {
        throw Exception(response.detail ?? 'Something went wrong');
      }
      // Store token in local storage using the reference
      _localStorage?.save(
        accessToken: response.accessToken,
      );

      onSuccess?.call();

      // Note: response.isActive can be used here or in the UI to prompt for verification
      if (response.isActive == false) {
        print('Warning: User is logged in but account is not active.');
      }
    } catch (e, st) {
      onError?.call(e.toFriendlyMessage(), st);
      final formatted = {'error': e, 'trace': st.toString()};
      formatted.debugLog();
    }
  }

  Future<void> logout() async {
    _localStorage?.clear();
  }

  bool get isAuthenticated => state.value != null;
}
