import 'dart:async';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:learnitin_admin/components/course_create_outline_modal.dart';
import 'package:learnitin_admin/components/course_edit_form.dart';
import 'package:learnitin_admin/core/core.dart';
import 'package:learnitin_admin/models/course_generation.dart';

import '../providers/admin_course_provider.dart';
import '../providers/category_provider.dart';
import '../models/paginated_response.dart';
import '../models/course.dart';

class CoursesListPage extends StatefulComponent {
  const CoursesListPage({super.key});

  @override
  State<CoursesListPage> createState() => _CoursesListPageState();
}

class _CoursesListPageState extends State<CoursesListPage> {
  bool _showCreateModal = false;
  String? _searchQuery;
  String? _level;
  int? _minEnrollees;
  bool _sortByPopularity = true;
  int? _categoryId;
  int? _subCategoryId;

  void _openCreateModal() {
    setState(() {
      _showCreateModal = true;
    });
  }

  void _closeCreateModal() {
    setState(() {
      _showCreateModal = false;
    });
  }

  void _onOutlineGenerated(GeneratedCourse course) {
    setState(() {
      _showCreateModal = false;
    });
    // Set selected course outline in provider and navigate to preview page
    context.read(selectedGeneratedCourseProvider.notifier).state = course;
    Router.of(context).push('/courses/preview');
  }

  @override
  Component build(BuildContext context) {
    final editingCourse = context.watch(editingCourseProvider);

    final familyParams = (
      sortByPopularity: _sortByPopularity,
      minEnrollees: _minEnrollees,
      search: _searchQuery,
      level: _level,
      categoryId: _categoryId,
      subCategoryId: _subCategoryId,
    );

    if (editingCourse != null) {
      return CourseEditForm(
        course: editingCourse,
        familyParams: familyParams,
        onClose: () => context.read(editingCourseProvider.notifier).state = null,
      );
    }

    return div(classes: 'space-y-8 pb-8 relative', [
      // ── Page Header ──────────────────────────────────────────────
      div(classes: 'flex flex-col md:flex-row md:items-center justify-between gap-4', [
        div(classes: 'space-y-1', [
          h1(classes: 'text-3xl font-bold text-white tracking-tight', [
            Component.text('Course Catalog'),
          ]),
          p(classes: 'text-dark-muted', [
            Component.text('Manage and monitor all learning content on the platform.'),
          ]),
        ]),
        button(
          classes:
              'btn-primary flex items-center space-x-2 px-6 py-3 rounded-xl shadow-lg shadow-primary/20 hover:shadow-primary/40 transition-all cursor-pointer',
          onClick: _openCreateModal,
          [
            span([Component.text('➕')]),
            span([Component.text('Create New Course')]),
          ],
        ),
      ]),

      // ── Course List Table ────────────────────────────────────────
      _CoursesSection(
        searchQuery: _searchQuery,
        level: _level,
        minEnrollees: _minEnrollees,
        sortByPopularity: _sortByPopularity,
        categoryId: _categoryId,
        subCategoryId: _subCategoryId,
        onSearchChanged: (q) => setState(() => _searchQuery = q),
        onLevelChanged: (l) => setState(() => _level = l),
        onMinEnrolleesChanged: (m) => setState(() => _minEnrollees = m),
        onSortChanged: (sortByPop) => setState(() => _sortByPopularity = sortByPop),
        onCategoryChanged: (c) => setState(() {
          _categoryId = c;
          _subCategoryId = null; // reset subcategory on category change
        }),
        onSubCategoryChanged: (sc) => setState(() => _subCategoryId = sc),
      ),

      // ── Create Course Outline Modal ────────────────────────────────
      if (_showCreateModal)
        CourseCreateOutlineModal(
          onClose: _closeCreateModal,
          onOutlineGenerated: _onOutlineGenerated,
        ),
    ]);
  }
}

class _CoursesSection extends StatefulComponent {
  final String? searchQuery;
  final String? level;
  final int? minEnrollees;
  final bool sortByPopularity;
  final int? categoryId;
  final int? subCategoryId;
  final ValueChanged<String?> onSearchChanged;
  final ValueChanged<String?> onLevelChanged;
  final ValueChanged<int?> onMinEnrolleesChanged;
  final ValueChanged<bool> onSortChanged;
  final ValueChanged<int?> onCategoryChanged;
  final ValueChanged<int?> onSubCategoryChanged;

  const _CoursesSection({
    required this.searchQuery,
    required this.level,
    required this.minEnrollees,
    required this.sortByPopularity,
    required this.categoryId,
    required this.subCategoryId,
    required this.onSearchChanged,
    required this.onLevelChanged,
    required this.onMinEnrolleesChanged,
    required this.onSortChanged,
    required this.onCategoryChanged,
    required this.onSubCategoryChanged,
  });

  @override
  State<_CoursesSection> createState() => _CoursesSectionState();
}

class _CoursesSectionState extends State<_CoursesSection> {
  Timer? _debounce;
  late String _localSearchQuery;

  Timer? _categorySearchDebounce;
  String _localCategorySearchQuery = '';
  String _categorySearchQuery = '';
  bool _isLoadingMoreCategories = false;
  CourseCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _localSearchQuery = component.searchQuery ?? '';
  }

  @override
  void didUpdateComponent(_CoursesSection oldComponent) {
    super.didUpdateComponent(oldComponent);
    if (component.searchQuery != oldComponent.searchQuery) {
      _localSearchQuery = component.searchQuery ?? '';
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _categorySearchDebounce?.cancel();
    super.dispose();
  }

  void _onSearchInput(String query) {
    setState(() {
      _localSearchQuery = query;
    });
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      component.onSearchChanged(query.isEmpty ? null : query);
    });
  }

  void _onCategorySearchInput(String query) {
    setState(() {
      _localCategorySearchQuery = query;
    });
    if (_categorySearchDebounce?.isActive ?? false) _categorySearchDebounce!.cancel();
    _categorySearchDebounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _categorySearchQuery = query;
      });
    });
  }

  @override
  Component build(BuildContext context) {
    final paramsRecord = (
      sortByPopularity: component.sortByPopularity,
      minEnrollees: component.minEnrollees,
      search: component.searchQuery,
      level: component.level,
      categoryId: component.categoryId,
      subCategoryId: component.subCategoryId,
    );
    final coursesAsync = context.watch(adminCourseProvider(paramsRecord));
    final notifier = context.read(adminCourseProvider(paramsRecord).notifier);
    final params = notifier.params;

    final categoriesAsync = context.watch(categoriesProvider((search: _categorySearchQuery, sortByPopularity: null)));
    final subCategoriesAsync = component.categoryId != null
        ? context.watch(subCategoriesProvider(component.categoryId!))
        : null;

    return div(classes: 'card overflow-hidden', [
      // Filters Header
      div(classes: 'flex flex-wrap items-center gap-4 mb-8 w-full', [
        // Search Input
        div(classes: 'relative flex-1 md:flex-none md:min-w-[240px]', [
          span(classes: 'absolute left-4 top-1/2 -translate-y-1/2 text-dark-muted', [Component.text('🔍')]),
          input<String>(
            type: InputType.text,
            classes:
                'bg-dark-border/30 border border-dark-border rounded-xl pl-10 pr-4 py-2.5 text-sm text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-all w-full',
            value: _localSearchQuery,
            onInput: _onSearchInput,
          ),
        ]),

        // Category Filter with Search & Load More
        div(classes: 'flex flex-col gap-1 min-w-[320px]', [
          // Horizontal container: Search + Select
          div(classes: 'flex items-center gap-2', [
            // Search input
            div(classes: 'relative flex-1 min-w-[120px]', [
              input(
                type: InputType.text,
                classes:
                    'bg-dark-border/30 border border-dark-border rounded-xl pl-3 pr-7 py-2.5 text-xs text-white placeholder:text-dark-muted/40 w-full focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-all',
                value: _localCategorySearchQuery,
                attributes: {'placeholder': 'Search categories...'},
                onInput: _onCategorySearchInput,
              ),
              if (_localCategorySearchQuery.isNotEmpty)
                button(
                  type: ButtonType.button,
                  classes:
                      'absolute right-2 top-1/2 -translate-y-1/2 text-xs text-dark-muted/50 hover:text-white transition-colors cursor-pointer',
                  onClick: () {
                    _onCategorySearchInput('');
                  },
                  [Component.text('✕')],
                ),
            ]),

            // Dropdown select
            div(classes: 'flex-[1.5] min-w-[150px]', [
              categoriesAsync.when(
                data: (categories) {
                  // Update selected category cache if we find it in the current loaded list
                  if (component.categoryId != null) {
                    CourseCategory? found;
                    for (final c in categories) {
                      if (c.id == component.categoryId) {
                        found = c;
                        break;
                      }
                    }
                    if (found != null) {
                      _selectedCategory = found;
                    }
                  } else {
                    _selectedCategory = null;
                  }

                  final displayedCategories = [...categories];
                  if (component.categoryId != null && _selectedCategory != null) {
                    final hasSelected = displayedCategories.any((c) => c.id == component.categoryId);
                    if (!hasSelected) {
                      displayedCategories.insert(0, _selectedCategory!);
                    }
                  }

                  return select(
                    classes:
                        'bg-dark-border/30 border border-dark-border rounded-xl pl-4 pr-10 py-2.5 text-sm text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-all cursor-pointer w-full appearance-none bg-[url("data:image/svg+xml;charset=utf-8,%3Csvg xmlns=\'http://www.w3.org/2000/svg\' fill=\'none\' viewBox=\'0 0 24 24\' stroke=\'%2371717A\'%3E%3Cpath stroke-linecap=\'round\' stroke-linejoin=\'round\' stroke-width=\'2\' d=\'M19 9l-7 7-7-7\'/%3E%3C/svg%3E")] bg-no-repeat bg-[right_0.75rem_center] bg-[length:1.25em_1.25em]',
                    onChange: (values) {
                      final val = values.firstOrNull;
                      final parsedId = val == 'all' ? null : int.tryParse(val ?? '');
                      setState(() {
                        if (parsedId == null) {
                          _selectedCategory = null;
                        } else {
                          CourseCategory? found;
                          for (final c in displayedCategories) {
                            if (c.id == parsedId) {
                              found = c;
                              break;
                            }
                          }
                          _selectedCategory = found ?? _selectedCategory;
                        }
                      });
                      component.onCategoryChanged(parsedId);
                    },
                    [
                      option(value: 'all', selected: component.categoryId == null, [
                        Component.text('All Categories'),
                      ]),
                      for (final cat in displayedCategories)
                        option(
                          value: cat.id.toString(),
                          selected: component.categoryId == cat.id,
                          [Component.text(cat.name ?? '')],
                        ),
                    ],
                  );
                },
                loading: () => div(
                  classes:
                      'bg-dark-border/30 border border-dark-border rounded-xl px-4 py-2.5 text-sm text-dark-muted animate-pulse w-full',
                  [Component.text('Loading...')],
                ),
                error: (e, __) => div(classes: 'text-xs text-red-400 py-2.5', [Component.text('Error')]),
              ),
            ]),
          ]),

          // Footer count + Load More below the horizontal layout
          categoriesAsync.when(
            data: (categories) {
              final displayedCategories = [...categories];
              if (component.categoryId != null && _selectedCategory != null) {
                final hasSelected = displayedCategories.any((c) => c.id == component.categoryId);
                if (!hasSelected) {
                  displayedCategories.insert(0, _selectedCategory!);
                }
              }

              final notifier = context.read(
                categoriesProvider((search: _categorySearchQuery, sortByPopularity: null)).notifier,
              );
              final hasMore = notifier.hasMore;
              final totalCount = displayedCategories.length;

              return div(classes: 'flex items-center justify-between px-1 text-[9px]', [
                span(classes: 'text-dark-muted/50', [
                  Component.text('Showing $totalCount cats'),
                ]),
                if (hasMore)
                  _isLoadingMoreCategories
                      ? span(classes: 'text-dark-muted/50 animate-pulse', [Component.text('Loading...')])
                      : button(
                          type: ButtonType.button,
                          classes:
                              'text-primary hover:text-primary/80 font-semibold transition-colors cursor-pointer flex items-center space-x-1',
                          onClick: () async {
                            setState(() {
                              _isLoadingMoreCategories = true;
                            });
                            try {
                              await context
                                  .read(
                                    categoriesProvider((
                                      search: _categorySearchQuery,
                                      sortByPopularity: null,
                                    )).notifier,
                                  )
                                  .loadMore();
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isLoadingMoreCategories = false;
                                });
                              }
                            }
                          },
                          [
                            Component.text('Load More ➔'),
                          ],
                        ),
              ]);
            },
            loading: () => div([]),
            error: (e, __) => div([]),
          ),
        ]),

        // Subcategory Filter (Optional)
        if (component.categoryId != null && subCategoriesAsync != null)
          subCategoriesAsync.when(
            data: (subCategories) => select(
              classes:
                  'bg-dark-border/30 border border-dark-border rounded-xl pl-4 pr-10 py-2.5 text-sm text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-all cursor-pointer min-w-[140px] appearance-none bg-[url("data:image/svg+xml;charset=utf-8,%3Csvg xmlns=\'http://www.w3.org/2000/svg\' fill=\'none\' viewBox=\'0 0 24 24\' stroke=\'%2371717A\'%3E%3Cpath stroke-linecap=\'round\' stroke-linejoin=\'round\' stroke-width=\'2\' d=\'M19 9l-7 7-7-7\'/%3E%3C/svg%3E")] bg-no-repeat bg-[right_0.75rem_center] bg-[length:1.25em_1.25em]',
              onChange: (values) {
                final val = values.firstOrNull;
                component.onSubCategoryChanged(val == 'all' ? null : int.tryParse(val ?? ''));
              },
              [
                option(value: 'all', selected: component.subCategoryId == null, [
                  Component.text('All Subcategories'),
                ]),
                for (final sub in subCategories)
                  option(
                    value: sub.id.toString(),
                    selected: component.subCategoryId == sub.id,
                    [Component.text(sub.name ?? '')],
                  ),
              ],
            ),
            loading: () => div(
              classes:
                  'bg-dark-border/30 border border-dark-border rounded-xl px-4 py-2.5 text-sm text-dark-muted animate-pulse min-w-[140px]',
              [Component.text('Loading...')],
            ),
            error: (e, __) => div(classes: 'text-xs text-red-400', [Component.text('Error')]),
          ),

        // Level Filter
        select(
          classes:
              'bg-dark-border/30 border border-dark-border rounded-xl pl-4 pr-10 py-2.5 text-sm text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-all cursor-pointer min-w-[120px] appearance-none bg-[url("data:image/svg+xml;charset=utf-8,%3Csvg xmlns=\'http://www.w3.org/2000/svg\' fill=\'none\' viewBox=\'0 0 24 24\' stroke=\'%2371717A\'%3E%3Cpath stroke-linecap=\'round\' stroke-linejoin=\'round\' stroke-width=\'2\' d=\'M19 9l-7 7-7-7\'/%3E%3C/svg%3E")] bg-no-repeat bg-[right_0.75rem_center] bg-[length:1.25em_1.25em]',
          onChange: (values) {
            final val = values.firstOrNull;
            component.onLevelChanged(val == 'all' ? null : val);
          },
          [
            option(value: 'all', selected: component.level == null, [Component.text('All Levels')]),
            option(value: 'beginner', selected: component.level == 'beginner', [Component.text('Beginner')]),
            option(value: 'intermediate', selected: component.level == 'intermediate', [
              Component.text('Intermediate'),
            ]),
            option(value: 'expert', selected: component.level == 'expert', [Component.text('Expert')]),
          ],
        ),

        // Minimum Enrollees Filter
        select(
          classes:
              'bg-dark-border/30 border border-dark-border rounded-xl pl-4 pr-10 py-2.5 text-sm text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-all cursor-pointer min-w-[130px] appearance-none bg-[url("data:image/svg+xml;charset=utf-8,%3Csvg xmlns=\'http://www.w3.org/2000/svg\' fill=\'none\' viewBox=\'0 0 24 24\' stroke=\'%2371717A\'%3E%3Cpath stroke-linecap=\'round\' stroke-linejoin=\'round\' stroke-width=\'2\' d=\'M19 9l-7 7-7-7\'/%3E%3C/svg%3E")] bg-no-repeat bg-[right_0.75rem_center] bg-[length:1.25em_1.25em]',
          onChange: (values) {
            final val = values.firstOrNull;
            component.onMinEnrolleesChanged(val == 'all' ? null : int.tryParse(val ?? ''));
          },
          [
            option(value: 'all', selected: component.minEnrollees == null, [Component.text('All Enrollees')]),
            option(value: '10', selected: component.minEnrollees == 10, [Component.text('10+ Learners')]),
            option(value: '100', selected: component.minEnrollees == 100, [Component.text('100+ Learners')]),
            option(value: '1000', selected: component.minEnrollees == 1000, [Component.text('1000+ Learners')]),
          ],
        ),

        // Refresh Button
        button(
          classes:
              'p-2.5 rounded-xl bg-dark-border/30 border border-dark-border text-dark-muted hover:text-white hover:bg-dark-border/50 transition-all cursor-pointer',
          onClick: () => notifier.refresh(),
          [Component.text('🔄')],
        ),

        // Sort By Filter
        div(classes: 'flex items-center space-x-2 text-sm text-dark-muted ml-auto', [
          span([Component.text('Sorted by:')]),
          select(
            classes: 'bg-transparent border-none text-white font-semibold focus:outline-none cursor-pointer',
            onChange: (values) {
              final val = values.firstOrNull;
              component.onSortChanged(val == 'popularity');
            },
            [
              option(value: 'newest', selected: component.sortByPopularity != true, [Component.text('Newest First')]),
              option(value: 'popularity', selected: component.sortByPopularity == true, [Component.text('Popularity')]),
            ],
          ),
        ]),
      ]),

      // Table Content
      coursesAsync.when(
        data: (data) => _CoursesTable(
          courses: data?.items ?? [],
          pagination: data,
          onPageChange: (page) => notifier.setPage(page),
        ),
        loading: () => div(classes: 'flex flex-col items-center justify-center py-24 space-y-4', [
          div(classes: 'w-12 h-12 border-4 border-primary border-t-transparent rounded-full animate-spin', []),
          p(classes: 'text-dark-muted animate-pulse', [Component.text('Fetching course catalog...')]),
        ]),
        error: (e, st) => div(classes: 'p-12 text-center bg-red-500/5 rounded-2xl border border-red-500/10', [
          span(classes: 'text-4xl mb-4 block', [Component.text('⚠️')]),
          h4(classes: 'text-lg font-bold text-red-400 mb-2', [Component.text('Failed to Load Courses')]),
          p(classes: 'text-dark-muted mb-6 max-w-md mx-auto', [Component.text(e.toFriendlyMessage())]),
          if (params.page > 1)
            p(classes: 'text-xs text-dark-muted mb-4', [
              Component.text('Error occurred on page ${params.page}'),
            ]),
          div(classes: 'flex items-center justify-center gap-3', [
            if (params.page > 1)
              button(
                classes:
                    'px-6 py-2 bg-white/5 text-white border border-dark-border rounded-xl hover:bg-white/10 transition-all flex items-center space-x-2 cursor-pointer',
                onClick: () => notifier.setPage(params.page - 1),
                [
                  span([Component.text('←')]),
                  span([Component.text('Go Back')]),
                ],
              ),
            button(
              classes:
                  'px-6 py-2 bg-red-500/20 text-red-400 border border-red-500/30 rounded-xl hover:bg-red-500/30 transition-all cursor-pointer',
              onClick: () => notifier.refresh(),
              [Component.text('Retry Request')],
            ),
          ]),
        ]),
      ),
    ]);
  }
}

class _CoursesTable extends StatelessComponent {
  final List<Course> courses;
  final PaginatedCourses? pagination;
  final ValueChanged<int>? onPageChange;

  const _CoursesTable({
    required this.courses,
    this.pagination,
    this.onPageChange,
  });

  @override
  Component build(BuildContext context) {
    final totalPages = pagination?.totalPages ?? 1;
    final currentPage = pagination?.page ?? 1;

    List<dynamic> pageRange = [];
    if (totalPages <= 7) {
      pageRange = List.generate(totalPages, (index) => index + 1);
    } else if (currentPage <= 4) {
      pageRange = [1, 2, 3, 4, 5, '...', totalPages];
    } else if (currentPage >= totalPages - 3) {
      pageRange = [1, '...', totalPages - 4, totalPages - 3, totalPages - 2, totalPages - 1, totalPages];
    } else {
      pageRange = [1, '...', currentPage - 1, currentPage, currentPage + 1, '...', totalPages];
    }

    return div([
      div(classes: 'overflow-x-auto -mx-6', [
        table(classes: 'w-full', [
          thead([
            tr(classes: 'border-b border-dark-border', [
              th(classes: 'text-left py-4 px-6 text-xs font-bold text-dark-muted uppercase tracking-widest', [
                Component.text('Course Details'),
              ]),
              th(classes: 'text-left py-4 px-6 text-xs font-bold text-dark-muted uppercase tracking-widest', [
                Component.text('Category'),
              ]),
              th(classes: 'text-left py-4 px-6 text-xs font-bold text-dark-muted uppercase tracking-widest', [
                Component.text('Level / Pace'),
              ]),
              th(classes: 'text-left py-4 px-6 text-xs font-bold text-dark-muted uppercase tracking-widest', [
                Component.text('Enrollees'),
              ]),
              th(classes: 'text-left py-4 px-6 text-xs font-bold text-dark-muted uppercase tracking-widest', [
                Component.text('Performance'),
              ]),
              th(classes: 'text-right py-4 px-6 text-xs font-bold text-dark-muted uppercase tracking-widest', [
                Component.text('Actions'),
              ]),
            ]),
          ]),
          tbody([
            if (courses.isEmpty)
              tr([
                td(
                  classes: 'py-24 text-center text-dark-muted',
                  attributes: {'colspan': '6'},
                  [
                    div(classes: 'space-y-2', [
                      span(classes: 'text-3xl block', [Component.text('🔎')]),
                      p([Component.text('No courses found matching your criteria.')]),
                    ]),
                  ],
                ),
              ])
            else
              for (final course in courses)
                tr(classes: 'border-b border-dark-border/40 hover:bg-white/[0.03] transition-all group', [
                  // Detail Cell
                  td(classes: 'py-5 px-6', [
                    div(classes: 'flex items-start space-x-4', [
                      div(
                        classes:
                            'w-12 h-12 rounded-xl bg-gradient-to-br from-primary/20 to-primary-700/10 border border-primary/20 flex items-center justify-center text-xl shrink-0 group-hover:scale-110 transition-transform',
                        [Component.text(_getEmojiForCategory(course.category?.name))],
                      ),
                      div(classes: 'min-w-0', [
                        p(classes: 'text-sm font-bold text-white group-hover:text-primary transition-colors truncate', [
                          Component.text(course.title ?? 'Untitled Course'),
                        ]),
                        p(classes: 'text-xs text-dark-muted truncate max-w-[200px]', [
                          Component.text(course.description ?? 'No description available.'),
                        ]),
                        if (course.duration != null)
                          p(classes: 'text-[10px] text-dark-muted/70 mt-0.5', [
                            Component.text('⏱ ${course.duration}'),
                          ]),
                      ]),
                    ]),
                  ]),

                  // Category Cell
                  td(classes: 'py-5 px-6', [
                    div(classes: 'space-y-1', [
                      span(
                        classes:
                            'text-[10px] font-bold uppercase tracking-wider px-2.5 py-1 rounded-lg bg-white/5 border border-white/10 text-dark-muted',
                        [Component.text(course.category?.name ?? 'Uncategorized')],
                      ),
                      if (course.subCategory?.name != null)
                        p(classes: 'text-[10px] text-dark-muted/60 pl-0.5', [
                          Component.text(course.subCategory!.name!),
                        ]),
                    ]),
                  ]),

                  // Level / Pace Cell
                  td(classes: 'py-5 px-6', [
                    div(classes: 'space-y-1', [
                      span(
                        classes:
                            'text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded-md ${_levelStyle(course.level)}',
                        [Component.text(course.level ?? 'N/A')],
                      ),
                      if (course.learningPace != null)
                        p(classes: 'text-[10px] text-dark-muted/60 capitalize', [
                          Component.text(course.learningPace!),
                        ]),
                    ]),
                  ]),

                  // Enrollees Cell
                  td(classes: 'py-5 px-6', [
                    div([
                      p(classes: 'text-sm font-bold text-white', [
                        Component.text((course.totalEnrollees ?? 0).toString()),
                      ]),
                      p(classes: 'text-[10px] text-dark-muted uppercase font-semibold', [
                        Component.text('Learners'),
                      ]),
                    ]),
                  ]),

                  // Performance Cell
                  td(classes: 'py-5 px-6', [
                    div(classes: 'space-y-1.5', [
                      div(classes: 'flex items-center justify-between min-w-[120px]', [
                        span(classes: 'text-[10px] font-bold text-dark-muted uppercase', [Component.text('Rating')]),
                        span(classes: 'text-xs font-bold text-amber-400', [
                          Component.text('⭐ ${(course.reviewSummary?.averageRating ?? 0.0).toStringAsFixed(1)}'),
                        ]),
                      ]),
                      div(classes: 'flex items-center justify-between', [
                        span(classes: 'text-[10px] text-dark-muted', [Component.text('Reviews')]),
                        span(classes: 'text-[10px] font-bold text-white', [
                          Component.text('${course.reviewSummary?.totalReviews ?? 0}'),
                        ]),
                      ]),
                      div(classes: 'flex items-center justify-between', [
                        span(classes: 'text-[10px] text-dark-muted', [Component.text('Popularity')]),
                        span(classes: 'text-[10px] font-bold text-sky-400', [
                          Component.text((course.popularityScore ?? 0.0).toStringAsFixed(1)),
                        ]),
                      ]),
                      div(classes: 'flex items-center space-x-1', [
                        div(
                          classes:
                              'w-1.5 h-1.5 rounded-full ${course.isPublic == true ? "bg-emerald-400" : "bg-amber-400"}',
                          [],
                        ),
                        span(classes: 'text-[10px] text-dark-muted', [
                          Component.text(course.isPublic == true ? 'Public' : 'Private'),
                        ]),
                      ]),
                    ]),
                  ]),

                  // Actions Cell
                  td(classes: 'py-5 px-6 text-right', [
                    div(classes: 'flex items-center justify-end space-x-2', [
                      button(
                        classes:
                            'p-2 rounded-lg bg-white/5 border border-white/5 text-dark-muted hover:text-white hover:bg-white/10 hover:border-white/20 transition-all cursor-pointer',
                        onClick: () => context.read(editingCourseProvider.notifier).state = course,
                        [Component.text('✏️')],
                      ),
                      button(
                        classes:
                            'p-2 rounded-lg bg-red-500/5 border border-red-500/5 text-red-400/70 hover:text-red-400 hover:bg-red-500/10 hover:border-red-500/20 transition-all cursor-pointer',
                        [Component.text('🗑️')],
                      ),
                    ]),
                  ]),
                ]),
          ]),
        ]),
      ]),

      // Pagination Controls
      if (pagination != null)
        div(classes: 'mt-8 flex flex-col sm:flex-row items-center justify-between gap-4 border-t border-dark-border pt-6', [
          p(classes: 'text-xs text-dark-muted', [
            Component.text('Displaying '),
            span(classes: 'text-white font-bold', [
              Component.text(
                '${(currentPage - 1) * pagination!.perPage + 1} - ${((currentPage - 1) * pagination!.perPage + courses.length)}',
              ),
            ]),
            if (courses.length < pagination!.perPage) ...[
              Component.text(' of '),
              span(classes: 'text-white font-bold', [
                Component.text('${(currentPage - 1) * pagination!.perPage + courses.length}'),
              ]),
            ],
            Component.text(' items'),
          ]),

          div(classes: 'flex items-center space-x-1.5', [
            button(
              classes:
                  'flex items-center justify-center w-10 h-10 rounded-xl bg-dark-border/30 border border-dark-border text-dark-muted hover:text-white hover:bg-dark-border/50 disabled:opacity-20 disabled:cursor-not-allowed transition-all cursor-pointer',
              attributes: currentPage <= 1 ? {'disabled': ''} : {},
              onClick: () => onPageChange?.call(currentPage - 1),
              [Component.text('←')],
            ),

            for (final pageToken in pageRange)
              if (pageToken is int)
                button(
                  classes:
                      'flex items-center justify-center w-10 h-10 rounded-xl border transition-all text-sm font-bold cursor-pointer '
                      '${pageToken == currentPage ? "bg-primary border-primary text-white shadow-lg shadow-primary/20" : "bg-dark-border/30 border-dark-border text-dark-muted hover:text-white hover:bg-dark-border/50"}',
                  onClick: () => pageToken != currentPage ? onPageChange?.call(pageToken) : null,
                  [Component.text('$pageToken')],
                )
              else
                span(classes: 'text-dark-muted px-1.5', [Component.text('...')]),

            button(
              classes:
                  'flex items-center justify-center w-10 h-10 rounded-xl bg-dark-border/30 border border-dark-border text-dark-muted hover:text-white hover:bg-dark-border/50 disabled:opacity-20 disabled:cursor-not-allowed transition-all cursor-pointer',
              attributes: (currentPage >= totalPages || courses.isEmpty) ? {'disabled': ''} : {},
              onClick: () => onPageChange?.call(currentPage + 1),
              [Component.text('→')],
            ),
          ]),
        ]),
    ]);
  }

  static String _levelStyle(String? level) {
    return switch (level) {
      'beginner' => 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20',
      'intermediate' => 'bg-blue-500/10 text-blue-400 border border-blue-500/20',
      'advanced' || 'expert' => 'bg-purple-500/10 text-purple-400 border border-purple-500/20',
      _ => 'bg-dark-border/50 text-dark-muted',
    };
  }

  static String _getEmojiForCategory(String? category) {
    if (category == null) return '📚';
    final lower = category.toLowerCase();
    if (lower.contains('web') || lower.contains('frontend') || lower.contains('backend')) return '🌐';
    if (lower.contains('mobile') || lower.contains('android') || lower.contains('ios')) return '📱';
    if (lower.contains('data') || lower.contains('science') || lower.contains('analytics')) return '📊';
    if (lower.contains('design') || lower.contains('ui') || lower.contains('ux')) return '🎨';
    if (lower.contains('business') || lower.contains('marketing')) return '💼';
    if (lower.contains('devops') || lower.contains('cloud')) return '☁️';
    if (lower.contains('security') || lower.contains('cyber')) return '🛡️';
    if (lower.contains('ai') || lower.contains('machine') || lower.contains('learning')) return '🤖';
    return '📚';
  }
}
