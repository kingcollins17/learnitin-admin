import 'dart:async';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:learnitin_admin/models/paginated_response.dart';
import 'package:learnitin_admin/models/user.dart';
import 'package:learnitin_admin/providers/api_provider.dart';

class AdminUserParams {
  final int page;
  final int perPage;
  final String? search;
  final bool? isActive;
  final bool? isSuperuser;
  final String? createdAfter;
  final String? createdBefore;

  const AdminUserParams({
    this.page = 1,
    this.perPage = 20,
    this.search,
    this.isActive,
    this.isSuperuser,
    this.createdAfter,
    this.createdBefore,
  });

  AdminUserParams copyWith({
    int? page,
    int? perPage,
    String? Function()? search,
    bool? Function()? isActive,
    bool? Function()? isSuperuser,
    String? Function()? createdAfter,
    String? Function()? createdBefore,
  }) {
    return AdminUserParams(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      search: search != null ? search() : this.search,
      isActive: isActive != null ? isActive() : this.isActive,
      isSuperuser: isSuperuser != null ? isSuperuser() : this.isSuperuser,
      createdAfter: createdAfter != null ? createdAfter() : this.createdAfter,
      createdBefore: createdBefore != null ? createdBefore() : this.createdBefore,
    );
  }
}

class AdminUserNotifier extends AsyncNotifier<PaginatedData<User>?> {
  AdminUserParams _params = const AdminUserParams();

  AdminUserParams get params => _params;

  @override
  FutureOr<PaginatedData<User>?> build() async {
    ref.watch(apiServiceProvider);
    return _fetch();
  }

  Future<PaginatedData<User>?> _fetch() async {
    final api = ref.read(apiServiceProvider);
    try {
      final response = await api.adminListUsers(
        page: _params.page,
        perPage: _params.perPage,
        search: _params.search,
        isActive: _params.isActive,
        isSuperuser: _params.isSuperuser,
        createdAfter: _params.createdAfter,
        createdBefore: _params.createdBefore,
      );
      return response.data;
    } catch (e) {
      print('Error fetching users: $e');
      rethrow;
    }
  }

  Future<void> setPage(int page) async {
    _params = _params.copyWith(page: page);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<void> updateParams({
    String? search,
    bool? isActive,
    bool? isSuperuser,
  }) async {
    // We only update what is passed. But if search is "", we might want to keep it as "".
    // If it's null, we don't know.
    // For this specific UI, I'll just allow passing null to represent "All".

    _params = AdminUserParams(
      page: 1,
      perPage: _params.perPage,
      search: search ?? _params.search,
      isActive: isActive ?? _params.isActive,
      isSuperuser: isSuperuser ?? _params.isSuperuser,
      createdAfter: _params.createdAfter,
      createdBefore: _params.createdBefore,
    );
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch());
  }

  // More specific update methods to avoid ambiguity
  Future<void> setSearch(String? search) async {
    _params = _params.copyWith(page: 1, search: () => (search?.isEmpty == true ? null : search));
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<void> setIsActive(bool? isActive) async {
    _params = _params.copyWith(page: 1, isActive: () => isActive);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<void> setIsSuperuser(bool? isSuperuser) async {
    _params = _params.copyWith(page: 1, isSuperuser: () => isSuperuser);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch());
  }
}

final adminUserProvider = AsyncNotifierProvider<AdminUserNotifier, PaginatedData<User>?>(() {
  return AdminUserNotifier();
});
