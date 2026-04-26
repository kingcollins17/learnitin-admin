import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import '../providers/user_provider.dart';

class Header extends StatelessComponent {
  const Header({super.key});

  @override
  Component build(BuildContext context) {
    var state = RouteState.of(context);
    var title = state.name;
    final userAsync = context.watch(currentUserProvider);

    return header(
      classes:
          'h-16 px-8 flex items-center justify-between border-b border-dark-border bg-dark-bg/50 backdrop-blur sticky top-0 z-40',
      [
        // Left: Breadcrumbs
        div(classes: 'flex items-center space-x-2 text-sm', [
          span(classes: 'text-dark-muted', [Component.text('Pages')]),
          span(classes: 'text-dark-muted', [Component.text('/')]),
          span(classes: 'text-white font-medium', [Component.text(title ?? 'Dashboard')]),
        ]),

        // Right: Actions
        div(classes: 'flex items-center space-x-6', [
          // Search bar
          div(
            classes: 'hidden md:flex items-center bg-dark-card border border-dark-border rounded-lg px-3 py-1.5 w-64',
            [
              span(classes: 'text-dark-muted mr-2', [Component.text('🔍')]),
              input(
                classes:
                    'bg-transparent border-none outline-none text-sm text-white placeholder:text-dark-muted w-full',
                attributes: {'placeholder': 'Search...'},
              ),
            ],
          ),

          // Notifications
          button(classes: 'text-dark-muted hover:text-white transition-colors relative', [
            Component.text('🔔'),
            div(classes: 'absolute -top-1 -right-1 w-2 h-2 bg-primary rounded-full', []),
          ]),

          // Profile Shortcut (Mobile-ish)
          div(
            classes:
                'w-8 h-8 rounded-full bg-primary/20 flex items-center justify-center text-xs font-bold text-primary border border-primary/20 cursor-pointer overflow-hidden',
            [
              userAsync.when(
                data: (user) => Component.text(user?.fullName?.isNotEmpty == true ? user!.fullName!.substring(0, 1).toUpperCase() : 'A'),
                loading: () => div(classes: 'w-full h-full bg-primary/10 animate-pulse', []),
                error: (e, st) => Component.text('?'),
              )
            ],
          ),
        ]),
      ],
    );
  }
}
