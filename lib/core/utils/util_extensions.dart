import 'dart:convert';
import 'package:jaspr/jaspr.dart';

extension ObjectLogger on Object? {
  /// Logs the object to the console in a pretty JSON format if in debug mode.
  /// 
  /// Attempts to call `toJson()` if the object supports it.
  /// Falls back to `toString()` if JSON encoding fails.
  void debugLog() {
    if (kDebugMode) {
      if (this == null) {
        print('[DEBUG] null');
        return;
      }

      try {
        const encoder = JsonEncoder.withIndent('  ');
        
        dynamic jsonValue;
        try {
          // Attempt to call toJson if available via dynamic dispatch
          jsonValue = (this as dynamic).toJson();
        } catch (_) {
          // Fallback to the object itself
          jsonValue = this;
        }

        // Attempt pretty print
        final output = encoder.convert(jsonValue);
        print('[DEBUG] $output');
      } catch (_) {
        // Final fallback to toString
        print('[DEBUG] $this');
      }
    }
  }
}
