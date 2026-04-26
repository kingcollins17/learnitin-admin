import 'package:json_annotation/json_annotation.dart';

part 'course.g.dart';

@JsonSerializable()
class Course {
  final int? id;
  final String? title;
  final String? description;
  final String? category;
  final int? enrollments;
  final double? rating;
  @JsonKey(name: 'completion_rate')
  final double? completionRate;
  @JsonKey(name: 'creator_id')
  final int? creatorId;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  const Course({
    this.id,
    this.title,
    this.description,
    this.category,
    this.enrollments,
    this.rating,
    this.completionRate,
    this.creatorId,
    this.createdAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);
  Map<String, dynamic> toJson() => _$CourseToJson(this);
}
