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
      classes:
          'fixed inset-0 z-[100] flex items-center justify-center p-4 bg-dark-bg/60 backdrop-blur-md animate-in fade-in duration-200',
      [
        // Backdrop click to close (when not loading)
        div(
          classes: 'absolute inset-0 cursor-default',
          events: _isLoading ? {} : {'click': (e) => component.onClose()},
          [],
        ),

        // Dialog Content Card
        div(
          classes:
              'relative w-full max-w-xl bg-dark-card border border-dark-border/80 rounded-2xl shadow-2xl p-6 md:p-8 space-y-6 animate-in zoom-in-95 duration-200 overflow-y-auto max-h-[90vh] text-left',
          [
            // Header
            div(classes: 'flex items-center justify-between border-b border-dark-border/30 pb-4', [
              div(classes: 'space-y-1', [
                h3(classes: 'text-lg font-bold text-white', [
                  Component.text('Edit Course Details'),
                ]),
                p(classes: 'text-xs text-dark-muted', [
                  Component.text('Modify attributes and classifications of this course.'),
                ]),
              ]),
              if (!_isLoading)
                button(
                  classes:
                      'p-2 text-dark-muted hover:text-white rounded-lg hover:bg-white/5 transition-all cursor-pointer',
                  onClick: component.onClose,
                  [Component.text('✕')],
                ),
            ]),

            // Form
            div(classes: 'space-y-4', [
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
                      'bg-dark-border/20 border border-dark-border rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-all w-full min-h-[100px]',
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

              // Duration & Popularity Grid
              div(classes: 'grid grid-cols-1 sm:grid-cols-2 gap-4', [
                // Duration
                div(classes: 'space-y-1.5', [
                  label(classes: 'text-xs font-bold text-dark-muted uppercase tracking-wider', [
                    Component.text('Duration'),
                  ]),
                  input<String>(
                    type: InputType.text,
                    classes:
                        'bg-dark-border/20 border border-dark-border rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-all w-full',
                    value: _duration,
                    onInput: (val) => setState(() => _duration = val),
                    attributes: _isLoading ? {'disabled': ''} : {},
                  ),
                ]),

                // Popularity Score
                div(classes: 'space-y-1.5', [
                  label(classes: 'text-xs font-bold text-dark-muted uppercase tracking-wider', [
                    Component.text('Popularity Score'),
                  ]),
                  input<num>(
                    type: InputType.number,
                    classes:
                        'bg-dark-border/20 border border-dark-border rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-all w-full',
                    value: _popularityScore.toString(),
                    onInput: (val) => setState(() => _popularityScore = val.toDouble()),
                    attributes: {
                      'step': '0.1',
                      'min': '0',
                      if (_isLoading) 'disabled': '',
                    },
                  ),
                ]),
              ]),

              // Category & Subcategory Grid
              div(classes: 'grid grid-cols-1 sm:grid-cols-2 gap-4', [
                // Category select
                div(classes: 'space-y-1.5', [
                  label(classes: 'text-xs font-semibold text-dark-muted', [
                    Component.text('Category'),
                  ]),
                  categoriesAsync.when(
                    data: (categories) => select(
                      classes:
                          'bg-dark-border/20 border border-dark-border rounded-xl px-3 py-3 text-sm text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-all w-full cursor-pointer',
                      onChange: (values) {
                        final val = values.firstOrNull ?? 'null';
                        setState(() {
                          _selectedCategoryId = val == 'null' ? null : int.tryParse(val);
                          _selectedSubCategoryId = null; // Reset subcategory when category changes
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
                          'bg-white/5 border border-white/10 rounded-xl px-3 py-3 text-sm text-dark-muted animate-pulse',
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
                  label(classes: 'text-xs font-semibold text-dark-muted', [
                    Component.text('Subcategory'),
                  ]),
                  if (_selectedCategoryId == null)
                    select(
                      classes:
                          'bg-dark-border/20 border border-dark-border/40 rounded-xl px-3 py-3 text-sm text-dark-muted/40 w-full cursor-not-allowed',
                      attributes: {'disabled': ''},
                      [
                        option(value: 'null', [Component.text('Select category first')]),
                      ],
                    )
                  else if (subCategoriesAsync != null)
                    subCategoriesAsync.when(
                      data: (subCategories) => select(
                        classes:
                            'bg-dark-border/20 border border-dark-border rounded-xl px-3 py-3 text-sm text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-all w-full cursor-pointer',
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
                            'bg-white/5 border border-white/10 rounded-xl px-3 py-3 text-sm text-dark-muted animate-pulse',
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

            // Footer Actions
            div(classes: 'flex items-center justify-end gap-3 pt-4 border-t border-dark-border/30', [
              if (!_isLoading)
                button(
                  classes:
                      'px-6 py-2.5 bg-white/5 border border-dark-border rounded-xl text-sm font-semibold text-white hover:bg-white/10 transition-all cursor-pointer',
                  onClick: component.onClose,
                  [Component.text('Cancel')],
                ),
              button(
                classes:
                    'px-6 py-2.5 btn-primary rounded-xl text-sm font-bold shadow-lg shadow-primary/20 flex items-center space-x-2 disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer',
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
          ],
        ),
      ],
    );
  }
}
