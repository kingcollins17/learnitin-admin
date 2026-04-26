import 'dart:async';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:learnitin_admin/models/user.dart';
import 'package:learnitin_admin/providers/api_provider.dart';

class UserDetailNotifier extends AsyncNotifier<User?> {
  final int userId;

  UserDetailNotifier({required this.userId});
  @override
  FutureOr<User?> build() async {
    return _fetchUser(userId);
  }

  Future<User?> _fetchUser(int id) async {
    final apiService = ref.read(apiServiceProvider);
    final response = await apiService.getUserDetail(userId: id);
    return response.data;
  }

  Future<void> banUser({
    required String reason,
    required void Function() onSuccess,
    required void Function(String error) onError,
  }) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.banUser(userId: userId, body: {'reason': reason});
      onSuccess();
      ref.invalidateSelf();
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<void> unbanUser({
    required void Function() onSuccess,
    required void Function(String error) onError,
  }) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.unbanUser(userId: userId);
      onSuccess();
      ref.invalidateSelf();
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<void> grantPremium({
    int durationDays = 30,
    String productId = 'premium_monthly',
    required void Function() onSuccess,
    required void Function(String error) onError,
  }) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.grantPremium(
        userId: userId,
        body: {
          'duration_days': durationDays,
          'product_id': productId,
        },
      );
      onSuccess();
      ref.invalidateSelf();
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<void> revokePremium({
    required void Function() onSuccess,
    required void Function(String error) onError,
  }) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.revokePremium(userId: userId);
      onSuccess();
      ref.invalidateSelf();
    } catch (e) {
      onError(e.toString());
    }
  }
}

final userDetailProvider = AsyncNotifierProvider.family.autoDispose<UserDetailNotifier, User?, int>(
  (userId) => UserDetailNotifier(userId: userId),
);
