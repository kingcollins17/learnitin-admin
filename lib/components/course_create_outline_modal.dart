import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:learnitin_admin/core/core.dart';
import 'package:learnitin_admin/models/course_generation.dart';
import 'package:learnitin_admin/providers/admin_course_provider.dart';

class CourseCreateOutlineModal extends StatefulComponent {
  final VoidCallback onClose;
  final void Function(GeneratedCourse course) onOutlineGenerated;

  const CourseCreateOutlineModal({
    required this.onClose,
    required this.onOutlineGenerated,
    super.key,
  });

  @override
  State<CourseCreateOutlineModal> createState() => _CourseCreateOutlineModalState();
}

class _CourseCreateOutlineModalState extends State<CourseCreateOutlineModal> {
  String _topic = '';
  String _level = 'beginner';
  String _learningPace = 'balanced';
  int _durationWeeks = 6;
  String _learningGoalsInput = '';
  bool _isLoading = false;

  void _generateOutline() async {
    if (_topic.trim().isEmpty) {
      context.showError('Please enter a course topic.');
      return;
    }

    final request = GenerateCoursesRequest(
      topic: _topic.trim(),
      level: _level.toLowerCase(),
      learningPace: _learningPace.toLowerCase(),
      durationPreference: '$_durationWeeks weeks',
      learningGoals: _learningGoalsInput.isNotEmpty
          ? _learningGoalsInput.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
          : null,
    );

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await context
          .read(adminCourseProvider(defaultAdminCourseParams).notifier)
          .generateCourseOutline(
            request,
            onError: (msg, [st]) {
              context.showError(msg);
            },
          );

      if (response != null && response.courses != null && response.courses!.isNotEmpty) {
        context.showSuccess('Course outline generated successfully!');
        component.onOutlineGenerated(response.courses!.first);
      } else {
        context.showError('No course outlines generated. Please try again.');
      }
    } catch (e) {
      // Handled via notifier's onError callback
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Component build(BuildContext context) {
    return div(
      classes:
          'fixed inset-0 z-[100] flex items-center justify-center p-4 bg-dark-bg/60 backdrop-blur-md animate-in fade-in duration-200',
      [
        // Backdrop click to close (when not loading)
        div(
          classes: 'absolute inset-0 cursor-default',
          events: _isLoading ? {} : {'click': (e) => component.onClose()},
          [],
        ),

        // Dialog Content Card
        div(
          classes:
              'relative w-full max-w-lg bg-dark-card border border-dark-border/80 rounded-2xl shadow-2xl p-6 md:p-8 space-y-6 animate-in zoom-in-95 duration-200 overflow-y-auto max-h-[90vh]',
          [
            // Header
            div(classes: 'flex items-center justify-between', [
              div(classes: 'space-y-1', [
                h3(classes: 'text-xl font-bold text-white', [
                  Component.text('Generate AI Course Outline'),
                ]),
                p(classes: 'text-xs text-dark-muted', [
                  Component.text('Fill in the parameters below to generate a new syllabus outline.'),
                ]),
              ]),
              if (!_isLoading)
                button(
                  classes:
                      'p-2 text-dark-muted hover:text-white rounded-lg hover:bg-white/5 transition-all cursor-pointer',
                  onClick: component.onClose,
                  [Component.text('✕')],
                ),
            ]),

            // Form
            div(classes: 'space-y-4 text-left', [
              // Topic Input
              div(classes: 'space-y-1.5', [
                label(classes: 'text-xs font-bold text-dark-muted uppercase tracking-wider', [
                  Component.text('Course Topic'),
                ]),
                input<String>(
                  type: InputType.text,
                  classes:
                      'bg-dark-border/20 border border-dark-border rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-all w-full',
                  value: _topic,
                  onInput: (val) => setState(() => _topic = val),
                  attributes: _isLoading ? {'disabled': ''} : {},
                ),
              ]),

              // Level, Pace, Duration in grid
              div(classes: 'grid grid-cols-1 sm:grid-cols-3 gap-4', [
                // Level Dropdown
                div(classes: 'space-y-1.5', [
                  label(classes: 'text-xs font-bold text-dark-muted uppercase tracking-wider', [
                    Component.text('Difficulty Level'),
                  ]),
                  select(
                    classes:
                        'bg-dark-border/20 border border-dark-border rounded-xl px-3 py-3 text-sm text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-all w-full appearance-none cursor-pointer',
                    onChange: (values) {
                      final val = values.firstOrNull ?? 'beginner';
                      setState(() => _level = val);
                    },
                    attributes: _isLoading ? {'disabled': ''} : {},
                    [
                      option(value: 'beginner', selected: _level == 'beginner', [Component.text('Beginner')]),
                      option(value: 'intermediate', selected: _level == 'intermediate', [
                        Component.text('Intermediate'),
                      ]),
                      option(value: 'expert', selected: _level == 'expert', [Component.text('Expert')]),
                    ],
                  ),
                ]),

                // Pace Dropdown
                div(classes: 'space-y-1.5', [
                  label(classes: 'text-xs font-bold text-dark-muted uppercase tracking-wider', [
                    Component.text('Learning Pace'),
                  ]),
                  select(
                    classes:
                        'bg-dark-border/20 border border-dark-border rounded-xl px-3 py-3 text-sm text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-all w-full appearance-none cursor-pointer',
                    onChange: (values) {
                      final val = values.firstOrNull ?? 'balanced';
                      setState(() => _learningPace = val);
                    },
                    attributes: _isLoading ? {'disabled': ''} : {},
                    [
                      option(value: 'balanced', selected: _learningPace == 'balanced', [Component.text('Balanced')]),
                      option(value: 'fast', selected: _learningPace == 'fast', [Component.text('Fast')]),
                      option(value: 'thorough', selected: _learningPace == 'thorough', [Component.text('Thorough')]),
                    ],
                  ),
                ]),

                // Duration Slider
                div(classes: 'space-y-1.5', [
                  label(classes: 'text-xs font-bold text-dark-muted uppercase tracking-wider', [
                    Component.text('Duration: $_durationWeeks weeks'),
                  ]),
                  input<num>(
                    type: InputType.range,
                    classes: 'w-full accent-primary cursor-pointer',
                    value: _durationWeeks.toString(),
                    onInput: (val) => setState(() => _durationWeeks = val.toInt()),
                    attributes: {
                      'min': '4',
                      'max': '12',
                      'step': '1',
                      if (_isLoading) 'disabled': '',
                    },
                  ),
                  div(classes: 'flex justify-between text-[10px] text-dark-muted', [
                    span([Component.text('4 weeks')]),
                    span([Component.text('12 weeks')]),
                  ]),
                ]),
              ]),

              // Goals text area
              div(classes: 'space-y-1.5', [
                label(classes: 'text-xs font-bold text-dark-muted uppercase tracking-wider', [
                  Component.text('Learning Goals (Comma Separated)'),
                ]),
                textarea(
                  classes:
                      'bg-dark-border/20 border border-dark-border rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-all w-full min-h-[80px]',
                  onInput: (val) => setState(() => _learningGoalsInput = val),
                  attributes: _isLoading ? {'disabled': ''} : {},
                  [Component.text(_learningGoalsInput)],
                ),
              ]),
            ]),

            // Footer Actions
            div(classes: 'flex items-center justify-end gap-3 pt-4 border-t border-dark-border/40', [
              if (!_isLoading)
                button(
                  classes:
                      'px-6 py-2.5 bg-white/5 border border-dark-border rounded-xl text-sm font-semibold text-white hover:bg-white/10 transition-all cursor-pointer',
                  onClick: component.onClose,
                  [Component.text('Cancel')],
                ),
              button(
                classes:
                    'px-6 py-2.5 btn-primary rounded-xl text-sm font-bold shadow-lg shadow-primary/20 flex items-center space-x-2 disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer',
                attributes: (_topic.trim().isEmpty || _isLoading) ? {'disabled': ''} : {},
                onClick: _isLoading ? null : _generateOutline,
                [
                  if (_isLoading)
                    div(
                      classes: 'w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin mr-1.5',
                      [],
                    )
                  else
                    span([Component.text('⚡')]),
                  span([Component.text(_isLoading ? 'Generating...' : 'Generate Outline')]),
                ],
              ),
            ]),
          ],
        ),
      ],
    );
  }
}
