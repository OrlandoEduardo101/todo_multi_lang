package com.todo.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

/**
 * LoginRequest DTO
 *
 * Recebe credenciais do usuário (email e senha)
 * para autenticação.
 *
 * Fluxo:
 * 1. Cliente envia JSON: {"email": "user@example.com", "password": "123456"}
 * 2. Spring desserializa para LoginRequest
 * 3. AuthController passa para UserService.login()
 * 4. Retorna JWT token se válido
 */
public class LoginRequest {

    @Email(message = "Email deve ser válido")
    @NotBlank(message = "Email é obrigatório")
    private String email;

    @NotBlank(message = "Senha é obrigatória")
    private String password;

    // Construtores
    public LoginRequest() {}

    public LoginRequest(String email, String password) {
        this.email = email;
        this.password = password;
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
}
