import 'package:freezed_annotation/freezed_annotation.dart';

part 'log_entry.freezed.dart';
part 'log_entry.g.dart';

@freezed
abstract class LogEntry with _$LogEntry {
  const factory LogEntry({
    int? id,
    String? level,
    String? message,
    Map<String, dynamic>? data,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _LogEntry;

  factory LogEntry.fromJson(Map<String, dynamic> json) => _$LogEntryFromJson(json);
}
