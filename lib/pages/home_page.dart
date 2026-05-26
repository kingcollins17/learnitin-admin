import 'dart:async';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:learnitin_admin/components/user_side_panel.dart';
import 'package:learnitin_admin/core/core.dart';

import '../providers/dashboard_provider.dart';
import '../providers/user_provider.dart';
import '../providers/admin_stats_provider.dart';
import '../providers/admin_user_provider.dart';
import '../providers/admin_course_provider.dart';
import '../models/paginated_response.dart';
import '../models/user.dart';
import '../models/course.dart';
import '../providers/auth_provider.dart';

class Home extends StatefulComponent {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() {
    final authState = context.read(authProvider);
    if (authState is AsyncData && authState.value == null) {
      Router.of(context).replace('/login');
    }
  }

  @override
  Component build(BuildContext context) {
    final authState = context.watch(authProvider);

    // If we definitely know the user is not authenticated, redirect
    if (authState is AsyncData && authState.value == null) {
      Future.microtask(() => Router.of(context).replace('/login'));
      return div([]);
    }

    // While loading auth or if authenticated, show content
    if (authState.isLoading) {
      return div(classes: 'flex items-center justify-center min-h-[60vh]', [
        div(classes: 'w-12 h-12 border-4 border-primary border-t-transparent rounded-full animate-spin', []),
      ]);
    }

    final dashboardData = context.watch(dashboardProvider);
    final userAsync = context.watch(currentUserProvider);
    if (userAsync is AsyncError) {
      Future.microtask(() async {
        await context.read(authProvider.notifier).logout();
        Router.of(context).replace('/login');
      });
      return div([]);
    }

    final statsAsync = context.watch(adminStatsProvider);

    return div(classes: 'space-y-8 pb-8', [
      // ── Welcome Banner ──────────────────────────────────────────
      userAsync.when(
        data: (user) => statsAsync.when(
          data: (stats) => _WelcomeBanner(
            userName: user?.fullName ?? user?.username ?? 'Admin',
            activeNow: stats?.activeUsers ?? 0,
          ),
          loading: () => _WelcomeBanner(userName: user?.fullName ?? 'Admin', activeNow: 0),
          error: (e, st) => _WelcomeBanner(userName: user?.fullName ?? 'Admin', activeNow: 0),
        ),
        loading: () => _WelcomeBanner(userName: 'Admin', activeNow: 0),
        error: (e, st) => _WelcomeBanner(userName: 'Admin', activeNow: 0),
      ),

      // ── Stats Grid ──────────────────────────────────────────────
      statsAsync.when(
        data: (stats) {
          final realStats = [
            StatItem(
              label: 'Total Users',
              value: (stats?.totalUsers ?? 0).toString(),
              trend: '+12.5%', // Mock trend for now
              isPositive: true,
              icon: '👥',
              subtitle: 'Platform-wide',
            ),
            StatItem(
              label: 'Active Users',
              value: (stats?.activeUsers ?? 0).toString(),
              trend: '+5.2%',
              isPositive: true,
              icon: '⚡',
              subtitle: 'Currently online',
            ),
            StatItem(
              label: 'Total Courses',
              value: (stats?.totalCourses ?? 0).toString(),
              trend: '+3.1%',
              isPositive: true,
              icon: '📚',
              subtitle: 'Available content',
              to: '/courses',
            ),
            StatItem(
              label: 'Total Lessons',
              value: (stats?.totalLessons ?? 0).toString(),
              trend: '+8.4%',
              isPositive: true,
              icon: '🎯',
              subtitle: 'Including audio',
            ),
          ];

          return div(classes: 'grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-5', [
            for (final stat in realStats) _StatCard(stat: stat),
          ]);
        },
        loading: () => div(classes: 'grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-5', [
          for (var i = 0; i < 4; i++) const _ShimmerStatCard(),
        ]),
        error: (e, st) => div(classes: 'text-red-500 p-4', [Component.text('Error loading stats: $e')]),
      ),

      // ── Revenue Section ─────────────────────────────────────────
      _RevenueChart(data: dashboardData.revenueChart),

      // ── Users Table ─────────────────────────────────────────────
      _UsersSection(),

      // ── Top Courses + Server Status ─────────────────────────────
      div(classes: 'grid grid-cols-1 xl:grid-cols-3 gap-6', [
        // Top Courses — 2/3 width
        div(classes: 'xl:col-span-2', [
          const _TopCoursesSection(),
        ]),

        // Quick Stats / Server Info
        _SystemOverview(
          uptime: dashboardData.serverUptime,
          activeNow: statsAsync.value?.activeUsers ?? dashboardData.activeNow,
        ),
      ]),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════════
//  WELCOME BANNER
// ══════════════════════════════════════════════════════════════════

class _WelcomeBanner extends StatelessComponent {
  final String userName;
  final int activeNow;
  const _WelcomeBanner({required this.userName, required this.activeNow});

  @override
  Component build(BuildContext context) {
    return div(
      classes:
          'relative overflow-hidden rounded-2xl bg-gradient-to-br from-primary-900/60 via-primary-800/30 to-dark-card border border-primary/20 p-8',
      [
        // Decorative circles
        div(classes: 'absolute -top-10 -right-10 w-40 h-40 bg-primary/10 rounded-full blur-3xl', []),
        div(classes: 'absolute -bottom-8 -left-8 w-32 h-32 bg-primary/5 rounded-full blur-2xl', []),

        // Content
        div(classes: 'relative z-10 flex flex-col md:flex-row md:items-center md:justify-between gap-4', [
          div(classes: 'space-y-2', [
            h1(classes: 'text-2xl md:text-3xl font-bold text-white tracking-tight', [
              Component.text('Welcome back, $userName 👋'),
            ]),
            p(classes: 'text-dark-muted text-sm md:text-base max-w-lg', [
              Component.text('Here\'s an overview of your platform\'s performance today. Everything is looking great!'),
            ]),
          ]),
          div(classes: 'flex items-center space-x-3', [
            div(classes: 'flex items-center space-x-2 px-4 py-2.5 rounded-xl glass', [
              div(classes: 'w-2.5 h-2.5 bg-emerald-400 rounded-full animate-pulse', []),
              span(classes: 'text-sm font-semibold text-white', [
                Component.text('$activeNow online now'),
              ]),
            ]),
            button(
              classes: 'btn-primary flex items-center space-x-2 rounded-xl',
              [
                span([Component.text('📊')]),
                span([Component.text('Generate Report')]),
              ],
            ),
          ]),
        ]),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  STAT CARD
// ══════════════════════════════════════════════════════════════════

class _StatCard extends StatelessComponent {
  final StatItem stat;
  const _StatCard({required this.stat});

  @override
  Component build(BuildContext context) {
    final cardContent = div(
      classes:
          'group card hover:border-primary/30 transition-all duration-300 hover:-translate-y-0.5 hover:shadow-primary/5 hover:shadow-2xl cursor-pointer h-full',
      [
        div(classes: 'flex items-start justify-between mb-5', [
          div(
            classes:
                'w-12 h-12 rounded-xl bg-primary/10 border border-primary/20 flex items-center justify-center text-xl group-hover:scale-110 transition-transform duration-300',
            [
              Component.text(stat.icon),
            ],
          ),
          div(
            classes:
                'flex items-center space-x-1 px-2.5 py-1 rounded-full text-xs font-bold '
                '${stat.isPositive ? "bg-emerald-500/10 text-emerald-400 border border-emerald-500/20" : "bg-red-500/10 text-red-400 border border-red-500/20"}',
            [
              span([Component.text(stat.isPositive ? '↑' : '↓')]),
              span([Component.text(stat.trend)]),
            ],
          ),
        ]),
        h2(classes: 'text-3xl font-bold text-white mb-1 tracking-tight', [
          Component.text(stat.value),
        ]),
        div(classes: 'flex items-center justify-between', [
          p(classes: 'text-sm font-medium text-dark-muted', [
            Component.text(stat.label),
          ]),
          p(classes: 'text-xs text-dark-muted/70', [
            Component.text(stat.subtitle),
          ]),
        ]),
      ],
    );

    if (stat.to != null) {
      return Link(to: stat.to!, classes: 'no-underline block h-full', child: cardContent);
    }

    return cardContent;
  }
}

class _ShimmerStatCard extends StatelessComponent {
  const _ShimmerStatCard();

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'card h-full animate-pulse',
      [
        div(classes: 'flex items-start justify-between mb-5', [
          div(classes: 'w-12 h-12 rounded-xl bg-dark-border/30', []),
          div(classes: 'w-16 h-6 rounded-full bg-dark-border/30', []),
        ]),
        div(classes: 'w-24 h-8 rounded-lg bg-dark-border/30 mb-2', []),
        div(classes: 'flex items-center justify-between', [
          div(classes: 'w-20 h-4 rounded-md bg-dark-border/30', []),
          div(classes: 'w-24 h-3 rounded-md bg-dark-border/30', []),
        ]),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  REVENUE CHART (Visual Bar Chart)
// ══════════════════════════════════════════════════════════════════

class _RevenueChart extends StatelessComponent {
  final List<RevenueDataPoint> data;
  const _RevenueChart({required this.data});

  @override
  Component build(BuildContext context) {
    final maxAmount = data.map((d) => d.amount).reduce((val1, val2) => val1 > val2 ? val1 : val2);

    return div(classes: 'card', [
      // Header
      div(classes: 'flex items-center justify-between mb-8', [
        div(classes: 'space-y-1', [
          h3(classes: 'text-lg font-bold text-white', [Component.text('Revenue Overview')]),
          p(classes: 'text-sm text-dark-muted', [Component.text('Monthly revenue for the last 10 months')]),
        ]),
        div(classes: 'flex items-center space-x-2', [
          button(
            classes: 'px-3 py-1.5 rounded-lg text-xs font-medium bg-primary/10 text-primary border border-primary/20',
            [
              Component.text('Monthly'),
            ],
          ),
          button(
            classes:
                'px-3 py-1.5 rounded-lg text-xs font-medium text-dark-muted hover:text-white hover:bg-white/5 transition-colors',
            [
              Component.text('Weekly'),
            ],
          ),
          button(
            classes:
                'px-3 py-1.5 rounded-lg text-xs font-medium text-dark-muted hover:text-white hover:bg-white/5 transition-colors',
            [
              Component.text('Daily'),
            ],
          ),
        ]),
      ]),

      // Chart area
      div(classes: 'flex items-end justify-between space-x-2 h-56 px-2', [
        for (var i = 0; i < data.length; i++)
          _ChartBar(
            label: data[i].month,
            value: data[i].amount,
            maxValue: maxAmount,
            isLast: i == data.length - 1,
          ),
      ]),

      // Summary footer
      div(classes: 'mt-6 pt-4 border-t border-dark-border flex items-center justify-between', [
        div(classes: 'flex items-center space-x-6', [
          div(classes: 'flex items-center space-x-2', [
            div(classes: 'w-3 h-3 rounded-full bg-primary', []),
            span(classes: 'text-xs text-dark-muted', [Component.text('Revenue')]),
          ]),
          div(classes: 'flex items-center space-x-2', [
            div(classes: 'w-3 h-3 rounded-full bg-primary/30', []),
            span(classes: 'text-xs text-dark-muted', [Component.text('Previous Period')]),
          ]),
        ]),
        span(classes: 'text-xs text-dark-muted', [Component.text('Updated 5 min ago')]),
      ]),
    ]);
  }
}

class _ChartBar extends StatelessComponent {
  final String label;
  final double value;
  final double maxValue;
  final bool isLast;

  const _ChartBar({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.isLast,
  });

  @override
  Component build(BuildContext context) {
    final percentage = (value / maxValue * 100).round();
    final displayValue = (value / 1000).toStringAsFixed(1);

    return div(classes: 'flex-1 flex flex-col items-center space-y-2 group', [
      // Value tooltip
      span(classes: 'text-xs font-medium text-dark-muted opacity-0 group-hover:opacity-100 transition-opacity', [
        Component.text('\$$displayValue K'),
      ]),

      // Bar
      div(classes: 'w-full flex items-end justify-center', [
        div(
          classes:
              'w-full max-w-[36px] rounded-t-lg transition-all duration-500 group-hover:opacity-100 '
              '${isLast ? "bg-gradient-to-t from-primary-600 to-primary opacity-100" : "bg-gradient-to-t from-primary-800/50 to-primary/40 opacity-70"}',
          styles: Styles(raw: {'height': '${percentage * 2}px', 'min-height': '12px'}),
          [],
        ),
      ]),

      // Label
      span(classes: 'text-xs ${isLast ? "text-primary font-semibold" : "text-dark-muted"}', [
        Component.text(label),
      ]),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════════
//  USER DISTRIBUTION
// ══════════════════════════════════════════════════════════════════

// ══════════════════════════════════════════════════════════════════
//  USERS SECTION
// ══════════════════════════════════════════════════════════════════

class _UsersSection extends StatefulComponent {
  @override
  State<_UsersSection> createState() => _UsersSectionState();
}

class _UsersSectionState extends State<_UsersSection> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query, AdminUserNotifier notifier) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      notifier.setSearch(query);
    });
  }

  @override
  Component build(BuildContext context) {
    final usersAsync = context.watch(adminUserProvider);
    final notifier = context.read(adminUserProvider.notifier);
    final params = notifier.params;

    return div(classes: 'card overflow-hidden', [
      // Header
      div(classes: 'flex flex-col md:flex-row md:items-center justify-between mb-6 gap-4', [
        div(classes: 'space-y-1', [
          h3(classes: 'text-lg font-bold text-white', [Component.text('Platform Users')]),
          p(classes: 'text-sm text-dark-muted', [Component.text('Manage your users and their activity')]),
        ]),
        div(classes: 'flex flex-wrap items-center gap-3', [
          Link(
            to: '/users',
            classes:
                'text-sm text-primary font-medium hover:underline underline-offset-4 transition-all flex items-center space-x-1',
            child: Component.text('See All Users →'),
          ),
        ]),
      ]),

      // Table
      usersAsync.when(
        data: (data) {
          final topUsers = data?.items.take(5).toList() ?? [];
          return _RecentUsersTable(
            users: topUsers
                .map(
                  (userItem) => RecentUser(
                    id: userItem.id,
                    name: userItem.fullName ?? userItem.username ?? 'Unknown',
                    email: userItem.email ?? '',
                    initials: (userItem.fullName ?? userItem.username ?? 'U')
                        .substring(0, userItem.fullName?.isEmpty == false ? 2 : 1)
                        .toUpperCase(),
                    role: userItem.isSuperuser == true ? 'Admin' : 'Learner',
                    joinedAgo: _formatDate(userItem.createdAt),
                    status: userItem.isActive == true ? 'active' : 'inactive',
                  ),
                )
                .toList(),
            pagination: null,
            onPageChange: null,
          );
        },

        loading: () => div(classes: 'flex items-center justify-center py-20', [
          div(classes: 'w-10 h-10 border-4 border-primary border-t-transparent rounded-full animate-spin', []),
        ]),
        error: (e, st) => div(classes: 'p-10 text-center text-red-400', [
          Component.text(e.toFriendlyMessage()),
          br(),
          button(
            classes: 'mt-4 px-4 py-2 bg-primary/20 text-primary border border-primary/30 rounded-lg',
            onClick: () => notifier.refresh(),
            [Component.text('Retry')],
          ),
        ]),
      ),
    ]);
  }
}

String _formatDate(DateTime? dt) {
  if (dt == null) return 'Unknown';
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inDays > 7) return '${dt.day}/${dt.month}/${dt.year}';
  if (diff.inDays > 0) return '${diff.inDays}d ago';
  if (diff.inHours > 0) return '${diff.inHours}h ago';
  if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
  return 'Just now';
}

class _RecentUsersTable extends StatelessComponent {
  final List<RecentUser> users;
  final PaginatedData<User>? pagination;
  final ValueChanged<int>? onPageChange;

  const _RecentUsersTable({
    required this.users,
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
              th(classes: 'text-left py-3 px-6 text-xs font-semibold text-dark-muted uppercase tracking-wider', [
                Component.text('User'),
              ]),
              th(classes: 'text-left py-3 px-6 text-xs font-semibold text-dark-muted uppercase tracking-wider', [
                Component.text('Role'),
              ]),
              th(classes: 'text-left py-3 px-6 text-xs font-semibold text-dark-muted uppercase tracking-wider', [
                Component.text('Status'),
              ]),
              th(classes: 'text-right py-3 px-6 text-xs font-semibold text-dark-muted uppercase tracking-wider', [
                Component.text('Joined'),
              ]),
            ]),
          ]),
          tbody([
            if (users.isEmpty)
              tr([
                td(
                  classes: 'py-20 text-center text-dark-muted',
                  attributes: {'colspan': '4'},
                  [
                    Component.text('No users found matching your filters'),
                  ],
                ),
              ])
            else
              for (final user in users)
                tr(
                  classes: 'border-b border-dark-border/50 hover:bg-white/[0.02] transition-colors cursor-pointer',
                  events: {
                    'click': (e) {
                      if (user.id != null) {
                        UserSidePanel.open(context, user.id!);
                      }
                    },
                  },
                  [
                    // User info cell
                    td(classes: 'py-4 px-6', [
                      div(classes: 'flex items-center space-x-3', [
                        div(
                          classes:
                              'w-9 h-9 rounded-full bg-gradient-to-br from-primary/30 to-primary-700/30 border border-primary/20 flex items-center justify-center text-xs font-bold text-primary',
                          [Component.text(user.initials)],
                        ),
                        div([
                          p(classes: 'text-sm font-medium text-white', [Component.text(user.name)]),
                          p(classes: 'text-xs text-dark-muted', [Component.text(user.email)]),
                        ]),
                      ]),
                    ]),
                    // Role cell
                    td(classes: 'py-4 px-6', [
                      span(
                        classes:
                            'text-xs font-medium px-2.5 py-1 rounded-md '
                            '${_roleStyle(user.role)}',
                        [Component.text(user.role)],
                      ),
                    ]),
                    // Status cell
                    td(classes: 'py-4 px-6', [
                      div(classes: 'flex items-center space-x-2', [
                        div(classes: 'w-2 h-2 rounded-full ${_statusDot(user.status)}', []),
                        span(classes: 'text-sm capitalize ${_statusText(user.status)}', [
                          Component.text(user.status),
                        ]),
                      ]),
                    ]),
                    // Joined cell
                    td(classes: 'py-4 px-6 text-right', [
                      span(classes: 'text-sm text-dark-muted', [Component.text(user.joinedAgo)]),
                    ]),
                  ],
                ),
          ]),
        ]),
      ]),

      // Pagination
      if (pagination != null)
        div(classes: 'mt-6 flex items-center justify-between', [
          p(classes: 'text-xs text-dark-muted', [
            Component.text('Showing '),
            span(classes: 'text-white font-medium', [
              Component.text('${(pagination!.page - 1) * pagination!.perPage + 1}'),
            ]),
            Component.text(' to '),
            span(classes: 'text-white font-medium', [
              Component.text('${(pagination!.page - 1) * pagination!.perPage + users.length}'),
            ]),
            Component.text(' of '),
            span(classes: 'text-white font-medium', [Component.text('${pagination!.total}')]),
            Component.text(' users'),
          ]),
          div(classes: 'flex items-center gap-2', [
            button(
              classes:
                  'p-2 rounded-lg bg-dark-border/30 border border-dark-border text-dark-muted hover:text-white disabled:opacity-30 disabled:cursor-not-allowed',
              attributes: pagination!.page <= 1 ? {'disabled': ''} : {},
              onClick: () => onPageChange?.call(pagination!.page - 1),
              [Component.text('←')],
            ),
            div(classes: 'text-sm font-medium text-white px-3', [
              Component.text('Page ${pagination!.page} of ${pagination!.totalPages}'),
            ]),
            button(
              classes:
                  'p-2 rounded-lg bg-dark-border/30 border border-dark-border text-dark-muted hover:text-white disabled:opacity-30 disabled:cursor-not-allowed',
              attributes: pagination!.page >= pagination!.totalPages ? {'disabled': ''} : {},
              onClick: () => onPageChange?.call(pagination!.page + 1),
              [Component.text('→')],
            ),
          ]),
        ]),
    ]);
  }

  static String _roleStyle(String role) {
    return switch (role) {
      'Admin' => 'bg-purple-500/10 text-purple-400 border border-purple-500/20',
      'Instructor' => 'bg-blue-500/10 text-blue-400 border border-blue-500/20',
      _ => 'bg-dark-border/50 text-dark-muted',
    };
  }

  static String _statusDot(String status) {
    return switch (status) {
      'active' => 'bg-emerald-400',
      'pending' => 'bg-amber-400 animate-pulse',
      _ => 'bg-dark-muted',
    };
  }

  static String _statusText(String status) {
    return switch (status) {
      'active' => 'text-emerald-400',
      'pending' => 'text-amber-400',
      _ => 'text-dark-muted',
    };
  }
}

// ══════════════════════════════════════════════════════════════════
//  ACTIVITY FEED
// ══════════════════════════════════════════════════════════════════

// ══════════════════════════════════════════════════════════════════
//  TOP COURSES (API-driven)
// ══════════════════════════════════════════════════════════════════

class _TopCoursesSection extends StatelessComponent {
  const _TopCoursesSection();

  @override
  Component build(BuildContext context) {
    final coursesAsync = context.watch(adminCourseProvider);

    return div(classes: 'card', [
      div(classes: 'flex items-center justify-between mb-6', [
        div(classes: 'space-y-1', [
          h3(classes: 'text-lg font-bold text-white', [Component.text('Top Performing Courses')]),
          p(classes: 'text-sm text-dark-muted', [Component.text('Ranked by enrollment count')]),
        ]),
        Link(
          to: '/courses',
          classes: 'text-sm text-primary font-medium hover:underline underline-offset-4 transition-all',
          child: span([Component.text('Manage Courses →')]),
        ),
      ]),

      coursesAsync.when(
        data: (data) {
          final courses = data?.items ?? [];
          if (courses.isEmpty) {
            return div(classes: 'py-12 text-center', [
              span(classes: 'text-3xl block mb-2', [Component.text('📚')]),
              p(classes: 'text-dark-muted text-sm', [Component.text('No courses available yet.')]),
            ]);
          }
          // Take top 5 courses by enrollment for the dashboard widget
          final topCourses = List<Course>.from(courses)
            ..sort((a, b) => (b.totalEnrollees ?? 0).compareTo(a.totalEnrollees ?? 0));
          final displayCourses = topCourses.take(5).toList();

          return div(classes: 'space-y-3', [
            for (var i = 0; i < displayCourses.length; i++) _CourseRow(course: displayCourses[i], rank: i + 1),
          ]);
        },
        loading: () => div(classes: 'space-y-3', [
          for (var i = 0; i < 5; i++)
            div(classes: 'flex items-center space-x-4 p-3 rounded-xl animate-pulse', [
              div(classes: 'w-8 h-8 rounded-lg bg-dark-border/30 shrink-0', []),
              div(classes: 'flex-1 space-y-2', [
                div(classes: 'w-3/4 h-4 bg-dark-border/30 rounded', []),
                div(classes: 'w-1/2 h-3 bg-dark-border/30 rounded', []),
              ]),
              div(classes: 'w-16 h-8 bg-dark-border/30 rounded shrink-0', []),
            ]),
        ]),
        error: (e, st) => div(classes: 'py-8 text-center', [
          span(classes: 'text-2xl block mb-2', [Component.text('⚠️')]),
          p(classes: 'text-red-400 text-sm', [Component.text(e.toFriendlyMessage())]),
        ]),
      ),
    ]);
  }
}

class _CourseRow extends StatelessComponent {
  final Course course;
  final int rank;

  const _CourseRow({required this.course, required this.rank});

  @override
  Component build(BuildContext context) {
    final enrollees = course.totalEnrollees ?? 0;
    final rating = course.reviewSummary?.averageRating ?? 0.0;

    return div(
      classes: 'flex items-center space-x-4 p-3 rounded-xl hover:bg-white/[0.02] transition-colors -mx-3 group',
      [
        // Rank
        div(
          classes:
              'w-8 h-8 rounded-lg flex items-center justify-center text-xs font-bold shrink-0 '
              '${rank <= 3 ? "bg-primary/10 text-primary border border-primary/20" : "bg-dark-border/50 text-dark-muted"}',
          [Component.text('#$rank')],
        ),

        // Course info
        div(classes: 'flex-1 min-w-0', [
          p(classes: 'text-sm font-semibold text-white truncate', [
            Component.text(course.title ?? 'Untitled'),
          ]),
          div(classes: 'flex items-center space-x-3 mt-1', [
            span(classes: 'text-xs px-2 py-0.5 rounded-md bg-dark-border/50 text-dark-muted', [
              Component.text(course.category?.name ?? 'Uncategorized'),
            ]),
            if (course.level != null)
              span(classes: 'text-xs text-dark-muted capitalize', [
                Component.text(course.level!),
              ]),
            span(classes: 'text-xs text-dark-muted', [
              Component.text('⭐ ${rating.toStringAsFixed(1)}'),
            ]),
          ]),
        ]),

        // Enrollment count
        div(classes: 'text-right shrink-0 hidden sm:block', [
          p(classes: 'text-sm font-bold text-white', [
            Component.text(enrollees >= 1000 ? '${(enrollees / 1000).toStringAsFixed(1)}K' : enrollees.toString()),
          ]),
          p(classes: 'text-xs text-dark-muted', [Component.text('enrolled')]),
        ]),

        // Reviews count
        div(classes: 'w-24 shrink-0 hidden md:block text-right', [
          p(classes: 'text-xs font-bold text-white', [
            Component.text('${course.reviewSummary?.totalReviews ?? 0}'),
          ]),
          p(classes: 'text-[10px] text-dark-muted', [Component.text('reviews')]),
        ]),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  SYSTEM OVERVIEW
// ══════════════════════════════════════════════════════════════════

class _SystemOverview extends StatelessComponent {
  final double uptime;
  final int activeNow;

  const _SystemOverview({required this.uptime, required this.activeNow});

  @override
  Component build(BuildContext context) {
    return div(classes: 'card space-y-5', [
      h3(classes: 'text-lg font-bold text-white', [Component.text('System Status')]),

      // Uptime
      div(classes: 'p-4 rounded-xl bg-emerald-500/5 border border-emerald-500/10', [
        div(classes: 'flex items-center justify-between mb-3', [
          span(classes: 'text-sm font-medium text-emerald-400', [Component.text('Server Uptime')]),
          div(classes: 'flex items-center space-x-1.5', [
            div(classes: 'w-2 h-2 bg-emerald-400 rounded-full', []),
            span(classes: 'text-xs font-bold text-emerald-400', [Component.text('Operational')]),
          ]),
        ]),
        span(classes: 'text-3xl font-bold text-white', [Component.text('$uptime%')]),
        div(classes: 'w-full h-1.5 bg-dark-border rounded-full overflow-hidden mt-3', [
          div(
            classes: 'h-full bg-emerald-400 rounded-full',
            styles: Styles(raw: {'width': '$uptime%'}),
            [],
          ),
        ]),
      ]),

      // Quick metrics
      div(classes: 'grid grid-cols-2 gap-3', [
        _MiniStat(label: 'API Calls', value: '2.4M', icon: '⚡'),
        _MiniStat(label: 'Avg Response', value: '45ms', icon: '🔄'),
        _MiniStat(label: 'Error Rate', value: '0.03%', icon: '🛡️'),
        _MiniStat(label: 'Storage', value: '68%', icon: '💾'),
      ]),

      // Quick actions
      div(classes: 'space-y-2 pt-2', [
        p(classes: 'text-xs font-semibold text-dark-muted uppercase tracking-wider', [Component.text('Quick Actions')]),
        _QuickAction(icon: '📧', label: 'Send Newsletter', subtitle: '15K subscribers'),
        _QuickAction(icon: '🔄', label: 'Sync Database', subtitle: 'Last: 2h ago'),
        _QuickAction(icon: '📋', label: 'Export Reports', subtitle: 'CSV & PDF'),
      ]),
    ]);
  }
}

class _MiniStat extends StatelessComponent {
  final String label;
  final String value;
  final String icon;

  const _MiniStat({required this.label, required this.value, required this.icon});

  @override
  Component build(BuildContext context) {
    return div(classes: 'p-3 rounded-xl bg-white/[0.02] border border-dark-border/50 text-center', [
      span(classes: 'text-sm', [Component.text(icon)]),
      p(classes: 'text-lg font-bold text-white mt-1', [Component.text(value)]),
      p(classes: 'text-xs text-dark-muted', [Component.text(label)]),
    ]);
  }
}

class _QuickAction extends StatelessComponent {
  final String icon;
  final String label;
  final String subtitle;

  const _QuickAction({required this.icon, required this.label, required this.subtitle});

  @override
  Component build(BuildContext context) {
    return button(
      classes:
          'w-full flex items-center space-x-3 p-3 rounded-xl hover:bg-white/[0.03] border border-transparent hover:border-dark-border transition-all text-left group',
      [
        div(
          classes:
              'w-9 h-9 rounded-lg bg-dark-border/50 flex items-center justify-center text-sm group-hover:bg-primary/10 transition-colors',
          [
            Component.text(icon),
          ],
        ),
        div(classes: 'flex-1', [
          p(classes: 'text-sm font-medium text-white', [Component.text(label)]),
          p(classes: 'text-xs text-dark-muted', [Component.text(subtitle)]),
        ]),
        span(classes: 'text-dark-muted group-hover:text-primary transition-colors', [Component.text('→')]),
      ],
    );
  }
}
