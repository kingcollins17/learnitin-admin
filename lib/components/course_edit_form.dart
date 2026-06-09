import 'dart:async';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:learnitin_admin/core/core.dart';
import 'package:learnitin_admin/models/course.dart';
import 'package:learnitin_admin/providers/admin_course_provider.dart';
import 'package:learnitin_admin/providers/category_provider.dart';

class CourseEditForm extends StatefulComponent {
  final Course course;
  final VoidCallback onClose;
  final AdminCourseRecord familyParams;

  const CourseEditForm({
    required this.course,
    required this.onClose,
    this.familyParams = defaultAdminCourseParams,
    super.key,
  });

  @override
  State<CourseEditForm> createState() => _CourseEditFormState();
}

class _CourseEditFormState extends State<CourseEditForm> {
  late String _title;
  late String _description;
  late String _imageUrl;
  late String _duration;
  late double _popularityScore;
  late int _totalEnrollees;
  int? _selectedCategoryId;
  int? _selectedSubCategoryId;
  bool _isLoading = false;

  CourseCategory? _selectedCategory;
  String _localCategorySearchQuery = '';
  String _categorySearchQuery = '';
  Timer? _categorySearchDebounce;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _title = component.course.title ?? '';
    _description = component.course.description ?? '';
    _imageUrl = component.course.imageUrl ?? '';
    _duration = component.course.duration ?? '';
    _popularityScore = component.course.popularityScore ?? 0.0;
    _totalEnrollees = component.course.totalEnrollees ?? 0;
    _selectedCategoryId = component.course.category?.id;
    _selectedSubCategoryId = component.course.subCategory?.id;
    _selectedCategory = component.course.category;
  }

  @override
  void dispose() {
    _categorySearchDebounce?.cancel();
    super.dispose();
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

  void _submit() async {
    if (_title.trim().isEmpty) {
      context.showError('Please enter a course title.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final body = CourseUpdate(
      title: _title.trim(),
      description: _description.trim().isNotEmpty ? _description.trim() : null,
      imageUrl: _imageUrl.trim().isNotEmpty ? _imageUrl.trim() : null,
      duration: _duration.trim().isNotEmpty ? _duration.trim() : null,
      categoryId: _selectedCategoryId,
      subCategoryId: _selectedSubCategoryId,
      popularityScore: _popularityScore,
      totalEnrollees: _totalEnrollees,
    );

    try {
      await context
          .read(adminCourseProvider(component.familyParams).notifier)
          .updateCourse(
            courseId: component.course.id.toString(),
            body: body,
            onSuccess: () {
              context.showSuccess('Course updated successfully!');
              component.onClose();
            },
            onError: (msg, [st]) {
              context.showError(msg);
            },
          );
    } catch (e) {
      // Handled via notifier
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ── STYLED HELPERS ─────────────────────────────────────────────────────

  /// Section header with title + subtitle like the reference design
  Component _sectionHeader(String title, String subtitle) {
    return div(classes: 'mb-6', [
      h2(classes: 'text-lg font-bold text-white tracking-tight', [
        Component.text(title),
      ]),
      p(classes: 'text-xs text-dark-muted mt-1 leading-relaxed', [
        Component.text(subtitle),
      ]),
    ]);
  }

  /// Field label rendered above inputs
  Component _fieldLabel(String label, {bool required = false}) {
    return div(classes: 'mb-2', [
      span(
        classes: 'text-[12px] font-semibold text-white/80 tracking-wide',
        [
          Component.text(label),
          if (required) span(classes: 'text-primary ml-0.5', [Component.text(' *')]),
        ],
      ),
    ]);
  }

  String get _inputClasses =>
      'bg-dark-bg/60 border border-dark-border/60 rounded-xl px-4 py-3 text-sm text-white '
      'focus:outline-none focus:border-primary/60 focus:ring-2 focus:ring-primary/10 '
      'transition-all w-full placeholder:text-dark-muted/40';

  String get _selectClasses =>
      'bg-dark-bg/60 border border-dark-border/60 rounded-xl pl-4 pr-10 py-3 text-sm text-white '
      'focus:outline-none focus:border-primary/60 focus:ring-2 focus:ring-primary/10 '
      'transition-all w-full cursor-pointer hover:border-white/20 appearance-none '
      'bg-[url("data:image/svg+xml;charset=utf-8,%3Csvg xmlns=\'http://www.w3.org/2000/svg\' fill=\'none\' viewBox=\'0 0 24 24\' stroke=\'%2371717A\'%3E%3Cpath stroke-linecap=\'round\' stroke-linejoin=\'round\' stroke-width=\'2\' d=\'M19 9l-7 7-7-7\'/%3E%3C/svg%3E")] '
      'bg-no-repeat bg-[right_0.75rem_center] bg-[length:1.25em_1.25em]';

  @override
  Component build(BuildContext context) {
    final categoriesAsync = context.watch(categoriesProvider((search: _categorySearchQuery, sortByPopularity: null)));
    final subCategoriesAsync = _selectedCategoryId != null
        ? context.watch(subCategoriesProvider(_selectedCategoryId!))
        : null;

    final hasImage = _imageUrl.trim().isNotEmpty;

    return div(
      classes: 'space-y-0 animate-in fade-in duration-300',
      [
        // ══════════════════════════════════════════════════════════════════
        // TOP HEADER BAR
        // ══════════════════════════════════════════════════════════════════
        div(classes: 'relative overflow-hidden rounded-2xl border border-dark-border bg-dark-card shadow-2xl mb-6', [
          // Accent gradient bar
          div(classes: 'h-1 w-full bg-gradient-to-r from-primary via-primary/60 to-transparent', []),

          div(classes: 'px-6 py-5 flex flex-col md:flex-row md:items-center justify-between gap-4', [
            // Left: Back nav + title
            div(classes: 'flex items-center space-x-4 min-w-0', [
              // Back button
              button(
                classes:
                    'w-9 h-9 rounded-xl bg-white/5 border border-dark-border flex items-center justify-center '
                    'text-dark-muted hover:text-white hover:bg-white/10 hover:border-white/20 transition-all cursor-pointer shrink-0',
                onClick: component.onClose,
                [
                  span(classes: 'text-sm', [Component.text('←')]),
                ],
              ),
              div(classes: 'min-w-0', [
                h1(
                  classes: 'text-xl font-extrabold text-white tracking-tight leading-tight flex items-center space-x-2',
                  [
                    Component.text('Course Editor'),
                    span(classes: 'text-lg', [Component.text('📝')]),
                  ],
                ),
                p(classes: 'text-[11px] text-dark-muted mt-0.5 truncate max-w-[320px]', [
                  Component.text(component.course.title ?? 'Edit Course'),
                ]),
              ]),
            ]),

            // Right: Status + action buttons
            div(classes: 'flex items-center gap-3 shrink-0', [
              // Editing status badge
              div(
                classes:
                    'hidden md:flex items-center space-x-1.5 px-3 py-1.5 rounded-lg bg-primary/10 border border-primary/20',
                [
                  div(classes: 'w-1.5 h-1.5 rounded-full bg-primary animate-pulse', []),
                  span(classes: 'text-[10px] font-semibold text-primary uppercase tracking-wider', [
                    Component.text('Editing'),
                  ]),
                ],
              ),
              if (!_isLoading)
                button(
                  classes:
                      'px-4 py-2.5 bg-white/5 border border-dark-border rounded-xl text-xs font-semibold text-white '
                      'hover:bg-white/10 hover:border-white/20 transition-all cursor-pointer',
                  onClick: component.onClose,
                  [Component.text('Discard')],
                ),
              button(
                classes:
                    'relative px-6 py-2.5 rounded-xl text-xs font-bold cursor-pointer transition-all '
                    'flex items-center space-x-2 overflow-hidden group '
                    '${(_title.trim().isEmpty || _isLoading) ? "opacity-50 cursor-not-allowed bg-primary/60 text-black" : "btn-primary shadow-lg shadow-primary/20 hover:shadow-primary/40 hover:-translate-y-0.5 active:scale-95"}',
                attributes: (_title.trim().isEmpty || _isLoading) ? {'disabled': ''} : {},
                onClick: _isLoading ? null : _submit,
                [
                  if (_isLoading)
                    div(
                      classes: 'w-3.5 h-3.5 border-2 border-black border-t-transparent rounded-full animate-spin',
                      [],
                    )
                  else
                    span(classes: 'text-sm', [Component.text('💾')]),
                  span([Component.text(_isLoading ? 'Saving…' : 'Save Changes')]),
                ],
              ),
            ]),
          ]),
        ]),

        // ══════════════════════════════════════════════════════════════════
        // MAIN CONTENT — Two-column layout
        // ══════════════════════════════════════════════════════════════════
        div(classes: 'grid grid-cols-1 lg:grid-cols-12 gap-6 items-start text-left', [
          // ── LEFT COLUMN — Primary form fields ─────────────────────────
          div(classes: 'lg:col-span-7 space-y-6', [
            // ── COURSE INFORMATION SECTION ───────────────────────────────
            div(classes: 'rounded-2xl border border-dark-border bg-dark-card shadow-xl overflow-hidden', [
              div(classes: 'p-6 pb-7 space-y-0', [
                _sectionHeader(
                  'Course Information',
                  'Enter the required information below. You can change it anytime you want.',
                ),

                // ── Title ──────────────────────────────────
                div(classes: 'mb-5', [
                  _fieldLabel('Course Title', required: true),
                  input<String>(
                    type: InputType.text,
                    classes: _inputClasses,
                    value: _title,
                    attributes: {
                      'placeholder': 'e.g. Advanced Python for Data Science',
                      if (_isLoading) 'disabled': '',
                    },
                    onInput: (val) => setState(() => _title = val),
                  ),
                  if (_title.trim().isEmpty)
                    div(classes: 'flex items-center space-x-1.5 mt-2', [
                      span(classes: 'text-amber-400 text-[10px]', [Component.text('⚠️')]),
                      span(classes: 'text-[11px] text-amber-400/80 font-medium', [
                        Component.text('Please enter a course title'),
                      ]),
                    ]),
                ]),

                // ── Duration + Popularity (side by side) ─────────────────
                div(classes: 'grid grid-cols-1 sm:grid-cols-2 gap-4 mb-5', [
                  // Duration
                  div([
                    _fieldLabel('Duration'),
                    input<String>(
                      type: InputType.text,
                      classes: _inputClasses,
                      value: _duration,
                      attributes: {
                        'placeholder': 'e.g. 8 weeks',
                        if (_isLoading) 'disabled': '',
                      },
                      onInput: (val) => setState(() => _duration = val),
                    ),
                  ]),
                  // Popularity Score
                  div([
                    _fieldLabel('Popularity Score'),
                    div(classes: 'relative', [
                      input<num>(
                        type: InputType.number,
                        classes: _inputClasses,
                        value: _popularityScore.toString(),
                        onInput: (val) => setState(() => _popularityScore = val.toDouble()),
                        attributes: {
                          'step': '0.1',
                          'min': '0',
                          'max': '10',
                          'placeholder': '0.0',
                          if (_isLoading) 'disabled': '',
                        },
                      ),
                      // Score badge overlay
                      div(
                        classes: 'absolute right-3 top-1/2 -translate-y-1/2 pointer-events-none',
                        [
                          span(
                            classes:
                                'px-2 py-0.5 rounded-md text-[10px] font-bold '
                                '${_popularityScore >= 7
                                    ? "bg-primary/10 border border-primary/20 text-primary"
                                    : _popularityScore >= 4
                                    ? "bg-amber-500/10 border border-amber-500/20 text-amber-400"
                                    : "bg-dark-border/50 border border-dark-border text-dark-muted"}',
                            [Component.text('${_popularityScore.toStringAsFixed(1)} / 10')],
                          ),
                        ],
                      ),
                    ]),
                    // Progress bar
                    div(classes: 'mt-2 relative h-1 rounded-full bg-dark-border/40 overflow-hidden', [
                      div(
                        classes:
                            'h-full rounded-full bg-gradient-to-r from-amber-500 to-primary transition-all duration-500',
                        attributes: {
                          'style': 'width: ${((_popularityScore.clamp(0, 10) / 10) * 100).toStringAsFixed(1)}%',
                        },
                        [],
                      ),
                    ]),
                  ]),
                ]),

                // ── Description ────────────────────────────
                div(classes: 'mb-5', [
                  _fieldLabel('Description'),
                  textarea(
                    classes: '$_inputClasses min-h-[140px] max-h-[280px] resize-y',
                    attributes: {
                      'placeholder': 'Describe the course content, learning outcomes, and target audience…',
                      if (_isLoading) 'disabled': '',
                    },
                    onInput: (val) => setState(() => _description = val),
                    [Component.text(_description)],
                  ),
                ]),

                // ── Image URL ──────────────────────────────
                div([
                  _fieldLabel('Cover Image URL'),
                  input<String>(
                    type: InputType.text,
                    classes: _inputClasses,
                    value: _imageUrl,
                    attributes: {
                      'placeholder': 'https://example.com/course-cover.jpg',
                      if (_isLoading) 'disabled': '',
                    },
                    onInput: (val) => setState(() => _imageUrl = val),
                  ),
                  p(classes: 'text-[10px] text-dark-muted/60 mt-1.5 pl-0.5', [
                    Component.text('Paste a direct URL to an image (JPEG, PNG, WebP).'),
                  ]),
                ]),
              ]),
            ]),

            // ── TOTAL ENROLLEES — standalone small card ──────────────────
            div(classes: 'rounded-2xl border border-dark-border bg-dark-card shadow-xl overflow-hidden', [
              div(classes: 'p-6', [
                _sectionHeader(
                  'Enrollment Data',
                  'Manually override the enrollment count displayed for this course.',
                ),
                div(classes: 'relative', [
                  _fieldLabel('Total Enrollees'),
                  input<num>(
                    type: InputType.number,
                    classes: _inputClasses,
                    value: _totalEnrollees.toString(),
                    onInput: (val) => setState(() => _totalEnrollees = val.toInt()),
                    attributes: {
                      'min': '0',
                      'placeholder': '0',
                      if (_isLoading) 'disabled': '',
                    },
                  ),
                  if (_totalEnrollees > 0)
                    div(classes: 'mt-2.5 flex items-center space-x-2', [
                      div(classes: 'w-2 h-2 rounded-full bg-primary/60', []),
                      span(
                        classes: 'text-[11px] font-semibold text-primary',
                        [
                          Component.text(
                            '${_totalEnrollees >= 1000 ? '${(_totalEnrollees / 1000).toStringAsFixed(1)}k' : _totalEnrollees} students enrolled',
                          ),
                        ],
                      ),
                    ]),
                ]),
              ]),
            ]),
          ]),

          // ── RIGHT COLUMN — Sidebar ────────────────────────────────────
          div(classes: 'lg:col-span-5 space-y-6', [
            // ── COVER IMAGE PREVIEW ─────────────────────────────────────
            div(classes: 'rounded-2xl border border-dark-border bg-dark-card shadow-xl overflow-hidden', [
              div(classes: 'px-6 pt-5 pb-2', [
                span(classes: 'text-[12px] font-semibold text-white/80 tracking-wide', [
                  Component.text('Cover Image'),
                ]),
              ]),
              div(classes: 'px-6 pb-6 pt-3', [
                if (hasImage)
                  div(
                    classes:
                        'relative w-full aspect-video rounded-xl overflow-hidden border border-dark-border/50 '
                        'bg-dark-bg/40 group',
                    [
                      img(
                        src: _imageUrl.trim(),
                        classes: 'w-full h-full object-cover transition-transform duration-500 group-hover:scale-105',
                      ),
                      // Overlay on hover
                      div(
                        classes:
                            'absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300',
                        [],
                      ),
                      // Preview badge
                      div(
                        classes:
                            'absolute top-2.5 right-2.5 px-2.5 py-1 rounded-lg bg-black/60 backdrop-blur-sm border border-white/10',
                        [
                          span(classes: 'text-[10px] text-white font-semibold', [Component.text('Preview')]),
                        ],
                      ),
                    ],
                  )
                else
                  div(
                    classes:
                        'w-full aspect-video rounded-xl border-2 border-dashed border-dark-border/40 flex flex-col '
                        'items-center justify-center space-y-2 text-dark-muted/50 bg-dark-bg/20',
                    [
                      span(classes: 'text-3xl', [Component.text('🖼️')]),
                      span(classes: 'text-[11px] font-medium', [Component.text('Image preview')]),
                      span(classes: 'text-[10px]', [Component.text('Add a URL on the left')]),
                    ],
                  ),
              ]),
            ]),

            // ── TAXONOMY & CATEGORY CARD ────────────────────────────────
            div(classes: 'rounded-2xl border border-dark-border bg-dark-card shadow-xl overflow-hidden', [
              div(classes: 'p-6 space-y-0', [
                _sectionHeader(
                  'Category and Sub Category',
                  'Choose a category and subcategory for this course.',
                ),

                // ── Category Selector ─────────────────────
                div(classes: 'mb-5', [
                  _fieldLabel('Category'),
                  // Search input
                  div(classes: 'relative mb-2', [
                    input(
                      type: InputType.text,
                      classes:
                          'bg-dark-bg/60 border border-dark-border/60 rounded-xl pl-10 pr-8 py-3 text-xs text-white placeholder:text-dark-muted/40 w-full focus:outline-none focus:border-primary/60 focus:ring-2 focus:ring-primary/10 transition-all',
                      value: _localCategorySearchQuery,
                      attributes: {
                        'placeholder': 'Search categories...',
                        if (_isLoading) 'disabled': '',
                      },
                      onInput: _onCategorySearchInput,
                    ),
                    span(classes: 'absolute left-3.5 top-1/2 -translate-y-1/2 text-xs text-dark-muted/60', [
                      Component.text('🔍'),
                    ]),
                    if (_localCategorySearchQuery.isNotEmpty)
                      button(
                        type: ButtonType.button,
                        classes:
                            'absolute right-3 top-1/2 -translate-y-1/2 text-xs text-dark-muted/60 hover:text-white transition-colors cursor-pointer',
                        onClick: () {
                          _onCategorySearchInput('');
                        },
                        [Component.text('✕')],
                      ),
                  ]),
                  // Dropdown select
                  categoriesAsync.when(
                    data: (categories) {
                      final displayedCategories = [...categories];
                      if (_selectedCategoryId != null && _selectedCategory != null) {
                        final hasSelected = displayedCategories.any((c) => c.id == _selectedCategoryId);
                        if (!hasSelected) {
                          displayedCategories.insert(0, _selectedCategory!);
                        }
                      }

                      return select(
                        classes: _selectClasses,
                        onChange: (values) {
                          final val = values.firstOrNull ?? 'null';
                          setState(() {
                            if (val == 'null') {
                              _selectedCategoryId = null;
                              _selectedCategory = null;
                            } else {
                              final parsedId = int.tryParse(val);
                              _selectedCategoryId = parsedId;
                              _selectedCategory = displayedCategories.firstWhere(
                                (c) => c.id == parsedId,
                                orElse: () => _selectedCategory ?? CourseCategory(id: parsedId!, name: ''),
                              );
                            }
                            _selectedSubCategoryId = null;
                          });
                        },
                        [
                          option(value: 'null', selected: _selectedCategoryId == null, [
                            Component.text('— Select a category —'),
                          ]),
                          for (final category in displayedCategories)
                            option(
                              value: category.id.toString(),
                              selected: _selectedCategoryId == category.id,
                              [Component.text(category.name ?? '')],
                            ),
                        ],
                      );
                    },
                    loading: () => div(
                      classes:
                          'bg-dark-bg/60 border border-dark-border/60 rounded-xl px-4 py-3 text-sm text-dark-muted/60 animate-pulse flex items-center space-x-2 w-full',
                      [
                        div(
                          classes: 'w-3 h-3 rounded-full bg-dark-muted/40 animate-spin border border-t-transparent',
                          [],
                        ),
                        Component.text('Loading…'),
                      ],
                    ),
                    error: (e, __) => div(classes: 'flex items-center space-x-1.5 text-xs text-red-400 py-3', [
                      span([Component.text('⚠️')]),
                      Component.text('Error loading categories'),
                    ]),
                  ),

                  // Footer for Showing count + Load More
                  categoriesAsync.when(
                    data: (categories) {
                      final displayedCategories = [...categories];
                      if (_selectedCategoryId != null && _selectedCategory != null) {
                        final hasSelected = displayedCategories.any((c) => c.id == _selectedCategoryId);
                        if (!hasSelected) {
                          displayedCategories.insert(0, _selectedCategory!);
                        }
                      }

                      final notifier = context.read(
                        categoriesProvider((search: _categorySearchQuery, sortByPopularity: null)).notifier,
                      );
                      final hasMore = notifier.hasMore;
                      final totalCount = displayedCategories.length;

                      return div(classes: 'flex items-center justify-between px-1 mt-2 text-[10px]', [
                        span(classes: 'text-dark-muted/60', [
                          Component.text('Showing $totalCount categories'),
                        ]),
                        if (hasMore)
                          _isLoadingMore
                              ? span(classes: 'text-dark-muted/60 animate-pulse', [Component.text('Loading...')])
                              : button(
                                  type: ButtonType.button,
                                  classes:
                                      'text-primary hover:text-primary/80 font-semibold transition-colors cursor-pointer flex items-center space-x-1',
                                  onClick: () async {
                                    setState(() {
                                      _isLoadingMore = true;
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
                                          _isLoadingMore = false;
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

                // Divider
                div(classes: 'border-t border-dark-border/30 my-1', []),

                // ── Subcategory Selector ────────────────────
                div(classes: 'mt-4', [
                  _fieldLabel('Subcategory'),
                  _selectedCategoryId == null
                      ? div(
                          classes:
                              'bg-dark-bg/25 border border-dark-border/30 rounded-xl px-4 py-3 text-xs '
                              'text-dark-muted/40 flex items-center space-x-2 cursor-not-allowed',
                          [
                            span([Component.text('🔒')]),
                            Component.text('Select a category first'),
                          ],
                        )
                      : subCategoriesAsync != null
                      ? subCategoriesAsync.when(
                          data: (subCategories) => select(
                            classes: _selectClasses,
                            onChange: (values) {
                              final val = values.firstOrNull ?? 'null';
                              setState(() {
                                _selectedSubCategoryId = val == 'null' ? null : int.tryParse(val);
                              });
                            },
                            [
                              option(value: 'null', selected: _selectedSubCategoryId == null, [
                                Component.text('— None —'),
                              ]),
                              for (final sub in subCategories)
                                option(
                                  value: sub.id.toString(),
                                  selected: _selectedSubCategoryId == sub.id,
                                  [Component.text(sub.name ?? '')],
                                ),
                            ],
                          ),
                          loading: () => div(
                            classes:
                                'bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-xs text-dark-muted animate-pulse flex items-center space-x-2',
                            [
                              div(classes: 'w-3 h-3 rounded-full bg-dark-muted/40', []),
                              Component.text('Loading subcategories…'),
                            ],
                          ),
                          error: (e, __) => div(classes: 'flex items-center space-x-1.5 text-xs text-red-400 py-2', [
                            span([Component.text('⚠️')]),
                            Component.text('Error loading subcategories'),
                          ]),
                        )
                      : div(classes: '', []),
                ]),
              ]),
            ]),

            // ── QUICK INFO SUMMARY ──────────────────────────────────────
            div(
              classes:
                  'rounded-2xl border border-dark-border/50 bg-gradient-to-br from-primary/5 to-transparent overflow-hidden',
              [
                div(classes: 'p-5 space-y-3', [
                  div(classes: 'flex items-center space-x-2', [
                    div(classes: 'w-1 h-4 rounded-full bg-primary', []),
                    span(classes: 'text-[11px] font-bold uppercase tracking-widest text-primary/70', [
                      Component.text('Quick Summary'),
                    ]),
                  ]),
                  div(classes: 'space-y-2.5 text-xs text-dark-muted mt-2', [
                    _buildSummaryRow('🆔', 'Course ID', '#${component.course.id}'),
                    if (component.course.createdAt != null)
                      _buildSummaryRow('📅', 'Created', _formatDate(component.course.createdAt!)),
                    if (component.course.level != null && component.course.level!.isNotEmpty)
                      _buildSummaryRow('📶', 'Level', component.course.level!),
                    _buildSummaryRow(
                      '🌐',
                      'Visibility',
                      component.course.isPublic == true ? 'Public' : 'Private',
                    ),
                    if (component.course.reviewSummary?.averageRating != null)
                      _buildSummaryRow(
                        '⭐',
                        'Avg Rating',
                        '${component.course.reviewSummary!.averageRating!.toStringAsFixed(1)} / 5.0',
                      ),
                  ]),
                ]),
              ],
            ),
          ]),
        ]),

        // Bottom spacing
        div(classes: 'pb-16', []),
      ],
    );
  }

  Component _buildSummaryRow(String icon, String label, String value) {
    return div(classes: 'flex items-center justify-between gap-2 py-1', [
      div(classes: 'flex items-center space-x-2 shrink-0', [
        span(classes: 'text-sm', [Component.text(icon)]),
        span(classes: 'text-dark-muted/70', [Component.text(label)]),
      ]),
      span(classes: 'text-white/80 font-medium truncate text-right', [Component.text(value)]),
    ]);
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
