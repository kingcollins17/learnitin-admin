import 'dart:async';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:learnitin_admin/core/core.dart';

import '../providers/admin_course_provider.dart';
import '../models/paginated_response.dart';
import '../models/course.dart';

class CoursesListPage extends StatelessComponent {
  const CoursesListPage({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'space-y-8 pb-8', [
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
              'btn-primary flex items-center space-x-2 px-6 py-3 rounded-xl shadow-lg shadow-primary/20 hover:shadow-primary/40 transition-all',
          [
            span([Component.text('➕')]),
            span([Component.text('Create New Course')]),
          ],
        ),
      ]),

      // ── Course List Table ────────────────────────────────────────
      const _CoursesSection(),
    ]);
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
              // placeholder: 'Search courses by title or description...',
              value: params.search ?? '',
              onInput: (value) => _onSearchChanged(value, notifier),
            ),
          ]),

          // Refresh Button
          button(
            classes:
                'p-2.5 rounded-xl bg-dark-border/30 border border-dark-border text-dark-muted hover:text-white hover:bg-dark-border/50 transition-all',
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
                    'px-6 py-2 bg-white/5 text-white border border-dark-border rounded-xl hover:bg-white/10 transition-all flex items-center space-x-2',
                onClick: () => notifier.setPage(params.page - 1),
                [
                  span([Component.text('←')]),
                  span([Component.text('Go Back')]),
                ],
              ),
            button(
              classes:
                  'px-6 py-2 bg-red-500/20 text-red-400 border border-red-500/30 rounded-xl hover:bg-red-500/30 transition-all',
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
  final PaginatedData<Course>? pagination;
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
                      // Visibility badge
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
                            'p-2 rounded-lg bg-white/5 border border-white/5 text-dark-muted hover:text-white hover:bg-white/10 hover:border-white/20 transition-all',

                        [Component.text('✏️')],
                      ),
                      button(
                        classes:
                            'p-2 rounded-lg bg-red-500/5 border border-red-500/5 text-red-400/70 hover:text-red-400 hover:bg-red-500/10 hover:border-red-500/20 transition-all',

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
                  'flex items-center justify-center w-10 h-10 rounded-xl bg-dark-border/30 border border-dark-border text-dark-muted hover:text-white hover:bg-dark-border/50 disabled:opacity-20 disabled:cursor-not-allowed transition-all',
              attributes: pagination!.page <= 1 ? {'disabled': ''} : {},
              onClick: () => onPageChange?.call(pagination!.page - 1),
              [Component.text('←')],
            ),

            for (var i = 1; i <= pagination!.totalPages; i++)
              if (i == 1 || i == pagination!.totalPages || (i >= pagination!.page - 1 && i <= pagination!.page + 1))
                button(
                  classes:
                      'flex items-center justify-center w-10 h-10 rounded-xl border transition-all text-sm font-bold '
                      '${i == pagination!.page ? "bg-primary border-primary text-white shadow-lg shadow-primary/20" : "bg-dark-border/30 border-dark-border text-dark-muted hover:text-white hover:bg-dark-border/50"}',
                  onClick: () => i != pagination!.page ? onPageChange?.call(i) : null,
                  [Component.text('$i')],
                )
              else if (i == 2 || i == pagination!.totalPages - 1)
                span(classes: 'text-dark-muted px-1.5', [Component.text('...')]),

            button(
              classes:
                  'flex items-center justify-center w-10 h-10 rounded-xl bg-dark-border/30 border border-dark-border text-dark-muted hover:text-white hover:bg-dark-border/50 disabled:opacity-20 disabled:cursor-not-allowed transition-all',
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
      'advanced' => 'bg-purple-500/10 text-purple-400 border border-purple-500/20',
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
