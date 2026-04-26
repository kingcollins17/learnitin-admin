import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:learnitin_admin/models/admin_stats.dart';
import 'package:learnitin_admin/providers/api_provider.dart';
import 'package:learnitin_admin/providers/auth_provider.dart';

final adminStatsProvider = FutureProvider<AdminStats?>((ref) async {
  ref.watch(authProvider);
  final apiService = ref.watch(apiServiceProvider);
  try {
    final response = await apiService.getAdminStats();
    return response.data;
  } catch (e, st) {
    print('Error fetching admin stats: $e');
    print(st);
    rethrow;
  }
});
