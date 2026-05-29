import 'dart:async';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:learnitin_admin/components/category_side_panel.dart';
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
  String _categoryImageUrl = '';

  // Form inputs for Subcategory Creation / Edit
  bool _showSubCategoryForm = false;
  CourseSubCategory? _editingSubCategory;
  String _subCategoryName = '';
  String _subCategoryDescription = '';
  String _subCategoryImageUrl = '';

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
      _categoryImageUrl = '';
    });
  }

  void _openEditCategoryForm(CourseCategory category) {
    setState(() {
      _showCategoryForm = true;
      _editingCategory = category;
      _categoryName = category.name ?? '';
      _categoryDescription = category.description ?? '';
      _categoryImageUrl = category.imageUrl ?? '';
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
      notifier.updateCategory(
        categoryId: _editingCategory!.id!,
        body: CategoryUpdate(
          name: _categoryName.trim(),
          description: _categoryDescription.trim().isNotEmpty ? _categoryDescription.trim() : null,
          imageUrl: _categoryImageUrl.trim().isNotEmpty ? _categoryImageUrl.trim() : null,
        ),
        onSuccess: () {
          context.hideLoading();
          context.showSuccess('Category updated successfully');
          if (_selectedCategory?.id == _editingCategory!.id) {
            setState(() {
              _selectedCategory = CourseCategory(
                id: _editingCategory!.id,
                name: _categoryName.trim(),
                description: _categoryDescription.trim().isNotEmpty ? _categoryDescription.trim() : null,
                imageUrl: _categoryImageUrl.trim().isNotEmpty ? _categoryImageUrl.trim() : null,
                createdAt: _selectedCategory?.createdAt,
              );
            });
          }
          _closeCategoryForm();
        },
        onError: (msg, [st]) {
          context.hideLoading();
          context.showError(msg);
        },
      );
    } else {
      notifier.createCategory(
        CategoryCreate(
          name: _categoryName.trim(),
          description: _categoryDescription.trim().isNotEmpty ? _categoryDescription.trim() : null,
          imageUrl: _categoryImageUrl.trim().isNotEmpty ? _categoryImageUrl.trim() : null,
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
            setState(() => _selectedCategory = null);
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
  void _openCreateSubCategoryFormFor(CourseCategory category) {
    setState(() {
      _selectedCategory = category;
      _showSubCategoryForm = true;
      _editingSubCategory = null;
      _subCategoryName = '';
      _subCategoryDescription = '';
      _subCategoryImageUrl = '';
    });
  }

  void _openEditSubCategoryFormFor(CourseCategory category, CourseSubCategory subCategory) {
    setState(() {
      _selectedCategory = category;
      _showSubCategoryForm = true;
      _editingSubCategory = subCategory;
      _subCategoryName = subCategory.name ?? '';
      _subCategoryDescription = subCategory.description ?? '';
      _subCategoryImageUrl = subCategory.imageUrl ?? '';
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
      notifier.updateSubCategory(
        subCategoryId: _editingSubCategory!.id!,
        body: SubCategoryUpdate(
          name: _subCategoryName.trim(),
          description: _subCategoryDescription.trim().isNotEmpty ? _subCategoryDescription.trim() : null,
          categoryId: _selectedCategory!.id,
          imageUrl: _subCategoryImageUrl.trim().isNotEmpty ? _subCategoryImageUrl.trim() : null,
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
      notifier.createSubCategory(
        SubCategoryCreate(
          name: _subCategoryName.trim(),
          description: _subCategoryDescription.trim().isNotEmpty ? _subCategoryDescription.trim() : null,
          categoryId: _selectedCategory!.id,
          imageUrl: _subCategoryImageUrl.trim().isNotEmpty ? _subCategoryImageUrl.trim() : null,
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

  // --- Helpers ---

  Component _buildModal({
    required String title,
    required VoidCallback onClose,
    required VoidCallback onSubmit,
    required String submitText,
    required List<Component> body,
  }) {
    return div(
      classes: 'fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/85 backdrop-blur-sm animate-in fade-in duration-200',
      [
        div(
          classes: 'w-full max-w-lg overflow-hidden border border-dark-border bg-dark-card shadow-2xl rounded-2xl flex flex-col',
          [
            // Header
            div(classes: 'px-6 py-4 border-b border-dark-border flex justify-between items-center', [
              h3(classes: 'text-lg font-bold text-white tracking-tight', [Component.text(title)]),
              button(
                classes: 'text-dark-muted hover:text-white transition-colors cursor-pointer text-sm p-2 rounded-lg hover:bg-white/5',
                onClick: onClose,
                [Component.text('✕')],
              ),
            ]),
            // Body
            div(classes: 'p-6 space-y-6', body),
            // Footer
            div(classes: 'px-6 py-4 border-t border-dark-border flex justify-end space-x-3', [
              button(
                classes: 'px-4 py-2 bg-dark-border/50 rounded-xl text-sm font-semibold hover:bg-dark-border hover:text-white transition-all cursor-pointer text-dark-muted',
                onClick: onClose,
                [Component.text('Cancel')],
              ),
              button(
                classes: 'px-6 py-2 bg-primary text-black rounded-xl text-sm font-bold hover:shadow-lg hover:shadow-primary/20 hover:-translate-y-0.5 transition-all cursor-pointer',
                onClick: onSubmit,
                [Component.text(submitText)],
              ),
            ]),
          ],
        ),
      ],
    );
  }

  Component _buildFormField(
    String fieldLabel,
    String placeholder,
    String value,
    void Function(String) onInput,
  ) {
    return div(classes: 'space-y-2', [
      label(classes: 'text-xs font-semibold uppercase tracking-wider text-dark-muted', [
        Component.text(fieldLabel),
      ]),
      input<String>(
        type: InputType.text,
        classes: 'w-full bg-dark-bg border border-dark-border rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-primary/50 transition-all placeholder:text-dark-muted',
        attributes: {'placeholder': placeholder},
        value: value,
        onInput: onInput,
      ),
    ]);
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

    return div(classes: 'space-y-6 pb-8', [
      // ══════════════════════════════════════════════════════════════
      //  HEADER BAR — clean, no card wrapper
      // ══════════════════════════════════════════════════════════════
      div(
        classes: 'flex flex-col md:flex-row md:items-center md:justify-between gap-4',
        [
          div(classes: 'space-y-1', [
            h1(classes: 'text-2xl font-bold text-white tracking-tight', [
              Component.text('Categories'),
            ]),
            p(classes: 'text-dark-muted text-sm', [
              Component.text('Organize and manage your course classifications.'),
            ]),
          ]),
          div(classes: 'flex items-center gap-3', [
            categoriesAsync.when(
              data: (cats) => span(classes: 'text-xs font-medium text-dark-muted bg-white/5 px-3 py-1.5 rounded-lg', [
                Component.text('${cats.length} categories'),
              ]),
              loading: () => span(classes: 'text-xs font-medium text-dark-muted', [
                Component.text('Loading...'),
              ]),
              error: (_, __) => span(classes: 'text-xs text-dark-muted', [Component.text('—')]),
            ),
            button(
              classes: 'btn-primary flex items-center space-x-2 rounded-xl text-sm',
              onClick: _openCreateCategoryForm,
              [
                span([Component.text('➕')]),
                span([Component.text('New Category')]),
              ],
            ),
          ]),
        ],
      ),

      // ══════════════════════════════════════════════════════════════
      //  SEARCH & CONTROLS — borderless, subtle fill
      // ══════════════════════════════════════════════════════════════
      div(classes: 'flex flex-col md:flex-row md:items-center justify-between gap-3', [
        // Search — border around search bar only, icon cleanly positioned
        div(classes: 'relative flex-1 max-w-md border border-dark-border bg-white/5 rounded-xl flex items-center px-4 py-1', [
          span(classes: 'text-dark-muted text-sm mr-2.5 flex items-center justify-center pointer-events-none', [Component.text('🔍')]),
          input<String>(
            type: InputType.text,
            classes: 'w-full bg-transparent border-none rounded-xl pl-0 pr-8 py-2 text-sm text-white focus:outline-none transition-all placeholder:text-dark-muted',
            attributes: {'placeholder': 'Search categories...'},
            value: _searchInputVal,
            onInput: (val) {
              _searchInputVal = val;
              _debounceTimer?.cancel();
              _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                setState(() => _categorySearch = _searchInputVal);
              });
            },
          ),
          if (_searchInputVal.isNotEmpty)
            button(
              classes: 'absolute right-4 top-1/2 -translate-y-1/2 text-dark-muted hover:text-white transition-colors cursor-pointer p-0.5',
              onClick: () => setState(() { _searchInputVal = ''; _categorySearch = ''; }),
              [Component.text('✕')],
            ),
        ]),
        // Refresh
        button(
          classes: 'px-3.5 py-2 bg-white/5 rounded-xl text-sm font-medium text-dark-muted hover:text-white hover:bg-white/10 transition-all flex items-center space-x-2 cursor-pointer',
          onClick: () {
            categoriesNotifier.refresh();
          },
          [
            span([Component.text('🔄')]),
            span([Component.text('Refresh')]),
          ],
        ),
      ]),

      // ══════════════════════════════════════════════════════════════
      //  MODALS
      // ══════════════════════════════════════════════════════════════
      if (_showCategoryForm)
        _buildModal(
          title: _editingCategory != null ? 'Edit Category' : 'Create New Category',
          onClose: _closeCategoryForm,
          onSubmit: () => _handleCategorySubmit(categoriesNotifier),
          submitText: _editingCategory != null ? 'Save Changes' : 'Create Category',
          body: [
            _buildFormField('Category Name', 'e.g. Software Engineering', _categoryName, (val) => _categoryName = val),
            _buildFormField('Description', 'Describe this category...', _categoryDescription, (val) => _categoryDescription = val),
            _buildFormField('Image URL', 'https://example.com/image.png', _categoryImageUrl, (val) => _categoryImageUrl = val),
          ],
        ),

      if (_showSubCategoryForm)
        _buildModal(
          title: _editingSubCategory != null ? 'Edit Subcategory' : 'Add Subcategory',
          onClose: _closeSubCategoryForm,
          onSubmit: () {
            if (_selectedCategory != null) {
              final activeSubCategoriesNotifier = context.read(subCategoriesProvider(_selectedCategory!.id!).notifier);
              _handleSubCategorySubmit(activeSubCategoriesNotifier);
            }
          },
          submitText: _editingSubCategory != null ? 'Save Changes' : 'Create Subcategory',
          body: [
            _buildFormField('Subcategory Name', 'e.g. Flutter & Dart', _subCategoryName, (val) => _subCategoryName = val),
            _buildFormField('Description', 'Describe this subcategory...', _subCategoryDescription, (val) => _subCategoryDescription = val),
            _buildFormField('Image URL', 'https://example.com/image.png', _subCategoryImageUrl, (val) => _subCategoryImageUrl = val),
          ],
        ),

      // ══════════════════════════════════════════════════════════════
      //  CATEGORIES GRID — 4 columns, compact, no borders
      // ══════════════════════════════════════════════════════════════
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
              classes: 'py-20 flex flex-col items-center justify-center text-center space-y-4',
              [
                div(
                  classes: 'w-16 h-16 rounded-2xl bg-primary/10 flex items-center justify-center text-3xl',
                  [Component.text('🏷️')],
                ),
                div(classes: 'space-y-1.5', [
                  h4(classes: 'text-lg font-bold text-white', [Component.text('No categories found')]),
                  p(classes: 'text-dark-muted text-sm max-w-[280px]', [
                    Component.text(_categorySearch.isNotEmpty
                        ? 'No results match your search. Try a different query.'
                        : 'Get started by creating your first category.'),
                  ]),
                ]),
                if (_categorySearch.isEmpty)
                  button(
                    classes: 'btn-primary flex items-center space-x-2 rounded-xl mt-2 text-sm',
                    onClick: _openCreateCategoryForm,
                    [
                      span([Component.text('➕')]),
                      span([Component.text('Create Category')]),
                    ],
                  ),
              ],
            );
          }

          return div(classes: 'grid grid-cols-2 xl:grid-cols-4 gap-3 items-start', [
            for (final cat in filtered)
              _CategoryCard(
                category: cat,
                onTap: () {
                  setState(() {
                    _selectedCategory = cat;
                  });
                  CategorySidePanel.open(
                    context,
                    category: cat,
                    onAddSubCategory: () {
                      _openCreateSubCategoryFormFor(cat);
                    },
                    onEditSubCategory: (sub) {
                      _openEditSubCategoryFormFor(cat, sub);
                    },
                    onDeleteSubCategory: (sub) {
                      final subNotifier = context.read(subCategoriesProvider(cat.id!).notifier);
                      _handleSubCategoryDelete(subNotifier, sub);
                    },
                  );
                },
                onEdit: () => _openEditCategoryForm(cat),
                onDelete: () => _handleCategoryDelete(categoriesNotifier, cat),
              ),
            if (categoriesNotifier.hasMore)
              div(classes: 'col-span-full flex justify-center pt-4', [
                button(
                  classes: 'px-5 py-2.5 bg-white/5 rounded-xl text-sm font-semibold text-dark-muted hover:text-white hover:bg-white/10 transition-all cursor-pointer flex items-center space-x-2',
                  onClick: () => categoriesNotifier.loadMore(),
                  [
                    span([Component.text('📥')]),
                    span([Component.text('Load More')]),
                  ],
                ),
              ]),
          ]);
        },
        loading: () => div(classes: 'grid grid-cols-2 xl:grid-cols-4 gap-3 items-start', [
          for (var i = 0; i < 8; i++)
            div(classes: 'bg-dark-card rounded-xl p-4 animate-pulse', [
              div(classes: 'flex items-center space-x-3', [
                div(classes: 'w-9 h-9 rounded-lg bg-dark-border/30 shrink-0', []),
                div(classes: 'flex-1 space-y-2', [
                  div(classes: 'h-4 bg-dark-border/30 rounded w-3/4', []),
                  div(classes: 'h-3 bg-dark-border/30 rounded w-1/2', []),
                ]),
              ]),
            ]),
        ]),
        error: (e, __) => div(classes: 'py-12 text-center space-y-4', [
          span(classes: 'text-3xl block', [Component.text('⚠️')]),
          p(classes: 'text-red-400 text-sm', [Component.text(e.toFriendlyMessage())]),
          button(
            classes: 'px-5 py-2.5 bg-red-500/10 text-red-400 rounded-xl text-sm font-semibold hover:bg-red-500/20 transition-all cursor-pointer',
            onClick: () => categoriesNotifier.refresh(),
            [Component.text('Retry')],
          ),
        ]),
      ),
    ]);
  }
}

class _CategoryCard extends StatelessComponent {
  final CourseCategory category;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.category,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'bg-dark-card rounded-xl border border-dark-border/50 hover:border-primary/20 overflow-hidden transition-all duration-300 hover:-translate-y-0.5 hover:shadow-xl hover:shadow-primary/5 flex flex-col h-[170px]',
      [
        div(
          classes: 'p-4 cursor-pointer h-full flex flex-col group',
          events: {
            'click': (e) => onTap(),
          },
          [
            // Title & Hover Actions row
            div(classes: 'flex items-center justify-between gap-2 mb-2', [
              if (category.imageUrl != null && category.imageUrl!.isNotEmpty)
                img(
                  src: category.imageUrl!,
                  classes: 'w-8 h-8 rounded-lg object-cover shrink-0 border border-white/10 mr-1.5',
                ),
              h4(classes: 'text-sm font-bold text-white group-hover:text-primary transition-colors truncate flex-1', [
                Component.text(category.name ?? 'Unnamed Category'),
              ]),
              div(
                classes: 'flex items-center space-x-1 shrink-0 md:opacity-0 group-hover:opacity-100 transition-opacity',
                events: {'click': (e) => e.stopPropagation()},
                [
                  button(
                    classes: 'p-1 rounded text-dark-muted hover:text-white hover:bg-white/5 transition-all cursor-pointer',
                    onClick: onEdit,
                    [Component.text('✏️')],
                  ),
                  button(
                    classes: 'p-1 rounded text-dark-muted hover:text-red-400 hover:bg-red-500/10 transition-all cursor-pointer',
                    onClick: onDelete,
                    [Component.text('🗑️')],
                  ),
                ],
              ),
            ]),

            // Description
            p(classes: 'text-xs text-dark-muted line-clamp-2 mb-4 flex-1 leading-relaxed', [
              Component.text(category.description ?? 'No description provided.'),
            ]),

            // Bottom row indicator
            div(classes: 'flex items-center justify-between border-t border-white/5 pt-2.5 mt-auto', [
              button(
                classes: 'px-2 py-0.5 bg-white/5 text-[9px] font-bold text-dark-muted rounded-md group-hover:text-primary group-hover:bg-primary/10 transition-all cursor-pointer',
                [
                  Component.text('View Subcategories'),
                ],
              ),
            ]),
          ],
        ),
      ],
    );
  }
}
