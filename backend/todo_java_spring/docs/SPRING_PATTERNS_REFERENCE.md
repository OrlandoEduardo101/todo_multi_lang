# 🏗️ Padrões Spring Boot - Referência Rápida

## 1. Controller Pattern

```java
@RestController
@RequestMapping("/api/resource")
public class ResourceController {
    
    @Autowired
    private ResourceService service;
    
    // POST - Criar
    @PostMapping
    public ResponseEntity<?> create(@RequestBody CreateRequest req) {
        try {
            ResourceResponse res = service.create(req);
            return ResponseEntity.status(HttpStatus.CREATED).body(res);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(new ErrorResponse(e.getMessage()));
        }
    }
    
    // GET - Listar
    @GetMapping
    public ResponseEntity<List<ResourceResponse>> list() {
        return ResponseEntity.ok(service.findAll());
    }
    
    // GET - Buscar por ID
    @GetMapping("/{id}")
    public ResponseEntity<?> getById(@PathVariable UUID id) {
        try {
            ResourceResponse res = service.findById(id);
            return ResponseEntity.ok(res);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(new ErrorResponse("Não encontrado"));
        }
    }
    
    // PUT - Atualizar
    @PutMapping("/{id}")
    public ResponseEntity<?> update(
        @PathVariable UUID id,
        @RequestBody UpdateRequest req
    ) {
        try {
            ResourceResponse res = service.update(id, req);
            return ResponseEntity.ok(res);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(new ErrorResponse(e.getMessage()));
        }
    }
    
    // DELETE - Deletar
    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable UUID id) {
        try {
            service.delete(id);
            return ResponseEntity.noContent().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(new ErrorResponse("Não encontrado"));
        }
    }
}
```

---

## 2. Service Pattern

```java
@Service
public class ResourceService {
    
    @Autowired
    private ResourceRepository repository;
    
    @Autowired
    private PasswordEncoder encoder;  // Se precisar criptografia
    
    // CREATE
    public ResourceResponse create(CreateRequest req) {
        // 1. Validar
        if (repository.existsByEmail(req.getEmail())) {
            throw new IllegalArgumentException("Email já existe");
        }
        
        // 2. Criar objeto
        Resource resource = new Resource();
        resource.setEmail(req.getEmail());
        resource.setName(req.getName());
        
        // 3. Se precisar criptografia:
        if (req.getPassword() != null) {
            resource.setPassword(encoder.encode(req.getPassword()));
        }
        
        // 4. Salvar
        Resource saved = repository.save(resource);
        
        // 5. Retornar DTO (NUNCA a entidade)
        return new ResourceResponse(
            saved.getId().toString(),
            saved.getName(),
            saved.getEmail()
        );
    }
    
    // READ
    public List<ResourceResponse> findAll() {
        return repository.findAll()
            .stream()
            .map(r -> new ResourceResponse(
                r.getId().toString(),
                r.getName(),
                r.getEmail()
            ))
            .collect(Collectors.toList());
    }
    
    public ResourceResponse findById(UUID id) {
        Resource resource = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Não encontrado"));
        
        return new ResourceResponse(
            resource.getId().toString(),
            resource.getName(),
            resource.getEmail()
        );
    }
    
    // UPDATE
    public ResourceResponse update(UUID id, UpdateRequest req) {
        Resource resource = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Não encontrado"));
        
        // Atualizar campos
        if (req.getName() != null) {
            resource.setName(req.getName());
        }
        if (req.getEmail() != null) {
            resource.setEmail(req.getEmail());
        }
        
        Resource updated = repository.save(resource);
        
        return new ResourceResponse(
            updated.getId().toString(),
            updated.getName(),
            updated.getEmail()
        );
    }
    
    // DELETE
    public void delete(UUID id) {
        Resource resource = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Não encontrado"));
        
        repository.delete(resource);
    }
}
```

---

## 3. Repository Pattern

```java
// Interface - você escreve
public interface ResourceRepository extends JpaRepository<Resource, UUID> {
    
    // Métodos automáticos do JpaRepository:
    // - save(resource)
    // - findById(id)
    // - findAll()
    // - delete(resource)
    // - deleteById(id)
    
    // Você adiciona métodos customizados:
    Optional<Resource> findByEmail(String email);
    boolean existsByEmail(String email);
    List<Resource> findByNameContaining(String name);
    List<Resource> findByCompleted(boolean completed);
}

// Spring cria a implementação AUTOMATICAMENTE!
// Segue a convenção:
// findBy<FieldName>      → SELECT * FROM table WHERE field = ?
// existsBy<FieldName>    → SELECT COUNT(*) FROM table WHERE field = ?
// findBy<Field>Containing → SELECT * FROM table WHERE field LIKE ?
```

---

## 4. DTO Pattern

```java
// REQUEST DTO (entrada)
public class CreateResourceRequest {
    private String email;
    private String name;
    private String password;
    
    // Construtores
    public CreateResourceRequest() {}
    
    public CreateResourceRequest(String email, String name, String password) {
        this.email = email;
        this.name = name;
        this.password = password;
    }
    
    // Getters e Setters
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
}

// RESPONSE DTO (saída)
public class ResourceResponse {
    private String id;
    private String name;
    private String email;
    // ❌ SEM password, timestamps privados, etc.
    
    public ResourceResponse(String id, String name, String email) {
        this.id = id;
        this.name = name;
        this.email = email;
    }
    
    // Getters
    public String getId() { return id; }
    public String getName() { return name; }
    public String getEmail() { return email; }
}
```

---

## 5. Entity Pattern

```java
@Entity
@Table(name = "resources")
public class Resource {
    
    @Id
    @GeneratedValue
    private UUID id;
    
    @Column(unique = true, nullable = false)
    private String email;
    
    @Column(nullable = false)
    private String name;
    
    @Column(nullable = false)
    private String password;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
    
    // Getters e Setters
    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public LocalDateTime getDeletedAt() { return deletedAt; }
    public void setDeletedAt(LocalDateTime deletedAt) { this.deletedAt = deletedAt; }
}
```

---

## 6. Exceções Customizadas

```java
// Criar exceção customizada
public class ResourceNotFoundException extends RuntimeException {
    public ResourceNotFoundException(String message) {
        super(message);
    }
}

// Usar no Service
public ResourceResponse findById(UUID id) {
    return repository.findById(id)
        .map(this::toResponse)
        .orElseThrow(() -> new ResourceNotFoundException(
            "Recurso com ID " + id + " não encontrado"
        ));
}

// Tratar no Controller
@ExceptionHandler(ResourceNotFoundException.class)
public ResponseEntity<?> handleNotFound(ResourceNotFoundException e) {
    return ResponseEntity.status(HttpStatus.NOT_FOUND)
        .body(new ErrorResponse(e.getMessage()));
}
```

---

## 7. Anotações Mais Usadas

| Anotação | Uso | Exemplo |
|----------|-----|---------|
| `@RestController` | Marca classe como REST controller | `@RestController` |
| `@Service` | Marca classe como serviço | `@Service` |
| `@Repository` | Marca classe como repository | Automático com `extends JpaRepository` |
| `@Autowired` | Injeta dependência | `@Autowired private UserService service;` |
| `@PostMapping` | Handler POST | `@PostMapping("/register")` |
| `@GetMapping` | Handler GET | `@GetMapping("/{id}")` |
| `@PutMapping` | Handler PUT | `@PutMapping("/{id}")` |
| `@DeleteMapping` | Handler DELETE | `@DeleteMapping("/{id}")` |
| `@RequestMapping` | Prefixo de rotas | `@RequestMapping("/api/users")` |
| `@RequestBody` | Desserializar JSON | `@RequestBody CreateRequest req` |
| `@PathVariable` | Parâmetro da URL | `@PathVariable UUID id` |
| `@RequestParam` | Query parameter | `@RequestParam(name="page") int page` |
| `@Entity` | JPA entity | `@Entity public class User` |
| `@Table` | Nome da tabela | `@Table(name="users")` |
| `@Column` | Coluna do banco | `@Column(unique=true)` |
| `@Id` | Chave primária | `@Id private UUID id;` |
| `@GeneratedValue` | Auto-gerar ID | `@GeneratedValue` |

---

## 8. HTTP Status Codes

```java
// 200 - OK (Sucesso geral)
ResponseEntity.ok(data);

// 201 - CREATED (Recurso criado)
ResponseEntity.status(HttpStatus.CREATED).body(data);

// 204 - NO CONTENT (DELETE bem-sucedido)
ResponseEntity.noContent().build();

// 400 - BAD REQUEST (Dados inválidos)
ResponseEntity.status(HttpStatus.BAD_REQUEST)
    .body(new ErrorResponse("Validação falhou"));

// 401 - UNAUTHORIZED (Não autenticado)
ResponseEntity.status(HttpStatus.UNAUTHORIZED)
    .body(new ErrorResponse("Faça login"));

// 403 - FORBIDDEN (Sem permissão)
ResponseEntity.status(HttpStatus.FORBIDDEN)
    .body(new ErrorResponse("Acesso negado"));

// 404 - NOT FOUND (Recurso não existe)
ResponseEntity.status(HttpStatus.NOT_FOUND)
    .body(new ErrorResponse("Não encontrado"));

// 500 - INTERNAL SERVER ERROR (Erro do servidor)
ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
    .body(new ErrorResponse("Erro interno"));
```

---

## 9. Exemplo Completo: Todo CRUD

```java
// Controller
@RestController
@RequestMapping("/api/todos")
public class TodoController {
    @Autowired
    private TodoService service;
    
    @PostMapping
    public ResponseEntity<?> create(@RequestBody CreateTodoRequest req) {
        try {
            return ResponseEntity.status(HttpStatus.CREATED)
                .body(service.create(req));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body(new ErrorResponse(e.getMessage()));
        }
    }
    
    @GetMapping
    public ResponseEntity<?> list(
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "10") int limit
    ) {
        return ResponseEntity.ok(service.findAll(page, limit));
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<?> getById(@PathVariable UUID id) {
        try {
            return ResponseEntity.ok(service.findById(id));
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<?> update(
        @PathVariable UUID id,
        @RequestBody UpdateTodoRequest req
    ) {
        try {
            return ResponseEntity.ok(service.update(id, req));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                .body(new ErrorResponse(e.getMessage()));
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable UUID id) {
        try {
            service.delete(id);
            return ResponseEntity.noContent().build();
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }
}

// Service
@Service
public class TodoService {
    @Autowired
    private TodoRepository repository;
    
    public TodoResponse create(CreateTodoRequest req) {
        Todo todo = new Todo();
        todo.setTitle(req.getTitle());
        todo.setCompleted(false);
        
        Todo saved = repository.save(todo);
        return toResponse(saved);
    }
    
    public List<TodoResponse> findAll(int page, int limit) {
        Pageable pageable = PageRequest.of(page, limit);
        return repository.findAll(pageable)
            .stream()
            .map(this::toResponse)
            .collect(Collectors.toList());
    }
    
    public TodoResponse findById(UUID id) {
        return repository.findById(id)
            .map(this::toResponse)
            .orElseThrow(() -> new RuntimeException("Não encontrado"));
    }
    
    public TodoResponse update(UUID id, UpdateTodoRequest req) {
        Todo todo = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Não encontrado"));
        
        if (req.getTitle() != null) {
            todo.setTitle(req.getTitle());
        }
        if (req.getCompleted() != null) {
            todo.setCompleted(req.getCompleted());
        }
        
        return toResponse(repository.save(todo));
    }
    
    public void delete(UUID id) {
        if (!repository.existsById(id)) {
            throw new RuntimeException("Não encontrado");
        }
        repository.deleteById(id);
    }
    
    private TodoResponse toResponse(Todo todo) {
        return new TodoResponse(
            todo.getId().toString(),
            todo.getTitle(),
            todo.isCompleted()
        );
    }
}

// Repository
public interface TodoRepository extends JpaRepository<Todo, UUID> {
    List<Todo> findByTitleContaining(String title);
    List<Todo> findByCompleted(boolean completed);
}
```

---

## 🎯 Checklist para Novas Features

```
[ ] 1. Criar Entity (Model)
[ ] 2. Criar Repository (extends JpaRepository)
[ ] 3. Criar RequestDTO
[ ] 4. Criar ResponseDTO
[ ] 5. Criar Service (lógica)
[ ] 6. Criar Controller (HTTP)
[ ] 7. Testar com cURL
[ ] 8. Adicionar validações
[ ] 9. Adicionar error handling
[ ] 10. Documentar com comentários
```

---

**Referência rápida para desenvolvimento Spring Boot**  
Atualizado: 9 de janeiro de 2026
