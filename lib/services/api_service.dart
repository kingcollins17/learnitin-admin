import 'package:dio/dio.dart';
import 'package:learnitin_admin/models/app_config.dart';
import 'package:retrofit/retrofit.dart';
import 'package:learnitin_admin/models/auth/login_response.dart';
import 'package:learnitin_admin/models/user.dart';
import 'package:learnitin_admin/models/admin_stats.dart';
import 'package:learnitin_admin/models/generic_api_response.dart';
import 'package:learnitin_admin/models/course.dart';
import 'package:learnitin_admin/models/paginated_response.dart';
import 'package:learnitin_admin/models/log_entry.dart';
import 'package:learnitin_admin/models/course_generation.dart';

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

  // MARK: Courses Management
  /// Lists all courses on the platform with pagination and optional filters.
  @GET('/courses')
  Future<GenericApiResponse<PaginatedCourses>> getCourses({
    @Query('page') int? page,
    @Query('per_page') int? perPage,
    @Query('is_public') bool? isPublic,
    @Query('level') String? level,
    @Query('search') String? search,
    @Query('min_enrollees') int? minEnrollees,
    @Query('sort_by_popularity') bool? sortByPopularity,
    @Query('category_id') int? categoryId,
    @Query('sub_category_id') int? subCategoryId,
  });

  /// Generates a personalized course outline using AI.
  @POST('/courses/generate')
  Future<GenericApiResponse<GenerateCoursesResponseData>> generateCourseOutline({
    @Body() required GenerateCoursesRequest body,
  });

  /// Creates a new course from a generated outline.
  @POST('/courses/create')
  Future<GenericApiResponse<Course>> createCourse({
    @Body() required GeneratedCourse body,
    @Query('category_id') int? categoryId,
    @Query('sub_category_id') int? subCategoryId,
    @Query('enroll') bool enroll = false,
    @Query('is_public') bool isPublic = true,
  });

  @PATCH('/courses/{course_id}')
  Future<GenericApiResponse> updateCourse({
    @Path('course_id') required String courseId,
    @Body() required CourseUpdate body,
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

  /// Retrieves system or application logs with pagination and optional level filtering.
  @GET('/logs/')
  Future<GenericApiResponse<List<LogEntry>>> getLogs({
    @Query('page') int? page,
    @Query('per_page') int? perPage,
    @Query('level') String? level,
  });

  /// Clears all system or application logs.
  @DELETE('/logs/')
  Future<GenericApiResponse<dynamic>> clearLogs();

  /// Deletes a specific log entry by its ID.
  @DELETE('/logs/{log_id}')
  Future<GenericApiResponse<dynamic>> deleteLog({
    @Path('log_id') required int logId,
  });

  //MARK: Manage App Configs
  @GET('/app-configs/')
  Future<GenericApiResponse<List<AppConfig>>> getAppConfigs({
    @Query('page') int page = 1,
    @Query('per_page') int perPage = 100,
  });

  @GET('/app-configs/{key}')
  Future<GenericApiResponse<AppConfig>> getAppConfigByKey(@Path('key') String key);

  @POST('/app-configs/')
  Future<GenericApiResponse<AppConfig>> createAppConfig({
    @Body() required CreateAppConfig body,
  });

  @PATCH('/app-configs/{config_id}')
  Future<GenericApiResponse<dynamic>> updateAppConfig({
    @Path('config_id') required int configId,
    @Body() required UpdateAppConfig body,
  });

  @DELETE('/app-configs/{config_id}')
  Future<GenericApiResponse<dynamic>> deleteAppConfig({
    @Path('config_id') required int configId,
  });
  // ------------------------------------------------

  // MARK: Category & Sub Categories Management
  @POST('/courses/categories')
  Future<GenericApiResponse<CourseCategory>> createCategory({
    @Body() required CategoryCreate body,
  });

  @GET('/courses/categories')
  Future<GenericApiResponse<List<CourseCategory>>> getCategories({
    @Query('page') int? page = 1,
    @Query('per_page') int? perPage = 200,
    @Query('search') String? search,
    @Query('sort_by_popularity') bool? sortByPopularity = false,
  });

  @PATCH('/courses/categories/{category_id}')
  Future<GenericApiResponse<CourseCategory>> updateCategory({
    @Path('category_id') required int categoryId,
    @Body() required CategoryUpdate body,
  });

  @DELETE('/courses/categories/{category_id}')
  Future<GenericApiResponse<dynamic>> deleteCategory({
    @Path('category_id') required int categoryId,
  });

  @POST('/courses/sub-categories')
  Future<GenericApiResponse<CourseSubCategory>> createSubCategory({
    @Body() required SubCategoryCreate body,
  });

  @GET('/courses/sub-categories')
  Future<GenericApiResponse<List<CourseSubCategory>>> getSubCategories({
    @Query('page') int? page,
    @Query('per_page') int? perPage,
    @Query('category_id') int? categoryId,
  });

  @PATCH('/courses/sub-categories/{sub_category_id}')
  Future<GenericApiResponse<CourseSubCategory>> updateSubCategory({
    @Path('sub_category_id') required int subCategoryId,
    @Body() required SubCategoryUpdate body,
  });

  @DELETE('/courses/sub-categories/{sub_category_id}')
  Future<GenericApiResponse<dynamic>> deleteSubCategory({
    @Path('sub_category_id') required int subCategoryId,
  });
  // ----------------------------------------------------
}
