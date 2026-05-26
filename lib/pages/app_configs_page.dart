import 'dart:async';
import 'dart:convert';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:learnitin_admin/components/key_value_pair_editor.dart';
import 'package:learnitin_admin/components/json_viewer.dart';
import 'package:learnitin_admin/core/core.dart';
import 'package:learnitin_admin/core/utils/browser_utils.dart';
import 'package:learnitin_admin/models/app_config.dart';
import 'package:learnitin_admin/providers/auth_provider.dart';
import 'package:learnitin_admin/providers/app_config_provider.dart';

/// A dashboard page to list, create, update, and delete app configuration keys.
class AppConfigsPage extends StatefulComponent {
  const AppConfigsPage({super.key});

  @override
  State<AppConfigsPage> createState() => _AppConfigsPageState();
}

class _AppConfigsPageState extends State<AppConfigsPage> {
  // UI States
  bool _showForm = false;
  AppConfig? _editingConfig;

  // Form Fields
  String _configKey = '';
  String _configValue = '';
  Map<String, dynamic> _configMetadata = {};

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

  void _openCreateForm() {
    setState(() {
      _showForm = true;
      _editingConfig = null;
      _configKey = '';
      _configValue = '';
      _configMetadata = {};
    });
  }

  void _openEditForm(AppConfig config) {
    setState(() {
      _showForm = true;
      _editingConfig = config;
      _configKey = config.key ?? '';
      _configValue = config.value ?? '';
      _configMetadata = (config.metadata is Map) ? Map<String, dynamic>.from(config.metadata as Map) : {};
    });
  }

  void _closeForm() {
    setState(() {
      _showForm = false;
      _editingConfig = null;
    });
  }

  void _handleSubmit(AppConfigsNotifier notifier) {
    if (_configKey.trim().isEmpty || _configValue.trim().isEmpty) {
      context.showError('Key and Value cannot be empty');
      return;
    }

    context.showLoading();

    if (_editingConfig != null) {
      // Update
      final body = UpdateAppConfig(
        key: _configKey.trim(),
        value: _configValue.trim(),
        metadata: _configMetadata.isNotEmpty ? _configMetadata : null,
      );

      notifier.updateAppConfig(
        configId: _editingConfig!.id!,
        body: body,
        onSuccess: () {
          context.hideLoading();
          context.showSuccess('Configuration successfully updated');
          _closeForm();
        },
        onError: (msg, [st]) {
          context.hideLoading();
          context.showError(msg);
        },
      );
    } else {
      // Create
      final body = CreateAppConfig(
        key: _configKey.trim(),
        value: _configValue.trim(),
        metadata: _configMetadata.isNotEmpty ? _configMetadata : null,
      );

      notifier.createAppConfig(
        body,
        onSuccess: () {
          context.hideLoading();
          context.showSuccess('Configuration successfully created');
          _closeForm();
        },
        onError: (msg, [st]) {
          context.hideLoading();
          context.showError(msg);
        },
      );
    }
  }

  void _handleDelete(AppConfigsNotifier notifier, AppConfig config) {
    if (appConfirm('Are you sure you want to delete the configuration "${config.key}"? This action is permanent.')) {
      context.showLoading();
      notifier.deleteAppConfig(
        configId: config.id!,
        onSuccess: () {
          context.hideLoading();
          context.showSuccess('Configuration successfully deleted');
        },
        onError: (msg, [st]) {
          context.hideLoading();
          context.showError(msg);
        },
      );
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

    final configsAsync = context.watch(appConfigsProvider);
    final notifier = context.read(appConfigsProvider.notifier);

    return div(classes: 'flex-1 space-y-8 pb-12 min-h-screen text-white', [
      // ── Page Header ──────────────────────────────────────────────
      div(classes: 'flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-white/5 pb-6', [
        div(classes: 'space-y-1', [
          h1(classes: 'text-3xl font-bold tracking-tight text-white flex items-center space-x-3', [
            span(classes: 'text-2xl', [Component.text('⚙️')]),
            span([Component.text('App Configurations')]),
          ]),
          p(classes: 'text-dark-muted text-sm', [
            Component.text('Manage server-side key-value pairs, feature toggles, and metadata flags.'),
          ]),
        ]),
        div(classes: 'flex items-center gap-3', [
          button(
            classes:
                'px-4 py-2 bg-dark-border/30 border border-dark-border rounded-xl text-sm font-medium hover:text-white transition-all flex items-center space-x-2 cursor-pointer',
            onClick: () => notifier.refresh(),
            [
              span([Component.text('🔄')]),
              span([Component.text('Refresh')]),
            ],
          ),
          if (!_showForm)
            button(
              classes:
                  'px-4 py-2 bg-primary text-black rounded-xl text-sm font-bold hover:shadow-lg hover:shadow-primary/20 transition-all flex items-center space-x-2 cursor-pointer',
              onClick: _openCreateForm,
              [
                span([Component.text('➕')]),
                span([Component.text('New Configuration')]),
              ],
            ),
        ]),
      ]),

      // ── Form Panel (Create / Edit) ──────────────────────────────
      if (_showForm)
        div(classes: 'card p-6 border border-primary/20 bg-dark-card/60 space-y-6', [
          div(classes: 'flex justify-between items-center border-b border-white/5 pb-4', [
            h3(classes: 'text-lg font-bold text-white', [
              Component.text(_editingConfig != null ? 'Edit Configuration' : 'Create Configuration'),
            ]),
            button(
              classes: 'text-dark-muted hover:text-white text-sm cursor-pointer',
              onClick: _closeForm,
              [Component.text('Cancel ❌')],
            ),
          ]),

          div(classes: 'grid grid-cols-1 md:grid-cols-2 gap-6', [
            // Left Column (Key, Value)
            div(classes: 'space-y-4', [
              div(classes: 'space-y-1.5', [
                label(classes: 'text-xs font-semibold uppercase tracking-wider text-dark-muted', [
                  Component.text('Key'),
                ]),
                input<String>(
                  type: InputType.text,
                  classes:
                      'w-full bg-dark-bg border border-dark-border rounded-xl px-4 py-2.5 text-sm text-white focus:outline-none focus:border-primary/50 transition-all',
                  value: _configKey,
                  onInput: (val) => _configKey = val,
                ),
              ]),
              div(classes: 'space-y-1.5', [
                label(classes: 'text-xs font-semibold uppercase tracking-wider text-dark-muted', [
                  Component.text('Value'),
                ]),
                textarea(
                  classes:
                      'w-full bg-dark-bg border border-dark-border rounded-xl px-4 py-2.5 text-sm text-white focus:outline-none focus:border-primary/50 transition-all min-h-[120px]',
                  onInput: (val) => _configValue = val,
                  [.text(_configValue)],
                ),
              ]),
            ]),

            // Right Column (Metadata - optional KeyValuePairEditor)
            div(classes: 'space-y-3', [
              KeyValuePairEditor(
                label: 'Metadata Parameters (Optional)',
                initialData: _configMetadata,
                onChange: (map) => _configMetadata = map,
              ),
            ]),
          ]),

          div(classes: 'flex justify-end space-x-3 border-t border-white/5 pt-4', [
            button(
              classes:
                  'px-5 py-2.5 bg-white/5 border border-dark-border hover:bg-white/10 rounded-xl text-sm font-semibold transition-all cursor-pointer',
              onClick: _closeForm,
              [Component.text('Discard')],
            ),
            button(
              classes:
                  'px-6 py-2.5 bg-primary text-black rounded-xl text-sm font-bold hover:shadow-lg hover:shadow-primary/20 transition-all cursor-pointer',
              onClick: () => _handleSubmit(notifier),
              [Component.text(_editingConfig != null ? 'Save Changes' : 'Create Config')],
            ),
          ]),
        ]),

      // ── Main List Content ───────────────────────────────────────
      configsAsync.when(
        data: (configs) {
          if (configs.isEmpty) {
            return div(
              classes:
                  'card py-24 flex flex-col items-center justify-center text-center space-y-4 border border-dashed border-white/10 bg-transparent',
              [
                span(classes: 'text-5xl block animate-bounce', [Component.text('⚙️')]),
                h3(classes: 'text-lg font-bold text-white', [Component.text('No Configurations')]),
                p(classes: 'text-dark-muted max-w-sm text-sm', [
                  Component.text('There are no app configurations defined. Click "New Configuration" to add one.'),
                ]),
              ],
            );
          }

          return div(classes: 'space-y-6', [
            div(classes: 'card overflow-hidden p-0', [
              div(classes: 'overflow-x-auto', [
                table(classes: 'w-full text-left border-collapse', [
                  thead([
                    tr(classes: 'border-b border-dark-border bg-white/[0.01]', [
                      th(classes: 'py-4 px-6 text-xs font-bold text-dark-muted uppercase tracking-widest', [
                        Component.text('Configuration Key'),
                      ]),
                      th(classes: 'py-4 px-6 text-xs font-bold text-dark-muted uppercase tracking-widest', [
                        Component.text('Value'),
                      ]),
                      th(classes: 'py-4 px-6 text-xs font-bold text-dark-muted uppercase tracking-widest', [
                        Component.text('Metadata'),
                      ]),
                      th(classes: 'py-4 px-6 text-xs font-bold text-dark-muted uppercase tracking-widest text-right', [
                        Component.text('Actions'),
                      ]),
                    ]),
                  ]),
                  tbody([
                    for (final config in configs)
                      tr(classes: 'border-b border-dark-border/40 hover:bg-white/[0.02] transition-all group', [
                        // Key
                        td(classes: 'py-4 px-6 font-mono text-sm text-primary', [
                          Component.text(config.key ?? 'N/A'),
                        ]),
                        // Value
                        td(classes: 'py-4 px-6 text-sm text-white/90 max-w-xs truncate', [
                          Component.text(config.value ?? 'N/A'),
                        ]),
                        // Metadata
                        td(classes: 'py-4 px-6 text-sm', [
                          () {
                            Map<String, dynamic>? metadataMap;
                            if (config.metadata is Map) {
                              metadataMap = Map<String, dynamic>.from(config.metadata as Map);
                            } else if (config.metadata is String && (config.metadata as String).trim().isNotEmpty) {
                              try {
                                final decoded = jsonDecode(config.metadata as String);
                                if (decoded is Map) {
                                  metadataMap = Map<String, dynamic>.from(decoded);
                                }
                              } catch (_) {}
                            }
                            
                            if (metadataMap != null && metadataMap.isNotEmpty) {
                              return div(classes: 'text-xs text-dark-muted font-mono max-h-24 overflow-y-auto max-w-xs', [
                                JsonViewer(data: metadataMap),
                              ]);
                            } else {
                              return span(classes: 'text-xs text-dark-muted italic', [Component.text('No metadata')]);
                            }
                          }(),
                        ]),
                        // Actions
                        td(classes: 'py-4 px-6 text-right', [
                          div(classes: 'flex items-center justify-end space-x-2', [
                            button(
                              classes:
                                  'p-2 rounded-lg bg-white/5 border border-white/5 text-dark-muted hover:text-white hover:bg-white/10 hover:border-white/20 transition-all cursor-pointer',
                              onClick: () => _openEditForm(config),
                              [Component.text('✏️')],
                            ),
                            button(
                              classes:
                                  'p-2 rounded-lg bg-red-500/5 border border-red-500/5 text-red-400/70 hover:text-red-400 hover:bg-red-500/10 hover:border-red-500/20 transition-all cursor-pointer',
                              onClick: () => _handleDelete(notifier, config),
                              [Component.text('🗑️')],
                            ),
                          ]),
                        ]),
                      ]),
                  ]),
                ]),
              ]),
            ]),

            // Paginated Loading / Footers
            if (notifier.hasMore)
              div(classes: 'flex justify-center pt-6', [
                button(
                  classes:
                      'px-8 py-3 bg-white/5 border border-white/10 rounded-xl text-sm font-semibold hover:bg-white/10 hover:border-white/20 hover:shadow-lg transition-all flex items-center space-x-2 cursor-pointer',
                  onClick: () => notifier.loadMore(),
                  [
                    span([Component.text('📥')]),
                    span([Component.text('Load More Configurations')]),
                  ],
                ),
              ])
            else
              p(classes: 'text-center text-xs text-dark-muted pt-4', [
                Component.text('Showing all configurations.'),
              ]),
          ]);
        },
        loading: () => div(classes: 'space-y-4 py-12 text-center', [
          div(classes: 'w-12 h-12 border-4 border-primary border-t-transparent rounded-full animate-spin mx-auto', []),
          p(classes: 'text-dark-muted animate-pulse text-sm', [
            Component.text('Loading application configurations...'),
          ]),
        ]),
        error: (e, st) => div(
          classes: 'p-12 text-center bg-red-500/5 rounded-2xl border border-red-500/10 max-w-lg mx-auto',
          [
            span(classes: 'text-4xl mb-4 block', [Component.text('⚠️')]),
            h4(classes: 'text-lg font-bold text-red-400 mb-2', [Component.text('Failed to Load Configurations')]),
            p(classes: 'text-dark-muted mb-6 text-sm', [Component.text(e.toFriendlyMessage())]),
            button(
              classes:
                  'px-6 py-2.5 bg-red-500/20 text-red-400 border border-red-500/30 rounded-xl hover:bg-red-500/30 transition-all font-semibold cursor-pointer',
              onClick: () => notifier.refresh(),
              [Component.text('Retry Fetch')],
            ),
          ],
        ),
      ),
    ]);
  }
}
