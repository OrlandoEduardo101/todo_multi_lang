/// Global paginated response interface for concrete DTOs.
/// Do NOT annotate this with @DTO to avoid generic codegen issues.
abstract class PaginatedResponse<T> {
  List<T> get data;
  int get page;
  int get limit;
  int get total;
  bool get hasMore;
}
