import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import '../providers/user_provider.dart';

class Sidebar extends StatelessComponent {
  const Sidebar({super.key});

  @override
  Component build(BuildContext context) {
    var activePath = RouteState.of(context).location;
    final userAsync = context.watch(currentUserProvider);

    return aside(classes: 'w-64 shrink-0 z-20 h-full bg-dark-card border-r border-dark-border flex flex-col p-4 space-y-8', [
      // Logo section
      div(classes: 'px-2 flex items-center space-x-3', [
        div(classes: 'w-8 h-8 bg-primary rounded-lg flex items-center justify-center', [
          span(classes: 'text-black font-bold', [.text('L')])
        ]),
        span(classes: 'text-xl font-bold tracking-tight text-white', [.text('LearnItIn')])
      ]),

      // Navigation
      nav(classes: 'flex-1 space-y-1', [
        _SidebarLink(
          icon: '📊',
          label: 'Dashboard',
          path: '/',
          active: activePath == '/',
        ),
        _SidebarLink(
          icon: '📚',
          label: 'Courses',
          path: '/courses',
          active: activePath == '/courses',
        ),
        _SidebarLink(
          icon: '👥',
          label: 'Users',
          path: '/users',
          active: activePath == '/users',
        ),
        _SidebarLink(
          icon: '📋',
          label: 'System Logs',
          path: '/logs',
          active: activePath == '/logs',
        ),
      ]),

      // Footer / Profile
      div(classes: 'pt-4 border-t border-dark-border px-2', [
        userAsync.when(
          data: (user) => div(classes: 'flex items-center space-x-3', [
            div(classes: 'w-10 h-10 rounded-full bg-dark-border flex items-center justify-center border border-white/10 overflow-hidden', [
              .text(user?.fullName?.isNotEmpty == true ? user!.fullName!.substring(0, 1).toUpperCase() : 'A')
            ]),
            div([
              p(classes: 'text-sm font-medium text-white', [.text(user?.fullName ?? user?.username ?? 'User')]),
              p(classes: 'text-xs text-dark-muted', [.text(user?.isSuperuser == true ? 'Super Admin' : 'Admin')])
            ])
          ]),
          loading: () => div(classes: 'flex items-center space-x-3 opacity-50', [
            div(classes: 'w-10 h-10 rounded-full bg-dark-border animate-pulse', []),
            div(classes: 'space-y-1', [
              div(classes: 'w-20 h-3 bg-dark-border rounded animate-pulse', []),
              div(classes: 'w-16 h-2 bg-dark-border rounded animate-pulse', []),
            ])
          ]),
          error: (e, st) => div(classes: 'text-xs text-red-500', [.text('Error loading profile')]),
        )
      ])
    ]);
  }
}

class _SidebarLink extends StatelessComponent {
  final String icon;
  final String label;
  final String path;
  final bool active;

  const _SidebarLink({
    required this.icon,
    required this.label,
    required this.path,
    required this.active,
  });

  @override
  Component build(BuildContext context) {
    return Link(
      to: path,
      classes: 'flex items-center space-x-3 px-3 py-2.5 rounded-lg transition-all '
          '${active ? 'bg-primary/10 text-primary border border-primary/20' : 'text-dark-muted hover:bg-white/5 hover:text-white'}',
      child: .fragment([
        span(classes: 'text-lg', [.text(icon)]),
        span(classes: 'font-medium', [.text(label)]),
      ]),
    );
  }
}
