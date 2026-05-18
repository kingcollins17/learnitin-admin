import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// A interactive JSON viewer widget that formats a Map,
/// allowing deep nested objects and lists to be collapsed and expanded.
class JsonViewer extends StatefulComponent {
  final Map<String, dynamic> data;
  final int depth;

  const JsonViewer({
    super.key,
    required this.data,
    this.depth = 0,
  });

  @override
  State<JsonViewer> createState() => _JsonViewerState();
}

class _JsonViewerState extends State<JsonViewer> {
  // Set to keep track of expanded keys
  final Set<String> _expandedKeys = {};

  void _toggleKey(String key) {
    setState(() {
      if (_expandedKeys.contains(key)) {
        _expandedKeys.remove(key);
      } else {
        _expandedKeys.add(key);
      }
    });
  }

  @override
  Component build(BuildContext context) {
    if (component.data.isEmpty) {
      return span(classes: 'text-dark-muted font-mono text-xs italic', [Component.text('{ }')]);
    }

    final indentClass = component.depth == 0 ? '' : 'pl-4 border-l border-white/5 ml-2.5';

    return div(classes: 'font-mono text-xs space-y-1.5 $indentClass', [
      for (final entry in component.data.entries)
        _buildItem(entry.key, entry.value),
    ]);
  }

  Component _buildItem(String key, dynamic value) {
    final cleanKey = '${component.depth}_$key';

    if (value is Map<String, dynamic>) {
      final isExpanded = _expandedKeys.contains(cleanKey);
      return div(classes: 'space-y-1', [
        div(
          classes: 'flex items-center space-x-2 cursor-pointer hover:bg-white/[0.04] py-0.5 rounded px-2 -mx-2 select-none transition-colors duration-150',
          events: {'click': (e) => _toggleKey(cleanKey)},
          [
            span(
              classes: 'text-dark-muted text-[10px] w-3 flex items-center justify-center transition-transform duration-200 ${isExpanded ? "rotate-90" : ""}',
              [Component.text('▶')],
            ),
            span(classes: 'text-primary font-semibold', [Component.text('"$key"')]),
            span(classes: 'text-dark-muted', [Component.text(': { ... }')]),
          ],
        ),
        if (isExpanded)
          div(classes: 'mt-1', [
            JsonViewer(data: value, depth: component.depth + 1),
          ]),
      ]);
    } else if (value is List) {
      final isExpanded = _expandedKeys.contains(cleanKey);
      // Map the list indices to a key-value format for recursive rendering
      final listMap = <String, dynamic>{};
      for (var i = 0; i < value.length; i++) {
        listMap['$i'] = value[i];
      }

      return div(classes: 'space-y-1', [
        div(
          classes: 'flex items-center space-x-2 cursor-pointer hover:bg-white/[0.04] py-0.5 rounded px-2 -mx-2 select-none transition-colors duration-150',
          events: {'click': (e) => _toggleKey(cleanKey)},
          [
            span(
              classes: 'text-dark-muted text-[10px] w-3 flex items-center justify-center transition-transform duration-200 ${isExpanded ? "rotate-90" : ""}',
              [Component.text('▶')],
            ),
            span(classes: 'text-purple-400 font-semibold', [Component.text('"$key"')]),
            span(classes: 'text-dark-muted', [Component.text(': [ ... ] (${value.length} items)')]),
          ],
        ),
        if (isExpanded)
          div(classes: 'mt-1', [
            JsonViewer(data: listMap, depth: component.depth + 1),
          ]),
      ]);
    } else {
      return div(classes: 'flex items-baseline space-x-2 py-0.5 px-2', [
        span(classes: 'w-3', []), // Aligns with expansion arrows
        span(classes: 'text-dark-muted/80', [Component.text('"$key"')]),
        span(classes: 'text-dark-muted/60', [Component.text(':')]),
        _buildPrimitiveValue(value),
      ]);
    }
  }

  Component _buildPrimitiveValue(dynamic value) {
    if (value == null) {
      return span(classes: 'text-red-400/90 font-bold', [Component.text('null')]);
    } else if (value is String) {
      return span(classes: 'text-emerald-400 break-all', [Component.text('"$value"')]);
    } else if (value is num) {
      return span(classes: 'text-amber-400', [Component.text(value.toString())]);
    } else if (value is bool) {
      return span(classes: 'text-cyan-400 font-semibold', [Component.text(value.toString())]);
    } else {
      return span(classes: 'text-white/90', [Component.text(value.toString())]);
    }
  }
}
