import 'package:json_annotation/json_annotation.dart';

part 'course_generation.g.dart';

@JsonSerializable()
class GenerateCoursesRequest {
  final String? topic;
  final String? level;
  @JsonKey(name: 'learning_pace')
  final String? learningPace;
  @JsonKey(name: 'duration_preference')
  final String? durationPreference;
  @JsonKey(name: 'learning_goals')
  final List<String>? learningGoals;

  GenerateCoursesRequest({
    this.topic,
    this.level,
    this.learningPace,
    this.durationPreference,
    this.learningGoals,
  });

  factory GenerateCoursesRequest.fromJson(Map<String, dynamic> json) => _$GenerateCoursesRequestFromJson(json);
  Map<String, dynamic> toJson() => _$GenerateCoursesRequestToJson(this);
}

@JsonSerializable()
class GenerateCoursesResponseData {
  final List<GeneratedCourse>? courses;

  GenerateCoursesResponseData({this.courses});

  factory GenerateCoursesResponseData.fromJson(Map<String, dynamic> json) => _$GenerateCoursesResponseDataFromJson(json);
  Map<String, dynamic> toJson() => _$GenerateCoursesResponseDataToJson(this);
}

@JsonSerializable()
class GeneratedCourse {
  final String? title;
  final String? description;
  final String? duration;
  final String? level;
  final List<GeneratedOutlineItem>? outline;

  GeneratedCourse({
    this.title,
    this.description,
    this.duration,
    this.level,
    this.outline,
  });

  factory GeneratedCourse.fromJson(Map<String, dynamic> json) => _$GeneratedCourseFromJson(json);
  Map<String, dynamic> toJson() => _$GeneratedCourseToJson(this);
}

@JsonSerializable()
class GeneratedOutlineItem {
  final String? title;
  final String? description;
  final String? duration;
  final List<String>? objectives;
  final List<GeneratedLesson>? lessons;

  GeneratedOutlineItem({
    this.title,
    this.description,
    this.duration,
    this.objectives,
    this.lessons,
  });

  factory GeneratedOutlineItem.fromJson(Map<String, dynamic> json) => _$GeneratedOutlineItemFromJson(json);
  Map<String, dynamic> toJson() => _$GeneratedOutlineItemToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GeneratedLesson {
  final String? title;
  final List<String>? objectives;
  final String? description;
  final String? duration;
  final int? creditCost;
  final int? audioCreditCost;
  final int? quizCreditCost;

  GeneratedLesson({
    this.title,
    this.objectives,
    this.description,
    this.duration,
    this.creditCost,
    this.audioCreditCost,
    this.quizCreditCost,
  });

  factory GeneratedLesson.fromJson(Map<String, dynamic> json) => _$GeneratedLessonFromJson(json);
  Map<String, dynamic> toJson() => _$GeneratedLessonToJson(this);
}
