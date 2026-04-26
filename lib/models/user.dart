import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    String? email,
    String? username,
    @JsonKey(name: 'full_name') String? fullName,
    int? id,
    @JsonKey(name: 'is_active') bool? isActive,
    @JsonKey(name: 'is_superuser') bool? isSuperuser,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    Subscription? subscription,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
abstract class Subscription with _$Subscription {
  const factory Subscription({
    int? id,
    @JsonKey(name: 'user_id') int? userId,
    @JsonKey(name: 'product_id') String? productId,
    String? status,
    @JsonKey(name: 'expiry_time') DateTime? expiryTime,
    @JsonKey(name: 'auto_renew') bool? autoRenew,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    Usage? usage,
  }) = _Subscription;

  factory Subscription.fromJson(Map<String, dynamic> json) => _$SubscriptionFromJson(json);
}

@freezed
abstract class Usage with _$Usage {
  const factory Usage({
    int? id,
    @JsonKey(name: 'subscription_id') int? subscriptionId,
    int? year,
    int? month,
    @JsonKey(name: 'learning_journeys_used') int? learningJourneysUsed,
    @JsonKey(name: 'lessons_used') int? lessonsUsed,
    @JsonKey(name: 'audio_lessons_used') int? audioLessonsUsed,
  }) = _Usage;

  factory Usage.fromJson(Map<String, dynamic> json) => _$UsageFromJson(json);
}
