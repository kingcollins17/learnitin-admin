import 'package:json_annotation/json_annotation.dart';

part 'paginated_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class PaginatedData<T> {
  final List<T> items;
  final int total;
  final int page;
  @JsonKey(name: 'per_page')
  final int perPage;
  @JsonKey(name: 'total_pages')
  final int totalPages;

  PaginatedData({
    List<T>? items,
    int? total,
    int? page,
    int? perPage,
    int? totalPages,
  })  : items = items ?? [],
        total = total ?? 0,
        page = page ?? 1,
        perPage = perPage ?? 10,
        totalPages = totalPages ?? 1;

  factory PaginatedData.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$PaginatedDataFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$PaginatedDataToJson(this, toJsonT);
}
