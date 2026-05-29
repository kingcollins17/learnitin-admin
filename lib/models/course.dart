import 'package:json_annotation/json_annotation.dart';

part 'course.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class CourseCategory {
  final String? name;
  final String? description;
  final int? id;
  final DateTime? createdAt;
  final String? imageUrl;

  const CourseCategory({
    this.name,
    this.description,
    this.id,
    this.createdAt,
    this.imageUrl,
  });

  factory CourseCategory.fromJson(Map<String, dynamic> json) => _$CourseCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CourseCategoryToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CourseSubCategory {
  final String? name;
  final String? description;
  final int? categoryId;
  final int? id;
  final DateTime? createdAt;
  final String? imageUrl;

  const CourseSubCategory({
    this.name,
    this.description,
    this.categoryId,
    this.id,
    this.createdAt,
    this.imageUrl,
  });

  factory CourseSubCategory.fromJson(Map<String, dynamic> json) => _$CourseSubCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CourseSubCategoryToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ReviewSummary {
  final double? averageRating;
  final int? totalReviews;

  const ReviewSummary({
    this.averageRating,
    this.totalReviews,
  });

  factory ReviewSummary.fromJson(Map<String, dynamic> json) => _$ReviewSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewSummaryToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Course {
  final int? id;
  final String? title;
  final String? description;
  final String? duration;
  final String? imageUrl;
  final bool? isPublic;
  final int? categoryId;
  final int? subCategoryId;
  final int? userId;
  final String? level;
  final String? learningPace;
  final int? totalEnrollees;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final CourseCategory? category;
  final CourseSubCategory? subCategory;
  final ReviewSummary? reviewSummary;
  final double? popularityScore;

  const Course({
    this.id,
    this.title,
    this.description,
    this.duration,
    this.imageUrl,
    this.isPublic,
    this.categoryId,
    this.subCategoryId,
    this.userId,
    this.level,
    this.learningPace,
    this.totalEnrollees,
    this.createdAt,
    this.updatedAt,
    this.category,
    this.popularityScore,
    this.subCategory,
    this.reviewSummary,
  });

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);
  Map<String, dynamic> toJson() => _$CourseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CourseUpdate {
  final String? title, description, imageUrl, duration;
  final int? categoryId, subCategoryId;
  final double? popularityScore;

  CourseUpdate({
    this.title,
    this.description,
    this.imageUrl,
    this.duration,
    this.categoryId,
    this.subCategoryId,
    this.popularityScore,
  });
  factory CourseUpdate.fromJson(Map<String, dynamic> json) => _$CourseUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$CourseUpdateToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CategoryCreate {
  final String? name;
  final String? description;
  final String? imageUrl;
  final double? popularityScore;

  const CategoryCreate({this.name, this.description, this.imageUrl, this.popularityScore});

  factory CategoryCreate.fromJson(Map<String, dynamic> json) => _$CategoryCreateFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryCreateToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CategoryUpdate {
  final String? name;
  final String? description;
  final String? imageUrl;
  final double? popularityScore;
  const CategoryUpdate({
    this.name,
    this.description,
    this.imageUrl,
    this.popularityScore,
  });

  factory CategoryUpdate.fromJson(Map<String, dynamic> json) => _$CategoryUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryUpdateToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SubCategoryCreate {
  final String? name;
  final String? description;
  final int? categoryId;
  final String? imageUrl;

  const SubCategoryCreate({
    this.name,
    this.description,
    this.categoryId,
    this.imageUrl,
  });

  factory SubCategoryCreate.fromJson(Map<String, dynamic> json) => _$SubCategoryCreateFromJson(json);
  Map<String, dynamic> toJson() => _$SubCategoryCreateToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SubCategoryUpdate {
  final String? name;
  final String? description;
  final int? categoryId;
  final String? imageUrl;

  const SubCategoryUpdate({this.name, this.description, this.categoryId, this.imageUrl});

  factory SubCategoryUpdate.fromJson(Map<String, dynamic> json) => _$SubCategoryUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$SubCategoryUpdateToJson(this);
}
