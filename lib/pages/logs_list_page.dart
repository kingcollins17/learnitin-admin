import 'dart:async';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:learnitin_admin/components/json_viewer.dart';
import 'package:learnitin_admin/core/utils/browser_utils.dart';
import 'package:learnitin_admin/core/utils/context_extensions.dart';
import 'package:learnitin_admin/core/utils/error_sanitizer.dart';
import 'package:learnitin_admin/models/log_entry.dart';
import 'package:learnitin_admin/providers/auth_provider.dart';
import 'package:learnitin_admin/providers/logs_provider.dart';

class LogsListPage extends StatefulComponent {
  const LogsListPage({super.key});

  @override
  State<LogsListPage> createState() => _LogsListPageState();
}

class _LogsListPageState extends State<LogsListPage> {
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

    if (authState is AsyncData && authState.value == null) {
      Future.microtask(() => Router.of(context).replace('/login'));
      return div([]);
    }

    if (authState.isLoading) {
      return div(classes: 'flex items-center justify-center min-h-[60vh]', [
        div(classes: 'w-12 h-12 border-4 border-primary border-t-transparent rounded-full animate-spin', []),
      ]);
    }

    final logsAsync = context.watch(logsProvider);
    final logsNotifier = context.read(logsProvider.notifier);

    return div(classes: 'flex-1 space-y-8 pb-12 min-h-screen text-white', [
      // ── Page Header ──────────────────────────────────────────────
      div(classes: 'flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-white/5 pb-6', [
        div(classes: 'space-y-1', [
          h1(classes: 'text-3xl font-bold tracking-tight text-white flex items-center space-x-3', [
            span(classes: 'text-2xl', [Component.text('📋')]),
            span([Component.text('System Logs')]),
          ]),
          p(classes: 'text-dark-muted text-sm', [
            Component.text('Monitor, inspect, and manage real-time application and server logs.'),
          ]),
        ]),
        div(classes: 'flex items-center gap-3', [
          button(
            classes:
                'px-4 py-2 bg-dark-border/30 border border-dark-border rounded-xl text-sm font-medium hover:text-white transition-all flex items-center space-x-2',
            onClick: () => logsNotifier.refresh(),
            [
              span([Component.text('🔄')]),
              span([Component.text('Refresh Logs')]),
            ],
          ),
          button(
            classes:
                'px-4 py-2 bg-red-500/10 border border-red-500/20 text-red-400 hover:bg-red-500/20 hover:text-red-300 rounded-xl text-sm font-semibold transition-all flex items-center space-x-2',
            onClick: () => _handleClearAll(context, logsNotifier),
            [
              span([Component.text('🗑️')]),
              span([Component.text('Clear All Logs')]),
            ],
          ),
        ]),
      ]),

      // ── Filters & Controls ───────────────────────────────────────
      div(classes: 'card p-4 flex flex-col sm:flex-row sm:items-center justify-between gap-4', [
        div(classes: 'flex items-center space-x-3', [
          span(classes: 'text-xs font-semibold uppercase tracking-wider text-dark-muted', [
            Component.text('Filter by Level:'),
          ]),
          select(
            classes:
                'bg-dark-border/30 border border-dark-border rounded-xl px-4 py-2 text-sm text-white focus:outline-none focus:border-primary/50 transition-all cursor-pointer min-w-[140px]',
            onChange: (values) {
              final val = values.firstOrNull ?? '';
              logsNotifier.setLevel(val.isEmpty ? null : val);
            },
            [
              option(value: '', [Component.text('All Levels')]),
              option(value: 'info', [Component.text('Info')]),
              option(value: 'error', [Component.text('Error')]),
            ],
          ),
        ]),

        logsAsync.when(
          data: (logs) => p(classes: 'text-xs text-dark-muted', [
            Component.text('Currently displaying '),
            span(classes: 'text-white font-bold', [Component.text('${logs.length}')]),
            Component.text(' log entries'),
          ]),
          loading: () => div([]),
          error: (e, st) => div([]),
        ),
      ]),

      // ── Log List / Feed ──────────────────────────────────────────
      logsAsync.when(
        data: (logs) {
          if (logs.isEmpty) {
            return div(
              classes: 'card py-24 flex flex-col items-center justify-center text-center space-y-4 border border-dashed border-white/10 bg-transparent',
              [
                span(classes: 'text-5xl block animate-bounce', [Component.text('✨')]),
                h3(classes: 'text-lg font-bold text-white', [Component.text('All Quiet!')]),
                p(classes: 'text-dark-muted max-w-sm text-sm', [
                  Component.text('No system logs found matching your filters. Your application is running flawlessly.'),
                ]),
              ],
            );
          }

          return div(classes: 'space-y-4', [
            // Feed list
            div(classes: 'space-y-3', [
              for (final log in logs)
                _LogItemCard(
                  key: ValueKey(log.id),
                  log: log,
                  onDelete: () => _handleDeleteLog(context, logsNotifier, log.id),
                ),
            ]),

            // Pagination load more
            if (logsNotifier.hasMore)
              div(classes: 'flex justify-center pt-6', [
                button(
                  classes:
                      'px-8 py-3 bg-white/5 border border-white/10 rounded-xl text-sm font-semibold hover:bg-white/10 hover:border-white/20 hover:shadow-lg transition-all flex items-center space-x-2',
                  onClick: () => logsNotifier.loadMore(),
                  [
                    span([Component.text('📥')]),
                    span([Component.text('Load More Logs')]),
                  ],
                ),
              ])
            else if (logs.isNotEmpty)
              p(classes: 'text-center text-xs text-dark-muted pt-8', [
                Component.text('No more logs to load.'),
              ]),
          ]);
        },
        loading: () => div(classes: 'space-y-3', [
          for (var i = 0; i < 5; i++) const _LogShimmerCard(),
        ]),
        error: (e, st) => div(classes: 'p-12 text-center bg-red-500/5 rounded-2xl border border-red-500/10 max-w-lg mx-auto', [
          span(classes: 'text-4xl mb-4 block', [Component.text('⚠️')]),
          h4(classes: 'text-lg font-bold text-red-400 mb-2', [Component.text('Failed to Load Logs')]),
          p(classes: 'text-dark-muted mb-6 text-sm', [Component.text(e.toFriendlyMessage())]),
          button(
            classes:
                'px-6 py-2.5 bg-red-500/20 text-red-400 border border-red-500/30 rounded-xl hover:bg-red-500/30 transition-all font-semibold',
            onClick: () => logsNotifier.refresh(),
            [Component.text('Retry Fetch')],
          ),
        ]),
      ),
    ]);
  }

  void _handleDeleteLog(BuildContext context, LogsNotifier notifier, int? logId) {
    if (logId == null) return;
    if (appConfirm('Are you sure you want to delete this log entry (#$logId)? This action cannot be undone.')) {
      context.showLoading();
      notifier.deleteLog(
        logId,
        onSuccess: () {
          context.hideLoading();
          context.showSuccess('Log entry #$logId has been deleted.');
        },
        onError: (message, [st]) {
          context.hideLoading();
          context.showError(message);
        },
      );
    }
  }

  void _handleClearAll(BuildContext context, LogsNotifier notifier) {
    if (appConfirm('💥 WARNING: Are you absolutely sure you want to delete ALL system logs? This action is permanent and irreversible.')) {
      context.showLoading();
      notifier.clearAllLogs(
        onSuccess: () {
          context.hideLoading();
          context.showSuccess('All system logs have been successfully cleared.');
        },
        onError: (message, [st]) {
          context.hideLoading();
          context.showError(message);
        },
      );
    }
  }
}

class _LogItemCard extends StatefulComponent {
  final LogEntry log;
  final VoidCallback onDelete;

  const _LogItemCard({
    required this.log,
    required this.onDelete,
    super.key,
  });

  @override
  State<_LogItemCard> createState() => _LogItemCardState();
}

class _LogItemCardState extends State<_LogItemCard> {
  bool _isExpanded = false;

  @override
  Component build(BuildContext context) {
    final isError = component.log.level?.toLowerCase() == 'error';

    final badgeClass = isError
        ? 'bg-red-500/10 text-red-400 border border-red-500/20'
        : 'bg-sky-500/10 text-sky-400 border border-sky-500/20';

    return div(
      classes: 'card p-4 hover:border-white/10 transition-all duration-200 overflow-hidden',
      [
        // Header row
        div(classes: 'flex items-center justify-between gap-4 cursor-pointer select-none', events: {
          'click': (e) => setState(() => _isExpanded = !_isExpanded),
        }, [
          div(classes: 'flex flex-1 items-start sm:items-center gap-3 min-w-0 flex-col sm:flex-row', [
            // Collapse Indicator + ID / Badge
            div(classes: 'flex items-center space-x-2 shrink-0', [
              span(
                classes: 'text-dark-muted text-[10px] w-3 flex items-center justify-center transition-transform duration-200 ${_isExpanded ? "rotate-90" : ""}',
                [Component.text('▶')],
              ),
              span(classes: 'text-xs font-semibold px-2 py-0.5 rounded-md uppercase tracking-wider $badgeClass', [
                Component.text(component.log.level ?? 'UNKNOWN'),
              ]),
              span(classes: 'text-xs font-mono text-dark-muted/80', [
                Component.text('#${component.log.id ?? "N/A"}'),
              ]),
            ]),

            // Log Message
            p(
              classes: 'text-sm font-medium text-white truncate w-full sm:max-w-xl group-hover:text-primary transition-colors',
              [Component.text(component.log.message ?? 'No log message provided.')],
            ),
          ]),

          // Date & Actions
          div(classes: 'flex items-center space-x-4 shrink-0', [
            span(classes: 'text-xs text-dark-muted hidden md:inline', [
              Component.text(_formatTimestamp(component.log.createdAt)),
            ]),
            button(
              classes:
                  'p-1.5 rounded-lg hover:bg-red-500/10 text-dark-muted hover:text-red-400 border border-transparent hover:border-red-500/20 transition-all',
              events: {'click': (e) {
                e.stopPropagation(); // Avoid triggering card expand
                component.onDelete();
              }},
              [Component.text('🗑️')],
            ),
          ]),
        ]),

        // Expanded JSON Payload Section
        if (_isExpanded)
          div(classes: 'mt-4 pt-4 border-t border-white/5 space-y-3', [
            div(classes: 'flex items-center justify-between', [
              span(classes: 'text-xs font-semibold uppercase tracking-wider text-dark-muted', [
                Component.text('Event Payload Data'),
              ]),
              span(classes: 'text-xs text-dark-muted md:hidden', [
                Component.text(_formatTimestamp(component.log.createdAt)),
              ]),
            ]),
            div(classes: 'bg-dark-bg/60 border border-white/[0.03] rounded-xl p-4 overflow-x-auto max-h-96', [
              JsonViewer(data: component.log.data ?? {}),
            ]),
          ]),
      ],
    );
  }

  String _formatTimestamp(DateTime? dt) {
    if (dt == null) return 'Unknown';
    // Format: YYYY-MM-DD HH:MM:SS
    final year = dt.year;
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute:$second';
  }
}

class _LogShimmerCard extends StatelessComponent {
  const _LogShimmerCard();

  @override
  Component build(BuildContext context) {
    return div(classes: 'card p-4 animate-pulse flex items-center justify-between', [
      div(classes: 'flex items-center space-x-3 w-2/3', [
        div(classes: 'w-3 h-3 bg-dark-border/30 rounded-full', []),
        div(classes: 'w-16 h-5 bg-dark-border/30 rounded-md', []),
        div(classes: 'w-8 h-4 bg-dark-border/30 rounded-md', []),
        div(classes: 'w-1/2 h-4 bg-dark-border/30 rounded-md', []),
      ]),
      div(classes: 'w-32 h-4 bg-dark-border/30 rounded-md', []),
    ]);
  }
}
