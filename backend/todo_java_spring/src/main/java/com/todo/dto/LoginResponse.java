package com.todo.dto;

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
    private String token;
    private String tokenType;
    private long expiresIn; // em segundos
    private UserResponse user;

    // Construtores
    public LoginResponse() {}

    public LoginResponse(String token, String tokenType, long expiresIn, UserResponse user) {
        this.token = token;
        this.tokenType = tokenType;
        this.expiresIn = expiresIn;
        this.user = user;
    }

    // Getters e Setters
    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public String getTokenType() {
        return tokenType;
    }

    public void setTokenType(String tokenType) {
        this.tokenType = tokenType;
    }

    public long getExpiresIn() {
        return expiresIn;
    }

    public void setExpiresIn(long expiresIn) {
        this.expiresIn = expiresIn;
    }

    public UserResponse getUser() {
        return user;
    }

    public void setUser(UserResponse user) {
        this.user = user;
    }
}
