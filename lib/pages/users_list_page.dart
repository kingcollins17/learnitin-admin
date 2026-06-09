import 'package:learnitin_admin/core/utils/browser_utils.dart';
import 'dart:async';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../providers/admin_user_provider.dart';
import '../models/paginated_response.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/api_provider.dart';
import '../core/utils/error_sanitizer.dart';
import '../components/user_side_panel.dart';

class UsersListPage extends StatefulComponent {
  const UsersListPage({super.key});

  @override
  State<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
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
    final notificationState = context.watch(appNotificationProvider);

    if (authState is AsyncData && authState.value == null) {
      Future.microtask(() => Router.of(context).replace('/login'));
      return div([]);
    }

    if (authState.isLoading) {
      return div(classes: 'flex items-center justify-center min-h-[60vh]', [
        div(classes: 'w-12 h-12 border-4 border-primary border-t-transparent rounded-full animate-spin', []),
      ]);
    }

    return div(classes: 'flex gap-6 items-start pb-8 min-h-screen', [
      div(classes: 'flex-1 space-y-8 min-w-0', [
        // ── Page Header ──────────────────────────────────────────────
        div(classes: 'flex flex-col md:flex-row md:items-center justify-between gap-4', [
          div(classes: 'space-y-1', [
            h1(classes: 'text-3xl font-bold text-white tracking-tight', [
              Component.text('User Management'),
            ]),
            p(classes: 'text-dark-muted', [
              Component.text('Oversee all platform users, manage roles, and subscriptions.'),
            ]),
          ]),
          div(classes: 'flex items-center gap-3', [
            if (notificationState.selectedUserIds.isNotEmpty)
              button(
                classes:
                    'px-4 py-2 bg-primary/20 border border-primary/30 rounded-xl text-sm font-bold text-primary hover:bg-primary/30 transition-all flash-primary',
                onClick: () => _showBulkNotifyPrompt(context, notificationState.selectedUserIds),
                [Component.text('Notify Selected (${notificationState.selectedUserIds.length}) 🔔')],
              ),
            button(
              classes:
                  'px-4 py-2 bg-dark-border/30 border border-dark-border rounded-xl text-sm font-medium hover:text-white transition-all',
              onClick: () => _showBroadcastPrompt(context),
              [Component.text('Broadcast 📢')],
            ),
            button(
              classes:
                  'px-4 py-2 bg-dark-border/30 border border-dark-border rounded-xl text-sm font-medium hover:text-white transition-all',
              [Component.text('Export 📥')],
            ),
            button(
              classes:
                  'btn-primary flex items-center space-x-2 px-6 py-2.5 rounded-xl shadow-lg shadow-primary/20 hover:shadow-primary/40 transition-all',
              [
                span([Component.text('➕')]),
                span([Component.text('Create User')]),
              ],
            ),
          ]),
        ]),

        // ── Users Table ─────────────────────────────────────────────
        _UsersSection(
          onUserTap: (userId) {
            UserSidePanel.open(context, userId);
          },
        ),
      ]),
    ]);
  }
}

class _UsersSection extends StatefulComponent {
  final ValueChanged<int>? onUserTap;
  const _UsersSection({this.onUserTap});

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
              // placeholder: 'Search by name or email...',
              value: params.search ?? '',
              onInput: (value) => _onSearchChanged(value, notifier),
            ),
          ]),

          // Status Select
          select(
            classes:
                'bg-dark-border/30 border border-dark-border rounded-xl px-4 py-2.5 text-sm text-white focus:outline-none focus:border-primary/50 transition-all cursor-pointer min-w-[140px]',
            onChange: (values) {
              final val = values.firstOrNull ?? '';
              notifier.setIsActive(val == '' ? null : val == 'true');
            },
            [
              option(value: '', [Component.text('All Status')]),
              option(value: 'true', [Component.text('Active')]),
              option(value: 'false', [Component.text('Inactive')]),
            ],
          ),

          // Role Select
          select(
            classes:
                'bg-dark-border/30 border border-dark-border rounded-xl px-4 py-2.5 text-sm text-white focus:outline-none focus:border-primary/50 transition-all cursor-pointer min-w-[140px]',
            onChange: (values) {
              final val = values.firstOrNull ?? '';
              notifier.setIsSuperuser(val == '' ? null : val == 'true');
            },
            [
              option(value: '', [Component.text('All Roles')]),
              option(value: 'true', [Component.text('Admins')]),
              option(value: 'false', [Component.text('Learners')]),
            ],
          ),

          // Refresh Button
          button(
            classes:
                'p-2.5 rounded-xl bg-dark-border/30 border border-dark-border text-dark-muted hover:text-white hover:bg-dark-border/50 transition-all',
            onClick: () => notifier.refresh(),
            [Component.text('🔄')],
          ),
        ]),
      ]),

      // Table Content
      usersAsync.when(
        data: (data) => _UsersTable(
          users: data?.items ?? [],
          pagination: data,
          onPageChange: (page) => notifier.setPage(page),
          onUserTap: component.onUserTap,
        ),
        loading: () => div(classes: 'flex flex-col items-center justify-center py-24 space-y-4', [
          div(classes: 'w-12 h-12 border-4 border-primary border-t-transparent rounded-full animate-spin', []),
          p(classes: 'text-dark-muted animate-pulse', [Component.text('Loading user data...')]),
        ]),
        error: (e, st) => div(classes: 'p-12 text-center bg-red-500/5 rounded-2xl border border-red-500/10', [
          span(classes: 'text-4xl mb-4 block', [Component.text('⚠️')]),
          h4(classes: 'text-lg font-bold text-red-400 mb-2', [Component.text('Failed to Load Users')]),
          p(classes: 'text-dark-muted mb-6 max-w-md mx-auto', [Component.text(e.toFriendlyMessage())]),
          button(
            classes:
                'px-6 py-2 bg-red-500/20 text-red-400 border border-red-500/30 rounded-xl hover:bg-red-500/30 transition-all',
            onClick: () => notifier.refresh(),
            [Component.text('Retry Request')],
          ),
        ]),
      ),
    ]);
  }
}

class _UsersTable extends StatelessComponent {
  final List<User> users;
  final PaginatedData<User>? pagination;
  final ValueChanged<int>? onPageChange;
  final ValueChanged<int>? onUserTap;

  const _UsersTable({
    required this.users,
    this.pagination,
    this.onPageChange,
    this.onUserTap,
  });

  @override
  Component build(BuildContext context) {
    return div([
      div(classes: 'overflow-x-auto -mx-6', [
        table(classes: 'w-full', [
          thead([
            tr(classes: 'border-b border-dark-border', [
              th(classes: 'py-4 px-6 text-left', [
                // Global checkbox or similar could go here
              ]),
              th(classes: 'text-left py-4 px-6 text-xs font-bold text-dark-muted uppercase tracking-widest', [
                Component.text('User'),
              ]),
              th(classes: 'text-left py-4 px-6 text-xs font-bold text-dark-muted uppercase tracking-widest', [
                Component.text('Role'),
              ]),
              th(classes: 'text-left py-4 px-6 text-xs font-bold text-dark-muted uppercase tracking-widest', [
                Component.text('Status'),
              ]),
              th(classes: 'text-left py-4 px-6 text-xs font-bold text-dark-muted uppercase tracking-widest', [
                Component.text('Created'),
              ]),
              th(classes: 'text-right py-4 px-6 text-xs font-bold text-dark-muted uppercase tracking-widest', [
                Component.text('Actions'),
              ]),
            ]),
          ]),
          tbody([
            if (users.isEmpty)
              tr([
                td(
                  classes: 'py-24 text-center text-dark-muted',
                  attributes: {'colspan': '5'},
                  [
                    div(classes: 'space-y-2', [
                      span(classes: 'text-3xl block', [Component.text('👥')]),
                      p([Component.text('No users found matching your filters.')]),
                    ]),
                  ],
                ),
              ])
            else
              for (final user in users)
                tr(
                  classes:
                      'border-b border-dark-border/40 hover:bg-white/[0.03] transition-all group cursor-pointer '
                      '${context.watch(appNotificationProvider).selectedUserIds.contains(user.id) ? "bg-primary/5" : ""}',
                  events: {
                    'click': (e) {
                      onUserTap?.call(user.id!);
                    },
                  },
                  [
                    // Checkbox cell
                    td(
                      classes: 'py-4 px-6',
                      events: {'click': (e) => e.stopPropagation()},
                      [
                        input(
                          type: InputType.checkbox,
                          classes:
                              'w-4 h-4 rounded border-dark-border bg-dark-bg text-primary focus:ring-primary/50 cursor-pointer',
                          checked: context.watch(appNotificationProvider).isUserSelected(user.id!),
                          onChange: (value) {
                            context.read(appNotificationProvider.notifier).toggleUserSelection(user.id!);
                          },
                        ),
                      ],
                    ),
                    // User info cell
                    td(classes: 'py-4 px-6', [
                      div(classes: 'flex items-center space-x-3', [
                        div(
                          classes:
                              'w-10 h-10 rounded-full bg-gradient-to-br from-primary/30 to-primary-700/30 border border-primary/20 flex items-center justify-center text-xs font-bold text-primary group-hover:scale-105 transition-transform',
                          [Component.text(_getInitials(user))],
                        ),
                        div([
                          p(classes: 'text-sm font-bold text-white', [
                            Component.text(user.fullName ?? user.username ?? 'Unknown'),
                          ]),
                          p(classes: 'text-xs text-dark-muted', [Component.text(user.email ?? '')]),
                        ]),
                      ]),
                    ]),
                    // Role cell
                    td(classes: 'py-4 px-6', [
                      span(
                        classes:
                            'text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded-md '
                            '${user.isSuperuser == true ? "bg-purple-500/10 text-purple-400 border border-purple-500/20" : "bg-blue-500/10 text-blue-400 border border-blue-500/20"}',
                        [Component.text(user.isSuperuser == true ? 'Admin' : 'Learner')],
                      ),
                    ]),
                    // Status cell
                    td(classes: 'py-4 px-6', [
                      div(classes: 'flex items-center space-x-2', [
                        div(
                          classes: 'w-2 h-2 rounded-full ${user.isActive == true ? "bg-emerald-400" : "bg-dark-muted"}',
                          [],
                        ),
                        span(
                          classes:
                              'text-sm font-medium ${user.isActive == true ? "text-emerald-400" : "text-dark-muted"}',
                          [
                            Component.text(user.isActive == true ? 'Active' : 'Inactive'),
                          ],
                        ),
                      ]),
                    ]),
                    // Created cell
                    td(classes: 'py-4 px-6', [
                      span(classes: 'text-sm text-dark-muted', [
                        Component.text(_formatDate(user.createdAt)),
                      ]),
                    ]),
                    // Actions Cell
                    td(
                      classes: 'py-4 px-6 text-right',
                      events: {'click': (e) => e.stopPropagation()},
                      [
                        _UserActionMenu(user: user),
                      ],
                    ),
                  ],
                ),
          ]),
        ]),
      ]),

      // Pagination
      if (pagination != null)
        div(classes: 'mt-8 flex flex-col sm:flex-row items-center justify-between gap-4 border-t border-dark-border pt-6', [
          p(classes: 'text-xs text-dark-muted', [
            Component.text('Showing '),
            span(classes: 'text-white font-bold', [
              Component.text(
                '${(pagination!.page - 1) * pagination!.perPage + 1} - ${((pagination!.page - 1) * pagination!.perPage + users.length)}',
              ),
            ]),
            Component.text(' of '),
            span(classes: 'text-white font-bold', [Component.text('${pagination!.total}')]),
          ]),

          div(classes: 'flex items-center space-x-1.5', [
            button(
              classes:
                  'flex items-center justify-center w-10 h-10 rounded-xl bg-dark-border/30 border border-dark-border text-dark-muted hover:text-white hover:bg-dark-border/50 disabled:opacity-20 disabled:cursor-not-allowed transition-all',
              attributes: pagination!.page <= 1 ? {'disabled': ''} : {},
              onClick: () => onPageChange?.call(pagination!.page - 1),
              [Component.text('←')],
            ),

            div(classes: 'text-sm font-bold text-white px-2', [
              Component.text('Page ${pagination!.page} / ${pagination!.totalPages}'),
            ]),

            button(
              classes:
                  'flex items-center justify-center w-10 h-10 rounded-xl bg-dark-border/30 border border-dark-border text-dark-muted hover:text-white hover:bg-dark-border/50 disabled:opacity-20 disabled:cursor-not-allowed transition-all',
              attributes: pagination!.page >= pagination!.totalPages ? {'disabled': ''} : {},
              onClick: () => onPageChange?.call(pagination!.page + 1),
              [Component.text('→')],
            ),
          ]),
        ]),
    ]);
  }

  String _getInitials(User user) {
    if (user.fullName != null && user.fullName!.isNotEmpty) {
      final parts = user.fullName!.split(' ');
      if (parts.length > 1) return (parts[0][0] + parts[1][0]).toUpperCase();
      return parts[0][0].toUpperCase();
    }
    return (user.username ?? 'U')[0].toUpperCase();
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Unknown';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _UserActionMenu extends StatefulComponent {
  final User user;
  const _UserActionMenu({required this.user});

  @override
  State<_UserActionMenu> createState() => _UserActionMenuState();
}

class _UserActionMenuState extends State<_UserActionMenu> {
  bool _isOpen = false;

  @override
  Component build(BuildContext context) {
    final notificationState = context.watch(appNotificationProvider);

    return div(classes: 'relative inline-block', [
      button(
        classes:
            'p-2 rounded-lg bg-white/5 border border-white/5 text-dark-muted hover:text-white hover:bg-white/10 hover:border-white/20 transition-all',
        onClick: () => setState(() => _isOpen = !_isOpen),
        [Component.text('⋮')],
      ),
      if (_isOpen)
        div(
          classes:
              'absolute right-0 mt-2 w-48 rounded-xl bg-dark-card border border-dark-border shadow-2xl z-50 overflow-hidden',
          [
            div(classes: 'flex flex-col', [
              _ActionItem(
                label: notificationState.selectedUserIds.contains(component.user.id)
                    ? 'Deselect User 👤'
                    : 'Select User 👤',
                onClick: () => _handleAction(context, 'select'),
              ),
              _ActionItem(label: 'Notify User 🔔', onClick: () => _handleAction(context, 'notify')),
              div(classes: 'h-px bg-dark-border my-1', []),
              _ActionItem(
                label: 'Grant Premium ⭐',
                onClick: () => _handleAction(context, 'grant'),
                color: 'text-emerald-400',
              ),
              _ActionItem(
                label: 'Revoke Premium 🚫',
                onClick: () => _handleAction(context, 'revoke'),
                color: 'text-red-400',
              ),
            ]),
          ],
        ),
    ]);
  }

  void _handleAction(BuildContext context, String action) async {
    setState(() => _isOpen = false);
    final userId = component.user.id;
    if (userId == null) return;

    final api = context.read(apiServiceProvider);
    final notificationNotifier = context.read(appNotificationProvider.notifier);

    try {
      switch (action) {
        case 'notify':
          final msg = appPrompt(
            'Enter notification message for ${component.user.fullName ?? component.user.username}:',
          );
          if (msg != null && msg.isNotEmpty) {
            await notificationNotifier.sendToUser(
              userId: userId,
              title: 'Admin Message',
              message: msg,
            );
            appAlert('Notification sent!');
          }
          break;
        case 'grant':
          await api.grantPremium(userId: userId, body: {'duration_days': 30, 'product_id': 'premium_monthly'});
          appAlert('Premium granted for 30 days!');
          break;
        case 'revoke':
          await api.revokePremium(userId: userId);
          appAlert('Premium revoked!');
          break;
        case 'select':
          notificationNotifier.toggleUserSelection(userId);
          break;
      }
    } catch (e) {
      appAlert('Error: ${e.toFriendlyMessage()}');
    }
  }
}

void _showBulkNotifyPrompt(BuildContext context, List<int> userIds) async {
  final msg = appPrompt('Enter notification message for the ${userIds.length} selected users:');
  if (msg != null && msg.isNotEmpty) {
    try {
      await context
          .read(appNotificationProvider.notifier)
          .sendToUsersBulk(
            userIds: userIds,
            title: 'Learnitin',
            message: msg,
          );
      context.read(appNotificationProvider.notifier).clearSelection();
      appAlert('Notifications sent to selected users!');
    } catch (e) {
      appAlert('Error: ${e.toFriendlyMessage()}');
    }
  }
}

void _showBroadcastPrompt(BuildContext context) async {
  final msg = appPrompt('Enter broadcast message for ALL users:');
  if (msg != null && msg.isNotEmpty) {
    try {
      await context
          .read(appNotificationProvider.notifier)
          .broadcast(
            title: 'Learnitin',
            message: msg,
          );
      appAlert('Broadcast sent to all users!');
    } catch (e) {
      appAlert('Error: ${e.toFriendlyMessage()}');
    }
  }
}

class _ActionItem extends StatelessComponent {
  final String label;
  final VoidCallback onClick;
  final String? color;

  const _ActionItem({required this.label, required this.onClick, this.color});

  @override
  Component build(BuildContext context) {
    return button(
      classes:
          'w-full text-left px-4 py-2.5 text-xs font-medium hover:bg-white/5 transition-all ${color ?? "text-white"}',
      onClick: onClick,
      [Component.text(label)],
    );
  }
}
