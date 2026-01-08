# 📖 Guia de Desenvolvimento - TODO Vaden Backend

## 🎯 Como Adicionar uma Nova Feature

### **Passo 1: Criar a Entidade no Domain**

```dart
// lib/src/domain/entities/comment.dart
import 'package:vaden/vaden.dart';

@DTO()
class Comment {
  final int id;
  final int todoId;
  final int userId;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.todoId,
    required this.userId,
    required this.text,
    required this.createdAt,
  });
}
```

### **Passo 2: Criar DTOs para I/O**

```dart
// lib/src/domain/dto/create_comment_input.dart
@DTO()
class CreateCommentInput {
  final int todoId;
  final String text;

  CreateCommentInput({
    required this.todoId,
    required this.text,
  });

  Map<String, dynamic> toMap() => {
    'todo_id': todoId,
    'text': text,
  };
}

// lib/src/domain/dto/comment_response.dart
@DTO()
class CommentResponse {
  final int id;
  final int todoId;
  final int userId;
  final String text;
  final DateTime createdAt;

  CommentResponse({
    required this.id,
    required this.todoId,
    required this.userId,
    required this.text,
    required this.createdAt,
  });

  factory CommentResponse.fromComment(Comment comment) => CommentResponse(
    id: comment.id,
    todoId: comment.todoId,
    userId: comment.userId,
    text: comment.text,
    createdAt: comment.createdAt,
  );
}
```

### **Passo 3: Criar Repositório (Interface)**

```dart
// lib/src/domain/repositories/comment_repository.dart
abstract interface class CommentRepository {
  AsyncResult<List<Comment>> getCommentsByTodo(int todoId);
  AsyncResult<Comment> createComment(int userId, CreateCommentInput input);
  AsyncResult<Comment> updateComment(int commentId, String text);
  AsyncResult<Unit> deleteComment(int commentId);
}
```

### **Passo 4: Implementar Repositório**

```dart
// lib/src/data/repositories/comment_repository_impl.dart
import 'package:postgres/postgres.dart';
import 'package:result_dart/result_dart.dart';
import 'package:vaden/vaden.dart';

@Repository()
class CommentRepositoryImpl implements CommentRepository {
  final Pool _connection;

  CommentRepositoryImpl(this._connection);

  @override
  AsyncResult<List<Comment>> getCommentsByTodo(int todoId) async {
    try {
      final query = '''
        SELECT id, todo_id, user_id, text, created_at
        FROM comments
        WHERE todo_id = \$1
        ORDER BY created_at DESC
      ''';

      final result = await _connection.execute(query, parameters: [todoId]);

      final comments = result
          .map((row) => Comment(
            id: row[0] as int,
            todoId: row[1] as int,
            userId: row[2] as int,
            text: row[3] as String,
            createdAt: row[4] as DateTime,
          ))
          .toList();

      return Success(comments);
    } catch (e) {
      return Failure(Exception('Failed to get comments: $e'));
    }
  }

  @override
  AsyncResult<Comment> createComment(int userId, CreateCommentInput input) async {
    try {
      final query = '''
        INSERT INTO comments (todo_id, user_id, text, created_at)
        VALUES (\$1, \$2, \$3, NOW())
        RETURNING id, todo_id, user_id, text, created_at
      ''';

      final result = await _connection.execute(
        query,
        parameters: [input.todoId, userId, input.text],
      );

      final row = result.first;
      return Success(Comment(
        id: row[0] as int,
        todoId: row[1] as int,
        userId: row[2] as int,
        text: row[3] as String,
        createdAt: row[4] as DateTime,
      ));
    } catch (e) {
      return Failure(Exception('Failed to create comment: $e'));
    }
  }

  // ... outros métodos
}
```

### **Passo 5: Criar Use Cases**

```dart
// lib/src/domain/usecases/comment/get_comments.dart
@Component()
class GetComments {
  final CommentRepository _repository;

  GetComments(this._repository);

  AsyncResult<List<Comment>> call(int todoId) {
    return _repository.getCommentsByTodo(todoId);
  }
}

// lib/src/domain/usecases/comment/create_comment.dart
@Component()
class CreateComment {
  final CommentRepository _repository;

  CreateComment(this._repository);

  AsyncResult<Comment> call(int userId, CreateCommentInput input) {
    if (input.text.isEmpty) {
      return Failure(
        ResponseException.badRequest('Comment text cannot be empty'),
      );
    }

    return _repository.createComment(userId, input);
  }
}
```

### **Passo 6: Criar Controller**

```dart
// lib/src/controllers/comment_controller.dart
import 'package:vaden/vaden.dart';
import '../domain/usecases/comment/get_comments.dart';
import '../domain/usecases/comment/create_comment.dart';
import '../domain/dto/create_comment_input.dart';
import '../domain/dto/comment_response.dart';

@Api(tag: 'Comments', description: 'Gerenciamento de comentários')
@Controller('/api/todos/:todoId/comments')
class CommentController {
  final GetComments _getComments;
  final CreateComment _createComment;

  CommentController(
    this._getComments,
    this._createComment,
  );

  @ApiOperation(
    summary: 'Listar comentários',
    description: 'Retorna todos os comentários de uma tarefa',
  )
  @Get()
  Future<Response> getComments(
    @PathParam() int todoId,
    @RequestUser() int userId,
  ) async {
    return (await _getComments(todoId))
        .fold(
          (comments) => Response.ok(
            jsonEncode(comments
                .map((c) => CommentResponse.fromComment(c))
                .toList()),
            headers: {'Content-Type': 'application/json'},
          ),
          (error) => Response.internalServerError(
            body: jsonEncode({'error': error.toString()}),
          ),
        );
  }

  @ApiOperation(
    summary: 'Criar comentário',
    description: 'Cria um novo comentário em uma tarefa',
  )
  @Post()
  Future<Response> createComment(
    @PathParam() int todoId,
    @RequestUser() int userId,
    @Body() CreateCommentInput input,
  ) async {
    return (await _createComment(userId, input))
        .fold(
          (comment) => Response.created(
            jsonEncode(CommentResponse.fromComment(comment)),
            headers: {'Content-Type': 'application/json'},
          ),
          (error) => Response.badRequest(
            body: jsonEncode({'error': error.toString()}),
          ),
        );
  }
}
```

### **Passo 7: Registrar no Módulo**

```dart
// lib/config/app_module.dart
@Component()
class CommentConfiguration {
  @Bean()
  CommentRepository commentRepository(Pool pool) {
    return CommentRepositoryImpl(pool);
  }
}

// Adicione a anotação ao AppModule
@VadenModule([
  VadenSecurity,
  CommentConfiguration, // Novo
])
class AppModule {}
```

### **Passo 8: Criar Migração do BD**

```yaml
# migrations/003_create_comments_table.yaml
querys:
  - >
    CREATE TABLE comments (
      id SERIAL PRIMARY KEY,
      todo_id INTEGER NOT NULL REFERENCES todos(id) ON DELETE CASCADE,
      user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      text TEXT NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
```

### **Passo 9: Adicionar Testes**

```dart
// test/unit/domain/usecases/create_comment_test.dart
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';

void main() {
  late MockCommentRepository mockRepository;
  late CreateComment useCase;

  setUp(() {
    mockRepository = MockCommentRepository();
    useCase = CreateComment(mockRepository);
  });

  group('CreateComment', () {
    test('deve criar comentário com sucesso', () async {
      // Arrange
      final input = CreateCommentInput(
        todoId: 1,
        text: 'Ótima tarefa!',
      );
      final comment = Comment(
        id: 1,
        todoId: 1,
        userId: 1,
        text: 'Ótima tarefa!',
        createdAt: DateTime.now(),
      );

      when(() => mockRepository.createComment(1, input))
          .thenAnswer((_) async => Success(comment));

      // Act
      final result = await useCase(1, input);

      // Assert
      expect(result.isSuccess, true);
      expect(result.getOrNull()?.text, 'Ótima tarefa!');
      verify(() => mockRepository.createComment(1, input)).called(1);
    });

    test('deve falhar com texto vazio', () async {
      // Arrange
      final input = CreateCommentInput(
        todoId: 1,
        text: '',
      );

      // Act
      final result = await useCase(1, input);

      // Assert
      expect(result.isFailure, true);
      verifyNever(() => mockRepository.createComment(any(), any()));
    });
  });
}
```

---

## 📋 Checklist para Novas Features

- [ ] Entidade criada em `domain/entities/`
- [ ] DTOs criados em `domain/dto/`
- [ ] Interface do repositório em `domain/repositories/`
- [ ] Implementação do repositório em `data/repositories/`
- [ ] Use cases criados em `domain/usecases/`
- [ ] Controller criado em `src/controllers/`
- [ ] Registrado no módulo de DI
- [ ] Migração de BD criada
- [ ] Testes unitários
- [ ] Documentação atualizada
- [ ] Endpoints documentados com `@ApiOperation`

---

## 🔄 Fluxo de Desenvolvimento Típico

```
1. Design da entidade
   ↓
2. Criar DTO para entrada/saída
   ↓
3. Definir repositório (interface)
   ↓
4. Implementar repositório
   ↓
5. Criar use cases (lógica)
   ↓
6. Criar controller (HTTP)
   ↓
7. Registrar dependências
   ↓
8. Criar migração de BD
   ↓
9. Testes
   ↓
10. Documentação
```

---

## 🐛 Debugging Tips

### **Ver logs de SQL**
```dart
// Em application.yaml
postgres:
  debug: true
```

### **Testar endpoint rapidamente**
```bash
curl -X POST http://localhost:8080/api/comments \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"todoId": 1, "text": "Novo comentário"}'
```

### **Verificar estrutura do BD**
```bash
psql -U postgres -d todo_db -c "\\dt"  # Listar tabelas
psql -U postgres -d todo_db -c "\\d comments"  # Ver estrutura
```

---

## 📚 Referências de Código

### **Pattern: Result Monadic**
```dart
// Encadeamento de operações com tratamento automático de erros
AsyncResult<Todo> getTodoWithComments(int todoId) async {
  return (await _todoRepository.getTodo(todoId))
      .flatMap((todo) async {
        final comments = await _commentRepository.getComments(todoId);
        return comments.map((list) => todo.copyWith(comments: list));
      });
}
```

### **Pattern: Validators**
```dart
@Component()
class CreateTodoValidator {
  AsyncResult<CreateTodoInput> validate(CreateTodoInput input) async {
    if (input.title.isEmpty) {
      return Failure(
        ResponseException.badRequest('Title cannot be empty'),
      );
    }
    if (input.title.length > 255) {
      return Failure(
        ResponseException.badRequest('Title too long (max 255 chars)'),
      );
    }
    return Success(input);
  }
}
```

---

## 🚀 Performance Tips

1. **Use índices no BD** para campos frequentemente filtrados
2. **Implemente paginação** em queries que retornam listas
3. **Cache** com Redis para dados frequentemente acessados
4. **Connection pooling** já configurado automaticamente
5. **Lazy load** relacionamentos quando possível

---

## 🤝 Code Review Checklist

Ao revisar código novo:

- [ ] Segue a arquitetura hexagonal?
- [ ] Testes acompanham a feature?
- [ ] DTOs são imutáveis?
- [ ] Use cases têm lógica bem separada?
- [ ] Documentação OpenAPI atualizada?
- [ ] Nomes de variáveis são descritivos?
- [ ] Não há duplicação de código?
- [ ] Tratamento de erro adequado?
- [ ] Migração de BD incluída?
- [ ] Comentários explicam WHY, não WHAT?
