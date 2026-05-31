import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:learnitin_admin/core/core.dart';
import 'package:learnitin_admin/models/course.dart';
import 'package:learnitin_admin/providers/admin_course_provider.dart';
import 'package:learnitin_admin/providers/category_provider.dart';

class CourseEditModal extends StatefulComponent {
  final Course course;
  final VoidCallback onClose;

  const CourseEditModal({
    required this.course,
    required this.onClose,
    super.key,
  });

  @override
  State<CourseEditModal> createState() => _CourseEditModalState();
}

class _CourseEditModalState extends State<CourseEditModal> {
  late String _title;
  late String _description;
  late String _imageUrl;
  late String _duration;
  late double _popularityScore;
  late int _totalEnrollees;
  int? _selectedCategoryId;
  int? _selectedSubCategoryId;
  bool _isLoading = false;

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
      await context.read(adminCourseProvider.notifier).updateCourse(
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

  @override
  Component build(BuildContext context) {
    final categoriesAsync = context.watch(categoriesProvider(null));
    final subCategoriesAsync = _selectedCategoryId != null
        ? context.watch(subCategoriesProvider(_selectedCategoryId!))
        : null;

    return div(
      classes: 'space-y-6 pb-12 relative animate-in fade-in duration-300',
      [
        // Top Navigation / Breadcrumbs & Actions Header
        div(classes: 'flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-dark-border/30 pb-6', [
          div(classes: 'space-y-1', [
            div(classes: 'flex items-center space-x-2 text-xs text-dark-muted', [
              button(
                classes: 'hover:text-white transition-colors cursor-pointer',
                onClick: component.onClose,
                [Component.text('Courses')],
              ),
              span([Component.text('/')]),
              span(classes: 'text-white font-medium', [Component.text('Course Editor')]),
              span([Component.text('/')]),
              span(classes: 'text-primary font-semibold', [Component.text(component.course.title ?? 'Edit Course')]),
            ]),
            h1(classes: 'text-3xl font-extrabold text-white tracking-tight mt-1', [
              Component.text('Edit Course Details'),
            ]),
            p(classes: 'text-xs text-dark-muted mt-1', [
              Component.text('Modify attributes, taxonomies, and performance scores for this course.'),
            ]),
          ]),
          div(classes: 'flex items-center gap-3 shrink-0', [
            if (!_isLoading)
              button(
                classes:
                    'px-5 py-2.5 bg-white/5 border border-dark-border rounded-xl text-sm font-semibold text-white hover:bg-white/10 transition-all cursor-pointer hover:border-white/20',
                onClick: component.onClose,
                [Component.text('Cancel')],
              ),
            button(
              classes:
                  'px-6 py-2.5 btn-primary rounded-xl text-sm font-bold shadow-lg shadow-primary/20 flex items-center space-x-2 cursor-pointer transition-all active:scale-98 disabled:opacity-50 disabled:cursor-not-allowed',
              attributes: (_title.trim().isEmpty || _isLoading) ? {'disabled': ''} : {},
              onClick: _isLoading ? null : _submit,
              [
                if (_isLoading)
                  div(
                    classes: 'w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin mr-1.5',
                    [],
                  ),
                span([Component.text('Save Changes')]),
              ],
            ),
          ]),
        ]),

        // Main Two-Column Layout
        div(classes: 'grid grid-cols-1 lg:grid-cols-12 gap-8 text-left', [
          // ── LEFT COLUMN (lg:col-span-8) - Main Content ──────────────
          div(classes: 'lg:col-span-8 space-y-6', [
            div(classes: 'card p-6 space-y-4 bg-dark-card border border-dark-border rounded-2xl shadow-xl', [
              h3(classes: 'text-sm font-bold text-white uppercase tracking-wider border-b border-dark-border/30 pb-2.5', [
                Component.text('Course Information'),
              ]),
              
              // Title Input
              div(classes: 'space-y-1.5', [
                label(classes: 'text-xs font-bold text-dark-muted uppercase tracking-wider', [
                  Component.text('Course Title *'),
                ]),
                input<String>(
                  type: InputType.text,
                  classes:
                      'bg-dark-border/20 border border-dark-border rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-all w-full',
                  value: _title,
                  onInput: (val) => setState(() => _title = val),
                  attributes: _isLoading ? {'disabled': ''} : {},
                ),
              ]),

              // Description Input
              div(classes: 'space-y-1.5', [
                label(classes: 'text-xs font-bold text-dark-muted uppercase tracking-wider', [
                  Component.text('Description'),
                ]),
                textarea(
                  classes:
                      'bg-dark-border/20 border border-dark-border rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-all w-full min-h-[150px] max-h-[300px]',
                  onInput: (val) => setState(() => _description = val),
                  attributes: _isLoading ? {'disabled': ''} : {},
                  [Component.text(_description)],
                ),
              ]),

              // Image URL Input
              div(classes: 'space-y-1.5', [
                label(classes: 'text-xs font-bold text-dark-muted uppercase tracking-wider', [
                  Component.text('Image URL'),
                ]),
                input<String>(
                  type: InputType.text,
                  classes:
                      'bg-dark-border/20 border border-dark-border rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-all w-full',
                  value: _imageUrl,
                  onInput: (val) => setState(() => _imageUrl = val),
                  attributes: _isLoading ? {'disabled': ''} : {},
                ),
              ]),
            ]),
          ]),

          // ── RIGHT COLUMN (lg:col-span-4) - Sidebar Metadata ──────────
          div(classes: 'lg:col-span-4 space-y-6', [
            // Taxonomy & Placement
            div(classes: 'bg-dark-card border border-dark-border rounded-2xl p-5 space-y-4 shadow-xl', [
              h3(classes: 'text-sm font-bold text-white uppercase tracking-wider border-b border-dark-border/30 pb-2.5', [
                Component.text('Taxonomy & Settings'),
              ]),
              div(classes: 'space-y-4', [
                // Category select
                div(classes: 'space-y-1.5', [
                  label(classes: 'text-xs font-semibold text-dark-muted pl-0.5', [
                    Component.text('Category'),
                  ]),
                  categoriesAsync.when(
                    data: (categories) => select(
                      classes:
                          'bg-dark-bg/40 border border-white/10 rounded-xl px-3.5 py-3 text-xs text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-all w-full cursor-pointer hover:border-white/20',
                      onChange: (values) {
                        final val = values.firstOrNull ?? 'null';
                        setState(() {
                          _selectedCategoryId = val == 'null' ? null : int.tryParse(val);
                          _selectedSubCategoryId = null;
                        });
                      },
                      [
                        option(value: 'null', selected: _selectedCategoryId == null, [Component.text('None')]),
                        for (final category in categories)
                          option(
                            value: category.id.toString(),
                            selected: _selectedCategoryId == category.id,
                            [Component.text(category.name ?? '')],
                          ),
                      ],
                    ),
                    loading: () => div(
                      classes:
                          'bg-white/5 border border-white/10 rounded-xl px-3.5 py-3 text-xs text-dark-muted animate-pulse',
                      [
                        Component.text('Loading categories...'),
                      ],
                    ),
                    error: (e, __) => div(classes: 'text-xs text-red-400', [
                      Component.text('Error loading categories'),
                    ]),
                  ),
                ]),

                // Subcategory select
                div(classes: 'space-y-1.5', [
                  label(classes: 'text-xs font-semibold text-dark-muted pl-0.5', [
                    Component.text('Subcategory'),
                  ]),
                  if (_selectedCategoryId == null)
                    select(
                      classes:
                          'bg-dark-bg/25 border border-white/5 rounded-xl px-3.5 py-3 text-xs text-dark-muted/40 w-full cursor-not-allowed',
                      attributes: {'disabled': ''},
                      [
                        option(value: 'null', [Component.text('Select category first')]),
                      ],
                    )
                  else if (subCategoriesAsync != null)
                    subCategoriesAsync.when(
                      data: (subCategories) => select(
                        classes:
                            'bg-dark-bg/40 border border-white/10 rounded-xl px-3.5 py-3 text-xs text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-all w-full cursor-pointer hover:border-white/20',
                        onChange: (values) {
                          final val = values.firstOrNull ?? 'null';
                          setState(() {
                            _selectedSubCategoryId = val == 'null' ? null : int.tryParse(val);
                          });
                        },
                        [
                          option(value: 'null', selected: _selectedSubCategoryId == null, [Component.text('None')]),
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
                            'bg-white/5 border border-white/10 rounded-xl px-3.5 py-3 text-xs text-dark-muted animate-pulse',
                        [
                          Component.text('Loading subcategories...'),
                        ],
                      ),
                      error: (e, __) => div(classes: 'text-xs text-red-400', [
                        Component.text('Error loading subcategories'),
                      ]),
                    ),
                ]),
              ]),
            ]),

            // Attributes and Metrics
            div(classes: 'bg-dark-card border border-dark-border rounded-2xl p-5 space-y-4 shadow-xl', [
              h3(classes: 'text-sm font-bold text-white uppercase tracking-wider border-b border-dark-border/30 pb-2.5', [
                Component.text('Course Metrics'),
              ]),
              div(classes: 'space-y-4', [
                // Duration
                div(classes: 'space-y-1.5', [
                  label(classes: 'text-xs font-bold text-dark-muted uppercase tracking-wider pl-0.5', [
                    Component.text('Duration'),
                  ]),
                  input<String>(
                    type: InputType.text,
                    classes:
                        'bg-dark-bg/40 border border-white/10 rounded-xl px-3.5 py-3 text-xs text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-all w-full',
                    value: _duration,
                    onInput: (val) => setState(() => _duration = val),
                    attributes: _isLoading ? {'disabled': ''} : {},
                  ),
                ]),

                // Popularity Score
                div(classes: 'space-y-1.5', [
                  label(classes: 'text-xs font-bold text-dark-muted uppercase tracking-wider pl-0.5', [
                    Component.text('Popularity Score'),
                  ]),
                  input<num>(
                    type: InputType.number,
                    classes:
                        'bg-dark-bg/40 border border-white/10 rounded-xl px-3.5 py-3 text-xs text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-all w-full',
                    value: _popularityScore.toString(),
                    onInput: (val) => setState(() => _popularityScore = val.toDouble()),
                    attributes: {
                      'step': '0.1',
                      'min': '0',
                      if (_isLoading) 'disabled': '',
                    },
                  ),
                ]),

                // Total Enrollees
                div(classes: 'space-y-1.5', [
                  label(classes: 'text-xs font-bold text-dark-muted uppercase tracking-wider pl-0.5', [
                    Component.text('Total Enrollees'),
                  ]),
                  input<num>(
                    type: InputType.number,
                    classes:
                        'bg-dark-bg/40 border border-white/10 rounded-xl px-3.5 py-3 text-xs text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-all w-full',
                    value: _totalEnrollees.toString(),
                    onInput: (val) => setState(() => _totalEnrollees = val.toInt()),
                    attributes: {
                      'min': '0',
                      if (_isLoading) 'disabled': '',
                    },
                  ),
                ]),
              ]),
            ]),
          ]),
        ]),
      ],
    );
  }
}
