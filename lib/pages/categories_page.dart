import 'dart:async';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:learnitin_admin/core/core.dart';
import 'package:learnitin_admin/core/utils/browser_utils.dart';
import 'package:learnitin_admin/models/course.dart';
import 'package:learnitin_admin/providers/auth_provider.dart';
import 'package:learnitin_admin/providers/category_provider.dart';

/// Categories Page allowing full administration of course categories and subcategories.
class CategoriesPage extends StatefulComponent {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  CourseCategory? _selectedCategory;

  // Search Filter
  String _categorySearch = '';
  String _searchInputVal = '';
  Timer? _debounceTimer;

  // Form inputs for Category Creation / Edit
  bool _showCategoryForm = false;
  CourseCategory? _editingCategory;
  String _categoryName = '';
  String _categoryDescription = '';

  // Form inputs for Subcategory Creation / Edit
  bool _showSubCategoryForm = false;
  CourseSubCategory? _editingSubCategory;
  String _subCategoryName = '';
  String _subCategoryDescription = '';

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _checkAuth() {
    final authState = context.read(authProvider);
    if (authState is AsyncData && authState.value == null) {
      Router.of(context).replace('/login');
    }
  }

  // --- Category Handlers ---
  void _openCreateCategoryForm() {
    setState(() {
      _showCategoryForm = true;
      _editingCategory = null;
      _categoryName = '';
      _categoryDescription = '';
    });
  }

  void _openEditCategoryForm(CourseCategory category) {
    setState(() {
      _showCategoryForm = true;
      _editingCategory = category;
      _categoryName = category.name ?? '';
      _categoryDescription = category.description ?? '';
    });
  }

  void _closeCategoryForm() {
    setState(() {
      _showCategoryForm = false;
      _editingCategory = null;
    });
  }

  void _handleCategorySubmit(CategoriesNotifier notifier) {
    if (_categoryName.trim().isEmpty) {
      context.showError('Category name cannot be empty');
      return;
    }

    context.showLoading();
    if (_editingCategory != null) {
      // Update Category
      notifier.updateCategory(
        categoryId: _editingCategory!.id!,
        body: CategoryUpdate(
          name: _categoryName.trim(),
          description: _categoryDescription.trim().isNotEmpty ? _categoryDescription.trim() : null,
        ),
        onSuccess: () {
          context.hideLoading();
          context.showSuccess('Category updated successfully');
          _closeCategoryForm();
          // Update selected category details if it was the one updated
          if (_selectedCategory?.id == _editingCategory!.id) {
            setState(() {
              _selectedCategory = CourseCategory(
                id: _editingCategory!.id,
                name: _categoryName.trim(),
                description: _categoryDescription.trim(),
                createdAt: _selectedCategory?.createdAt,
              );
            });
          }
        },
        onError: (msg, [st]) {
          context.hideLoading();
          context.showError(msg);
        },
      );
    } else {
      // Create Category
      notifier.createCategory(
        CategoryCreate(
          name: _categoryName.trim(),
          description: _categoryDescription.trim().isNotEmpty ? _categoryDescription.trim() : null,
        ),
        onSuccess: () {
          context.hideLoading();
          context.showSuccess('Category created successfully');
          _closeCategoryForm();
        },
        onError: (msg, [st]) {
          context.hideLoading();
          context.showError(msg);
        },
      );
    }
  }

  void _handleCategoryDelete(CategoriesNotifier notifier, CourseCategory category) {
    if (appConfirm(
      'Are you sure you want to delete the category "${category.name}"? This will detach any associated subcategories.',
    )) {
      context.showLoading();
      notifier.deleteCategory(
        categoryId: category.id!,
        onSuccess: () {
          context.hideLoading();
          context.showSuccess('Category deleted successfully');
          if (_selectedCategory?.id == category.id) {
            setState(() {
              _selectedCategory = null;
            });
          }
        },
        onError: (msg, [st]) {
          context.hideLoading();
          context.showError(msg);
        },
      );
    }
  }

  // --- Subcategory Handlers ---
  void _openCreateSubCategoryForm() {
    if (_selectedCategory == null) return;
    setState(() {
      _showSubCategoryForm = true;
      _editingSubCategory = null;
      _subCategoryName = '';
      _subCategoryDescription = '';
    });
  }

  void _openEditSubCategoryForm(CourseSubCategory subCategory) {
    setState(() {
      _showSubCategoryForm = true;
      _editingSubCategory = subCategory;
      _subCategoryName = subCategory.name ?? '';
      _subCategoryDescription = subCategory.description ?? '';
    });
  }

  void _closeSubCategoryForm() {
    setState(() {
      _showSubCategoryForm = false;
      _editingSubCategory = null;
    });
  }

  void _handleSubCategorySubmit(SubCategoriesNotifier notifier) {
    if (_subCategoryName.trim().isEmpty) {
      context.showError('Subcategory name cannot be empty');
      return;
    }
    if (_selectedCategory == null) return;

    context.showLoading();
    if (_editingSubCategory != null) {
      // Update Subcategory
      notifier.updateSubCategory(
        subCategoryId: _editingSubCategory!.id!,
        body: SubCategoryUpdate(
          name: _subCategoryName.trim(),
          description: _subCategoryDescription.trim().isNotEmpty ? _subCategoryDescription.trim() : null,
          categoryId: _selectedCategory!.id,
        ),
        onSuccess: () {
          context.hideLoading();
          context.showSuccess('Subcategory updated successfully');
          _closeSubCategoryForm();
        },
        onError: (msg, [st]) {
          context.hideLoading();
          context.showError(msg);
        },
      );
    } else {
      // Create Subcategory
      notifier.createSubCategory(
        SubCategoryCreate(
          name: _subCategoryName.trim(),
          description: _subCategoryDescription.trim().isNotEmpty ? _subCategoryDescription.trim() : null,
          categoryId: _selectedCategory!.id,
        ),
        onSuccess: () {
          context.hideLoading();
          context.showSuccess('Subcategory created successfully');
          _closeSubCategoryForm();
        },
        onError: (msg, [st]) {
          context.hideLoading();
          context.showError(msg);
        },
      );
    }
  }

  void _handleSubCategoryDelete(SubCategoriesNotifier notifier, CourseSubCategory subCategory) {
    if (appConfirm('Are you sure you want to delete the subcategory "${subCategory.name}"?')) {
      context.showLoading();
      notifier.deleteSubCategory(
        subCategoryId: subCategory.id!,
        onSuccess: () {
          context.hideLoading();
          context.showSuccess('Subcategory deleted successfully');
        },
        onError: (msg, [st]) {
          context.hideLoading();
          context.showError(msg);
        },
      );
    }
  }

  // --- Premium Redesign Helpers ---
  String _getAvatarText(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0].substring(0, parts[0].length > 1 ? 2 : 1).toUpperCase();
  }

  List<String> _getAvatarGradient(String? name) {
    if (name == null || name.trim().isEmpty) {
      return ['from-violet-500', 'to-indigo-500'];
    }
    final hash = name.codeUnits.fold(0, (prev, element) => prev + element);
    final gradients = [
      ['from-violet-500', 'to-indigo-500'],
      ['from-fuchsia-500', 'to-pink-500'],
      ['from-emerald-500', 'to-teal-500'],
      ['from-cyan-500', 'to-blue-500'],
      ['from-amber-500', 'to-orange-500'],
      ['from-rose-500', 'to-red-500'],
      ['from-purple-500', 'to-indigo-600'],
      ['from-sky-500', 'to-indigo-500'],
    ];
    return gradients[hash % gradients.length];
  }

  @override
  Component build(BuildContext context) {
    final authState = context.watch(authProvider);

    if (authState is AsyncData && authState.value == null) {
      Future.microtask(() => Router.of(context).replace('/login'));
      return div([]);
    }

    if (authState.isLoading) {
      return div(classes: 'flex items-center justify-center min-h-[60vh]', [
        div(classes: 'w-12 h-12 border-4 border-primary border-t-transparent rounded-full animate-spin', []),
      ]);
    }

    final categoriesAsync = context.watch(categoriesProvider(_categorySearch));
    final categoriesNotifier = context.read(categoriesProvider(_categorySearch).notifier);

    final subCategoriesAsync = context.watch(subCategoriesProvider);
    final subCategoriesNotifier = context.read(subCategoriesProvider.notifier);

    return div(classes: 'flex-1 space-y-8 pb-12 min-h-screen text-white', [
      // ── Page Header Banner ──────────────────────────────────────────
      div(
        classes:
            'relative overflow-hidden rounded-3xl bg-gradient-to-br from-primary-950/40 via-primary-900/20 to-dark-card border border-primary/10 p-6 md:p-8 shadow-xl shadow-black/10',
        [
          // Decorative glowing orbs
          div(
            classes:
                'absolute -top-16 -right-16 w-48 h-48 bg-primary/15 rounded-full blur-3xl animate-pulse duration-4000',
            [],
          ),
          div(classes: 'absolute -bottom-16 -left-16 w-40 h-40 bg-blue-500/10 rounded-full blur-3xl', []),

          // Banner Content
          div(classes: 'relative z-10 flex flex-col md:flex-row md:items-center md:justify-between gap-6', [
            div(classes: 'space-y-3', [
              div(
                classes:
                    'inline-flex items-center space-x-2 px-3 py-1 rounded-full bg-primary/10 border border-primary/20 text-xs font-semibold text-primary tracking-wide uppercase',
                [
                  span([Component.text('🏷️')]),
                  span([Component.text('Taxonomy Hub')]),
                ],
              ),
              h1(classes: 'text-3xl md:text-4xl font-extrabold text-white tracking-tight', [
                Component.text('Categories & Subcategories'),
              ]),
              p(classes: 'text-dark-muted text-sm md:text-base max-w-2xl leading-relaxed', [
                Component.text(
                  'Structure your educational catalog. Define parent learning domains, map precise content sub-channels, and manage course classifications.',
                ),
              ]),
            ]),
            div(classes: 'flex items-center gap-3 shrink-0', [
              button(
                classes:
                    'px-4 py-2.5 bg-dark-card/60 border border-dark-border rounded-xl text-sm font-semibold hover:text-white transition-all hover:bg-dark-card flex items-center space-x-2 cursor-pointer shadow-md hover:border-white/20',
                onClick: () {
                  categoriesNotifier.refresh();
                  if (_selectedCategory != null) {
                    subCategoriesNotifier.refresh();
                  }
                },
                [
                  span(classes: 'text-xs', [Component.text('🔄')]),
                  span([Component.text('Refresh All')]),
                ],
              ),
              button(
                classes:
                    'px-5 py-2.5 bg-primary text-black rounded-xl text-sm font-bold hover:shadow-lg hover:shadow-primary/25 transition-all hover:-translate-y-0.5 flex items-center space-x-2 cursor-pointer',
                onClick: _openCreateCategoryForm,
                [
                  span(classes: 'text-xs', [Component.text('➕')]),
                  span([Component.text('New Category')]),
                ],
              ),
            ]),
          ]),
        ],
      ),

      // ── Modals Section (Centered Full Overlay Modals) ──────────────────────
      if (_showCategoryForm)
        div(
          classes:
              'fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/85 backdrop-blur-md animate-in fade-in duration-200',
          [
            div(
              classes:
                  'w-full max-w-lg card overflow-hidden border border-primary/20 bg-dark-card/95 shadow-2xl shadow-primary/10 space-y-5 animate-in zoom-in-95 duration-250 rounded-2xl',
              [
                // Modal Header with top primary colored border line
                div(
                  classes:
                      'relative bg-gradient-to-r from-primary/10 to-transparent p-5 pb-4 border-b border-white/5 flex justify-between items-center',
                  [
                    div(classes: 'absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-primary to-primary-700', []),
                    h3(classes: 'text-lg font-bold text-white tracking-tight', [
                      Component.text(_editingCategory != null ? 'Edit Category' : 'Create New Category'),
                    ]),
                    button(
                      classes:
                          'text-dark-muted hover:text-white transition-colors cursor-pointer text-sm p-1 rounded-full hover:bg-white/5',
                      onClick: _closeCategoryForm,
                      [Component.text('✕')],
                    ),
                  ],
                ),

                // Modal Body
                div(classes: 'p-5 pt-0 space-y-4', [
                  div(classes: 'space-y-1.5', [
                    label(classes: 'text-xs font-bold uppercase tracking-wider text-dark-muted', [
                      Component.text('Category Name'),
                    ]),
                    input<String>(
                      type: InputType.text,
                      classes:
                          'w-full bg-dark-bg border border-dark-border rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-primary/50 transition-all focus:bg-dark-bg/80 placeholder:text-dark-muted/50',
                      attributes: {'placeholder': 'e.g. Software Engineering', 'autofocus': 'true'},
                      value: _categoryName,
                      onInput: (val) => _categoryName = val,
                    ),
                  ]),
                  div(classes: 'space-y-1.5', [
                    label(classes: 'text-xs font-bold uppercase tracking-wider text-dark-muted', [
                      Component.text('Description'),
                    ]),
                    input<String>(
                      type: InputType.text,
                      classes:
                          'w-full bg-dark-bg border border-dark-border rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-primary/50 transition-all focus:bg-dark-bg/80 placeholder:text-dark-muted/50',
                      attributes: {
                        'placeholder': 'e.g. Master code syntax, paradigms, algorithms and development tools.',
                      },
                      value: _categoryDescription,
                      onInput: (val) => _categoryDescription = val,
                    ),
                  ]),
                ]),

                // Modal Actions Footer
                div(classes: 'bg-dark-bg/40 px-5 py-4 border-t border-white/5 flex justify-end space-x-2.5', [
                  button(
                    classes:
                        'px-4 py-2.5 bg-white/5 border border-dark-border rounded-xl text-sm font-semibold hover:bg-white/10 hover:text-white transition-all cursor-pointer',
                    onClick: _closeCategoryForm,
                    [Component.text('Cancel')],
                  ),
                  button(
                    classes:
                        'px-5 py-2.5 bg-primary text-black rounded-xl text-sm font-bold hover:shadow-lg transition-all cursor-pointer hover:shadow-primary/20 hover:-translate-y-0.5',
                    onClick: () => _handleCategorySubmit(categoriesNotifier),
                    [Component.text(_editingCategory != null ? 'Save Changes' : 'Create Category')],
                  ),
                ]),
              ],
            ),
          ],
        ),

      if (_showSubCategoryForm)
        div(
          classes:
              'fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/85 backdrop-blur-md animate-in fade-in duration-200',
          [
            div(
              classes:
                  'w-full max-w-lg card overflow-hidden border border-blue-500/20 bg-dark-card/95 shadow-2xl shadow-blue-500/10 space-y-5 animate-in zoom-in-95 duration-250 rounded-2xl',
              [
                // Modal Header with top blue colored border line
                div(
                  classes:
                      'relative bg-gradient-to-r from-blue-500/10 to-transparent p-5 pb-4 border-b border-white/5 flex justify-between items-center',
                  [
                    div(classes: 'absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-blue-500 to-blue-700', []),
                    h3(classes: 'text-lg font-bold text-white tracking-tight', [
                      Component.text(_editingSubCategory != null ? 'Edit Subcategory' : 'Add Subcategory'),
                    ]),
                    button(
                      classes:
                          'text-dark-muted hover:text-white transition-colors cursor-pointer text-sm p-1 rounded-full hover:bg-white/5',
                      onClick: _closeSubCategoryForm,
                      [Component.text('✕')],
                    ),
                  ],
                ),

                // Modal Body
                div(classes: 'p-5 pt-0 space-y-4', [
                  div(classes: 'space-y-1.5', [
                    label(classes: 'text-xs font-bold uppercase tracking-wider text-dark-muted', [
                      Component.text('Subcategory Name'),
                    ]),
                    input<String>(
                      type: InputType.text,
                      classes:
                          'w-full bg-dark-bg border border-dark-border rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-blue-500/50 transition-all focus:bg-dark-bg/80 placeholder:text-dark-muted/50',
                      attributes: {'placeholder': 'e.g. Flutter & Dart', 'autofocus': 'true'},
                      value: _subCategoryName,
                      onInput: (val) => _subCategoryName = val,
                    ),
                  ]),
                  div(classes: 'space-y-1.5', [
                    label(classes: 'text-xs font-bold uppercase tracking-wider text-dark-muted', [
                      Component.text('Subcategory Description'),
                    ]),
                    input<String>(
                      type: InputType.text,
                      classes:
                          'w-full bg-dark-bg border border-dark-border rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-blue-500/50 transition-all focus:bg-dark-bg/80 placeholder:text-dark-muted/50',
                      attributes: {'placeholder': 'e.g. Build multiplatform native apps with beautiful custom UI.'},
                      value: _subCategoryDescription,
                      onInput: (val) => _subCategoryDescription = val,
                    ),
                  ]),
                ]),

                // Modal Actions Footer
                div(classes: 'bg-dark-bg/40 px-5 py-4 border-t border-white/5 flex justify-end space-x-2.5', [
                  button(
                    classes:
                        'px-4 py-2.5 bg-white/5 border border-dark-border rounded-xl text-sm font-semibold hover:bg-white/10 hover:text-white transition-all cursor-pointer',
                    onClick: _closeSubCategoryForm,
                    [Component.text('Cancel')],
                  ),
                  button(
                    classes:
                        'px-5 py-2.5 bg-blue-600 text-white rounded-xl text-sm font-bold hover:shadow-lg transition-all cursor-pointer hover:shadow-blue-500/20 hover:-translate-y-0.5 hover:bg-blue-500',
                    onClick: () => _handleSubCategorySubmit(subCategoriesNotifier),
                    [Component.text(_editingSubCategory != null ? 'Save Changes' : 'Create Subcategory')],
                  ),
                ]),
              ],
            ),
          ],
        ),

      // ── Main Master-Detail Workspace ─────────────────────────────
      div(classes: 'grid grid-cols-1 lg:grid-cols-12 gap-8 items-start', [
        // ── Navigation Index Column (5 cols) ──
        div(
          classes:
              'lg:col-span-5 space-y-4 bg-dark-card/10 border border-dark-border/40 rounded-3xl p-4 md:p-5 backdrop-blur-md shadow-sm',
          [
            div(classes: 'flex justify-between items-center px-1', [
              h3(classes: 'text-lg font-bold text-white flex items-center space-x-2.5', [
                span(classes: 'w-2 h-2 rounded-full bg-primary shadow-sm shadow-primary animate-pulse', []),
                span([Component.text('Categories Index')]),
              ]),
              span(
                classes:
                    'text-xs px-2.5 py-0.5 rounded-full bg-white/5 border border-white/10 text-dark-muted font-mono font-medium',
                [
                  categoriesAsync.when(
                    data: (cats) => Component.text('${cats.length} listed'),
                    loading: () => Component.text('...'),
                    error: (_, __) => Component.text('0'),
                  ),
                ],
              ),
            ]),

            // Premium Search Bar with clean state transitions
            div(classes: 'relative w-full group', [
              span(
                classes:
                    'absolute left-3.5 top-3.5 text-dark-muted text-sm transition-colors group-focus-within:text-primary',
                [Component.text('🔍')],
              ),
              input<String>(
                type: InputType.text,
                classes:
                    'w-full bg-dark-bg/60 border border-dark-border rounded-xl pl-10 pr-10 py-3 text-sm text-white focus:outline-none focus:border-primary/50 transition-all placeholder:text-dark-muted/50 focus:bg-dark-bg/85 focus:shadow-inner',
                attributes: {'placeholder': 'Search categories...'},
                value: _searchInputVal,
                onInput: (val) {
                  _searchInputVal = val;
                  _debounceTimer?.cancel();
                  _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                    setState(() {
                      _categorySearch = _searchInputVal;
                    });
                  });
                },
              ),
              if (_searchInputVal.isNotEmpty)
                button(
                  classes:
                      'absolute right-3.5 top-3.5 text-dark-muted hover:text-white transition-colors cursor-pointer text-xs p-1 rounded-full hover:bg-white/5',
                  onClick: () {
                    setState(() {
                      _searchInputVal = '';
                      _categorySearch = '';
                    });
                  },
                  [Component.text('✕')],
                ),
            ]),

            // Category Collection Loading / Data rendering
            categoriesAsync.when(
              data: (categories) {
                final filtered = categories.where((c) {
                  if (_categorySearch.isEmpty) return true;
                  final term = _categorySearch.toLowerCase();
                  return (c.name ?? '').toLowerCase().contains(term) ||
                      (c.description ?? '').toLowerCase().contains(term);
                }).toList();

                if (filtered.isEmpty) {
                  return div(
                    classes:
                        'card py-20 flex flex-col items-center justify-center border border-dashed border-dark-border bg-transparent text-center space-y-4 rounded-2xl',
                    [
                      span(classes: 'text-3xl filter saturate-50', [Component.text('🏷️')]),
                      div(classes: 'space-y-1', [
                        h4(classes: 'text-sm font-bold text-white', [Component.text('No categories found')]),
                        p(classes: 'text-dark-muted text-xs max-w-[240px]', [
                          Component.text('No results match your current filter query.'),
                        ]),
                      ]),
                    ],
                  );
                }

                return div(classes: 'space-y-3', [
                  for (final cat in filtered)
                    div(
                      classes:
                          'relative overflow-hidden border rounded-2xl transition-all duration-300 cursor-pointer p-4 group flex items-start justify-between '
                          '${_selectedCategory?.id == cat.id ? 'bg-primary/[0.03] border-primary/45 shadow-lg shadow-primary/5' : 'border-dark-border/50 bg-dark-card/30 hover:bg-dark-card/50 hover:border-dark-border/80 hover:-translate-y-0.5'}',
                      events: {
                        'click': (e) {
                          setState(() {
                            _selectedCategory = cat;
                          });
                          // Filter subcategories provider
                          subCategoriesNotifier.setCategoryFilter(cat.id);
                          _closeSubCategoryForm();
                        },
                      },
                      [
                        // Dynamic selected gradient indicator sidebar
                        if (_selectedCategory?.id == cat.id)
                          div(
                            classes:
                                'absolute left-0 top-0 bottom-0 w-1.5 bg-gradient-to-b from-primary to-primary-700',
                            [],
                          ),

                        div(classes: 'flex items-start space-x-3.5 flex-1 min-w-0 pr-3', [
                          // Letter Avatar with unique dynamic gradient colors
                          div(
                            classes:
                                'w-10 h-10 rounded-xl bg-gradient-to-br ${_getAvatarGradient(cat.name).join(" ")} flex items-center justify-center text-xs font-black text-black shrink-0 shadow-md shadow-black/10 group-hover:scale-105 transition-transform duration-300',
                            [
                              Component.text(_getAvatarText(cat.name)),
                            ],
                          ),
                          div(classes: 'space-y-1 flex-1 min-w-0', [
                            h4(
                              classes:
                                  'font-semibold text-white group-hover:text-primary transition-all truncate text-base leading-snug',
                              [
                                Component.text(cat.name ?? 'Unnamed Category'),
                              ],
                            ),
                            p(classes: 'text-xs text-dark-muted line-clamp-2 leading-relaxed font-normal', [
                              Component.text(cat.description ?? 'No description provided.'),
                            ]),
                          ]),
                        ]),

                        // Beautiful mini buttons for CRUD operations (visible on hover)
                        div(
                          classes:
                              'flex items-center space-x-1 shrink-0 opacity-0 group-hover:opacity-100 focus-within:opacity-100 transition-opacity duration-200',
                          [
                            button(
                              classes:
                                  'p-2 rounded-xl bg-white/5 border border-white/5 text-dark-muted hover:text-white hover:bg-white/10 hover:border-white/10 transition-all cursor-pointer shadow-sm',
                              events: {
                                'click': (e) {
                                  e.stopPropagation();
                                  _openEditCategoryForm(cat);
                                },
                              },
                              [Component.text('✏️')],
                            ),
                            button(
                              classes:
                                  'p-2 rounded-xl bg-red-500/5 border border-red-500/10 text-red-400/60 hover:text-red-400 hover:bg-red-500/10 hover:border-red-500/20 transition-all cursor-pointer shadow-sm',
                              events: {
                                'click': (e) {
                                  e.stopPropagation();
                                  _handleCategoryDelete(categoriesNotifier, cat);
                                },
                              },
                              [Component.text('🗑️')],
                            ),
                          ],
                        ),
                      ],
                    ),
                  if (categoriesNotifier.hasMore)
                    div(classes: 'flex justify-center pt-2', [
                      button(
                        classes:
                            'px-4 py-2 bg-white/5 border border-white/10 rounded-xl text-xs font-semibold hover:bg-white/10 hover:text-white hover:border-white/20 transition-all cursor-pointer',
                        onClick: () => categoriesNotifier.loadMore(),
                        [Component.text('📥 Load More Categories')],
                      ),
                    ]),
                ]);
              },
              loading: () => div(classes: 'space-y-3', [
                for (var i = 0; i < 4; i++)
                  div(
                    classes:
                        'card border border-dark-border/40 bg-dark-card/45 p-4 animate-pulse space-y-3 rounded-2xl',
                    [
                      div(classes: 'flex items-center space-x-3.5', [
                        div(classes: 'w-10 h-10 rounded-xl bg-white/5 shrink-0', []),
                        div(classes: 'flex-1 space-y-2', [
                          div(classes: 'h-4 bg-white/10 rounded w-1/2', []),
                          div(classes: 'h-3 bg-white/5 rounded w-3/4', []),
                        ]),
                      ]),
                    ],
                  ),
              ]),
              error: (e, __) => div(
                classes: 'card p-6 border border-red-500/20 text-center space-y-3 bg-red-500/5 rounded-2xl',
                [
                  p(classes: 'text-red-400 text-sm leading-relaxed', [Component.text(e.toFriendlyMessage())]),
                  button(
                    classes:
                        'px-4 py-2 bg-red-500/20 border border-red-500/30 text-red-400 rounded-xl text-xs hover:bg-red-500/30 transition-all cursor-pointer',
                    onClick: () => categoriesNotifier.refresh(),
                    [Component.text('Retry')],
                  ),
                ],
              ),
            ),
          ],
        ),

        // ── Details Workspace Column (7 cols) ──
        div(classes: 'lg:col-span-7 space-y-6', [
          if (_selectedCategory == null)
            div(
              classes:
                  'relative overflow-hidden card border border-dashed border-dark-border/60 bg-dark-card/10 py-36 px-6 text-center flex flex-col items-center justify-center space-y-5 rounded-3xl',
              [
                // Ambient background blur blob
                div(
                  classes:
                      'absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-72 h-72 bg-blue-500/5 rounded-full blur-3xl -z-10',
                  [],
                ),

                div(
                  classes:
                      'w-20 h-20 rounded-2xl bg-blue-500/5 border border-blue-500/10 flex items-center justify-center text-4xl shadow-inner shadow-blue-500/5 animate-pulse duration-3000',
                  [
                    Component.text('📂'),
                  ],
                ),
                div(classes: 'space-y-2 max-w-sm', [
                  h4(classes: 'text-xl font-bold text-white tracking-tight', [Component.text('Select a Category')]),
                  p(classes: 'text-dark-muted text-sm leading-relaxed', [
                    Component.text(
                      'Choose a parent category from the navigation index on the left to examine its parameters and build mapping channels.',
                    ),
                  ]),
                ]),
                div(
                  classes:
                      'flex items-center space-x-2 text-xs text-dark-muted/60 font-medium bg-dark-card/30 border border-dark-border/40 px-3.5 py-1.5 rounded-full',
                  [
                    span(classes: 'w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse', []),
                    span([Component.text('Keep hierarchical taxonomy structures aligned.')]),
                  ],
                ),
              ],
            )
          else ...[
            // Context header for active selected category
            div(
              classes:
                  'relative overflow-hidden rounded-2xl bg-gradient-to-br from-blue-950/20 via-blue-900/10 to-dark-card border border-blue-500/20 p-5 shadow-lg shadow-black/5 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4',
              [
                div(classes: 'absolute -right-8 -bottom-8 w-24 h-24 bg-blue-500/5 rounded-full blur-2xl', []),
                div(classes: 'space-y-1.5 flex-1 min-w-0 pr-4', [
                  div(classes: 'flex items-center space-x-2.5', [
                    div(classes: 'w-2 h-2 rounded-full bg-blue-500 animate-ping', []),
                    h3(classes: 'text-lg font-bold text-white tracking-tight truncate', [
                      Component.text(_selectedCategory!.name ?? 'Selected Category'),
                    ]),
                  ]),
                  p(classes: 'text-xs text-dark-muted line-clamp-2 leading-relaxed', [
                    Component.text(_selectedCategory!.description ?? 'No description defined for this category.'),
                  ]),
                ]),
                button(
                  classes:
                      'px-4 py-2.5 bg-blue-600 hover:bg-blue-500 text-white rounded-xl text-xs font-bold hover:shadow-lg hover:shadow-blue-500/20 transition-all hover:-translate-y-0.5 shrink-0 flex items-center space-x-1.5 cursor-pointer',
                  onClick: _openCreateSubCategoryForm,
                  [
                    span(classes: 'text-[10px]', [Component.text('➕')]),
                    span([Component.text('Add Subcategory')]),
                  ],
                ),
              ],
            ),

            // Subcategories Async content rendering
            subCategoriesAsync.when(
              data: (subCategories) {
                if (subCategories.isEmpty) {
                  return div(
                    classes:
                        'card py-24 px-6 text-center flex flex-col items-center justify-center space-y-4 bg-dark-card/10 border border-dashed border-dark-border/60 rounded-2xl',
                    [
                      div(
                        classes:
                            'w-16 h-16 rounded-2xl bg-white/5 border border-white/10 flex items-center justify-center text-3xl shadow-inner',
                        [
                          Component.text('🗂️'),
                        ],
                      ),
                      div(classes: 'space-y-1.5 max-w-sm', [
                        h4(classes: 'text-lg font-bold text-white tracking-tight', [
                          Component.text('No Subcategories Yet'),
                        ]),
                        p(classes: 'text-dark-muted text-xs leading-relaxed', [
                          Component.text(
                            'There are no subcategories mapped to this section. Get started by creating the first sub-channel layout.',
                          ),
                        ]),
                      ]),
                      button(
                        classes:
                            'px-4 py-2.5 bg-blue-500/10 border border-blue-500/25 text-blue-400 rounded-xl text-xs font-semibold hover:bg-blue-500/20 transition-all cursor-pointer',
                        onClick: _openCreateSubCategoryForm,
                        [Component.text('Create First Subcategory')],
                      ),
                    ],
                  );
                }

                return div(classes: 'grid grid-cols-1 sm:grid-cols-2 gap-4', [
                  for (final sub in subCategories)
                    div(
                      classes:
                          'relative group border border-dark-border/50 hover:border-blue-500/40 bg-dark-card/25 p-5 rounded-2xl transition-all duration-300 hover:bg-dark-card/45 flex flex-col justify-between space-y-4 hover:-translate-y-0.5 hover:shadow-xl hover:shadow-blue-500/[0.02]',
                      [
                        div(classes: 'space-y-1.5 min-w-0', [
                          h4(
                            classes:
                                'font-semibold text-white group-hover:text-blue-400 transition-colors truncate text-base leading-snug',
                            [
                              Component.text(sub.name ?? 'Unnamed Subcategory'),
                            ],
                          ),
                          p(classes: 'text-xs text-dark-muted line-clamp-3 leading-relaxed font-normal', [
                            Component.text(sub.description ?? 'No description defined.'),
                          ]),
                        ]),
                        div(classes: 'flex justify-between items-center pt-3 border-t border-white/5', [
                          span(
                            classes:
                                'text-[9px] bg-blue-500/10 text-blue-400 border border-blue-500/20 font-bold px-2.5 py-0.5 rounded-full uppercase tracking-wider',
                            [
                              Component.text('Subchannel'),
                            ],
                          ),
                          div(
                            classes:
                                'flex items-center space-x-1 shrink-0 opacity-0 group-hover:opacity-100 focus-within:opacity-100 transition-opacity duration-200',
                            [
                              button(
                                classes:
                                    'p-1.5 rounded-lg bg-white/5 border border-white/5 text-dark-muted hover:text-white hover:bg-white/10 hover:border-white/10 transition-all cursor-pointer shadow-sm',
                                onClick: () => _openEditSubCategoryForm(sub),
                                [Component.text('✏️')],
                              ),
                              button(
                                classes:
                                    'p-1.5 rounded-lg bg-red-500/5 border border-red-500/10 text-red-400/60 hover:text-red-400 hover:bg-red-500/10 hover:border-red-500/20 transition-all cursor-pointer shadow-sm',
                                onClick: () => _handleSubCategoryDelete(subCategoriesNotifier, sub),
                                [Component.text('🗑️')],
                              ),
                            ],
                          ),
                        ]),
                      ],
                    ),
                ]);
              },
              loading: () => div(classes: 'grid grid-cols-1 sm:grid-cols-2 gap-4', [
                for (var i = 0; i < 4; i++)
                  div(
                    classes:
                        'card border border-dark-border/40 bg-dark-card/45 p-5 animate-pulse space-y-4 rounded-2xl',
                    [
                      div(classes: 'space-y-2', [
                        div(classes: 'h-4 bg-white/10 rounded w-2/3', []),
                        div(classes: 'h-3 bg-white/5 rounded w-full', []),
                        div(classes: 'h-3 bg-white/5 rounded w-5/6', []),
                      ]),
                      div(classes: 'h-6 bg-white/5 rounded w-1/4 pt-2', []),
                    ],
                  ),
              ]),
              error: (e, __) => div(
                classes: 'card p-6 border border-red-500/20 text-center space-y-3 bg-red-500/5 rounded-2xl',
                [
                  p(classes: 'text-red-400 text-sm leading-relaxed', [Component.text(e.toFriendlyMessage())]),
                  button(
                    classes:
                        'px-4 py-2 bg-red-500/20 border border-red-500/30 text-red-400 rounded-xl text-xs hover:bg-red-500/30 transition-all cursor-pointer',
                    onClick: () => subCategoriesNotifier.refresh(),
                    [Component.text('Retry')],
                  ),
                ],
              ),
            ),
          ],
        ]),
      ]),
    ]);
  }
}
