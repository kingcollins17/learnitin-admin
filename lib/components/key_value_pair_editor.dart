import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// A component allowing interactive creation and modification of key-value maps.
/// Primarily useful for metadata parameter blocks or key-value entries.
class KeyValuePairEditor extends StatefulComponent {
  /// Initial data to pre-populate the editor.
  final Map<String, dynamic> initialData;

  /// Callback fired whenever a key or value is edited or removed.
  final ValueChanged<Map<String, dynamic>> onChange;

  /// Optional label/header to display above the editor.
  final String? label;

  const KeyValuePairEditor({
    required this.onChange,
    this.initialData = const {},
    this.label,
    super.key,
  });

  @override
  State<KeyValuePairEditor> createState() => _KeyValuePairEditorState();
}

class _KeyValuePairEditorState extends State<KeyValuePairEditor> {
  late List<MapEntry<String, String>> _pairs;

  @override
  void initState() {
    super.initState();
    _pairs = component.initialData.entries.map((e) => MapEntry(e.key, e.value.toString())).toList();
    if (_pairs.isEmpty) {
      _pairs.add(const MapEntry('', ''));
    }
  }

  void _notifyChanges() {
    final Map<String, dynamic> map = {};
    for (final pair in _pairs) {
      final key = pair.key.trim();
      final val = pair.value.trim();
      if (key.isNotEmpty) {
        map[key] = val;
      }
    }
    component.onChange(map);
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'space-y-3', [
      if (component.label != null)
        label(classes: 'text-xs font-semibold uppercase tracking-wider text-dark-muted block mb-1', [
          Component.text(component.label!),
        ]),
      div(classes: 'space-y-2.5', [
        for (int i = 0; i < _pairs.length; i++)
          div(classes: 'flex items-center gap-3 w-full', [
            // Key Field
            div(classes: 'flex-1', [
              input<String>(
                type: InputType.text,
                classes:
                    'w-full bg-dark-bg border border-dark-border rounded-xl px-4 py-2.5 text-sm text-white focus:outline-none focus:border-primary/50 transition-all placeholder-dark-muted/40',
                value: _pairs[i].key,
                // placeholder: 'Key',
                onInput: (val) {
                  _pairs[i] = MapEntry(val, _pairs[i].value);
                  _notifyChanges();
                },
              ),
            ]),
            // Value Field
            div(classes: 'flex-1', [
              input<String>(
                type: InputType.text,
                classes:
                    'w-full bg-dark-bg border border-dark-border rounded-xl px-4 py-2.5 text-sm text-white focus:outline-none focus:border-primary/50 transition-all placeholder-dark-muted/40',
                value: _pairs[i].value,
                // placeholder: 'Value',
                onInput: (val) {
                  _pairs[i] = MapEntry(_pairs[i].key, val);
                  _notifyChanges();
                },
              ),
            ]),
            // Delete Action
            button(
              classes:
                  'p-3 bg-red-500/10 border border-red-500/20 text-red-400 hover:bg-red-500/20 rounded-xl transition-all cursor-pointer flex items-center justify-center shrink-0',
              onClick: () {
                setState(() {
                  _pairs.removeAt(i);
                  if (_pairs.isEmpty) {
                    _pairs.add(const MapEntry('', ''));
                  }
                  _notifyChanges();
                });
              },
              [Component.text('🗑️')],
            ),
          ]),
      ]),
      // Add row action
      button(
        classes:
            'px-4 py-2 bg-white/5 border border-dark-border hover:bg-white/10 text-white rounded-xl text-xs font-semibold transition-all flex items-center space-x-2 cursor-pointer',
        onClick: () {
          setState(() {
            _pairs.add(const MapEntry('', ''));
          });
        },
        [
          span([Component.text('➕')]),
          span([Component.text('Add New Row')]),
        ],
      ),
    ]);
  }
}
