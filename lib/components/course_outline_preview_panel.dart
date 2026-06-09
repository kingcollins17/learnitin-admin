import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:learnitin_admin/core/core.dart';
import 'package:learnitin_admin/models/course_generation.dart';
import 'package:learnitin_admin/providers/admin_course_provider.dart';
import 'package:learnitin_admin/providers/category_provider.dart';

class CourseOutlinePreviewPanel extends StatefulComponent {
  final GeneratedCourse outline;
  final VoidCallback onClose;

  const CourseOutlinePreviewPanel({
    required this.outline,
    required this.onClose,
    super.key,
  });

  @override
  State<CourseOutlinePreviewPanel> createState() => _CourseOutlinePreviewPanelState();
}

class _CourseOutlinePreviewPanelState extends State<CourseOutlinePreviewPanel> {
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
          .read(adminCourseProvider(defaultAdminCourseParams).notifier)
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
      print(e);
      context.hideLoading();
    }
  }

  @override
  Component build(BuildContext context) {
    // Watch categories state
    final categoriesAsync = context.watch(categoriesProvider((search: null, sortByPopularity: null)));

    // Watch subcategories state
    final subCategoriesAsync = _selectedCategoryId != null
        ? context.watch(subCategoriesProvider(_selectedCategoryId!))
        : null;

    final outlineItems = component.outline.outline ?? [];

    return div(
      classes:
          'w-96 md:w-[48rem] max-w-[95vw] shrink-0 bg-dark-card border-l border-dark-border shadow-2xl flex flex-col h-full animate-in slide-in-from-right duration-300',
      [
        // Header
        div(classes: 'flex items-center justify-between p-6 border-b border-dark-border/50 bg-white/[0.01]', [
          div(classes: 'flex items-center space-x-4', [
            div(
              classes:
                  'w-11 h-11 rounded-xl bg-gradient-to-br from-primary/30 to-primary-700/10 border border-primary/20 flex items-center justify-center text-lg shrink-0 shadow-lg shadow-primary/5',
              [Component.text('🤖')],
            ),
            div(classes: 'min-w-0', [
              h3(classes: 'text-lg font-bold text-white truncate max-w-[260px] md:max-w-[400px]', [
                Component.text(component.outline.title ?? 'Generated Outline'),
              ]),
              p(classes: 'text-xs text-dark-muted font-medium', [
                Component.text('Review & structure AI course syllabus'),
              ]),
            ]),
          ]),
          button(
            classes:
                'p-2 text-dark-muted hover:text-white rounded-lg hover:bg-white/5 transition-all cursor-pointer border border-transparent hover:border-dark-border',
            onClick: component.onClose,
            [Component.text('✕')],
          ),
        ]),

        // Scrollable Content
        div(classes: 'flex-1 overflow-y-auto p-6 space-y-6 text-left scrollbar-thin scrollbar-thumb-dark-border', [
          // Basic Info Details Panel
          div(classes: 'space-y-2.5', [
            h5(classes: 'text-[10px] font-bold text-dark-muted uppercase tracking-widest pl-1', [
              Component.text('Course Overview'),
            ]),
            div(
              classes:
                  'bg-gradient-to-b from-white/[0.04] to-white/[0.01] rounded-2xl border border-white/5 p-5 space-y-4 shadow-inner',
              [
                div(classes: 'grid grid-cols-2 gap-4', [
                  div(classes: 'bg-white/[0.02] border border-white/5 rounded-xl p-3 flex flex-col justify-center', [
                    span(classes: 'text-[10px] font-medium text-dark-muted uppercase tracking-wider mb-0.5', [
                      Component.text('Level'),
                    ]),
                    span(classes: 'text-xs text-white capitalize font-semibold flex items-center space-x-1.5', [
                      span(classes: 'w-1.5 h-1.5 rounded-full bg-primary', []),
                      Component.text(component.outline.level ?? 'N/A'),
                    ]),
                  ]),
                  div(classes: 'bg-white/[0.02] border border-white/5 rounded-xl p-3 flex flex-col justify-center', [
                    span(classes: 'text-[10px] font-medium text-dark-muted uppercase tracking-wider mb-0.5', [
                      Component.text('Target Duration'),
                    ]),
                    span(classes: 'text-xs text-white font-semibold flex items-center space-x-1.5', [
                      span([Component.text('⏱')]),
                      Component.text(component.outline.duration ?? 'N/A'),
                    ]),
                  ]),
                ]),
                p(classes: 'text-sm text-white/80 leading-relaxed font-light', [
                  Component.text(component.outline.description ?? 'No description available for the generated course.'),
                ]),
              ],
            ),
          ]),

          // Taxonomy Selectors Card
          div(
            classes:
                'bg-gradient-to-b from-white/[0.04] to-white/[0.01] border border-white/5 rounded-2xl p-5 space-y-4 shadow-sm',
            [
              h5(classes: 'text-[10px] font-bold text-dark-muted uppercase tracking-widest pl-1', [
                Component.text('Course Placement & Taxonomy'),
              ]),
              div(classes: 'grid grid-cols-1 md:grid-cols-2 gap-4', [
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
                          _selectedSubCategoryId = null; // Reset subcategory when category changes
                        });
                      },
                      [
                        option(value: 'null', selected: _selectedCategoryId == null, [
                          Component.text('Select Category'),
                        ]),
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

                // Sub Category Dropdown
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
            ],
          ),

          // Syllabus Outline
          div(classes: 'space-y-3', [
            h5(classes: 'text-[10px] font-bold text-dark-muted uppercase tracking-widest pl-1', [
              Component.text('Syllabus Chapters'),
            ]),
            if (outlineItems.isEmpty)
              p(classes: 'text-xs text-dark-muted italic pl-1', [Component.text('No outline modules generated.')])
            else
              div(classes: 'space-y-5', [
                for (var idx = 0; idx < outlineItems.length; idx++)
                  CourseOutlineItemCard(
                    index: idx + 1,
                    item: outlineItems[idx],
                  ),
              ]),
          ]),
        ]),

        // Action Buttons Footer
        div(classes: 'p-6 border-t border-dark-border/50 bg-dark-bg/40 backdrop-blur-md flex gap-4', [
          button(
            classes:
                'flex-1 px-5 py-3.5 bg-white/5 border border-dark-border rounded-xl text-xs font-semibold text-white hover:bg-white/10 transition-all cursor-pointer hover:border-white/20 active:scale-98',
            onClick: component.onClose,
            [Component.text('Cancel')],
          ),
          button(
            classes:
                'flex-1 px-5 py-3.5 btn-primary rounded-xl text-xs font-bold shadow-lg shadow-primary/20 cursor-pointer disabled:opacity-40 disabled:cursor-not-allowed transition-all active:scale-98',
            attributes: _selectedCategoryId == null ? {'disabled': ''} : {},
            onClick: _createCourse,
            [Component.text('Confirm & Create')],
          ),
        ]),
      ],
    );
  }
}

class CourseOutlineItemCard extends StatelessComponent {
  final int index;
  final GeneratedOutlineItem item;

  const CourseOutlineItemCard({
    required this.index,
    required this.item,
    super.key,
  });

  @override
  Component build(BuildContext context) {
    final lessons = item.lessons ?? [];
    final objectives = item.objectives ?? [];

    return div(
      classes:
          'bg-gradient-to-br from-dark-card to-dark-bg/25 rounded-2xl border border-white/[0.08] p-6 md:p-8 space-y-6 relative overflow-hidden shadow-xl hover:shadow-primary/5 hover:border-primary/20 transition-all duration-300 group',
      [
        // Chapter indicator badge
        div(classes: 'flex items-center justify-between border-b border-white/5 pb-4', [
          div(
            classes:
                'bg-primary/10 border border-primary/20 px-3 py-1 rounded-full text-[10px] font-extrabold text-primary uppercase tracking-wider',
            [
              Component.text('Chapter $index'),
            ],
          ),
          if (item.duration != null)
            div(
              classes:
                  'text-xs text-dark-muted flex items-center space-x-1.5 font-medium bg-white/5 px-2.5 py-1 rounded-lg border border-white/5',
              [
                span([Component.text('⏱')]),
                span([Component.text(item.duration!)]),
              ],
            ),
        ]),

        // Title and Description
        div(classes: 'space-y-3 text-left', [
          h4(
            classes:
                'text-lg md:text-xl font-extrabold text-white leading-snug tracking-tight group-hover:text-primary transition-colors',
            [
              Component.text(item.title ?? 'Untitled Section'),
            ],
          ),
          if (item.description != null && item.description!.isNotEmpty)
            p(classes: 'text-sm text-white/80 leading-relaxed font-light pl-0.5', [
              Component.text(item.description!),
            ]),
        ]),

        // Objectives Container
        if (objectives.isNotEmpty)
          div(classes: 'space-y-3 bg-white/[0.02] border border-white/5 rounded-2xl p-5 text-left', [
            div(classes: 'flex items-center space-x-2', [
              span(classes: 'text-xs', [Component.text('🎯')]),
              p(classes: 'text-[10px] font-extrabold text-primary uppercase tracking-widest', [
                Component.text('Chapter Learning Objectives'),
              ]),
            ]),
            ul(classes: 'space-y-2.5 text-xs md:text-sm text-white/90 pl-1', [
              for (final objective in objectives)
                li(classes: 'flex items-start space-x-2.5', [
                  span(classes: 'text-primary mt-0.5 shrink-0', [Component.text('✓')]),
                  span([Component.text(objective)]),
                ]),
            ]),
          ]),

        // Lessons List Section
        if (lessons.isNotEmpty)
          div(classes: 'space-y-4 border-t border-white/5 pt-5 text-left', [
            p(classes: 'text-[10px] font-extrabold text-dark-muted uppercase tracking-widest pl-1', [
              Component.text('Syllabus Lessons (${lessons.length})'),
            ]),
            div(classes: 'space-y-4', [
              for (var lIdx = 0; lIdx < lessons.length; lIdx++)
                div(
                  classes:
                      'bg-white/[0.01] border border-white/[0.04] rounded-2xl p-5 space-y-3 hover:bg-white/[0.03] hover:border-white/10 transition-all duration-300 shadow-sm',
                  [
                    div(classes: 'flex items-center justify-between gap-3', [
                      div(classes: 'flex items-center space-x-3 font-bold text-white', [
                        span(
                          classes:
                              'text-primary bg-primary/10 border border-primary/20 px-2 py-0.5 rounded-lg text-xs font-mono',
                          [
                            Component.text('$index.${lIdx + 1}'),
                          ],
                        ),
                        span(classes: 'text-sm md:text-base font-bold tracking-tight', [
                          Component.text(lessons[lIdx].title ?? 'Untitled Lesson'),
                        ]),
                      ]),
                      if (lessons[lIdx].duration != null)
                        span(
                          classes:
                              'text-[10px] text-dark-muted font-medium bg-white/5 px-2 py-0.5 rounded border border-white/5',
                          [
                            Component.text(lessons[lIdx].duration!),
                          ],
                        ),
                    ]),
                    if (lessons[lIdx].description != null)
                      p(classes: 'text-xs md:text-sm text-white/70 leading-relaxed font-light pl-0.5', [
                        Component.text(lessons[lIdx].description!),
                      ]),
                    if (lessons[lIdx].objectives != null && lessons[lIdx].objectives!.isNotEmpty)
                      div(classes: 'pl-1 space-y-2 border-l-2 border-primary/20 ml-2 mt-3.5', [
                        p(classes: 'text-[9px] font-extrabold text-primary uppercase tracking-widest pl-2', [
                          Component.text('Key Takeaways'),
                        ]),
                        ul(classes: 'space-y-1.5 text-xs text-white/60 pl-2', [
                          for (final obj in lessons[lIdx].objectives!)
                            li(classes: 'flex items-start space-x-2', [
                              span(classes: 'text-primary shrink-0', [Component.text('•')]),
                              span([Component.text(obj)]),
                            ]),
                        ]),
                      ]),
                  ],
                ),
            ]),
          ]),
      ],
    );
  }
}
