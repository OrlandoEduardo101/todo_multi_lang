import 'package:vaden/vaden.dart';

import '../domain/repositories/user_repository.dart';
import '../dto/todo_dto.dart';
import '../dto/user_dto.dart';

/// User Controller - handles user management
@Api(tag: 'Users', description: 'User management endpoints')
@Controller('/api/users')
class UserController {
  UserController({required this.userRepository});
  final UserRepository userRepository;

  /// GET /api/users - List all users with pagination
  @ApiOperation(summary: 'List users', description: 'Get paginated list of all users')
  @ApiResponse(
    200,
    description: 'Users retrieved successfully',
    content: ApiContent(type: 'application/json', schema: PaginatedResponse),
  )
  @ApiResponse(500, description: 'Internal server error')
  @Get('/')
  Future<PaginatedResponse<UserProfile>> listUsers(@Query('page') int? page, @Query('limit') int? limit) async {
    try {
      final pageNum = page ?? 1;
      final limitNum = limit ?? 10;

      final users = await userRepository.findAll(page: pageNum, limit: limitNum);
      final total = await userRepository.getTotalCount();
      final hasMore = (pageNum * limitNum) < total;

      return PaginatedResponse<UserProfile>(
        data: users,
        page: pageNum,
        limit: limitNum,
        total: total,
        hasMore: hasMore,
      );
    } catch (e) {
      throw ResponseException(500, 'Failed to list users: ${e.toString()}');
    }
  }

  /// GET /api/users/:id - Get user by ID
  @ApiOperation(summary: 'Get user by ID', description: 'Retrieve detailed information about a specific user')
  @ApiResponse(
    200,
    description: 'User retrieved successfully',
    content: ApiContent(type: 'application/json', schema: UserProfile),
  )
  @ApiResponse(400, description: 'Invalid user ID')
  @ApiResponse(404, description: 'User not found')
  @ApiResponse(500, description: 'Internal server error')
  @Get('/<id>')
  Future<UserProfile> getUserById(@Param('id') int userId) async {
    try {
      final user = await userRepository.findById(userId);
      if (user == null) {
        throw const ResponseException(404, 'User not found');
      }

      return user;
    } catch (e) {
      if (e is ResponseException) rethrow;
      throw ResponseException(500, 'Failed to get user: ${e.toString()}');
    }
  }

  /// POST /api/users - Create new user
  @ApiOperation(summary: 'Create user', description: 'Create a new user in the system')
  @ApiResponse(
    201,
    description: 'User created successfully',
    content: ApiContent(type: 'application/json', schema: UserProfile),
  )
  @ApiResponse(400, description: 'Invalid request data')
  @ApiResponse(500, description: 'Internal server error')
  @Post('/')
  Future<UserProfile> createUser(@Body() CreateUserRequest data) async {
    try {
      return await userRepository.create(data);
    } catch (e) {
      throw ResponseException(500, 'Failed to create user: ${e.toString()}');
    }
  }

  /// PUT /api/users/:id - Update user
  @ApiOperation(summary: 'Update user', description: 'Update user information by ID')
  @ApiResponse(
    200,
    description: 'User updated successfully',
    content: ApiContent(type: 'application/json', schema: UserProfile),
  )
  @ApiResponse(400, description: 'Invalid user ID')
  @ApiResponse(404, description: 'User not found')
  @ApiResponse(500, description: 'Internal server error')
  @Put('/<id>')
  Future<UserProfile> updateUser(@Param('id') int userId, @Body() UpdateUserRequest updateData) async {
    try {
      final user = await userRepository.update(userId, updateData);
      if (user == null) {
        throw const ResponseException(404, 'User not found');
      }

      return user;
    } catch (e) {
      if (e is ResponseException) rethrow;
      throw ResponseException(500, 'Failed to update user: ${e.toString()}');
    }
  }

  /// DELETE /api/users/:id - Delete user (soft delete)
  @ApiOperation(summary: 'Delete user', description: 'Soft delete a user by ID')
  @ApiResponse(
    200,
    description: 'User deleted successfully',
    content: ApiContent(type: 'application/json', schema: StatusResponse),
  )
  @ApiResponse(400, description: 'Invalid user ID')
  @ApiResponse(404, description: 'User not found')
  @ApiResponse(500, description: 'Internal server error')
  @Delete('/<id>')
  Future<StatusResponse> deleteUser(@Param('id') int userId) async {
    try {
      final deleted = await userRepository.delete(userId);
      if (!deleted) {
        throw const ResponseException(404, 'User not found');
      }

      return StatusResponse(message: 'User deleted successfully');
    } catch (e) {
      if (e is ResponseException) rethrow;
      throw ResponseException(500, 'Failed to delete user: ${e.toString()}');
    }
  }
}

/// Status response DTO
class StatusResponse {
  StatusResponse({required this.message});
  final String message;

  Map<String, dynamic> toJson() => {'message': message};
}
