package com.todo.service;

import com.todo.dto.todo.CreateTodoRequest;
import com.todo.dto.todo.TodoListResponse;
import com.todo.dto.todo.TodoResponse;
import com.todo.dto.todo.UpdateTodoRequest;
import com.todo.model.Todo;
import com.todo.model.User;
import com.todo.repository.TodoRepository;
import com.todo.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
public class TodoService {

    @Autowired
    private TodoRepository todoRepository;

    @Autowired
    private UserRepository userRepository;

    public TodoResponse create(UUID userId, CreateTodoRequest request) {
        if (request.getTitle() == null || request.getTitle().trim().isEmpty()) {
            throw new IllegalArgumentException("Título é obrigatório");
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("Usuário não encontrado"));

        Todo todo = new Todo();
        todo.setUser(user);
        todo.setTitle(request.getTitle().trim());
        todo.setDescription(request.getDescription());
        todo.setCompleted(false);

        Todo saved = todoRepository.save(todo);
        return toResponse(saved);
    }

    public TodoResponse getById(UUID userId, UUID todoId) {
        Todo todo = todoRepository.findByIdAndUserIdAndDeletedAtIsNull(todoId, userId)
                .orElseThrow(() -> new IllegalArgumentException("TODO não encontrado"));
        return toResponse(todo);
    }

    public TodoListResponse listByUser(
            UUID userId,
            int page,
            int limit,
            String search,
            Boolean completed,
            String sort,
            String order
    ) {
        int safePage = page < 1 ? 1 : page;
        int safeLimit = (limit < 1 || limit > 100) ? 10 : limit;

        String safeSort = normalizeSort(sort);
        Sort.Direction direction = normalizeDirection(order);

        Pageable pageable = PageRequest.of(safePage - 1, safeLimit, Sort.by(direction, safeSort));

        Page<Todo> resultPage = todoRepository.findByUserWithFilters(userId, search, completed, pageable);
        long total = todoRepository.countByUserWithFilters(userId, search, completed);

        List<TodoResponse> results = resultPage.getContent().stream()
                .map(this::toResponse)
                .toList();

        return new TodoListResponse(
                safePage,
                safeLimit,
                total,
                search,
                completed,
                safeSort,
                direction.name().toLowerCase(),
                results
        );
    }

    public TodoResponse update(UUID userId, UUID todoId, UpdateTodoRequest request) {
        Todo todo = todoRepository.findByIdAndUserIdAndDeletedAtIsNull(todoId, userId)
                .orElseThrow(() -> new IllegalArgumentException("TODO não encontrado"));

        if (request.getTitle() != null) {
            String title = request.getTitle().trim();
            if (title.isEmpty()) {
                throw new IllegalArgumentException("Título não pode ser vazio");
            }
            todo.setTitle(title);
        }

        if (request.getDescription() != null) {
            todo.setDescription(request.getDescription());
        }

        if (request.getCompleted() != null) {
            todo.setCompleted(request.getCompleted());
        }

        Todo updated = todoRepository.save(todo);
        return toResponse(updated);
    }

    public void delete(UUID userId, UUID todoId) {
        Todo todo = todoRepository.findByIdAndUserIdAndDeletedAtIsNull(todoId, userId)
                .orElseThrow(() -> new IllegalArgumentException("TODO não encontrado"));

        todo.setDeletedAt(LocalDateTime.now());
        todoRepository.save(todo);
    }

    private TodoResponse toResponse(Todo todo) {
        return new TodoResponse(
                todo.getId(),
                todo.getTitle(),
                todo.getDescription(),
                todo.getCompleted(),
                todo.getCreatedAt(),
                todo.getUpdatedAt()
        );
    }

    private String normalizeSort(String sort) {
        if (sort == null || sort.isBlank()) return "createdAt";
        return switch (sort) {
            case "createdAt", "title", "completed" -> sort;
            default -> "createdAt";
        };
    }

    private Sort.Direction normalizeDirection(String order) {
        if ("asc".equalsIgnoreCase(order)) return Sort.Direction.ASC;
        return Sort.Direction.DESC;
    }
}
