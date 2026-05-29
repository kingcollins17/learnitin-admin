import 'package:json_annotation/json_annotation.dart';

part 'course.g.dart';

@JsonSerializable()
class CourseCategory {
  final String? name;
  final String? description;
  final int? id;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'image_url')
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

@JsonSerializable()
class CourseSubCategory {
  final String? name;
  final String? description;
  @JsonKey(name: 'category_id')
  final int? categoryId;
  final int? id;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'image_url')
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

@JsonSerializable()
class ReviewSummary {
  @JsonKey(name: 'average_rating')
  final double? averageRating;
  @JsonKey(name: 'total_reviews')
  final int? totalReviews;

  const ReviewSummary({
    this.averageRating,
    this.totalReviews,
  });

  factory ReviewSummary.fromJson(Map<String, dynamic> json) => _$ReviewSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewSummaryToJson(this);
}

@JsonSerializable()
class Course {
  final int? id;
  final String? title;
  final String? description;
  final String? duration;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'is_public')
  final bool? isPublic;
  @JsonKey(name: 'category_id')
  final int? categoryId;
  @JsonKey(name: 'sub_category_id')
  final int? subCategoryId;
  @JsonKey(name: 'user_id')
  final int? userId;
  final String? level;
  @JsonKey(name: 'learning_pace')
  final String? learningPace;
  @JsonKey(name: 'total_enrollees')
  final int? totalEnrollees;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  final CourseCategory? category;
  @JsonKey(name: 'sub_category')
  final CourseSubCategory? subCategory;
  @JsonKey(name: 'review_summary')
  final ReviewSummary? reviewSummary;

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
    this.subCategory,
    this.reviewSummary,
  });

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);
  Map<String, dynamic> toJson() => _$CourseToJson(this);
}

@JsonSerializable()
class CategoryCreate {
  final String? name;
  final String? description;
  @JsonKey(name: 'image_url')
  final String? imageUrl;

  const CategoryCreate({this.name, this.description, this.imageUrl});

  factory CategoryCreate.fromJson(Map<String, dynamic> json) => _$CategoryCreateFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryCreateToJson(this);
}

@JsonSerializable()
class CategoryUpdate {
  final String? name;
  final String? description;
  @JsonKey(name: 'image_url')
  final String? imageUrl;

  const CategoryUpdate({this.name, this.description, this.imageUrl});

  factory CategoryUpdate.fromJson(Map<String, dynamic> json) => _$CategoryUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryUpdateToJson(this);
}

@JsonSerializable()
class SubCategoryCreate {
  final String? name;
  final String? description;
  @JsonKey(name: 'category_id')
  final int? categoryId;
  @JsonKey(name: 'image_url')
  final String? imageUrl;

  const SubCategoryCreate({this.name, this.description, this.categoryId, this.imageUrl});

  factory SubCategoryCreate.fromJson(Map<String, dynamic> json) => _$SubCategoryCreateFromJson(json);
  Map<String, dynamic> toJson() => _$SubCategoryCreateToJson(this);
}

@JsonSerializable()
class SubCategoryUpdate {
  final String? name;
  final String? description;
  @JsonKey(name: 'category_id')
  final int? categoryId;
  @JsonKey(name: 'image_url')
  final String? imageUrl;

  const SubCategoryUpdate({this.name, this.description, this.categoryId, this.imageUrl});

  factory SubCategoryUpdate.fromJson(Map<String, dynamic> json) => _$SubCategoryUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$SubCategoryUpdateToJson(this);
}

