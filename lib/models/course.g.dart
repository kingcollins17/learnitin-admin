// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseCategory _$CourseCategoryFromJson(Map<String, dynamic> json) =>
    CourseCategory(
      name: json['name'] as String?,
      description: json['description'] as String?,
      id: (json['id'] as num?)?.toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      imageUrl: json['image_url'] as String?,
      popularityScore: (json['popularity_score'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$CourseCategoryToJson(CourseCategory instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'id': instance.id,
      'created_at': instance.createdAt?.toIso8601String(),
      'image_url': instance.imageUrl,
      'popularity_score': instance.popularityScore,
    };

CourseSubCategory _$CourseSubCategoryFromJson(Map<String, dynamic> json) =>
    CourseSubCategory(
      name: json['name'] as String?,
      description: json['description'] as String?,
      categoryId: (json['category_id'] as num?)?.toInt(),
      id: (json['id'] as num?)?.toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      imageUrl: json['image_url'] as String?,
      popularityScore: (json['popularity_score'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$CourseSubCategoryToJson(CourseSubCategory instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'category_id': instance.categoryId,
      'id': instance.id,
      'created_at': instance.createdAt?.toIso8601String(),
      'image_url': instance.imageUrl,
      'popularity_score': instance.popularityScore,
    };

ReviewSummary _$ReviewSummaryFromJson(Map<String, dynamic> json) =>
    ReviewSummary(
      averageRating: (json['average_rating'] as num?)?.toDouble(),
      totalReviews: (json['total_reviews'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ReviewSummaryToJson(ReviewSummary instance) =>
    <String, dynamic>{
      'average_rating': instance.averageRating,
      'total_reviews': instance.totalReviews,
    };

Course _$CourseFromJson(Map<String, dynamic> json) => Course(
  id: (json['id'] as num?)?.toInt(),
  title: json['title'] as String?,
  description: json['description'] as String?,
  duration: json['duration'] as String?,
  imageUrl: json['image_url'] as String?,
  isPublic: json['is_public'] as bool?,
  categoryId: (json['category_id'] as num?)?.toInt(),
  subCategoryId: (json['sub_category_id'] as num?)?.toInt(),
  userId: (json['user_id'] as num?)?.toInt(),
  level: json['level'] as String?,
  learningPace: json['learning_pace'] as String?,
  totalEnrollees: (json['total_enrollees'] as num?)?.toInt(),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  category: json['category'] == null
      ? null
      : CourseCategory.fromJson(json['category'] as Map<String, dynamic>),
  popularityScore: (json['popularity_score'] as num?)?.toDouble(),
  subCategory: json['sub_category'] == null
      ? null
      : CourseSubCategory.fromJson(
          json['sub_category'] as Map<String, dynamic>,
        ),
  reviewSummary: json['review_summary'] == null
      ? null
      : ReviewSummary.fromJson(json['review_summary'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CourseToJson(Course instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'duration': instance.duration,
  'image_url': instance.imageUrl,
  'is_public': instance.isPublic,
  'category_id': instance.categoryId,
  'sub_category_id': instance.subCategoryId,
  'user_id': instance.userId,
  'level': instance.level,
  'learning_pace': instance.learningPace,
  'total_enrollees': instance.totalEnrollees,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'category': instance.category,
  'sub_category': instance.subCategory,
  'review_summary': instance.reviewSummary,
  'popularity_score': instance.popularityScore,
};

CourseUpdate _$CourseUpdateFromJson(Map<String, dynamic> json) => CourseUpdate(
  title: json['title'] as String?,
  description: json['description'] as String?,
  imageUrl: json['image_url'] as String?,
  duration: json['duration'] as String?,
  categoryId: (json['category_id'] as num?)?.toInt(),
  subCategoryId: (json['sub_category_id'] as num?)?.toInt(),
  popularityScore: (json['popularity_score'] as num?)?.toDouble(),
);

Map<String, dynamic> _$CourseUpdateToJson(CourseUpdate instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'image_url': instance.imageUrl,
      'duration': instance.duration,
      'category_id': instance.categoryId,
      'sub_category_id': instance.subCategoryId,
      'popularity_score': instance.popularityScore,
    };

CategoryCreate _$CategoryCreateFromJson(Map<String, dynamic> json) =>
    CategoryCreate(
      name: json['name'] as String?,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      popularityScore: (json['popularity_score'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$CategoryCreateToJson(CategoryCreate instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'image_url': instance.imageUrl,
      'popularity_score': instance.popularityScore,
    };

CategoryUpdate _$CategoryUpdateFromJson(Map<String, dynamic> json) =>
    CategoryUpdate(
      name: json['name'] as String?,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      popularityScore: (json['popularity_score'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$CategoryUpdateToJson(CategoryUpdate instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'image_url': instance.imageUrl,
      'popularity_score': instance.popularityScore,
    };

SubCategoryCreate _$SubCategoryCreateFromJson(Map<String, dynamic> json) =>
    SubCategoryCreate(
      name: json['name'] as String?,
      description: json['description'] as String?,
      categoryId: (json['category_id'] as num?)?.toInt(),
      imageUrl: json['image_url'] as String?,
      popularityScore: (json['popularity_score'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$SubCategoryCreateToJson(SubCategoryCreate instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'category_id': instance.categoryId,
      'image_url': instance.imageUrl,
      'popularity_score': instance.popularityScore,
    };

SubCategoryUpdate _$SubCategoryUpdateFromJson(Map<String, dynamic> json) =>
    SubCategoryUpdate(
      name: json['name'] as String?,
      description: json['description'] as String?,
      categoryId: (json['category_id'] as num?)?.toInt(),
      imageUrl: json['image_url'] as String?,
      popularityScore: (json['popularity_score'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$SubCategoryUpdateToJson(SubCategoryUpdate instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'category_id': instance.categoryId,
      'image_url': instance.imageUrl,
      'popularity_score': instance.popularityScore,
    };
