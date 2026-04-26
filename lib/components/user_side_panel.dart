import 'package:learnitin_admin/core/utils/browser_utils.dart';
import 'dart:js_interop';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:learnitin_admin/core/utils/context_extensions.dart';
import 'package:learnitin_admin/core/utils/error_sanitizer.dart';
import 'package:learnitin_admin/providers/user_detail_provider.dart';
import 'package:learnitin_admin/providers/notification_provider.dart';

class UserSidePanel extends StatelessComponent {
  final int userId;
  final VoidCallback onClose;

  const UserSidePanel({
    super.key,
    required this.userId,
    required this.onClose,
  });

  static void open(BuildContext context, int userId) {
    context.showSidePanel(
      UserSidePanel(
        userId: userId,
        onClose: () => context.hideSidePanel(),
      ),
    );
  }

  @override
  Component build(BuildContext context) {
    final userAsync = context.watch(userDetailProvider(userId));

    return div(
      classes: 'w-80 md:w-[32rem] shrink-0 bg-dark-card border-l border-dark-border shadow-2xl flex flex-col h-full',
      [
        // Header
        div(classes: 'flex items-center justify-between p-6 border-b border-dark-border/50', [
          h3(classes: 'text-lg font-bold text-white', [Component.text('User Details')]),
          button(
            classes: 'p-2 text-dark-muted hover:text-white rounded-lg hover:bg-white/5 transition-all',
            onClick: onClose,
            [Component.text('✕')],
          ),
        ]),
        // Content
        div(classes: 'flex-1 overflow-y-auto p-6 space-y-6', [
          userAsync.when(
            data: (user) {
              if (user == null) return p([Component.text('User not found.')]);

              return div(classes: 'space-y-6', [
                // Profile Block
                div(classes: 'flex items-center space-x-4', [
                  div(
                    classes:
                        'w-16 h-16 rounded-full bg-gradient-to-br from-primary/30 to-primary-700/30 border border-primary/30 flex items-center justify-center text-xl font-bold text-primary',
                    [
                      Component.text(
                        (user.fullName != null && user.fullName!.isNotEmpty)
                            ? user.fullName![0].toUpperCase()
                            : (user.username ?? 'U')[0].toUpperCase(),
                      ),
                    ],
                  ),
                  div(classes: 'flex-1 min-w-0', [
                    h4(classes: 'text-lg font-bold text-white truncate', [
                      Component.text(user.fullName ?? user.username ?? 'Unknown'),
                    ]),
                    p(classes: 'text-sm text-dark-muted truncate', [Component.text(user.email ?? '')]),
                  ]),
                ]),

                // Subscription Details
                div(classes: 'space-y-2', [
                  h5(classes: 'text-xs font-bold text-dark-muted uppercase tracking-wider', [
                    Component.text('Subscription'),
                  ]),
                  div(classes: 'bg-white/5 rounded-xl border border-white/5 p-4 space-y-3', [
                    div(classes: 'flex justify-between items-center', [
                      span(classes: 'text-sm text-dark-muted', [Component.text('Status')]),
                      span(
                        classes:
                            'text-xs font-bold px-2 py-1 rounded-md ${user.subscription?.status == "active" && user.subscription?.productId != "free" ? "bg-emerald-500/10 text-emerald-400 border border-emerald-500/20" : "bg-dark-border/50 text-dark-muted border border-dark-border"}',
                        [
                          Component.text(
                            user.subscription?.status == "active" && user.subscription?.productId != "free"
                                ? 'Premium'
                                : 'Free',
                          ),
                        ],
                      ),
                    ]),
                    if (user.subscription?.expiryTime != null)
                      div(classes: 'flex justify-between items-center', [
                        span(classes: 'text-sm text-dark-muted', [Component.text('Expires')]),
                        span(classes: 'text-sm text-white', [
                          Component.text(
                            '${user.subscription!.expiryTime!.year}-${user.subscription!.expiryTime!.month.toString().padLeft(2, '0')}-${user.subscription!.expiryTime!.day.toString().padLeft(2, '0')}',
                          ),
                        ]),
                      ]),
                  ]),
                ]),

                // Account Status
                div(classes: 'space-y-2', [
                  h5(classes: 'text-xs font-bold text-dark-muted uppercase tracking-wider', [
                    Component.text('Account Details'),
                  ]),
                  div(classes: 'bg-white/5 rounded-xl border border-white/5 p-4 space-y-3', [
                    div(classes: 'flex justify-between items-center', [
                      span(classes: 'text-sm text-dark-muted', [Component.text('Active')]),
                      span(
                        classes: 'text-sm font-bold ${user.isActive == true ? "text-emerald-400" : "text-red-400"}',
                        [Component.text(user.isActive == true ? 'Yes' : 'No')],
                      ),
                    ]),
                    div(classes: 'flex justify-between items-center', [
                      span(classes: 'text-sm text-dark-muted', [Component.text('Role')]),
                      span(classes: 'text-sm font-bold text-white', [
                        Component.text(user.isSuperuser == true ? 'Admin' : 'Learner'),
                      ]),
                    ]),
                    div(classes: 'flex justify-between items-center', [
                      span(classes: 'text-sm text-dark-muted', [Component.text('Journeys Taken')]),
                      span(classes: 'text-sm font-bold text-white', [
                        Component.text('${user.subscription?.usage?.learningJourneysUsed ?? 0}'),
                      ]),
                    ]),
                  ]),
                ]),

                // Actions
                div(classes: 'space-y-2', [
                  h5(classes: 'text-xs font-bold text-dark-muted uppercase tracking-wider', [
                    Component.text('Actions'),
                  ]),
                  div(classes: 'grid grid-cols-2 gap-3', [
                    button(
                      classes:
                          'px-4 py-2.5 rounded-xl text-sm font-bold flex items-center justify-center ' +
                          (user.subscription?.status == "active" && user.subscription?.productId != "free"
                              ? 'bg-amber-500/10 text-amber-400 border border-amber-500/20 hover:bg-amber-500/20'
                              : 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 hover:bg-emerald-500/20'),
                      onClick: () {
                        final notifier = context.read(userDetailProvider(userId).notifier);
                        if (user.subscription?.status == "active" && user.subscription?.productId != "free") {
                          notifier.revokePremium(
                            onSuccess: () => appAlert('Premium revoked!'),
                            onError: (e) => appAlert('Error: $e'),
                          );
                        } else {
                          notifier.grantPremium(
                            onSuccess: () => appAlert('Premium granted!'),
                            onError: (e) => appAlert('Error: $e'),
                          );
                        }
                      },
                      [
                        Component.text(
                          user.subscription?.status == "active" && user.subscription?.productId != "free"
                              ? 'Revoke Premium'
                              : 'Grant Premium',
                        ),
                      ],
                    ),
                    button(
                      classes:
                          'px-4 py-2.5 rounded-xl text-sm font-bold flex items-center justify-center ' +
                          (user.isActive == true
                              ? 'bg-red-500/10 text-red-400 border border-red-500/20 hover:bg-red-500/20'
                              : 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 hover:bg-emerald-500/20'),
                      onClick: () {
                        final notifier = context.read(userDetailProvider(userId).notifier);
                        if (user.isActive == true) {
                          final reason = appPrompt('Enter reason for banning user:');
                          if (reason != null && reason.isNotEmpty) {
                            notifier.banUser(
                              reason: reason,
                              onSuccess: () => appAlert('User banned!'),
                              onError: (e) => appAlert('Error: $e'),
                            );
                          }
                        } else {
                          notifier.unbanUser(
                            onSuccess: () => appAlert('User unbanned!'),
                            onError: (e) => appAlert('Error: $e'),
                          );
                        }
                      },
                      [Component.text(user.isActive == true ? 'Ban User' : 'Unban User')],
                    ),
                    button(
                      classes:
                          'px-4 py-2.5 rounded-xl text-sm font-bold flex items-center justify-center bg-blue-500/10 text-blue-400 border border-blue-500/20 hover:bg-blue-500/20 col-span-2',
                      onClick: () {
                        final msg = appPrompt(
                          'Enter notification message for ${user.fullName ?? user.username ?? 'this user'}:',
                        );
                        if (msg != null && msg.isNotEmpty) {
                          context.showLoading();
                          context
                              .read(appNotificationProvider.notifier)
                              .sendToUser(
                                userId: userId,
                                title: 'Learnitin',
                                message: msg,
                                onSuccess: () => context.showSuccess('Notification sent!'),
                                onError: (e, [st]) => context.showError(e.toFriendlyMessage()),
                              );
                          context.hideLoading();
                        }
                      },
                      [Component.text('Send Notification')],
                    ),
                  ]),
                ]),
              ]);
            },
            loading: () => div(classes: 'py-12 flex justify-center', [
              div(classes: 'w-8 h-8 border-2 border-primary border-t-transparent rounded-full animate-spin', []),
            ]),
            error: (e, st) => p(classes: 'text-red-400', [Component.text('Error loading details')]),
          ),
        ]),
      ],
    );
  }
}
