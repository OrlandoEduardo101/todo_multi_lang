# 🚀 TODO CRUD: COMECE AQUI

**Tempo estimado:** 1-2 horas
**Dificuldade:** Fácil (você já conhece o padrão de User Registration)

---

## 📋 Roteiro Rápido

```
Passo 1: Criar Todo Entity         (5 min)
Passo 2: Criar TodoRepository      (3 min)
Passo 3: Criar DTOs                (5 min)
Passo 4: Criar TodoService         (15 min)
Passo 5: Criar TodoController      (15 min)
Passo 6: Testar endpoints          (20 min)
```

---

## 🔧 PASSO 1: Criar Todo Entity

### Arquivo: `src/main/java/com/todo/model/Todo.java`

```java
package com.todo.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Todo Entity
 *
 * Representa uma tarefa de um usuário
 */
@Entity
@Table(name = "todos")
public class Todo {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    /**
     * Relacionamento com User
     * ManyToOne = Muitos todos para um usuário
     * @ManyToOne busca User no banco
     * @JoinColumn especifica coluna FK (user_id)
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    /**
     * Título da tarefa
     * Obrigatório
     */
    @Column(nullable = false, length = 255)
    private String title;

    /**
     * Descrição da tarefa
     * Opcional
     */
    @Column(columnDefinition = "TEXT")
    private String description;

    /**
     * Status da tarefa
     * true = completa
     * false = pendente
     * Default: false
     */
    @Column(nullable = false)
    private Boolean completed = false;

    /**
     * Data de criação
     * Auto-preenchida
     */
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    /**
     * Data de atualização
     * Auto-atualizada a cada modificação
     */
    @Column(nullable = false)
    private LocalDateTime updatedAt;

    /**
     * Data de deleção (soft delete)
     * null = ativa
     * data = deletada logicamente
     */
    @Column
    private LocalDateTime deletedAt;

    /**
     * Hook: executa ANTES de inserir no banco
     * Preenche createdAt e updatedAt com hora atual
     */
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    /**
     * Hook: executa ANTES de atualizar no banco
     * Atualiza updatedAt com hora atual
     */
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // ==================== GETTERS E SETTERS ====================

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Boolean getCompleted() {
        return completed;
    }

    public void setCompleted(Boolean completed) {
        this.completed = completed;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public LocalDateTime getDeletedAt() {
        return deletedAt;
    }

    public void setDeletedAt(LocalDateTime deletedAt) {
        this.deletedAt = deletedAt;
    }
}
```

---

## 📚 PASSO 2: Criar TodoRepository

### Arquivo: `src/main/java/com/todo/repository/TodoRepository.java`

```java
package com.todo.repository;

import com.todo.model.Todo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * TodoRepository
 *
 * Interface que estende JpaRepository
 * Spring cria automaticamente a implementação
 */
@Repository
public interface TodoRepository extends JpaRepository<Todo, UUID> {

    /**
     * Busca todos os TODOs de um usuário
     * Ignora TODOs deletados (deletedAt = null)
     *
     * @param userId - ID do usuário
     * @return Lista de TODOs ativos
     */
    List<Todo> findByUserIdAndDeletedAtIsNull(UUID userId);

    /**
     * Busca TODOs de um usuário filtrados por status
     *
     * @param userId - ID do usuário
     * @param completed - true/false
     * @return Lista de TODOs com status específico
     */
    List<Todo> findByUserIdAndCompletedAndDeletedAtIsNull(UUID userId, Boolean completed);

    /**
     * Busca um TODO específico de um usuário
     * Garante que usuário só acessa seus TODOs
     *
     * @param id - ID do TODO
     * @param userId - ID do usuário
     * @return Optional com o TODO (vazio se não pertence ao usuário)
     */
    Optional<Todo> findByIdAndUserId(UUID id, UUID userId);

    /**
     * Verifica se um TODO pertence a um usuário
     * Útil para validação antes de atualizar/deletar
     *
     * @param id - ID do TODO
     * @param userId - ID do usuário
     * @return true se existe, false caso contrário
     */
    boolean existsByIdAndUserIdAndDeletedAtIsNull(UUID id, UUID userId);
}
```

---

## 🎯 PASSO 3: Criar DTOs

### Arquivo: `src/main/java/com/todo/dto/CreateTodoRequest.java`

```java
package com.todo.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * CreateTodoRequest
 *
 * DTO para criar um novo TODO
 * Recebe dados do cliente
 */
public class CreateTodoRequest {

    @NotBlank(message = "Título é obrigatório")
    @Size(min = 3, max = 255, message = "Título deve ter entre 3 e 255 caracteres")
    private String title;

    @Size(max = 2000, message = "Descrição não pode ter mais de 2000 caracteres")
    private String description;

    // ==================== GETTERS E SETTERS ====================

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}
```

### Arquivo: `src/main/java/com/todo/dto/UpdateTodoRequest.java`

```java
package com.todo.dto;

import jakarta.validation.constraints.Size;

/**
 * UpdateTodoRequest
 *
 * DTO para atualizar um TODO
 * Todos os campos são opcionais
 */
public class UpdateTodoRequest {

    @Size(min = 3, max = 255, message = "Título deve ter entre 3 e 255 caracteres")
    private String title;

    @Size(max = 2000, message = "Descrição não pode ter mais de 2000 caracteres")
    private String description;

    private Boolean completed;

    // ==================== GETTERS E SETTERS ====================

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Boolean getCompleted() {
        return completed;
    }

    public void setCompleted(Boolean completed) {
        this.completed = completed;
    }
}
```

### Arquivo: `src/main/java/com/todo/dto/TodoResponse.java`

```java
package com.todo.dto;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * TodoResponse
 *
 * DTO retornado em respostas
 * Nunca expõe dados sensíveis
 */
public class TodoResponse {

    private UUID id;
    private String title;
    private String description;
    private Boolean completed;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    /**
     * Construtor com todos os campos
     */
    public TodoResponse(UUID id, String title, String description, Boolean completed,
                       LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.id = id;
        this.title = title;
        this.description = description;
        this.completed = completed;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // ==================== GETTERS E SETTERS ====================

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Boolean getCompleted() {
        return completed;
    }

    public void setCompleted(Boolean completed) {
        this.completed = completed;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}
```

---

## 💼 PASSO 4: Criar TodoService

### Arquivo: `src/main/java/com/todo/service/TodoService.java`

```java
package com.todo.service;

import com.todo.dto.CreateTodoRequest;
import com.todo.dto.TodoResponse;
import com.todo.dto.UpdateTodoRequest;
import com.todo.model.Todo;
import com.todo.model.User;
import com.todo.repository.TodoRepository;
import com.todo.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * TodoService
 *
 * Serviço que contém lógica de negócio para TODOs
 * - Validação
 * - Permissões (usuário só acessa seus TODOs)
 * - Operações CRUD
 */
@Service
public class TodoService {

    @Autowired
    private TodoRepository todoRepository;

    @Autowired
    private UserRepository userRepository;

    /**
     * Cria um novo TODO para um usuário
     *
     * @param userId - ID do usuário
     * @param request - Dados do TODO (title, description)
     * @return TodoResponse com dados do TODO criado
     */
    public TodoResponse create(UUID userId, CreateTodoRequest request) {
        // 1️⃣ Validar entrada
        if (request.getTitle() == null || request.getTitle().isEmpty()) {
            throw new IllegalArgumentException("Título é obrigatório");
        }

        // 2️⃣ Buscar usuário (garantir que existe)
        Optional<User> userOpt = userRepository.findById(userId);
        if (userOpt.isEmpty()) {
            throw new IllegalArgumentException("Usuário não encontrado");
        }

        // 3️⃣ Criar novo TODO
        Todo todo = new Todo();
        todo.setUser(userOpt.get());
        todo.setTitle(request.getTitle());
        todo.setDescription(request.getDescription());
        todo.setCompleted(false);  // Novos TODOs começam incompletos

        // 4️⃣ Salvar no banco
        Todo savedTodo = todoRepository.save(todo);

        // 5️⃣ Retornar resposta
        return new TodoResponse(
            savedTodo.getId(),
            savedTodo.getTitle(),
            savedTodo.getDescription(),
            savedTodo.getCompleted(),
            savedTodo.getCreatedAt(),
            savedTodo.getUpdatedAt()
        );
    }

    /**
     * Busca um TODO específico
     * Valida que o TODO pertence ao usuário
     *
     * @param userId - ID do usuário
     * @param todoId - ID do TODO
     * @return TodoResponse
     */
    public TodoResponse getById(UUID userId, UUID todoId) {
        // Busca TODO validando userId
        Optional<Todo> todoOpt = todoRepository.findByIdAndUserId(todoId, userId);

        if (todoOpt.isEmpty()) {
            throw new IllegalArgumentException("TODO não encontrado ou não pertence a você");
        }

        Todo todo = todoOpt.get();
        return new TodoResponse(
            todo.getId(),
            todo.getTitle(),
            todo.getDescription(),
            todo.getCompleted(),
            todo.getCreatedAt(),
            todo.getUpdatedAt()
        );
    }

    /**
     * Lista todos os TODOs de um usuário
     * Opcionalmente filtra por status
     *
     * @param userId - ID do usuário
     * @param completed - null (todos) ou boolean (apenas completos/incompletos)
     * @return Lista de TodoResponse
     */
    public List<TodoResponse> listByUser(UUID userId, Boolean completed) {
        List<Todo> todos;

        if (completed == null) {
            // Buscar todos os TODOs (sem filtro)
            todos = todoRepository.findByUserIdAndDeletedAtIsNull(userId);
        } else {
            // Buscar TODOs filtrados por status
            todos = todoRepository.findByUserIdAndCompletedAndDeletedAtIsNull(userId, completed);
        }

        // Converter para DTOs
        return todos.stream()
            .map(todo -> new TodoResponse(
                todo.getId(),
                todo.getTitle(),
                todo.getDescription(),
                todo.getCompleted(),
                todo.getCreatedAt(),
                todo.getUpdatedAt()
            ))
            .collect(Collectors.toList());
    }

    /**
     * Atualiza um TODO
     * Valida que o TODO pertence ao usuário
     *
     * @param userId - ID do usuário
     * @param todoId - ID do TODO
     * @param request - Dados a atualizar (todos opcionais)
     * @return TodoResponse atualizado
     */
    public TodoResponse update(UUID userId, UUID todoId, UpdateTodoRequest request) {
        // 1️⃣ Validar que TODO existe e pertence ao usuário
        Optional<Todo> todoOpt = todoRepository.findByIdAndUserId(todoId, userId);
        if (todoOpt.isEmpty()) {
            throw new IllegalArgumentException("TODO não encontrado ou não pertence a você");
        }

        Todo todo = todoOpt.get();

        // 2️⃣ Atualizar apenas campos enviados
        if (request.getTitle() != null && !request.getTitle().isEmpty()) {
            todo.setTitle(request.getTitle());
        }

        if (request.getDescription() != null) {
            todo.setDescription(request.getDescription());
        }

        if (request.getCompleted() != null) {
            todo.setCompleted(request.getCompleted());
        }

        // 3️⃣ Salvar (updatedAt é atualizado automaticamente)
        Todo updatedTodo = todoRepository.save(todo);

        // 4️⃣ Retornar resposta
        return new TodoResponse(
            updatedTodo.getId(),
            updatedTodo.getTitle(),
            updatedTodo.getDescription(),
            updatedTodo.getCompleted(),
            updatedTodo.getCreatedAt(),
            updatedTodo.getUpdatedAt()
        );
    }

    /**
     * Deleta um TODO (soft delete)
     * Marca como deletado em vez de remover do banco
     *
     * @param userId - ID do usuário
     * @param todoId - ID do TODO
     */
    public void delete(UUID userId, UUID todoId) {
        // 1️⃣ Validar que TODO existe e pertence ao usuário
        Optional<Todo> todoOpt = todoRepository.findByIdAndUserId(todoId, userId);
        if (todoOpt.isEmpty()) {
            throw new IllegalArgumentException("TODO não encontrado ou não pertence a você");
        }

        // 2️⃣ Soft delete (marcar como deletado)
        Todo todo = todoOpt.get();
        todo.setDeletedAt(java.time.LocalDateTime.now());

        // 3️⃣ Salvar
        todoRepository.save(todo);
    }
}
```

---

## 🌐 PASSO 5: Criar TodoController

### Arquivo: `src/main/java/com/todo/controller/TodoController.java`

```java
package com.todo.controller;

import com.todo.dto.CreateTodoRequest;
import com.todo.dto.TodoResponse;
import com.todo.dto.UpdateTodoRequest;
import com.todo.service.TodoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

/**
 * TodoController
 *
 * Endpoints REST para CRUD de TODOs
 * Todos os endpoints requerem autenticação JWT
 */
@RestController
@RequestMapping("/api/todos")
public class TodoController {

    @Autowired
    private TodoService todoService;

    /**
     * Extrai userId do JWT token
     * O Spring Security popula Authentication com dados do token
     */
    private UUID getUserIdFromAuth(Authentication auth) {
        // auth.getName() retorna o user_id (subject do JWT)
        return UUID.fromString(auth.getName());
    }

    /**
     * POST /api/todos
     *
     * Cria um novo TODO
     *
     * @param auth - Informações do usuário autenticado
     * @param request - CreateTodoRequest (title, description)
     * @return 201 CREATED com TodoResponse
     */
    @PostMapping
    public ResponseEntity<?> create(
            Authentication auth,
            @RequestBody CreateTodoRequest request) {
        try {
            UUID userId = getUserIdFromAuth(auth);
            TodoResponse todo = todoService.create(userId, request);
            return ResponseEntity.status(HttpStatus.CREATED).body(todo);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ErrorResponse(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("Erro ao criar TODO: " + e.getMessage()));
        }
    }

    /**
     * GET /api/todos/:id
     *
     * Busca um TODO específico
     *
     * @param auth - Informações do usuário autenticado
     * @param id - ID do TODO
     * @return 200 OK com TodoResponse
     */
    @GetMapping("/{id}")
    public ResponseEntity<?> getById(
            Authentication auth,
            @PathVariable UUID id) {
        try {
            UUID userId = getUserIdFromAuth(auth);
            TodoResponse todo = todoService.getById(userId, id);
            return ResponseEntity.ok(todo);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("Erro ao buscar TODO: " + e.getMessage()));
        }
    }

    /**
     * GET /api/todos
     *
     * Lista TODOs do usuário
     * Query params opcionais:
     * - completed=true/false (filtrar por status)
     *
     * Exemplos:
     * GET /api/todos - Todos os TODOs
     * GET /api/todos?completed=true - Apenas completos
     * GET /api/todos?completed=false - Apenas pendentes
     *
     * @param auth - Informações do usuário autenticado
     * @param completed - Filtro opcional
     * @return 200 OK com lista de TodoResponse
     */
    @GetMapping
    public ResponseEntity<?> list(
            Authentication auth,
            @RequestParam(value = "completed", required = false) Boolean completed) {
        try {
            UUID userId = getUserIdFromAuth(auth);
            List<TodoResponse> todos = todoService.listByUser(userId, completed);
            return ResponseEntity.ok(todos);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("Erro ao listar TODOs: " + e.getMessage()));
        }
    }

    /**
     * PUT /api/todos/:id
     *
     * Atualiza um TODO
     * Apenas o proprietário pode atualizar
     *
     * @param auth - Informações do usuário autenticado
     * @param id - ID do TODO
     * @param request - UpdateTodoRequest (todos campos opcionais)
     * @return 200 OK com TodoResponse atualizado
     */
    @PutMapping("/{id}")
    public ResponseEntity<?> update(
            Authentication auth,
            @PathVariable UUID id,
            @RequestBody UpdateTodoRequest request) {
        try {
            UUID userId = getUserIdFromAuth(auth);
            TodoResponse todo = todoService.update(userId, id, request);
            return ResponseEntity.ok(todo);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("Erro ao atualizar TODO: " + e.getMessage()));
        }
    }

    /**
     * DELETE /api/todos/:id
     *
     * Deleta um TODO (soft delete)
     * Apenas o proprietário pode deletar
     *
     * @param auth - Informações do usuário autenticado
     * @param id - ID do TODO
     * @return 204 NO CONTENT
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(
            Authentication auth,
            @PathVariable UUID id) {
        try {
            UUID userId = getUserIdFromAuth(auth);
            todoService.delete(userId, id);
            return ResponseEntity.noContent().build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("Erro ao deletar TODO: " + e.getMessage()));
        }
    }

    /**
     * Classe interna para respostas de erro
     */
    static class ErrorResponse {
        private String error;

        public ErrorResponse(String error) {
            this.error = error;
        }

        public String getError() {
            return error;
        }

        public void setError(String error) {
            this.error = error;
        }
    }
}
```

---

## 🧪 PASSO 6: Testar Endpoints

### Pre-requisito
Certifique-se de que tem um usuário registrado e um token JWT:

```bash
# 1. Registrar usuário
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@test.com",
    "password": "123456",
    "name": "Test User"
  }'

# 2. Login (copie o token)
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@test.com",
    "password": "123456"
  }'

# Cole o token em: TOKEN="eyJhbGciOi..."
```

### Testes

#### ✅ 1. CREATE TODO
```bash
curl -X POST http://localhost:8080/api/todos \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "title": "Meu primeiro TODO",
    "description": "Descrição do meu TODO"
  }'

# Esperado: 201 CREATED com TodoResponse
```

#### ✅ 2. LIST TODOs
```bash
curl -X GET http://localhost:8080/api/todos \
  -H "Authorization: Bearer $TOKEN"

# Esperado: 200 OK com lista de TODOs
```

#### ✅ 3. LIST TODOs (filtrar por status)
```bash
# Apenas completos
curl -X GET "http://localhost:8080/api/todos?completed=true" \
  -H "Authorization: Bearer $TOKEN"

# Apenas pendentes
curl -X GET "http://localhost:8080/api/todos?completed=false" \
  -H "Authorization: Bearer $TOKEN"
```

#### ✅ 4. GET TODO BY ID
```bash
curl -X GET http://localhost:8080/api/todos/{id} \
  -H "Authorization: Bearer $TOKEN"

# Esperado: 200 OK com o TODO
```

#### ✅ 5. UPDATE TODO
```bash
curl -X PUT http://localhost:8080/api/todos/{id} \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "title": "TODO atualizado",
    "completed": true
  }'

# Esperado: 200 OK com TODO atualizado
```

#### ✅ 6. DELETE TODO
```bash
curl -X DELETE http://localhost:8080/api/todos/{id} \
  -H "Authorization: Bearer $TOKEN"

# Esperado: 204 NO CONTENT
```

#### ✅ 7. Testar segurança (sem token)
```bash
curl -X GET http://localhost:8080/api/todos
# Esperado: 401 UNAUTHORIZED
```

#### ✅ 8. Testar permissões (acessar TODO de outro usuário)
```bash
# Registre outro usuário, faça login e obtenha seu token
# Tente acessar TODO do primeiro usuário com esse token

curl -X GET http://localhost:8080/api/todos/{id-do-outro-usuario} \
  -H "Authorization: Bearer $TOKEN_OUTRO_USUARIO"

# Esperado: 404 NOT FOUND (TODO não encontrado para esse usuário)
```

---

## 📊 Estrutura Final

```
src/main/java/com/todo/
├── model/
│   ├── User.java
│   └── Todo.java               ← NOVO
│
├── repository/
│   ├── UserRepository.java
│   └── TodoRepository.java     ← NOVO
│
├── service/
│   ├── UserService.java
│   └── TodoService.java        ← NOVO
│
├── controller/
│   ├── AuthController.java
│   └── TodoController.java     ← NOVO
│
├── dto/
│   ├── RegisterRequest.java
│   ├── UserResponse.java
│   ├── LoginRequest.java
│   ├── LoginResponse.java
│   ├── CreateTodoRequest.java  ← NOVO
│   ├── UpdateTodoRequest.java  ← NOVO
│   └── TodoResponse.java       ← NOVO
│
├── security/
│   ├── JwtTokenProvider.java
│   └── JwtAuthenticationFilter.java
│
└── config/
    └── SecurityConfig.java
```

---

## 🗄️ Banco de Dados

### Tabela Criada Automaticamente

Hibernate criará a tabela `todos` automaticamente:

```sql
CREATE TABLE todos (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id),
  title VARCHAR(255) NOT NULL,
  description TEXT,
  completed BOOLEAN DEFAULT FALSE NOT NULL,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL,
  deleted_at TIMESTAMP
);

CREATE INDEX idx_todos_user_id ON todos(user_id);
CREATE INDEX idx_todos_deleted_at ON todos(deleted_at);
```

---

## 📋 Checklist

```
✅ Criar Todo Entity com relacionamento
✅ Criar TodoRepository
✅ Criar DTOs (Create, Update, Response)
✅ Criar TodoService com CRUD
✅ Criar TodoController com endpoints
✅ Testar POST /api/todos
✅ Testar GET /api/todos
✅ Testar GET /api/todos/:id
✅ Testar PUT /api/todos/:id
✅ Testar DELETE /api/todos/:id
✅ Testar segurança (sem token)
✅ Testar permissões (outro usuário)
```

---

## 🎓 Conceitos-Chave

| Conceito | O Que Você Aprendeu |
|----------|-------------------|
| **@ManyToOne** | Um TODO pertence a um usuário |
| **FetchType.LAZY** | Carrega usuário apenas quando necessário |
| **@PrePersist/@PreUpdate** | Preenche automaticamente datas |
| **Soft Delete** | Marca como deletado em vez de remover |
| **Stream().map()** | Converte Entity para DTO |
| **UUID Extraction** | Extrai ID do Authentication token |
| **Query Params** | Filtros em GET (completed=true) |
| **Validation** | @NotBlank, @Size para validação |

---

## 🚀 Próximo Passo

Depois de implementar Todo CRUD:

1. **Adicionar Filtering Avançado**
   - Buscar por título
   - Filtrar por data

2. **Implementar Pagination**
   - ?page=1&limit=10
   - Usar Pageable do Spring

3. **Adicionar Soft Delete Queries**
   - Garantir deletedAt = null em buscas

4. **Implementar Testes**
   - Unit tests com Mockito
   - Integration tests

---

## 💡 Dicas

1. **Use o padrão UserService como referência**
   - Mesma estrutura, mesmos padrões

2. **Sempre validar userId**
   - Garantir que usuário só acessa seus TODOs

3. **Teste com cURL primeiro**
   - Valide funcionalidade antes de UI

4. **Use Postman para documentar**
   - Salve testes para reusar

5. **Commit frequentemente**
   - Cada funcionalidade é um commit

---

**Tempo estimado:** 1-2 horas
**Nível de dificuldade:** ⭐ Fácil
**Pré-requisitos:** Conhecer User Registration + JWT (✅ Já tem!)

Boa sorte! 🚀

