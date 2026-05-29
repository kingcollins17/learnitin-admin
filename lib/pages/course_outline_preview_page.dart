import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:learnitin_admin/core/core.dart';
import 'package:learnitin_admin/providers/admin_course_provider.dart';
import 'package:learnitin_admin/providers/category_provider.dart';

class CourseOutlinePreviewPage extends StatefulComponent {
  const CourseOutlinePreviewPage({super.key});

  @override
  State<CourseOutlinePreviewPage> createState() => _CourseOutlinePreviewPageState();
}

class _CourseOutlinePreviewPageState extends State<CourseOutlinePreviewPage> {
  int? _selectedCategoryId;
  int? _selectedSubCategoryId;
  String _activeTab = 'overview';
  final Set<int> _expandedChapterIndices = {0}; // Default expand the first chapter

  void _toggleChapter(int index) {
    setState(() {
      if (_expandedChapterIndices.contains(index)) {
        _expandedChapterIndices.remove(index);
      } else {
        _expandedChapterIndices.add(index);
      }
    });
  }

  void _createCourse(dynamic outline) async {
    if (_selectedCategoryId == null) {
      context.showError('Please select a category before creating the course.');
      return;
    }

    context.showLoading();

    try {
      await context
          .read(adminCourseProvider.notifier)
          .createCourse(
            body: outline,
            categoryId: _selectedCategoryId,
            subCategoryId: _selectedSubCategoryId,
            enroll: false,
            isPublic: true,
            onSuccess: (course) {
              context.hideLoading();
              context.showSuccess('Course "${course.title}" created successfully!');
              Router.of(context).push('/courses');
            },
            onError: (msg, [st]) {
              context.hideLoading();
              context.showError(msg);
            },
          );
    } catch (e) {
      print(e);
      context.hideLoading();
    }
  }

  @override
  Component build(BuildContext context) {
    final outline = context.watch(selectedGeneratedCourseProvider);

    if (outline == null) {
      return div(classes: 'flex flex-col items-center justify-center py-24 space-y-4', [
        span(classes: 'text-4xl', [Component.text('⚠️')]),
        h3(classes: 'text-xl font-bold text-white', [Component.text('No Outline Selected')]),
        p(classes: 'text-dark-muted', [Component.text('Please generate a course outline first.')]),
        button(
          classes: 'btn-primary px-6 py-2.5 rounded-xl shadow-lg cursor-pointer',
          onClick: () => Router.of(context).push('/courses'),
          [Component.text('Back to Courses')],
        ),
      ]);
    }

    final categoriesAsync = context.watch(categoriesProvider(null));
    final subCategoriesAsync = _selectedCategoryId != null
        ? context.watch(subCategoriesProvider(_selectedCategoryId!))
        : null;

    final outlineItems = outline.outline ?? [];

    // Extract all objectives from all modules to show in 'What You'll Learn'
    final allObjectives = outlineItems.expand((item) => item.objectives ?? <String>[]).toList();

    return div(classes: 'space-y-6 pb-12 relative animate-in fade-in duration-300', [
      // Top Navigation / Breadcrumbs & Actions Header
      div(classes: 'flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-dark-border/30 pb-6', [
        div(classes: 'space-y-1', [
          div(classes: 'flex items-center space-x-2 text-xs text-dark-muted', [
            button(
              classes: 'hover:text-white transition-colors cursor-pointer',
              onClick: () => Router.of(context).push('/courses'),
              [Component.text('Courses')],
            ),
            span([Component.text('/')]),
            span(classes: 'text-white font-medium', [Component.text('Syllabus Generator')]),
            span([Component.text('/')]),
            span(classes: 'text-primary font-semibold', [Component.text(outline.title ?? 'Outline Preview')]),
          ]),
          h1(classes: 'text-3xl font-extrabold text-white tracking-tight mt-1', [
            Component.text(outline.title ?? 'Generated Outline'),
          ]),
          div(classes: 'flex items-center space-x-3 text-xs text-dark-muted mt-1', [
            span(
              classes:
                  'bg-primary/10 text-primary border border-primary/20 px-2.5 py-0.5 rounded-full font-bold uppercase tracking-wider',
              [
                Component.text(outline.level ?? 'Intermediate'),
              ],
            ),
            span([Component.text('•')]),
            span([Component.text('⏱ ${outline.duration ?? "N/A"}')]),
            span([Component.text('•')]),
            span([Component.text('📚 ${outlineItems.length} Modules')]),
          ]),
        ]),
        div(classes: 'flex items-center gap-3 shrink-0', [
          button(
            classes:
                'px-5 py-2.5 bg-white/5 border border-dark-border rounded-xl text-sm font-semibold text-white hover:bg-white/10 transition-all cursor-pointer hover:border-white/20',
            onClick: () => Router.of(context).push('/courses'),
            [Component.text('Cancel')],
          ),
          button(
            classes:
                'px-6 py-2.5 btn-primary rounded-xl text-sm font-bold shadow-lg shadow-primary/20 cursor-pointer transition-all active:scale-98',
            onClick: () => _createCourse(outline),
            [Component.text('Confirm & Publish')],
          ),
        ]),
      ]),

      // Main Two-Column Layout (Matching Figma UI Reference)
      div(classes: 'grid grid-cols-1 lg:grid-cols-12 gap-8 text-left', [
        // ── LEFT COLUMN (lg:col-span-8) ────────────────────────────────
        div(classes: 'lg:col-span-8 space-y-6', [
          // Featured Preview Visual Card (Matching the video box)
          div(
            classes:
                'w-full aspect-[16/9] bg-gradient-to-br from-primary/30 to-purple-600/10 border border-white/[0.08] rounded-2xl relative overflow-hidden shadow-xl flex items-center justify-center group',
            [
              // Decorative background texture
              div(classes: 'absolute inset-0 bg-cover bg-center opacity-30 mix-blend-overlay', [
                Component.text(''),
              ]),
              // Glowing overlay
              div(
                classes: 'absolute inset-0 bg-gradient-to-t from-dark-bg via-transparent to-transparent opacity-80',
                [],
              ),

              // Centered Play / Syllabus Preview Icon
              div(
                classes:
                    'w-16 h-16 rounded-full bg-white/15 backdrop-blur-md border border-white/30 flex items-center justify-center text-xl text-white shadow-2xl transition-all duration-300 group-hover:scale-110 group-hover:bg-primary group-hover:border-primary cursor-pointer',
                [
                  span(classes: 'pl-1', [Component.text('▶')]),
                ],
              ),

              // Bottom Badge Info
            ],
          ),

          // Horizontal Navigation Tabs (Figma style: Overview, Objectives, Details)
          div(classes: 'flex border-b border-dark-border/40 gap-6 text-sm font-semibold', [
            for (final tab in [
              {'id': 'overview', 'label': 'Overview'},
              {'id': 'objectives', 'label': 'What You\'ll Learn'},
              {'id': 'technical', 'label': 'AI Generation Info'},
            ])
              button(
                classes:
                    'pb-3 transition-colors cursor-pointer border-b-2 font-bold '
                    '${_activeTab == tab['id'] ? "text-primary border-primary" : "text-dark-muted border-transparent hover:text-white"}',
                onClick: () => setState(() => _activeTab = tab['id']!),
                [Component.text(tab['label']!)],
              ),
          ]),

          // Active Tab Panel Content
          div(classes: 'bg-white/[0.02] border border-white/[0.04] rounded-2xl p-6 md:p-8 space-y-6', [
            if (_activeTab == 'overview') ...[
              // Overview Tab
              div(classes: 'space-y-4', [
                h3(classes: 'text-lg font-bold text-white', [Component.text('About this Course')]),
                p(classes: 'text-sm md:text-base text-white/80 leading-relaxed font-light', [
                  Component.text(outline.description ?? 'No description provided for this generated course.'),
                ]),
              ]),
            ] else if (_activeTab == 'objectives') ...[
              // Objectives Tab
              div(classes: 'space-y-4', [
                h3(classes: 'text-lg font-bold text-white', [Component.text('What You\'ll Learn')]),
                if (allObjectives.isEmpty)
                  p(classes: 'text-sm text-dark-muted italic', [Component.text('No learning goals specified.')])
                else
                  div(classes: 'grid grid-cols-1 md:grid-cols-2 gap-4', [
                    for (final objective in allObjectives.take(8))
                      div(classes: 'flex items-start space-x-3 text-xs md:text-sm text-white/90', [
                        span(classes: 'text-primary mt-0.5 shrink-0 font-bold', [Component.text('✓')]),
                        span([Component.text(objective)]),
                      ]),
                  ]),
              ]),
            ] else ...[
              // Technical Info Tab
              div(classes: 'space-y-4', [
                h3(classes: 'text-lg font-bold text-white', [Component.text('Generation Parameters')]),
                div(classes: 'grid grid-cols-1 sm:grid-cols-3 gap-4 text-xs', [
                  div(classes: 'bg-white/[0.01] border border-white/5 rounded-xl p-4 space-y-1', [
                    span(classes: 'text-dark-muted uppercase font-bold tracking-wider block', [
                      Component.text('Difficulty Level'),
                    ]),
                    span(classes: 'text-sm text-white capitalize font-bold', [Component.text(outline.level ?? 'N/A')]),
                  ]),
                  div(classes: 'bg-white/[0.01] border border-white/5 rounded-xl p-4 space-y-1', [
                    span(classes: 'text-dark-muted uppercase font-bold tracking-wider block', [
                      Component.text('Duration Preference'),
                    ]),
                    span(classes: 'text-sm text-white font-bold', [Component.text(outline.duration ?? 'N/A')]),
                  ]),
                  div(classes: 'bg-white/[0.01] border border-white/5 rounded-xl p-4 space-y-1', [
                    span(classes: 'text-dark-muted uppercase font-bold tracking-wider block', [
                      Component.text('Chapters'),
                    ]),
                    span(classes: 'text-sm text-white font-bold', [Component.text('${outlineItems.length} Modules')]),
                  ]),
                ]),
              ]),
            ],
          ]),
        ]),

        // ── RIGHT COLUMN (lg:col-span-4) ───────────────────────────────
        div(classes: 'lg:col-span-4 space-y-6', [
          // Taxonomy Placement Panel
          div(classes: 'bg-dark-card border border-dark-border rounded-2xl p-5 space-y-4 shadow-xl', [
            h3(classes: 'text-sm font-bold text-white uppercase tracking-wider border-b border-dark-border/30 pb-2.5', [
              Component.text('Publish Settings'),
            ]),
            div(classes: 'space-y-4', [
              // Category Dropdown
              div(classes: 'space-y-1.5', [
                label(classes: 'text-xs font-semibold text-dark-muted pl-0.5', [
                  Component.text('Category *'),
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

              // Subcategory Dropdown
              div(classes: 'space-y-1.5', [
                label(classes: 'text-xs font-semibold text-dark-muted pl-0.5', [
                  Component.text('Subcategory (Optional)'),
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

          // Accordion Course Content List (Figma Side Box layout)
          div(classes: 'bg-dark-card border border-dark-border rounded-2xl p-5 space-y-4 shadow-xl text-left', [
            div(classes: 'flex items-center justify-between border-b border-dark-border/30 pb-2.5', [
              h3(classes: 'text-sm font-bold text-white uppercase tracking-wider', [
                Component.text('Course Content'),
              ]),
              span(classes: 'text-[10px] text-dark-muted font-bold', [
                Component.text('${outlineItems.length} Modules'),
              ]),
            ]),

            if (outlineItems.isEmpty)
              p(classes: 'text-xs text-dark-muted italic', [Component.text('No outline modules generated.')])
            else
              div(classes: 'space-y-2 max-h-[450px] overflow-y-auto pr-1', [
                for (var idx = 0; idx < outlineItems.length; idx++)
                  div(classes: 'border border-white/[0.04] rounded-xl overflow-hidden', [
                    // Accordion Header
                    button(
                      classes:
                          'w-full px-4 py-3 bg-white/[0.02] hover:bg-white/[0.05] flex items-center justify-between transition-colors cursor-pointer text-left',
                      onClick: () => _toggleChapter(idx),
                      [
                        div(classes: 'flex-1 min-w-0 pr-3', [
                          p(classes: 'text-xs font-bold text-white truncate', [
                            Component.text(
                              '${(idx + 1).toString().padLeft(2, "0")}: ${outlineItems[idx].title ?? "Untitled"}',
                            ),
                          ]),
                        ]),
                        div(classes: 'flex items-center space-x-2 shrink-0', [
                          if (outlineItems[idx].duration != null)
                            span(
                              classes:
                                  'text-[9px] text-dark-muted bg-white/5 px-2 py-0.5 rounded border border-white/5 font-mono',
                              [
                                Component.text(outlineItems[idx].duration!),
                              ],
                            ),
                          span(classes: 'text-[10px] text-dark-muted', [
                            Component.text(_expandedChapterIndices.contains(idx) ? '▲' : '▼'),
                          ]),
                        ]),
                      ],
                    ),

                    // Accordion Expanded Lessons List
                    if (_expandedChapterIndices.contains(idx))
                      div(classes: 'p-3 bg-dark-bg/40 border-t border-white/[0.04] space-y-2', [
                        if (outlineItems[idx].lessons == null || outlineItems[idx].lessons!.isEmpty)
                          p(classes: 'text-[10px] text-dark-muted italic pl-2', [
                            Component.text('No lessons in this module.'),
                          ])
                        else
                          for (final lesson in outlineItems[idx].lessons!)
                            div(
                              classes:
                                  'flex items-start justify-between text-xs p-2 bg-white/[0.01] hover:bg-white/[0.03] border border-white/5 rounded-lg transition-colors',
                              [
                                div(classes: 'flex-1 min-w-0 flex items-start space-x-2', [
                                  span(classes: 'text-primary mt-0.5', [Component.text('▶')]),
                                  span(classes: 'text-white/80 font-light truncate', [
                                    Component.text(lesson.title ?? 'Untitled Lesson'),
                                  ]),
                                ]),
                                if (lesson.duration != null)
                                  span(classes: 'text-[9px] text-dark-muted font-mono shrink-0 pl-2 mt-0.5', [
                                    Component.text(lesson.duration!),
                                  ]),
                              ],
                            ),
                      ]),
                  ]),
              ]),
          ]),
        ]),
      ]),
    ]);
  }
}
