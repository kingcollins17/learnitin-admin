import 'dart:async';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:learnitin_admin/models/paginated_response.dart';
import 'package:learnitin_admin/models/course.dart';

class AdminCourseParams {
  final int page;
  final int perPage;
  final String? search;
  final String? category;

  const AdminCourseParams({
    this.page = 1,
    this.perPage = 10,
    this.search,
    this.category,
  });

  AdminCourseParams copyWith({
    int? page,
    int? perPage,
    String? Function()? search,
    String? Function()? category,
  }) {
    return AdminCourseParams(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      search: search != null ? search() : this.search,
      category: category != null ? category() : this.category,
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
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      // Mock Data Generation
      final allMockCourses = List.generate(50, (index) {
        final categories = ['Web Dev', 'Mobile', 'Data Science', 'Design', 'Business'];
        final cat = categories[index % categories.length];
        return Course(
          id: index + 1,
          title: 'Mastering ${cat} Lesson ${index + 1}',
          description: 'A comprehensive guide to ${cat.toLowerCase()} concepts and advanced techniques.',
          category: cat,
          enrollments: (100 + index * 15),
          rating: 4.0 + (index % 10) / 10.0,
          completionRate: 0.5 + (index % 5) / 10.0,
          creatorId: 100 + (index % 3),
          createdAt: DateTime.now().subtract(Duration(days: index * 2)),
        );
      });

      // Simple Filtering
      var filtered = allMockCourses;
      if (_params.search != null && _params.search!.isNotEmpty) {
        filtered = filtered.where((c) => 
          (c.title?.toLowerCase().contains(_params.search!.toLowerCase()) ?? false) ||
          (c.description?.toLowerCase().contains(_params.search!.toLowerCase()) ?? false)
        ).toList();
      }
      if (_params.category != null && _params.category!.isNotEmpty) {
        filtered = filtered.where((c) => c.category == _params.category).toList();
      }

      // Pagination
      final total = filtered.length;
      final start = (_params.page - 1) * _params.perPage;
      if (start >= total) {
        return PaginatedData(
          items: [],
          total: total,
          page: _params.page,
          perPage: _params.perPage,
          totalPages: (total / _params.perPage).ceil(),
        );
      }
      
      final end = (start + _params.perPage) > total ? total : (start + _params.perPage);
      final items = filtered.sublist(start, end);

      return PaginatedData(
        items: items,
        total: total,
        page: _params.page,
        perPage: _params.perPage,
        totalPages: (total / _params.perPage).ceil() == 0 ? 1 : (total / _params.perPage).ceil(),
      );
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

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch());
  }
}

final adminCourseProvider = AsyncNotifierProvider<AdminCourseNotifier, PaginatedData<Course>?>(() {
  return AdminCourseNotifier();
});
