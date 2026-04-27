import 'dart:async';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:learnitin_admin/models/paginated_response.dart';
import 'package:learnitin_admin/models/course.dart';
import 'package:learnitin_admin/providers/api_provider.dart';

class AdminCourseParams {
  final int page;
  final int perPage;
  final String? search;
  final String? category;
  final int? creatorId;

  const AdminCourseParams({
    this.page = 1,
    this.perPage = 10,
    this.search,
    this.category,
    this.creatorId,
  });

  AdminCourseParams copyWith({
    int? page,
    int? perPage,
    String? Function()? search,
    String? Function()? category,
    int? Function()? creatorId,
  }) {
    return AdminCourseParams(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      search: search != null ? search() : this.search,
      category: category != null ? category() : this.category,
      creatorId: creatorId != null ? creatorId() : this.creatorId,
    );
  }
}

class AdminCourseNotifier extends AsyncNotifier<PaginatedData<Course>?> {
  AdminCourseParams _params = const AdminCourseParams();

  AdminCourseParams get params => _params;

  @override
  FutureOr<PaginatedData<Course>?> build() async {
    return _fetch();
  }

  Future<PaginatedData<Course>?> _fetch() async {
    final api = ref.read(apiServiceProvider);
    try {
      final response = await api.adminListCourses(
        page: _params.page,
        perPage: _params.perPage,
        creatorId: _params.creatorId,
      );
      return response.data;
    } catch (e) {
      print('Error fetching courses: $e');
      rethrow;
    }
  }

  Future<void> setPage(int page) async {
    _params = _params.copyWith(page: page);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<void> setSearch(String? search) async {
    _params = _params.copyWith(page: 1, search: () => (search?.isEmpty == true ? null : search));
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<void> setCategory(String? category) async {
    _params = _params.copyWith(page: 1, category: () => (category?.isEmpty == true ? null : category));
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<void> setCreatorId(int? creatorId) async {
    _params = _params.copyWith(page: 1, creatorId: () => creatorId);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch());
  }
}

final adminCourseProvider = AsyncNotifierProvider<AdminCourseNotifier, PaginatedData<Course>?>(() {
  return AdminCourseNotifier();
});
