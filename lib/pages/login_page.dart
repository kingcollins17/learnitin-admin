import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_router/jaspr_router.dart';
import '../providers/auth_provider.dart';
import '../core/utils/context_extensions.dart';

class LoginPage extends StatefulComponent {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  String email = '';
  String password = '';
  bool obscurePassword = true;
  String? error;

  void handleLogin() async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      context.showWarning('Please enter both email and password');
      return;
    }

    context.showLoading();
    await context
        .read(authProvider.notifier)
        .login(
          email.trim(),
          password,
          onSuccess: () {
            context.showSuccess('Login successful!');
            context.push('/');
          },
          onError: (msg, [st]) {
            context.showError(msg);
          },
        );
    context.hideLoading();
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'min-h-screen flex items-center justify-center bg-dark-bg p-6 relative overflow-hidden', [
      // Decorative background glow
      div(classes: 'absolute -top-24 -left-24 w-96 h-96 bg-primary/10 rounded-full blur-[100px]', []),
      div(classes: 'absolute -bottom-24 -right-24 w-96 h-96 bg-primary/5 rounded-full blur-[100px]', []),

      div(classes: 'w-full max-w-md space-y-8 z-10', [
        // Logo and Header
        div(classes: 'text-center space-y-4', [
          div(
            classes:
                'w-16 h-16 bg-primary rounded-2xl mx-auto flex items-center justify-center shadow-[0_0_20px_rgba(0,212,126,0.2)]',
            [
              span(classes: 'text-3xl text-black font-extrabold', [Component.text('L')]),
            ],
          ),
          h1(classes: 'text-3xl font-bold tracking-tight text-white', [Component.text('Welcome Back')]),
          p(classes: 'text-dark-muted', [Component.text('Enter your credentials to access the admin portal')]),
        ]),

        // Login Card
        div(classes: 'card p-8 space-y-6 bg-dark-card border-dark-border', [
          div(classes: 'space-y-4', [
            // Email Input
            div(classes: 'space-y-1.5', [
              label(classes: 'text-sm font-medium text-dark-muted', [Component.text('Email Address')]),
              input(
                type: InputType.email,
                classes:
                    'w-full bg-dark-bg border border-dark-border rounded-lg px-4 py-2.5 text-white outline-none focus:border-primary transition-colors',
                attributes: {'placeholder': 'name@example.com'},
                onInput: (value) => email = value.toString(),
              ),
            ]),

            // Password Input
            div(classes: 'space-y-1.5', [
              div(classes: 'flex items-center justify-between', [
                label(classes: 'text-sm font-medium text-dark-muted', [Component.text('Password')]),
                a(classes: 'text-xs text-primary hover:underline', href: '#', [Component.text('Forgot Password?')]),
              ]),
              div(classes: 'relative', [
                input(
                  type: obscurePassword ? InputType.password : InputType.text,
                  classes:
                      'w-full bg-dark-bg border border-dark-border rounded-lg px-4 py-2.5 text-white outline-none focus:border-primary transition-colors pr-10',
                  attributes: {'placeholder': '••••••••'},
                  onInput: (value) => password = value.toString(),
                ),
                button(
                  type: ButtonType.button,
                  classes:
                      'absolute right-3 top-1/2 -translate-y-1/2 p-1 text-dark-muted hover:text-white transition-colors focus:outline-none',
                  onClick: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                  [
                    if (obscurePassword)
                      svg(
                        attributes: {
                          'viewBox': '0 0 24 24',
                          'fill': 'none',
                          'stroke': 'currentColor',
                          'stroke-width': '2',
                          'class': 'w-5 h-5',
                        },
                        [
                          path(
                            attributes: {
                              'd': 'M15 12a3 3 0 11-6 0 3 3 0 016 0z',
                              'stroke-linecap': 'round',
                              'stroke-linejoin': 'round',
                            },
                            [],
                          ),
                          path(
                            attributes: {
                              'd':
                                  'M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z',
                              'stroke-linecap': 'round',
                              'stroke-linejoin': 'round',
                            },
                            [],
                          ),
                        ],
                      )
                    else
                      svg(
                        attributes: {
                          'viewBox': '0 0 24 24',
                          'fill': 'none',
                          'stroke': 'currentColor',
                          'stroke-width': '2',
                          'class': 'w-5 h-5',
                        },
                        [
                          path(
                            attributes: {
                              'd':
                                  'M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21',
                              'stroke-linecap': 'round',
                              'stroke-linejoin': 'round',
                            },
                            [],
                          ),
                        ],
                      ),
                  ],
                ),
              ]),
            ]),
          ]),

          div(classes: 'flex items-center space-x-2', [
            input(type: InputType.checkbox, classes: 'rounded border-dark-border bg-dark-bg text-primary'),
            label(classes: 'text-sm text-dark-muted', [Component.text('Remember me for 30 days')]),
          ]),

          button(
            classes: 'w-full btn-primary h-12 flex items-center justify-center space-x-2',
            onClick: handleLogin,
            [
              Component.text('Sign In to Dashboard'),
            ],
          ),
        ]),

        div(classes: 'text-center text-sm text-dark-muted', [
          Component.text('Don\'t have an account? '),
          a(classes: 'text-primary font-medium hover:underline', href: '#', [Component.text('Contact Support')]),
        ]),
      ]),
    ]);
  }
}
