import 'package:json_annotation/json_annotation.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  @JsonKey(name: 'access_token')
  final String? accessToken;
  
  @JsonKey(name: 'token_type')
  final String? tokenType;
  
  @JsonKey(name: 'user_id')
  final int? userId;
  
  final String? email;
  final String? username;
  
  @JsonKey(name: 'is_active')
  final bool? isActive;

  LoginResponse({
    this.accessToken,
    this.tokenType,
    this.userId,
    this.email,
    this.username,
    this.isActive,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}
