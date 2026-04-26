import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class Counter extends StatefulComponent {
  const Counter({super.key});

  @override
  State<Counter> createState() => CounterState();
}

class CounterState extends State<Counter> {
  int count = 0;

  @override
  Component build(BuildContext context) {
    return div(classes: 'flex flex-col items-center space-y-4', [
      span(classes: 'text-sm text-dark-muted font-medium', [Component.text('Session Count')]),
      div(classes: 'flex items-center space-x-6', [
        button(
          classes: 'w-10 h-10 flex items-center justify-center rounded-full border border-dark-border hover:bg-white/10 text-white transition-all',
          onClick: () {
            setState(() => count--);
          },
          [Component.text('-')],
        ),
        span(classes: 'text-4xl font-mono font-bold text-primary min-w-[3ch] text-center', [Component.text('$count')]),
        button(
          classes: 'w-10 h-10 flex items-center justify-center rounded-full bg-primary/20 border border-primary/50 hover:bg-primary/30 text-primary transition-all',
          onClick: () {
            setState(() => count++);
          },
          [Component.text('+')],
        ),
      ]),
    ]);
  }
}
