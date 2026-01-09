package com.todo.dto;

import java.util.UUID;

/**
 * LoginResponse DTO
 *
 * Retorna o JWT token e informações do usuário após
 * autenticação bem-sucedida.
 *
 * Nunca deve expor a senha!
 *
 * Exemplo de resposta:
 * {
 *   "id": "550e8400-e29b-41d4-a716-446655440000",
 *   "email": "user@example.com",
 *   "name": "João Silva",
 *   "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
 *   "expiresIn": 259200
 * }
 */
public class LoginResponse {

    private UUID id;
    private String email;
    private String name;
    private String token;
    private long expiresIn; // em segundos

    // Construtores
    public LoginResponse() {}

    public LoginResponse(UUID id, String email, String name, String token, long expiresIn) {
        this.id = id;
        this.email = email;
        this.name = name;
        this.token = token;
        this.expiresIn = expiresIn;
    }

    // Getters e Setters
    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public long getExpiresIn() {
        return expiresIn;
    }

    public void setExpiresIn(long expiresIn) {
        this.expiresIn = expiresIn;
    }
}
