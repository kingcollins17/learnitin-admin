import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'components/header.dart';
import 'components/sidebar.dart';
import 'pages/about.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/courses_list_page.dart';
import 'pages/users_list_page.dart';
import 'pages/logs_list_page.dart';
import 'providers/auth_provider.dart';

import 'core/utils/context_extensions.dart';

class App extends StatelessComponent {
  const App({super.key});

  @override
  Component build(BuildContext context) {
    final authState = context.watch(authProvider);
    final isAuthenticated = authState.value != null;

    return GlobalUIOverlayWrapper(
      child: Router(
        redirect: (context, state) {
          if (authState.isLoading) return null;

          if (state.location == '/login' && isAuthenticated) {
            return '/';
          }
          if (state.location != '/login' && !isAuthenticated) {
            return '/login';
          }
          return null;
        },
        routes: [
          Route(
            path: '/login',
            title: 'Login',
            builder: (context, state) => const LoginPage(),
          ),
          ShellRoute(
            builder: (context, state, child) => div(classes: 'flex h-screen w-full bg-dark-bg text-white overflow-hidden', [
              const Sidebar(),
              div(classes: 'flex-1 flex flex-col min-w-0', [
                const Header(),
                div(id: 'main-content', classes: 'flex-1 p-8 overflow-y-auto', [
                  child,
                ]),
              ]),
            ]),
            routes: [
              Route(
                path: '/',
                title: 'Dashboard',
                builder: (context, state) => const Home(),
              ),
              Route(
                path: '/about',
                title: 'Settings',
                builder: (context, state) => const About(),
              ),
              Route(
                path: '/courses',
                title: 'Courses',
                builder: (context, state) => const CoursesListPage(),
              ),
              Route(
                path: '/users',
                title: 'Users',
                builder: (context, state) => const UsersListPage(),
              ),
              Route(
                path: '/logs',
                title: 'System Logs',
                builder: (context, state) => const LogsListPage(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
