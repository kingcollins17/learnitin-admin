import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:learnitin_admin/providers/api_provider.dart';
import 'package:learnitin_admin/core/types.dart';
import 'package:learnitin_admin/core/utils/error_sanitizer.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:learnitin_admin/core/constants/app_strings.dart';
part 'notification_provider.freezed.dart';

@freezed
abstract class AppNotificationState with _$AppNotificationState {
  const factory AppNotificationState({
    @Default([]) List<int> selectedUserIds,
  }) = _AppNotificationState;

  const AppNotificationState._();

  bool isUserSelected(int userId) => selectedUserIds.contains(userId);
}

class AppNotificationNotifier extends Notifier<AppNotificationState> {
  @override
  AppNotificationState build() => const AppNotificationState();

  void toggleUserSelection(int userId) {
    final current = state.selectedUserIds;
    if (current.contains(userId)) {
      state = state.copyWith(
        selectedUserIds: current.where((id) => id != userId).toList(),
      );
    } else {
      state = state.copyWith(
        selectedUserIds: [...current, userId],
      );
    }
  }

  void clearSelection() {
    state = state.copyWith(selectedUserIds: []);
  }

  Future<void> sendToUser({
    required int userId,
    required String title,
    required String message,
    String type = 'info',
    OnSuccess? onSuccess,
    OnError? onError,
  }) async {
    final api = ref.read(apiServiceProvider);
    try {
      final response = await api.notifyUser(
        body: {
          'user_id': userId,
          'title': 'Learnitin',
          'message': message,
          'type': type,
        },
      );
      if (!response.isSuccess) {
        throw response.getErrorMsg() ?? AppStrings.unknownError;
      }
      onSuccess?.call();
    } catch (e, st) {
      onError?.call(e.toFriendlyMessage(), st);
    }
  }

  Future<void> sendToUsersBulk({
    required List<int> userIds,
    required String title,
    required String message,
    String type = 'info',
    OnSuccess? onSuccess,
    OnError? onError,
  }) async {
    final api = ref.read(apiServiceProvider);
    try {
      final response = await api.notifyUsersBulk(
        body: {
          'user_ids': userIds,
          'title': 'Learnitin',
          'message': message,
          'type': type,
        },
      );
      if (!response.isSuccess) {
        throw response.getErrorMsg() ?? AppStrings.unknownError;
      }
      onSuccess?.call();
    } catch (e, st) {
      onError?.call(e.toFriendlyMessage(), st);
    }
  }

  Future<void> broadcast({
    required String title,
    required String message,
    String type = 'info',
    OnSuccess? onSuccess,
    OnError? onError,
  }) async {
    final api = ref.read(apiServiceProvider);
    try {
      final response = await api.broadcastNotification(
        body: {
          'title': 'Learnitin',
          'message': message,
          'type': type,
        },
      );
      if (!response.isSuccess) {
        throw response.getErrorMsg() ?? AppStrings.unknownError;
      }
      onSuccess?.call();
    } catch (e, st) {
      onError?.call(e.toFriendlyMessage(), st);
    }
  }
}

final appNotificationProvider = NotifierProvider<AppNotificationNotifier, AppNotificationState>(() {
  return AppNotificationNotifier();
});
