// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AdminStats _$AdminStatsFromJson(Map<String, dynamic> json) => _AdminStats(
  totalUsers: (json['total_users'] as num?)?.toInt(),
  activeUsers: (json['active_users'] as num?)?.toInt(),
  totalSuperusers: (json['total_superusers'] as num?)?.toInt(),
  totalCourses: (json['total_courses'] as num?)?.toInt(),
  totalLessons: (json['total_lessons'] as num?)?.toInt(),
  totalAudioLessons: (json['total_audio_lessons'] as num?)?.toInt(),
);

Map<String, dynamic> _$AdminStatsToJson(_AdminStats instance) =>
    <String, dynamic>{
      'total_users': instance.totalUsers,
      'active_users': instance.activeUsers,
      'total_superusers': instance.totalSuperusers,
      'total_courses': instance.totalCourses,
      'total_lessons': instance.totalLessons,
      'total_audio_lessons': instance.totalAudioLessons,
    };
