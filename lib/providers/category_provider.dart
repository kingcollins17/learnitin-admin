import 'dart:async';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:learnitin_admin/core/types.dart';
import 'package:learnitin_admin/core/utils/error_sanitizer.dart';
import 'package:learnitin_admin/models/course.dart';
import 'package:learnitin_admin/providers/api_provider.dart';

/// A notifier that manages the state and CRUD operations for [CourseCategory] entities.
class CategoriesNotifier extends AsyncNotifier<List<CourseCategory>> {
  final String? search;

  CategoriesNotifier({required this.search});

  int _page = 1;
  final int _perPage = 20;
  bool _hasMore = true;

  int get page => _page;
  int get perPage => _perPage;
  bool get hasMore => _hasMore;

  @override
  FutureOr<List<CourseCategory>> build() async {
    _page = 1;
    _hasMore = true;
    return _fetch();
  }

  Future<List<CourseCategory>> _fetch() async {
    final api = ref.read(apiServiceProvider);
    try {
      final response = await api.getCategories(
        page: _page,
        perPage: _perPage,
        search: (search?.isNotEmpty == true) ? search : null,
      );
      final categories = response.data ?? [];

      if (categories.length < _perPage) {
        _hasMore = false;
      } else {
        _hasMore = true;
      }
      return categories;
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow;
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !_hasMore) return;

    _page++;
    try {
      final newCategories = await _fetch();
      if (state.hasValue) {
        final currentCategories = state.value ?? [];
        state = AsyncValue.data([...currentCategories, ...newCategories]);
      } else {
        state = AsyncValue.data(newCategories);
      }
    } catch (e, st) {
      _page--;
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    _page = 1;
    _hasMore = true;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<void> createCategory(
    CategoryCreate body, {
    OnSuccess? onSuccess,
    OnError? onError,
  }) async {
    final api = ref.read(apiServiceProvider);
    try {
      final response = await api.createCategory(body: body);
      if (response.isSuccess) {
        if (state.hasValue) {
          final currentCategories = state.value ?? [];
          state = AsyncValue.data([...currentCategories, response.data!]);
        } else {
          state = AsyncValue.data([response.data!]);
        }
        onSuccess?.call();
      } else {
        throw response.getErrorMsg() ?? 'Failed to create category';
      }
    } catch (e, st) {
      print('Error creating category: $e');
      onError?.call(e.toFriendlyMessage(), st);
    }
  }

  Future<void> updateCategory({
    required int categoryId,
    required CategoryUpdate body,
    OnSuccess? onSuccess,
    OnError? onError,
  }) async {
    final api = ref.read(apiServiceProvider);
    try {
      final response = await api.updateCategory(categoryId: categoryId, body: body);
      if (response.isSuccess) {
        if (state.hasValue) {
          final updated = state.value!.map((category) {
            if (category.id == categoryId) {
              return CourseCategory(
                id: category.id,
                name: body.name ?? category.name,
                description: body.description ?? category.description,
                createdAt: category.createdAt,
              );
            }
            return category;
          }).toList();
          state = AsyncValue.data(updated);
        }
        onSuccess?.call();
      } else {
        throw response.getErrorMsg() ?? 'Failed to update category';
      }
    } catch (e, st) {
      print('Error updating category: $e');
      onError?.call(e.toFriendlyMessage(), st);
    }
  }

  Future<void> deleteCategory({
    required int categoryId,
    OnSuccess? onSuccess,
    OnError? onError,
  }) async {
    final api = ref.read(apiServiceProvider);
    try {
      final response = await api.deleteCategory(categoryId: categoryId);
      if (response.isSuccess) {
        if (state.hasValue) {
          final updated = state.value!.where((category) => category.id != categoryId).toList();
          state = AsyncValue.data(updated);
        }
        onSuccess?.call();
      } else {
        throw response.getErrorMsg() ?? 'Failed to delete category';
      }
    } catch (e, st) {
      print('Error deleting category: $e');
      onError?.call(e.toFriendlyMessage(), st);
    }
  }
}

final categoriesProvider = AsyncNotifierProvider.family<CategoriesNotifier, List<CourseCategory>, String?>((search) {
  return CategoriesNotifier(search: search);
});

/// A notifier that manages the state and CRUD operations for [CourseSubCategory] entities.
class SubCategoriesNotifier extends AsyncNotifier<List<CourseSubCategory>> {
  int _page = 1;
  final int _perPage = 20;
  bool _hasMore = true;
  int? _categoryId;

  int get page => _page;
  int get perPage => _perPage;
  bool get hasMore => _hasMore;
  int? get categoryIdFilter => _categoryId;

  @override
  FutureOr<List<CourseSubCategory>> build() async {
    _page = 1;
    _hasMore = true;
    return _fetch();
  }

  /// Sets the category filter and refreshes the subcategories.
  Future<void> setCategoryFilter(int? categoryId) async {
    _categoryId = categoryId;
    await refresh();
  }

  Future<List<CourseSubCategory>> _fetch() async {
    final api = ref.read(apiServiceProvider);
    try {
      final response = await api.getSubCategories(
        page: _page,
        perPage: _perPage,
        categoryId: _categoryId,
      );
      final subCategories = response.data ?? [];

      if (subCategories.length < _perPage) {
        _hasMore = false;
      } else {
        _hasMore = true;
      }
      return subCategories;
    } catch (e) {
      print('Error fetching subcategories: $e');
      rethrow;
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !_hasMore) return;

    _page++;
    try {
      final newSubCategories = await _fetch();
      if (state.hasValue) {
        final currentSubCategories = state.value ?? [];
        state = AsyncValue.data([...currentSubCategories, ...newSubCategories]);
      } else {
        state = AsyncValue.data(newSubCategories);
      }
    } catch (e, st) {
      _page--;
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    _page = 1;
    _hasMore = true;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<void> createSubCategory(
    SubCategoryCreate body, {
    OnSuccess? onSuccess,
    OnError? onError,
  }) async {
    final api = ref.read(apiServiceProvider);
    try {
      final response = await api.createSubCategory(body: body);
      if (response.isSuccess) {
        if (state.hasValue) {
          final currentSubCategories = state.value ?? [];
          state = AsyncValue.data([...currentSubCategories, response.data!]);
        } else {
          state = AsyncValue.data([response.data!]);
        }
        onSuccess?.call();
      } else {
        throw response.getErrorMsg() ?? 'Failed to create subcategory';
      }
    } catch (e, st) {
      print('Error creating subcategory: $e');
      onError?.call(e.toFriendlyMessage(), st);
    }
  }

  Future<void> updateSubCategory({
    required int subCategoryId,
    required SubCategoryUpdate body,
    OnSuccess? onSuccess,
    OnError? onError,
  }) async {
    final api = ref.read(apiServiceProvider);
    try {
      final response = await api.updateSubCategory(subCategoryId: subCategoryId, body: body);
      if (response.isSuccess) {
        if (state.hasValue) {
          final updated = state.value!.map((subCategory) {
            if (subCategory.id == subCategoryId) {
              return CourseSubCategory(
                id: subCategory.id,
                name: body.name ?? subCategory.name,
                description: body.description ?? subCategory.description,
                categoryId: body.categoryId ?? subCategory.categoryId,
                createdAt: subCategory.createdAt,
              );
            }
            return subCategory;
          }).toList();
          state = AsyncValue.data(updated);
        }
        onSuccess?.call();
      } else {
        throw response.getErrorMsg() ?? 'Failed to update subcategory';
      }
    } catch (e, st) {
      print('Error updating subcategory: $e');
      onError?.call(e.toFriendlyMessage(), st);
    }
  }

  Future<void> deleteSubCategory({
    required int subCategoryId,
    OnSuccess? onSuccess,
    OnError? onError,
  }) async {
    final api = ref.read(apiServiceProvider);
    try {
      final response = await api.deleteSubCategory(subCategoryId: subCategoryId);
      if (response.isSuccess) {
        if (state.hasValue) {
          final updated = state.value!.where((subCategory) => subCategory.id != subCategoryId).toList();
          state = AsyncValue.data(updated);
        }
        onSuccess?.call();
      } else {
        throw response.getErrorMsg() ?? 'Failed to delete subcategory';
      }
    } catch (e, st) {
      print('Error deleting subcategory: $e');
      onError?.call(e.toFriendlyMessage(), st);
    }
  }
}

final subCategoriesProvider = AsyncNotifierProvider<SubCategoriesNotifier, List<CourseSubCategory>>(() {
  return SubCategoriesNotifier();
});
