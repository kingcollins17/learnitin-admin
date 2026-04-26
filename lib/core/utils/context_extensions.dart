import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

/// Extension to handle common UI interactions safely via BuildContext.
extension ContextUtils on BuildContext {
  /// Helper to get the Global UI Notifier
  _GlobalUINotifier get _ui => read(_globalUIProvider.notifier);

  /// Shows a beautifully animated loading overlay
  void showLoading() => _ui.setLoading(true);

  /// Hides the active loading overlay
  void hideLoading() => _ui.setLoading(false);

  /// Shows a success notification
  void showSuccess(String message) => _ui.addToast(message, ToastType.success);

  /// Shows an error notification
  void showError(String message) => _ui.addToast(message, ToastType.error);

  /// Shows an info notification
  void showInfo(String message) => _ui.addToast(message, ToastType.info);

  /// Shows a warning notification
  void showWarning(String message) => _ui.addToast(message, ToastType.warning);

  /// Shows a side panel component
  void showSidePanel(Component panel) => _ui.setSidePanel(panel);

  /// Hides the side panel
  void hideSidePanel() => _ui.setSidePanel(null);
}

// --- Internal Riverpod State Management for UI Overlays ---

enum ToastType { info, success, warning, error }

class ToastMessage {
  final String id;
  final String message;
  final ToastType type;
  ToastMessage(this.message, this.type) : id = DateTime.now().millisecondsSinceEpoch.toString();
}

class GlobalUIState {
  final bool isLoading;
  final List<ToastMessage> toasts;
  final Component? sidePanel;

  GlobalUIState({
    this.isLoading = false,
    this.toasts = const [],
    this.sidePanel,
  });
}

final _globalUIProvider = NotifierProvider<_GlobalUINotifier, GlobalUIState>(_GlobalUINotifier.new);

class _GlobalUINotifier extends Notifier<GlobalUIState> {
  @override
  GlobalUIState build() => GlobalUIState();

  void setLoading(bool loading) {
    state = GlobalUIState(isLoading: loading, toasts: state.toasts, sidePanel: state.sidePanel);
  }

  void addToast(String message, ToastType type) {
    final newToast = ToastMessage(message, type);
    state = GlobalUIState(isLoading: state.isLoading, toasts: [...state.toasts, newToast], sidePanel: state.sidePanel);

    // Auto-dismiss after 6 seconds
    Future.delayed(const Duration(seconds: 6), () {
      removeToast(newToast.id);
    });
  }

  void removeToast(String id) {
    state = GlobalUIState(isLoading: state.isLoading, toasts: state.toasts.where((t) => t.id != id).toList(), sidePanel: state.sidePanel);
  }

  void setSidePanel(Component? panel) {
    state = GlobalUIState(isLoading: state.isLoading, toasts: state.toasts, sidePanel: panel);
  }
}

/// A component that should be wrapped around the root of the app to render overlays.
class GlobalUIOverlayWrapper extends StatelessComponent {
  final Component child;
  const GlobalUIOverlayWrapper({required this.child, super.key});

  @override
  Component build(BuildContext context) {
    final uiState = context.watch(_globalUIProvider);

    return div(classes: 'relative min-h-screen overflow-x-hidden w-full', [
      child,

      // Backdrop and Side Panel
      if (uiState.sidePanel != null)
        div(classes: 'fixed inset-0 z-[90] flex justify-end', [
          // Backdrop
          div(
            classes: 'absolute inset-0 bg-dark-bg/60 backdrop-blur-sm animate-in fade-in duration-300',
            events: {
              'click': (e) => context.hideSidePanel(),
            },
            [],
          ),
          // Panel Container
          div(
            classes: 'relative h-full animate-in slide-in-from-right duration-300',
            [uiState.sidePanel!],
          ),
        ]),

      // Loading Overlay
      if (uiState.isLoading)
        div(
          classes:
              'fixed inset-0 z-[100] flex items-center justify-center bg-dark-bg/60 backdrop-blur-sm animate-in fade-in duration-300',
          [
            div(classes: 'flex flex-col items-center space-y-4', [
              div(classes: 'w-12 h-12 border-4 border-primary border-t-transparent rounded-full animate-spin', []),
              span(classes: 'text-primary font-medium tracking-wide animate-pulse', [Component.text('Loading...')]),
            ]),
          ],
        ),

      // Toast / Flushbar Container
      div(classes: 'fixed top-6 right-6 z-[110] flex flex-col items-end space-y-3', [
        for (final toast in uiState.toasts) _ToastItem(key: ValueKey(toast.id), toast: toast),
      ]),
    ]);
  }
}

class _ToastItem extends StatelessComponent {
  final ToastMessage toast;
  const _ToastItem({required this.toast, super.key});

  @override
  Component build(BuildContext context) {
    final (bg, border, icon, textColor) = switch (toast.type) {
      ToastType.success => ('bg-emerald-500/10', 'border-emerald-500/50', '✅', 'text-emerald-500'),
      ToastType.error => ('bg-red-500/10', 'border-red-500/50', '❌', 'text-red-500'),
      ToastType.warning => ('bg-amber-500/10', 'border-amber-500/50', '⚠️', 'text-amber-500'),
      ToastType.info => ('bg-blue-500/10', 'border-blue-500/50', 'ℹ️', 'text-blue-500'),
    };

    return div(
      classes:
          'flex items-center space-x-3 px-4 py-3 rounded-xl border $bg $border shadow-2xl animate-in slide-in-from-right duration-300',
      [
        span(classes: 'text-lg', [Component.text(icon)]),
        p(classes: 'text-sm font-medium $textColor', [Component.text(toast.message)]),
        button(
          classes: 'ml-2 text-dark-muted hover:text-white transition-colors',
          onClick: () => context.read(_globalUIProvider.notifier).removeToast(toast.id),
          [Component.text('✕')],
        ),
      ],
    );
  }
}
