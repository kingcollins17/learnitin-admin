// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Course _$CourseFromJson(Map<String, dynamic> json) => Course(
  id: (json['id'] as num?)?.toInt(),
  title: json['title'] as String?,
  description: json['description'] as String?,
  category: json['category'] as String?,
  enrollments: (json['enrollments'] as num?)?.toInt(),
  rating: (json['rating'] as num?)?.toDouble(),
  completionRate: (json['completion_rate'] as num?)?.toDouble(),
  creatorId: (json['creator_id'] as num?)?.toInt(),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$CourseToJson(Course instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'category': instance.category,
  'enrollments': instance.enrollments,
  'rating': instance.rating,
  'completion_rate': instance.completionRate,
  'creator_id': instance.creatorId,
  'created_at': instance.createdAt?.toIso8601String(),
};
