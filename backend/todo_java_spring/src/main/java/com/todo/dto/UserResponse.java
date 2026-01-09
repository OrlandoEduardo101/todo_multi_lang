package com.todo.dto;

/**
 * DTO para resposta de registro bem-sucedido
 *
 * Usamos um DTO de resposta para:
 * 1. Não expor dados sensíveis (nunca enviamos a senha!)
 * 2. Estruturar a resposta de forma consistente
 * 3. Documentar o que o cliente receberá
 */
public class UserResponse {

    private String id;
    private String email;
    private String name;

    // Construtores
    public UserResponse() {
    }

    public UserResponse(String id, String email, String name) {
        this.id = id;
        this.email = email;
        this.name = name;
    }

    // Getters e Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
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
}
