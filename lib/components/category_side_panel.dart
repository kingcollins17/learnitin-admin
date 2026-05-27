import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:learnitin_admin/core/core.dart';
import 'package:learnitin_admin/models/course.dart';
import 'package:learnitin_admin/providers/category_provider.dart';

class CategorySidePanel extends StatelessComponent {
  final CourseCategory category;
  final VoidCallback onClose;
  final VoidCallback onAddSubCategory;
  final void Function(CourseSubCategory) onEditSubCategory;
  final void Function(CourseSubCategory) onDeleteSubCategory;

  const CategorySidePanel({
    super.key,
    required this.category,
    required this.onClose,
    required this.onAddSubCategory,
    required this.onEditSubCategory,
    required this.onDeleteSubCategory,
  });

  static void open(
    BuildContext context, {
    required CourseCategory category,
    required VoidCallback onAddSubCategory,
    required void Function(CourseSubCategory) onEditSubCategory,
    required void Function(CourseSubCategory) onDeleteSubCategory,
  }) {
    context.showSidePanel(
      CategorySidePanel(
        category: category,
        onClose: () => context.hideSidePanel(),
        onAddSubCategory: onAddSubCategory,
        onEditSubCategory: onEditSubCategory,
        onDeleteSubCategory: onDeleteSubCategory,
      ),
    );
  }

  String _getAvatarText(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0].substring(0, parts[0].length > 1 ? 2 : 1).toUpperCase();
  }

  String _getAvatarGradient(String? name) {
    if (name == null || name.trim().isEmpty) return 'from-primary/30 to-primary-700/30';
    final hash = name.codeUnits.fold(0, (prev, element) => prev + element);
    final gradients = [
      'from-primary/30 to-primary-700/30',
      'from-blue-500/30 to-blue-500/10',
      'from-purple-500/30 to-purple-500/10',
      'from-emerald-500/30 to-emerald-500/10',
      'from-amber-500/30 to-amber-500/10',
      'from-red-500/30 to-red-500/10',
    ];
    return gradients[hash % gradients.length];
  }

  String _getAvatarTextColor(String? name) {
    if (name == null || name.trim().isEmpty) return 'text-primary';
    final hash = name.codeUnits.fold(0, (prev, element) => prev + element);
    final colors = [
      'text-primary',
      'text-blue-400',
      'text-purple-400',
      'text-emerald-400',
      'text-amber-400',
      'text-red-400',
    ];
    return colors[hash % colors.length];
  }

  @override
  Component build(BuildContext context) {
    final subCategoriesAsync = context.watch(subCategoriesProvider(category.id!));

    final gradient = _getAvatarGradient(category.name);
    final textColor = _getAvatarTextColor(category.name);

    return div(
      classes: 'w-80 md:w-[32rem] shrink-0 bg-dark-card border-l border-dark-border shadow-2xl flex flex-col h-full',
      [
        // Header
        div(classes: 'flex items-center justify-between p-6 border-b border-dark-border/50', [
          div(classes: 'flex items-center space-x-3', [
            div(
              classes: 'w-9 h-9 rounded-lg bg-gradient-to-br $gradient flex items-center justify-center text-xs font-bold $textColor shrink-0',
              [Component.text(_getAvatarText(category.name))],
            ),
            div(classes: 'min-w-0', [
              h3(classes: 'text-base font-bold text-white truncate max-w-[200px] md:max-w-[300px]', [
                Component.text(category.name ?? 'Category Details'),
              ]),
              p(classes: 'text-xs text-dark-muted truncate', [Component.text('Subcategory Management')]),
            ]),
          ]),
          button(
            classes: 'p-2 text-dark-muted hover:text-white rounded-lg hover:bg-white/5 transition-all',
            onClick: onClose,
            [Component.text('✕')],
          ),
        ]),

        // Content
        div(classes: 'flex-1 overflow-y-auto p-6 space-y-6', [
          // Category Info
          if (category.description != null && category.description!.isNotEmpty)
            div(classes: 'space-y-2', [
              h5(classes: 'text-[10px] font-bold text-dark-muted uppercase tracking-wider', [
                Component.text('About Category'),
              ]),
              div(classes: 'bg-white/5 rounded-xl border border-white/5 p-4', [
                p(classes: 'text-sm text-white leading-relaxed', [Component.text(category.description!)]),
              ]),
            ]),

          // Subcategories list
          div(classes: 'space-y-3', [
            div(classes: 'flex items-center justify-between', [
              h5(classes: 'text-[10px] font-bold text-dark-muted uppercase tracking-wider', [
                Component.text('Subcategories'),
              ]),
              button(
                classes: 'px-2.5 py-1 rounded-lg text-xs font-semibold text-primary hover:bg-primary/10 transition-all cursor-pointer flex items-center space-x-1',
                onClick: onAddSubCategory,
                [
                  span([Component.text('➕')]),
                  span([Component.text('Add New')]),
                ],
              ),
            ]),

            subCategoriesAsync.when(
              data: (subCategories) {
                if (subCategories.isEmpty) {
                  return div(classes: 'py-12 border border-dashed border-dark-border rounded-xl flex flex-col items-center justify-center text-center p-6 space-y-3', [
                    span(classes: 'text-2xl', [Component.text('📂')]),
                    p(classes: 'text-dark-muted text-xs', [
                      Component.text('No subcategories created yet.'),
                    ]),
                  ]);
                }

                return div(classes: 'space-y-2', [
                  for (final sub in subCategories)
                    div(
                      classes: 'flex items-center justify-between gap-3 px-4 py-3 bg-white/5 rounded-xl hover:bg-white/[0.08] border border-white/5 transition-colors group',
                      [
                        div(classes: 'flex-1 min-w-0', [
                          p(classes: 'text-sm font-semibold text-white truncate', [
                            Component.text(sub.name ?? 'Unnamed'),
                          ]),
                          if (sub.description != null && sub.description!.isNotEmpty)
                            p(classes: 'text-xs text-dark-muted truncate mt-0.5', [
                              Component.text(sub.description!),
                            ]),
                        ]),
                        div(
                          classes: 'flex items-center space-x-1 shrink-0 opacity-0 group-hover:opacity-100 transition-opacity',
                          [
                            button(
                              classes: 'p-1.5 rounded-lg text-dark-muted hover:text-white hover:bg-white/5 transition-all cursor-pointer',
                              onClick: () => onEditSubCategory(sub),
                              [Component.text('✏️')],
                            ),
                            button(
                              classes: 'p-1.5 rounded-lg text-dark-muted hover:text-red-400 hover:bg-red-500/10 transition-all cursor-pointer',
                              onClick: () => onDeleteSubCategory(sub),
                              [Component.text('🗑️')],
                            ),
                          ],
                        ),
                      ],
                    ),
                ]);
              },
              loading: () => div(classes: 'space-y-2 py-2', [
                for (var i = 0; i < 3; i++)
                  div(classes: 'flex items-center space-x-3 p-3 bg-white/5 rounded-xl border border-white/5 animate-pulse', [
                    div(classes: 'flex-1 space-y-2', [
                      div(classes: 'h-4 bg-dark-border/30 rounded w-1/3', []),
                      div(classes: 'h-3 bg-dark-border/30 rounded w-2/3', []),
                    ]),
                  ]),
              ]),
              error: (e, __) => div(classes: 'py-4 text-center', [
                p(classes: 'text-red-400 text-xs', [Component.text(e.toFriendlyMessage())]),
              ]),
            ),
          ]),
        ]),
      ],
    );
  }
}
