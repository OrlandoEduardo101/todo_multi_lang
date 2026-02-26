package com.todo.controller;

import com.todo.dto.todo.CreateTodoRequest;
import com.todo.dto.todo.TodoListResponse;
import com.todo.dto.todo.TodoResponse;
import com.todo.dto.todo.UpdateTodoRequest;
import com.todo.service.TodoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/todos")
public class TodoController {

    @Autowired
    private TodoService todoService;

    private UUID getUserId(Authentication auth) {
        return UUID.fromString(auth.getName());
    }

    @GetMapping
    public ResponseEntity<?> list(
            Authentication auth,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int limit,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) Boolean completed,
            @RequestParam(defaultValue = "createdAt") String sort,
            @RequestParam(defaultValue = "desc") String order
    ) {
        try {
            UUID userId = getUserId(auth);

            TodoListResponse response = todoService.listByUser(
                    userId, page, limit, search, completed, sort, order
            );

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Erro ao listar tarefas"));
        }
    }

    @PostMapping
    public ResponseEntity<?> create(
            Authentication auth,
            @RequestBody CreateTodoRequest request
    ) {
        try {
            UUID userId = getUserId(auth);
            TodoResponse created = todoService.create(userId, request);
            return ResponseEntity.status(HttpStatus.CREATED).body(created);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Erro ao criar tarefa"));
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getById(
            Authentication auth,
            @PathVariable UUID id
    ) {
        try {
            UUID userId = getUserId(auth);
            TodoResponse todo = todoService.getById(userId, id);
            return ResponseEntity.ok(todo);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Erro ao buscar tarefa"));
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> update(
            Authentication auth,
            @PathVariable UUID id,
            @RequestBody UpdateTodoRequest request
    ) {
        try {
            UUID userId = getUserId(auth);
            TodoResponse updated = todoService.update(userId, id, request);
            return ResponseEntity.ok(updated);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Erro ao atualizar tarefa"));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(
            Authentication auth,
            @PathVariable UUID id
    ) {
        try {
            UUID userId = getUserId(auth);
            todoService.delete(userId, id);
            return ResponseEntity.ok(Map.of("message", "Tarefa deletada com sucesso"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Erro ao deletar tarefa"));
        }
    }
}
