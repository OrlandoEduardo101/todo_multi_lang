import 'package:vaden/vaden.dart';

import '../domain/repositories/todo_repository.dart';
import '../dto/todo_dto.dart';
import '../dto/user_dto.dart';
import '../dto/common_dto.dart';
import '../services/user_details_service.dart';

/// Todo Controller - handles todo management
@Api(tag: 'Todos', description: 'Todo management endpoints')
@Controller('/api/todos')
class TodoController {
  TodoController({required this.todoRepository});
  final TodoRepository todoRepository;

  /// GET /api/todos - List todos with pagination and filters
  /// Query params: page, limit, search, completed, sortBy, order, userId
  @ApiOperation(
    summary: 'List todos',
    description: 'Get paginated list of todos with optional filters (search, completed status, sorting)',
  )
  @ApiResponse(
    200,
    description: 'Todos retrieved successfully',
    content: ApiContent(type: 'application/json', schema: TodoPaginatedResponse),
  )
  @ApiResponse(500, description: 'Internal server error')
  @Get('/')
  Future<TodoPaginatedResponse> listTodos(
    @Context('user') CustomUserDetails currentUser,
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('search') String? search,
    @Query('completed') bool? completed,
    @Query('sortBy') String? sortBy,
    @Query('order') String? order,
  ) async {
    try {
      final pageNum = page ?? 1;
      final limitNum = limit ?? 10;
      final sortByField = sortBy ?? 'created_at';
      final sortOrder = order ?? 'desc';

      final todos = await todoRepository.findByUserId(
        currentUser.id,
        page: pageNum,
        limit: limitNum,
        search: search,
        completed: completed,
        sortBy: sortByField,
        order: sortOrder,
      );

      final total = await todoRepository.getTotalCountByUserId(currentUser.id, search: search, completed: completed);

      final hasMore = (pageNum * limitNum) < total;

      return TodoPaginatedResponse(data: todos, page: pageNum, limit: limitNum, total: total, hasMore: hasMore);
    } catch (e) {
      throw ResponseException(500, 'Failed to list todos: ${e.toString()}');
    }
  }

  /// GET /api/todos/:id - Get todo by ID
  @ApiOperation(summary: 'Get todo by ID', description: 'Retrieve detailed information about a specific todo')
  @ApiResponse(
    200,
    description: 'Todo retrieved successfully',
    content: ApiContent(type: 'application/json', schema: TodoProfile),
  )
  @ApiResponse(400, description: 'Invalid todo ID')
  @ApiResponse(404, description: 'Todo not found')
  @ApiResponse(500, description: 'Internal server error')
  @Get('/<id>')
  Future<TodoProfile> getTodoById(@Param('id') int todoId) async {
    try {
      final todo = await todoRepository.findById(todoId);
      if (todo == null) {
        throw const ResponseException(404, 'Todo not found');
      }

      return todo;
    } catch (e) {
      if (e is ResponseException) rethrow;
      throw ResponseException(500, 'Failed to get todo: ${e.toString()}');
    }
  }

  /// POST /api/todos - Create new todo
  /// Query params: userId (required)
  /// Body: { title, description? }
  @ApiOperation(summary: 'Create todo', description: 'Create a new todo item for the authenticated user')
  @ApiResponse(
    201,
    description: 'Todo created successfully',
    content: ApiContent(type: 'application/json', schema: TodoProfile),
  )
  @ApiResponse(400, description: 'Invalid request data')
  @ApiResponse(500, description: 'Internal server error')
  @Post('/')
  Future<TodoProfile> createTodo(@Context('user') CustomUserDetails currentUser, @Body() CreateTodoRequest data) async {
    try {
      return await todoRepository.create(currentUser.id, data);
    } catch (e) {
      throw ResponseException(500, 'Failed to create todo: ${e.toString()}');
    }
  }

  /// PUT /api/todos/:id - Update todo
  /// Body: { title?, description?, completed? }
  @ApiOperation(summary: 'Update todo', description: 'Update todo information (title, description, completed status)')
  @ApiResponse(
    200,
    description: 'Todo updated successfully',
    content: ApiContent(type: 'application/json', schema: TodoProfile),
  )
  @ApiResponse(400, description: 'Invalid todo ID')
  @ApiResponse(404, description: 'Todo not found')
  @ApiResponse(500, description: 'Internal server error')
  @Put('/<id>')
  Future<TodoProfile> updateTodo(@Param('id') int todoId, @Body() UpdateTodoRequest updateData) async {
    try {
      final todo = await todoRepository.update(todoId, updateData);
      if (todo == null) {
        throw const ResponseException(404, 'Todo not found');
      }

      return todo;
    } catch (e) {
      if (e is ResponseException) rethrow;
      throw ResponseException(500, 'Failed to update todo: ${e.toString()}');
    }
  }

  /// DELETE /api/todos/:id - Delete todo (soft delete)
  @ApiOperation(summary: 'Delete todo', description: 'Soft delete a todo item by ID')
  @ApiResponse(
    200,
    description: 'Todo deleted successfully',
    content: ApiContent(type: 'application/json', schema: StatusResponse),
  )
  @ApiResponse(400, description: 'Invalid todo ID')
  @ApiResponse(404, description: 'Todo not found')
  @ApiResponse(500, description: 'Internal server error')
  @Delete('/<id>')
  Future<StatusResponse> deleteTodo(@Param('id') int todoId) async {
    try {
      final deleted = await todoRepository.delete(todoId);
      if (!deleted) {
        throw const ResponseException(404, 'Todo not found');
      }

      return const StatusResponse(message: 'Todo deleted successfully');
    } catch (e) {
      if (e is ResponseException) rethrow;
      throw ResponseException(500, 'Failed to delete todo: ${e.toString()}');
    }
  }
}

/// Status response DTO
