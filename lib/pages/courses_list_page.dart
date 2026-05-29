import 'dart:async';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:learnitin_admin/core/core.dart';
import 'package:learnitin_admin/models/course_generation.dart';
import 'package:learnitin_admin/providers/category_provider.dart';

import '../providers/admin_course_provider.dart';
import '../models/paginated_response.dart';
import '../models/course.dart';

class CoursesListPage extends StatefulComponent {
  const CoursesListPage({super.key});

  @override
  State<CoursesListPage> createState() => _CoursesListPageState();
}

class _CoursesListPageState extends State<CoursesListPage> {
  bool _showCreateModal = false;

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
    // Open preview side panel using ContextUtils extension showSidePanel
    context.showSidePanel(
      _OutlinePreviewPanel(
        outline: course,
        onClose: () => context.hideSidePanel(),
      ),
    );
  }

  @override
  Component build(BuildContext context) {
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
      const _CoursesSection(),

      // ── Create Course Outline Modal ────────────────────────────────
      if (_showCreateModal)
        _CreateOutlineModal(
          onClose: _closeCreateModal,
          onOutlineGenerated: _onOutlineGenerated,
        ),
    ]);
  }
}

class _CreateOutlineModal extends StatefulComponent {
  final VoidCallback onClose;
  final void Function(GeneratedCourse course) onOutlineGenerated;

  const _CreateOutlineModal({
    required this.onClose,
    required this.onOutlineGenerated,
    super.key,
  });

  @override
  State<_CreateOutlineModal> createState() => _CreateOutlineModalState();
}

class _CreateOutlineModalState extends State<_CreateOutlineModal> {
  String _topic = '';
  String _level = 'beginner';
  String _learningPace = 'balanced';
  int _durationWeeks = 6;
  String _learningGoalsInput = '';
  bool _isLoading = false;

  void _generateOutline() async {
    if (_topic.trim().isEmpty) {
      context.showError('Please enter a course topic.');
      return;
    }

    final request = GenerateCoursesRequest(
      topic: _topic.trim(),
      level: _level.toLowerCase(),
      learningPace: _learningPace.toLowerCase(),
      durationPreference: '$_durationWeeks weeks',
      learningGoals: _learningGoalsInput.isNotEmpty
          ? _learningGoalsInput.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
          : null,
    );

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await context
          .read(adminCourseProvider.notifier)
          .generateCourseOutline(
            request,
            onError: (msg, [st]) {
              context.showError(msg);
            },
          );

      if (response != null && response.courses != null && response.courses!.isNotEmpty) {
        context.showSuccess('Course outline generated successfully!');
        component.onOutlineGenerated(response.courses!.first);
      } else {
        context.showError('No course outlines generated. Please try again.');
      }
    } catch (e) {
      // Handled via notifier's onError callback
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
              'relative w-full max-w-lg bg-dark-card border border-dark-border/80 rounded-2xl shadow-2xl p-6 md:p-8 space-y-6 animate-in zoom-in-95 duration-200 overflow-y-auto max-h-[90vh]',
          [
            // Header
            div(classes: 'flex items-center justify-between', [
              div(classes: 'space-y-1', [
                h3(classes: 'text-xl font-bold text-white', [
                  Component.text('Generate AI Course Outline'),
                ]),
                p(classes: 'text-xs text-dark-muted', [
                  Component.text('Fill in the parameters below to generate a new syllabus outline.'),
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
            div(classes: 'space-y-4 text-left', [
              // Topic Input
              div(classes: 'space-y-1.5', [
                label(classes: 'text-xs font-bold text-dark-muted uppercase tracking-wider', [
                  Component.text('Course Topic'),
                ]),
                input<String>(
                  type: InputType.text,
                  classes:
                      'bg-dark-border/20 border border-dark-border rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-all w-full',
                  value: _topic,
                  onInput: (val) => setState(() => _topic = val),
                  attributes: _isLoading ? {'disabled': ''} : {},
                ),
              ]),

              // Level, Pace, Duration in grid
              div(classes: 'grid grid-cols-1 sm:grid-cols-3 gap-4', [
                // Level Dropdown
                div(classes: 'space-y-1.5', [
                  label(classes: 'text-xs font-bold text-dark-muted uppercase tracking-wider', [
                    Component.text('Difficulty Level'),
                  ]),
                  select(
                    classes:
                        'bg-dark-border/20 border border-dark-border rounded-xl px-3 py-3 text-sm text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-all w-full appearance-none cursor-pointer',
                    onChange: (values) {
                      final val = values.firstOrNull ?? 'beginner';
                      setState(() => _level = val);
                    },
                    attributes: _isLoading ? {'disabled': ''} : {},
                    [
                      option(value: 'beginner', selected: _level == 'beginner', [Component.text('Beginner')]),
                      option(value: 'intermediate', selected: _level == 'intermediate', [
                        Component.text('Intermediate'),
                      ]),
                      option(value: 'expert', selected: _level == 'expert', [Component.text('Expert')]),
                    ],
                  ),
                ]),

                // Pace Dropdown
                div(classes: 'space-y-1.5', [
                  label(classes: 'text-xs font-bold text-dark-muted uppercase tracking-wider', [
                    Component.text('Learning Pace'),
                  ]),
                  select(
                    classes:
                        'bg-dark-border/20 border border-dark-border rounded-xl px-3 py-3 text-sm text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-all w-full appearance-none cursor-pointer',
                    onChange: (values) {
                      final val = values.firstOrNull ?? 'balanced';
                      setState(() => _learningPace = val);
                    },
                    attributes: _isLoading ? {'disabled': ''} : {},
                    [
                      option(value: 'balanced', selected: _learningPace == 'balanced', [Component.text('Balanced')]),
                      option(value: 'fast', selected: _learningPace == 'fast', [Component.text('Fast')]),
                      option(value: 'thorough', selected: _learningPace == 'thorough', [Component.text('Thorough')]),
                    ],
                  ),
                ]),

                // Duration Slider
                div(classes: 'space-y-1.5', [
                  label(classes: 'text-xs font-bold text-dark-muted uppercase tracking-wider', [
                    Component.text('Duration: $_durationWeeks weeks'),
                  ]),
                  input<num>(
                    type: InputType.range,
                    classes: 'w-full accent-primary cursor-pointer',
                    value: _durationWeeks.toString(),
                    onInput: (val) => setState(() => _durationWeeks = val.toInt()),
                    attributes: {
                      'min': '4',
                      'max': '12',
                      'step': '1',
                      if (_isLoading) 'disabled': '',
                    },
                  ),
                  div(classes: 'flex justify-between text-[10px] text-dark-muted', [
                    span([Component.text('4 weeks')]),
                    span([Component.text('12 weeks')]),
                  ]),
                ]),
              ]),

              // Goals text area
              div(classes: 'space-y-1.5', [
                label(classes: 'text-xs font-bold text-dark-muted uppercase tracking-wider', [
                  Component.text('Learning Goals (Comma Separated)'),
                ]),
                textarea(
                  classes:
                      'bg-dark-border/20 border border-dark-border rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-all w-full min-h-[80px]',
                  onInput: (val) => setState(() => _learningGoalsInput = val),
                  attributes: _isLoading ? {'disabled': ''} : {},
                  [Component.text(_learningGoalsInput)],
                ),
              ]),
            ]),

            // Footer Actions
            div(classes: 'flex items-center justify-end gap-3 pt-4 border-t border-dark-border/40', [
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
                attributes: (_topic.trim().isEmpty || _isLoading) ? {'disabled': ''} : {},
                onClick: _isLoading ? null : _generateOutline,
                [
                  if (_isLoading)
                    div(
                      classes: 'w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin mr-1.5',
                      [],
                    )
                  else
                    span([Component.text('⚡')]),
                  span([Component.text(_isLoading ? 'Generating...' : 'Generate Outline')]),
                ],
              ),
            ]),
          ],
        ),
      ],
    );
  }
}

class _OutlinePreviewPanel extends StatefulComponent {
  final GeneratedCourse outline;
  final VoidCallback onClose;

  const _OutlinePreviewPanel({
    required this.outline,
    required this.onClose,
    super.key,
  });

  @override
  State<_OutlinePreviewPanel> createState() => _OutlinePreviewPanelState();
}

class _OutlinePreviewPanelState extends State<_OutlinePreviewPanel> {
  int? _selectedCategoryId;
  int? _selectedSubCategoryId;

  void _createCourse() async {
    if (_selectedCategoryId == null) {
      context.showError('Please select a category before creating the course.');
      return;
    }

    context.showLoading();

    try {
      await context
          .read(adminCourseProvider.notifier)
          .createCourse(
            body: component.outline,
            categoryId: _selectedCategoryId,
            subCategoryId: _selectedSubCategoryId,
            enroll: false,
            isPublic: true,
            onSuccess: (course) {
              context.hideLoading();
              context.showSuccess('Course "${course.title}" created successfully!');
              component.onClose();
            },
            onError: (msg, [st]) {
              context.hideLoading();
              context.showError(msg);
            },
          );
    } catch (e) {
      context.hideLoading();
    }
  }

  @override
  Component build(BuildContext context) {
    // Watch categories state
    final categoriesAsync = context.watch(categoriesProvider(null));

    // Watch subcategories state
    final subCategoriesAsync = _selectedCategoryId != null
        ? context.watch(subCategoriesProvider(_selectedCategoryId!))
        : null;

    final outlineItems = component.outline.outline ?? [];

    return div(
      classes: 'w-80 md:w-[36rem] shrink-0 bg-dark-card border-l border-dark-border shadow-2xl flex flex-col h-full',
      [
        // Header
        div(classes: 'flex items-center justify-between p-6 border-b border-dark-border/50', [
          div(classes: 'flex items-center space-x-3', [
            div(
              classes:
                  'w-9 h-9 rounded-lg bg-gradient-to-br from-primary/30 to-primary-700/30 flex items-center justify-center text-xs font-bold text-primary shrink-0',
              [Component.text('📝')],
            ),
            div(classes: 'min-w-0', [
              h3(classes: 'text-base font-bold text-white truncate max-w-[200px] md:max-w-[280px]', [
                Component.text(component.outline.title ?? 'Generated Outline'),
              ]),
              p(classes: 'text-xs text-dark-muted truncate', [Component.text('Confirm and publish course outline')]),
            ]),
          ]),
          button(
            classes: 'p-2 text-dark-muted hover:text-white rounded-lg hover:bg-white/5 transition-all cursor-pointer',
            onClick: component.onClose,
            [Component.text('✕')],
          ),
        ]),

        // Scrollable Content
        div(classes: 'flex-1 overflow-y-auto p-6 space-y-6 text-left', [
          // Basic Info
          div(classes: 'space-y-2', [
            h5(classes: 'text-[10px] font-bold text-dark-muted uppercase tracking-wider', [
              Component.text('Course Details'),
            ]),
            div(classes: 'bg-white/5 rounded-xl border border-white/5 p-4 space-y-3', [
              div(classes: 'flex justify-between text-xs', [
                div([
                  span(classes: 'text-dark-muted mr-1.5', [Component.text('Level:')]),
                  span(classes: 'text-white capitalize font-semibold', [
                    Component.text(component.outline.level ?? 'N/A'),
                  ]),
                ]),
                div([
                  span(classes: 'text-dark-muted mr-1.5', [Component.text('Duration:')]),
                  span(classes: 'text-white font-semibold', [Component.text(component.outline.duration ?? 'N/A')]),
                ]),
              ]),
              p(classes: 'text-sm text-white leading-relaxed', [
                Component.text(component.outline.description ?? 'No description available for the generated course.'),
              ]),
            ]),
          ]),

          // Category Selectors
          div(classes: 'space-y-4', [
            h5(classes: 'text-[10px] font-bold text-dark-muted uppercase tracking-wider', [
              Component.text('Taxonomy (Required)'),
            ]),
            div(classes: 'grid grid-cols-1 sm:grid-cols-2 gap-4', [
              // Category Dropdown
              div(classes: 'space-y-1.5', [
                label(classes: 'text-xs font-semibold text-dark-muted', [
                  Component.text('Category *'),
                ]),
                categoriesAsync.when(
                  data: (categories) => select(
                    classes:
                        'bg-white/5 border border-white/10 rounded-xl px-3 py-2 text-xs text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-all w-full cursor-pointer',
                    onChange: (values) {
                      final val = values.firstOrNull ?? 'null';
                      setState(() {
                        _selectedCategoryId = val == 'null' ? null : int.tryParse(val);
                        _selectedSubCategoryId = null; // Reset subcategory when category changes
                      });
                    },
                    [
                      option(value: 'null', selected: _selectedCategoryId == null, [Component.text('Select Category')]),
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
                        'bg-white/5 border border-white/10 rounded-xl px-3 py-2 text-xs text-dark-muted animate-pulse',
                    [
                      Component.text('Loading categories...'),
                    ],
                  ),
                  error: (e, __) => div(classes: 'text-xs text-red-400', [
                    Component.text('Error loading categories'),
                  ]),
                ),
              ]),

              // Sub Category Dropdown
              div(classes: 'space-y-1.5', [
                label(classes: 'text-xs font-semibold text-dark-muted', [
                  Component.text('Subcategory'),
                ]),
                if (_selectedCategoryId == null)
                  select(
                    classes:
                        'bg-white/5 border border-white/10 rounded-xl px-3 py-2 text-xs text-dark-muted/40 w-full cursor-not-allowed',
                    attributes: {'disabled': ''},
                    [
                      option(value: 'null', [Component.text('Select category first')]),
                    ],
                  )
                else if (subCategoriesAsync != null)
                  subCategoriesAsync.when(
                    data: (subCategories) => select(
                      classes:
                          'bg-white/5 border border-white/10 rounded-xl px-3 py-2 text-xs text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-all w-full cursor-pointer',
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
                          'bg-white/5 border border-white/10 rounded-xl px-3 py-2 text-xs text-dark-muted animate-pulse',
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

          // Syllabus Outline
          div(classes: 'space-y-3', [
            h5(classes: 'text-[10px] font-bold text-dark-muted uppercase tracking-wider', [
              Component.text('Syllabus Chapters'),
            ]),
            if (outlineItems.isEmpty)
              p(classes: 'text-xs text-dark-muted italic', [Component.text('No outline modules generated.')])
            else
              div(classes: 'space-y-4', [
                for (var idx = 0; idx < outlineItems.length; idx++)
                  _OutlineItemCard(
                    index: idx + 1,
                    item: outlineItems[idx],
                  ),
              ]),
          ]),
        ]),

        // Action Buttons Footer
        div(classes: 'p-6 border-t border-dark-border/50 bg-dark-bg/20 flex gap-3', [
          button(
            classes:
                'flex-1 px-4 py-3 bg-white/5 border border-dark-border rounded-xl text-xs font-semibold text-white hover:bg-white/10 transition-all cursor-pointer',
            onClick: component.onClose,
            [Component.text('Cancel')],
          ),
          button(
            classes:
                'flex-1 px-4 py-3 btn-primary rounded-xl text-xs font-bold shadow-lg shadow-primary/20 cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed',
            attributes: _selectedCategoryId == null ? {'disabled': ''} : {},
            onClick: _createCourse,
            [Component.text('Confirm & Create')],
          ),
        ]),
      ],
    );
  }
}

class _OutlineItemCard extends StatelessComponent {
  final int index;
  final GeneratedOutlineItem item;

  const _OutlineItemCard({
    required this.index,
    required this.item,
    super.key,
  });

  @override
  Component build(BuildContext context) {
    final lessons = item.lessons ?? [];
    final objectives = item.objectives ?? [];

    return div(
      classes: 'bg-white/5 rounded-xl border border-white/5 p-4 space-y-3 relative overflow-hidden',
      [
        // Chapter indicator badge
        div(
          classes:
              'absolute top-0 right-0 bg-primary/10 border-l border-b border-primary/20 px-3 py-1 rounded-bl-xl text-[9px] font-bold text-primary uppercase tracking-wide',
          [
            Component.text('Chapter $index'),
          ],
        ),

        div(classes: 'space-y-1 pr-16', [
          h4(classes: 'text-sm font-bold text-white leading-snug', [
            Component.text(item.title ?? 'Untitled Section'),
          ]),
          if (item.duration != null)
            p(classes: 'text-[10px] text-dark-muted flex items-center space-x-1', [
              span([Component.text('⏱')]),
              span([Component.text(item.duration!)]),
            ]),
        ]),

        if (item.description != null && item.description!.isNotEmpty)
          p(classes: 'text-xs text-dark-muted leading-relaxed', [
            Component.text(item.description!),
          ]),

        // Objectives
        if (objectives.isNotEmpty)
          div(classes: 'space-y-1', [
            p(classes: 'text-[9px] font-bold text-dark-muted uppercase tracking-wider', [
              Component.text('Objectives'),
            ]),
            ul(classes: 'list-disc pl-4 space-y-0.5 text-xs text-white/70', [
              for (final objective in objectives) li([Component.text(objective)]),
            ]),
          ]),

        // Lessons
        if (lessons.isNotEmpty)
          div(classes: 'space-y-2 border-t border-white/5 pt-2.5', [
            p(classes: 'text-[9px] font-bold text-dark-muted uppercase tracking-wider', [
              Component.text('Lessons (${lessons.length})'),
            ]),
            div(classes: 'space-y-2', [
              for (var lIdx = 0; lIdx < lessons.length; lIdx++)
                div(classes: 'bg-white/[0.02] border border-white/5 rounded-lg p-2.5 space-y-1 text-xs', [
                  div(classes: 'flex items-center space-x-2 font-bold text-white', [
                    span(classes: 'text-primary', [Component.text('$index.${lIdx + 1}')]),
                    span([Component.text(lessons[lIdx].title ?? 'Untitled Lesson')]),
                  ]),
                  if (lessons[lIdx].description != null)
                    p(classes: 'text-[11px] text-dark-muted leading-normal pl-5', [
                      Component.text(lessons[lIdx].description!),
                    ]),
                ]),
            ]),
          ]),
      ],
    );
  }
}

class _CoursesSection extends StatefulComponent {
  const _CoursesSection();

  @override
  State<_CoursesSection> createState() => _CoursesSectionState();
}

class _CoursesSectionState extends State<_CoursesSection> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query, AdminCourseNotifier notifier) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      notifier.setSearch(query);
    });
  }

  @override
  Component build(BuildContext context) {
    final coursesAsync = context.watch(adminCourseProvider);
    final notifier = context.read(adminCourseProvider.notifier);
    final params = notifier.params;

    return div(classes: 'card overflow-hidden', [
      // Filters Header
      div(classes: 'flex flex-col md:flex-row md:items-center justify-between mb-8 gap-4', [
        div(classes: 'flex flex-wrap items-center gap-3 w-full md:w-auto', [
          // Search Input
          div(classes: 'relative flex-1 md:flex-none md:min-w-[300px]', [
            span(classes: 'absolute left-4 top-1/2 -translate-y-1/2 text-dark-muted', [Component.text('🔍')]),
            input<String>(
              type: InputType.text,
              classes:
                  'bg-dark-border/30 border border-dark-border rounded-xl pl-11 pr-4 py-2.5 text-sm text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-all w-full',
              value: params.search ?? '',
              onInput: (value) => _onSearchChanged(value, notifier),
            ),
          ]),

          // Refresh Button
          button(
            classes:
                'p-2.5 rounded-xl bg-dark-border/30 border border-dark-border text-dark-muted hover:text-white hover:bg-dark-border/50 transition-all cursor-pointer',
            onClick: () => notifier.refresh(),
            [Component.text('🔄')],
          ),
        ]),

        div(classes: 'flex items-center space-x-2 text-sm text-dark-muted', [
          span([Component.text('Sorted by:')]),
          span(classes: 'text-white font-medium', [Component.text('Newest First')]),
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
                '${(pagination!.page - 1) * pagination!.perPage + 1} - ${((pagination!.page - 1) * pagination!.perPage + courses.length)}',
              ),
            ]),
            Component.text(' of '),
            span(classes: 'text-white font-bold', [Component.text('${pagination!.total}')]),
            Component.text(' items'),
          ]),

          div(classes: 'flex items-center space-x-1.5', [
            button(
              classes:
                  'flex items-center justify-center w-10 h-10 rounded-xl bg-dark-border/30 border border-dark-border text-dark-muted hover:text-white hover:bg-dark-border/50 disabled:opacity-20 disabled:cursor-not-allowed transition-all cursor-pointer',
              attributes: pagination!.page <= 1 ? {'disabled': ''} : {},
              onClick: () => onPageChange?.call(pagination!.page - 1),
              [Component.text('←')],
            ),

            for (var i = 1; i <= pagination!.totalPages; i++)
              if (i == 1 || i == pagination!.totalPages || (i >= pagination!.page - 1 && i <= pagination!.page + 1))
                button(
                  classes:
                      'flex items-center justify-center w-10 h-10 rounded-xl border transition-all text-sm font-bold cursor-pointer '
                      '${i == pagination!.page ? "bg-primary border-primary text-white shadow-lg shadow-primary/20" : "bg-dark-border/30 border-dark-border text-dark-muted hover:text-white hover:bg-dark-border/50"}',
                  onClick: () => i != pagination!.page ? onPageChange?.call(i) : null,
                  [Component.text('$i')],
                )
              else if (i == 2 || i == pagination!.totalPages - 1)
                span(classes: 'text-dark-muted px-1.5', [Component.text('...')]),

            button(
              classes:
                  'flex items-center justify-center w-10 h-10 rounded-xl bg-dark-border/30 border border-dark-border text-dark-muted hover:text-white hover:bg-dark-border/50 disabled:opacity-20 disabled:cursor-not-allowed transition-all cursor-pointer',
              attributes: (pagination!.page >= pagination!.totalPages || courses.isEmpty) ? {'disabled': ''} : {},
              onClick: () => onPageChange?.call(pagination!.page + 1),
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
