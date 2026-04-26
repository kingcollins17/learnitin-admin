// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  email: json['email'] as String?,
  username: json['username'] as String?,
  fullName: json['full_name'] as String?,
  id: (json['id'] as num?)?.toInt(),
  isActive: json['is_active'] as bool?,
  isSuperuser: json['is_superuser'] as bool?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  subscription: json['subscription'] == null
      ? null
      : Subscription.fromJson(json['subscription'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'email': instance.email,
  'username': instance.username,
  'full_name': instance.fullName,
  'id': instance.id,
  'is_active': instance.isActive,
  'is_superuser': instance.isSuperuser,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'subscription': instance.subscription,
};

_Subscription _$SubscriptionFromJson(Map<String, dynamic> json) =>
    _Subscription(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['user_id'] as num?)?.toInt(),
      productId: json['product_id'] as String?,
      status: json['status'] as String?,
      expiryTime: json['expiry_time'] == null
          ? null
          : DateTime.parse(json['expiry_time'] as String),
      autoRenew: json['auto_renew'] as bool?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      usage: json['usage'] == null
          ? null
          : Usage.fromJson(json['usage'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SubscriptionToJson(_Subscription instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'product_id': instance.productId,
      'status': instance.status,
      'expiry_time': instance.expiryTime?.toIso8601String(),
      'auto_renew': instance.autoRenew,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'usage': instance.usage,
    };

_Usage _$UsageFromJson(Map<String, dynamic> json) => _Usage(
  id: (json['id'] as num?)?.toInt(),
  subscriptionId: (json['subscription_id'] as num?)?.toInt(),
  year: (json['year'] as num?)?.toInt(),
  month: (json['month'] as num?)?.toInt(),
  learningJourneysUsed: (json['learning_journeys_used'] as num?)?.toInt(),
  lessonsUsed: (json['lessons_used'] as num?)?.toInt(),
  audioLessonsUsed: (json['audio_lessons_used'] as num?)?.toInt(),
);

Map<String, dynamic> _$UsageToJson(_Usage instance) => <String, dynamic>{
  'id': instance.id,
  'subscription_id': instance.subscriptionId,
  'year': instance.year,
  'month': instance.month,
  'learning_journeys_used': instance.learningJourneysUsed,
  'lessons_used': instance.lessonsUsed,
  'audio_lessons_used': instance.audioLessonsUsed,
};
