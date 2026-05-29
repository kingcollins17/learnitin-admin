// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_generation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GenerateCoursesRequest _$GenerateCoursesRequestFromJson(
  Map<String, dynamic> json,
) => GenerateCoursesRequest(
  topic: json['topic'] as String?,
  level: json['level'] as String?,
  learningPace: json['learning_pace'] as String?,
  durationPreference: json['duration_preference'] as String?,
  learningGoals: (json['learning_goals'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$GenerateCoursesRequestToJson(
  GenerateCoursesRequest instance,
) => <String, dynamic>{
  'topic': instance.topic,
  'level': instance.level,
  'learning_pace': instance.learningPace,
  'duration_preference': instance.durationPreference,
  'learning_goals': instance.learningGoals,
};

GenerateCoursesResponseData _$GenerateCoursesResponseDataFromJson(
  Map<String, dynamic> json,
) => GenerateCoursesResponseData(
  courses: (json['courses'] as List<dynamic>?)
      ?.map((e) => GeneratedCourse.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GenerateCoursesResponseDataToJson(
  GenerateCoursesResponseData instance,
) => <String, dynamic>{'courses': instance.courses};

GeneratedCourse _$GeneratedCourseFromJson(Map<String, dynamic> json) =>
    GeneratedCourse(
      title: json['title'] as String?,
      description: json['description'] as String?,
      duration: json['duration'] as String?,
      level: json['level'] as String?,
      outline: (json['outline'] as List<dynamic>?)
          ?.map((e) => GeneratedOutlineItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GeneratedCourseToJson(GeneratedCourse instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'duration': instance.duration,
      'level': instance.level,
      'outline': instance.outline,
    };

GeneratedOutlineItem _$GeneratedOutlineItemFromJson(
  Map<String, dynamic> json,
) => GeneratedOutlineItem(
  title: json['title'] as String?,
  description: json['description'] as String?,
  duration: json['duration'] as String?,
  objectives: (json['objectives'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  lessons: (json['lessons'] as List<dynamic>?)
      ?.map((e) => GeneratedLesson.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GeneratedOutlineItemToJson(
  GeneratedOutlineItem instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'duration': instance.duration,
  'objectives': instance.objectives,
  'lessons': instance.lessons,
};

GeneratedLesson _$GeneratedLessonFromJson(Map<String, dynamic> json) =>
    GeneratedLesson(
      title: json['title'] as String?,
      objectives: (json['objectives'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      description: json['description'] as String?,
      duration: json['duration'] as String?,
      creditCost: (json['credit_cost'] as num?)?.toInt(),
      audioCreditCost: (json['audio_credit_cost'] as num?)?.toInt(),
      quizCreditCost: (json['quiz_credit_cost'] as num?)?.toInt(),
    );

Map<String, dynamic> _$GeneratedLessonToJson(GeneratedLesson instance) =>
    <String, dynamic>{
      'title': instance.title,
      'objectives': instance.objectives,
      'description': instance.description,
      'duration': instance.duration,
      'credit_cost': instance.creditCost,
      'audio_credit_cost': instance.audioCreditCost,
      'quiz_credit_cost': instance.quizCreditCost,
    };
