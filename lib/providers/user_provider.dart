import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:learnitin_admin/models/user.dart';
import 'package:learnitin_admin/providers/api_provider.dart';
import 'package:learnitin_admin/providers/auth_provider.dart';

final currentUserProvider = FutureProvider<User>((ref) async {
  ref.watch(authProvider);
  final apiService = ref.watch(apiServiceProvider);
  try {
    final response = await apiService.getCurrentUser();
    final user = response.data;
    if (response.statusCode == 401 || response.statusCode == 403 || user == null) {
      throw Exception(response.details ?? 'Unauthorized');
    }
    return user;
  } catch (e, st) {
    print('Error fetching current user: $e');
    print(st);
    rethrow;
  }
});
