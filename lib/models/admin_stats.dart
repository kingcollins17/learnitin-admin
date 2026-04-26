import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_stats.freezed.dart';
part 'admin_stats.g.dart';

@freezed
abstract class AdminStats with _$AdminStats {
  const factory AdminStats({
    @JsonKey(name: 'total_users') int? totalUsers,
    @JsonKey(name: 'active_users') int? activeUsers,
    @JsonKey(name: 'total_superusers') int? totalSuperusers,
    @JsonKey(name: 'total_courses') int? totalCourses,
    @JsonKey(name: 'total_lessons') int? totalLessons,
    @JsonKey(name: 'total_audio_lessons') int? totalAudioLessons,
  }) = _AdminStats;

  factory AdminStats.fromJson(Map<String, dynamic> json) => _$AdminStatsFromJson(json);
}
