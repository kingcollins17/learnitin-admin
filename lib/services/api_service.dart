import 'package:dio/dio.dart';
import 'package:learnitin_admin/models/course.dart';
import 'package:retrofit/retrofit.dart';
import 'package:learnitin_admin/models/auth/login_response.dart';
import 'package:learnitin_admin/models/user.dart';
import 'package:learnitin_admin/models/admin_stats.dart';
import 'package:learnitin_admin/models/generic_api_response.dart';
import 'package:learnitin_admin/models/course.dart';
import 'package:learnitin_admin/models/paginated_response.dart';

part 'api_service.g.dart';

/// Main API service for the LearnItIn Admin application.
///
/// Handles authentication, user management, course oversight, and administrative statistics.
@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  /// Authenticates a user with the platform.
  ///
  /// Returns a [LoginResponse] containing the access token and basic user status.
  @POST('/auth/login')
  @FormUrlEncoded()
  Future<LoginResponse> login({
    @Field('username') required String username,
    @Field('password') required String password,
  });

  /// Retrieves the profile of the currently authenticated administrator.
  @GET('/users/me')
  Future<GenericApiResponse<User>> getCurrentUser();

  /// Retrieves high-level platform statistics (e.g., total users, active users) for the dashboard.
  @GET('/admin/stats')
  Future<GenericApiResponse<AdminStats>> getAdminStats();

  /// Lists platform users with advanced filtering and pagination.
  ///
  /// Supports filtering by activity status, role, and registration date range.
  @GET('/admin/users')
  Future<GenericApiResponse<PaginatedData<User>>> adminListUsers({
    @Query('page') int? page,
    @Query('per_page') int? perPage,
    @Query('search') String? search,
    @Query('is_active') bool? isActive,
    @Query('is_superuser') bool? isSuperuser,
    @Query('created_after') String? createdAfter,
    @Query('created_before') String? createdBefore,
  });

  /// Retrieves detailed information for a specific user, including their full subscription profile.
  @GET('/admin/users/{user_id}')
  Future<GenericApiResponse<User>> getUserDetail({
    @Path('user_id') required int userId,
  });

  /// Bans a user by deactivating their account.
  ///
  /// The [body] should contain a 'reason' (string) explaining the ban.
  @POST('/admin/users/{user_id}/ban')
  Future<GenericApiResponse<dynamic>> banUser({
    @Path('user_id') required int userId,
    @Body() required Map<String, dynamic> body,
  });

  /// Unbans a user by reactivating their platform access.
  @POST('/admin/users/{user_id}/unban')
  Future<GenericApiResponse<dynamic>> unbanUser({
    @Path('user_id') required int userId,
  });

  /// Manually grants a premium subscription to a user without requiring Google Play.
  ///
  /// The [body] must include:
  /// * `duration_days`: Number of days to grant (default: 30)
  /// * `product_id`: The ID of the subscription tier
  @POST('/admin/users/{user_id}/grant-premium')
  Future<GenericApiResponse<dynamic>> grantPremium({
    @Path('user_id') required int userId,
    @Body() required Map<String, dynamic> body,
  });

  /// Immediately revokes a user's current premium subscription.
  @POST('/admin/users/{user_id}/revoke-premium')
  Future<GenericApiResponse<dynamic>> revokePremium({
    @Path('user_id') required int userId,
  });

  // ...
  /// Lists all courses on the platform with pagination and optional filtering by creator ID.
  @GET('/admin/courses')
  Future<GenericApiResponse<PaginatedData<Course>>> adminListCourses({
    @Query('page') int? page,
    @Query('per_page') int? perPage,
    @Query('creator_id') int? creatorId,
  });

  /// Sends a notification to a single user.
  @POST('/admin/notifications/send')
  Future<GenericApiResponse<dynamic>> notifyUser({
    @Body() required Map<String, dynamic> body,
  });

  /// Sends notifications to a list of users.
  @POST('/admin/notifications/send-bulk')
  Future<GenericApiResponse<dynamic>> notifyUsersBulk({
    @Body() required Map<String, dynamic> body,
  });

  /// Broadcasts a notification to all active users.
  @POST('/admin/notifications/broadcast')
  Future<GenericApiResponse<dynamic>> broadcastNotification({
    @Body() required Map<String, dynamic> body,
  });
}
