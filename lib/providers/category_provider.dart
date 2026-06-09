import 'dart:async';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:learnitin_admin/core/types.dart';
import 'package:learnitin_admin/core/utils/error_sanitizer.dart';
import 'package:learnitin_admin/models/course.dart';
import 'package:learnitin_admin/providers/api_provider.dart';

/// Param record for [categoriesProvider] — carries search query and sort preference.
typedef CategoriesParams = ({String? search, bool? sortByPopularity});

/// A notifier that manages the state and CRUD operations for [CourseCategory] entities.
class CategoriesNotifier extends AsyncNotifier<List<CourseCategory>> {
  final String? search;
  final bool? sortByPopularity;

  CategoriesNotifier({required this.search, required this.sortByPopularity});

  int _page = 1;
  final int _perPage = 100; // max is 100
  bool _hasMore = true;

  int get page => _page;
  int get perPage => _perPage;
  bool get hasMore => _hasMore;

  @override
  FutureOr<List<CourseCategory>> build() async {
    _page = 1;
    _hasMore = true;
    ref.watch(apiServiceProvider);
    return _fetch();
  }

  Future<List<CourseCategory>> _fetch() async {
    final api = ref.read(apiServiceProvider);
    try {
      final response = await api.getCategories(
        page: _page,
        perPage: _perPage,
        search: (search?.isNotEmpty == true) ? search : null,
        sortByPopularity: sortByPopularity,
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
                imageUrl: body.imageUrl ?? category.imageUrl,
                createdAt: category.createdAt,
                popularityScore: body.popularityScore ?? category.popularityScore,
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

final categoriesProvider = AsyncNotifierProvider.family<CategoriesNotifier, List<CourseCategory>, CategoriesParams>(
  (params) => CategoriesNotifier(search: params.search, sortByPopularity: params.sortByPopularity),
);

/// A notifier that manages the state and CRUD operations for [CourseSubCategory] entities.
class SubCategoriesNotifier extends AsyncNotifier<List<CourseSubCategory>> {
  final int categoryId;

  SubCategoriesNotifier({required this.categoryId});

  int _page = 1;
  final int _perPage = 20;
  bool _hasMore = true;

  int get page => _page;
  int get perPage => _perPage;
  bool get hasMore => _hasMore;

  @override
  FutureOr<List<CourseSubCategory>> build() async {
    _page = 1;
    _hasMore = true;
    return _fetch();
  }

  Future<List<CourseSubCategory>> _fetch() async {
    final api = ref.read(apiServiceProvider);
    try {
      final response = await api.getSubCategories(
        page: _page,
        perPage: _perPage,
        categoryId: categoryId,
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
                imageUrl: body.imageUrl ?? subCategory.imageUrl,
                createdAt: subCategory.createdAt,
                popularityScore: body.popularityScore ?? subCategory.popularityScore,
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

final subCategoriesProvider = AsyncNotifierProvider.family<SubCategoriesNotifier, List<CourseSubCategory>, int>((
  categoryId,
) {
  return SubCategoriesNotifier(categoryId: categoryId);
});
