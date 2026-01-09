package com.todo.dto;

/**
 * DTO para requisição de registro de usuário
 *
 * DTO = Data Transfer Object
 * Usamos DTOs para:
 * 1. Validar dados da entrada
 * 2. Separar dados recebidos dos dados da entidade
 * 3. Documentar quais campos são esperados
 */
public class RegisterRequest {

    private String email;
    private String password;
    private String name;

    // Construtores
    public RegisterRequest() {
    }

    public RegisterRequest(String email, String password, String name) {
        this.email = email;
        this.password = password;
        this.name = name;
    }

    // Getters e Setters
    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
