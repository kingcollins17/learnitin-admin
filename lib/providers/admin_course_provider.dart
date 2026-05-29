import 'dart:async';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_riverpod/legacy.dart';
import 'package:learnitin_admin/core/types.dart';
import 'package:learnitin_admin/core/utils/error_sanitizer.dart';
import 'package:learnitin_admin/models/course_generation.dart';
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

class AdminCourseNotifier extends AsyncNotifier<PaginatedCourses?> {
  AdminCourseParams _params = const AdminCourseParams();

  AdminCourseParams get params => _params;

  @override
  FutureOr<PaginatedCourses?> build() async {
    return _fetch();
  }

  Future<PaginatedCourses?> _fetch() async {
    final api = ref.read(apiServiceProvider);
    try {
      final response = await api.getCourses(
        page: _params.page,
        perPage: _params.perPage,
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

  Future<GenerateCoursesResponseData?> generateCourseOutline(
    GenerateCoursesRequest body, {
    void Function(GenerateCoursesResponseData data)? onSuccess,
    OnError? onError,
  }) async {
    final api = ref.read(apiServiceProvider);
    try {
      final response = await api.generateCourseOutline(body: body);
      if (response.isSuccess) {
        onSuccess?.call(response.data!);
        return response.data;
      } else {
        throw response.getErrorMsg() ?? 'Failed to generate course outline';
      }
    } catch (e, st) {
      print('Error generating course outline: $e');
      onError?.call(e.toFriendlyMessage(), st);
      rethrow;
    }
  }

  Future<Course?> createCourse({
    required GeneratedCourse body,
    int? categoryId,
    int? subCategoryId,
    bool enroll = false,
    bool isPublic = true,
    void Function(Course course)? onSuccess,
    OnError? onError,
  }) async {
    final api = ref.read(apiServiceProvider);
    try {
      final response = await api.createCourse(
        body: body,
        categoryId: categoryId,
        subCategoryId: subCategoryId,
        enroll: enroll,
        isPublic: isPublic,
      );
      if (response.isSuccess) {
        onSuccess?.call(response.data!);
        await refresh();
        return response.data;
      } else {
        throw response.getErrorMsg() ?? 'Failed to create course';
      }
    } catch (e, st) {
      print('Error creating course: $e');
      onError?.call(e.toFriendlyMessage(), st);
      rethrow;
    }
  }

  Future<void> updateCourse({
    required String courseId,
    required CourseUpdate body,
    OnSuccess? onSuccess,
    OnError? onError,
  }) async {
    final api = ref.read(apiServiceProvider);
    try {
      final response = await api.updateCourse(
        courseId: courseId,
        body: body,
      );
      if (response.isSuccess) {
        onSuccess?.call();
        await refresh();
      } else {
        throw response.getErrorMsg() ?? 'Failed to update course';
      }
    } catch (e, st) {
      print('Error updating course: $e');
      onError?.call(e.toFriendlyMessage(), st);
      rethrow;
    }
  }
}

final adminCourseProvider = AsyncNotifierProvider<AdminCourseNotifier, PaginatedCourses?>(() {
  return AdminCourseNotifier();
});

final selectedGeneratedCourseProvider = StateProvider<GeneratedCourse?>((ref) => null);

final editingCourseProvider = StateProvider<Course?>((ref) => null);
