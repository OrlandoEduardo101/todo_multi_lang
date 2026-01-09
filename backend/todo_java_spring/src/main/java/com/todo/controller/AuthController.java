package com.todo.controller;

import com.todo.dto.LoginRequest;
import com.todo.dto.LoginResponse;
import com.todo.dto.RegisterRequest;
import com.todo.dto.UserResponse;
import com.todo.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * AuthController - Controller de Autenticação
 *
 * @RestController = Anotação que diz ao Spring:
 *                  "Isso é um controller REST, transforma o retorno em JSON"
 *
 * @RequestMapping("/auth") = Prefixo de todas as rotas deste controller
 *                             Então @PostMapping("/register") fica em POST /auth/register
 *                             E @PostMapping("/login") fica em POST /auth/login
 */
@RestController
@RequestMapping("/auth")
public class AuthController {

    /**
     * @Autowired = Spring injeta automaticamente o UserService
     *
     * UserService = Serviço que contém lógica de registro e login
     */
    @Autowired
    private UserService userService;

    /**
     * Endpoint: POST /auth/register
     *
     * @PostMapping = Marca que é uma requisição POST
     * @RequestBody = Spring automaticamente converte JSON para RegisterRequest
     * ResponseEntity = Permite retornar status HTTP customizado
     *
     * Fluxo:
     * 1. Cliente envia POST /auth/register com { email, password, name }
     * 2. Spring converte JSON em RegisterRequest
     * 3. Chamamos userService.register()
     * 4. Retornamos 201 (CREATED) + dados do usuário
     *
     * Se erro:
     * - Email inválido → 400 BAD REQUEST
     * - Email já existe → 400 BAD REQUEST
     * - Erro interno → 500 INTERNAL SERVER ERROR
     */
    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody RegisterRequest request) {
        try {
            // Chamamos o serviço para registrar
            UserResponse user = userService.register(request);

            // ✅ Sucesso! Retorna 201 CREATED com dados do usuário
            return ResponseEntity
                    .status(HttpStatus.CREATED)
                    .body(user);

        } catch (IllegalArgumentException e) {
            // ❌ Erro de validação (email duplicado, campos vazios, etc)
            // Retorna 400 BAD REQUEST com mensagem de erro
            return ResponseEntity
                    .status(HttpStatus.BAD_REQUEST)
                    .body(new ErrorResponse(e.getMessage()));

        } catch (Exception e) {
            // ❌ Erro inesperado
            // Retorna 500 INTERNAL SERVER ERROR
            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("Erro ao registrar usuário: " + e.getMessage()));
        }
    }

    /**
     * Endpoint: POST /auth/login
     *
     * Autentica um usuário e retorna JWT token
     *
     * Fluxo:
     * 1. Cliente envia POST /auth/login com { email, password }
     * 2. Spring converte JSON em LoginRequest
     * 3. UserService valida credenciais
     * 4. Se válido → Gera JWT token
     * 5. Retorna token + info do usuário
     *
     * Resposta (200 OK):
     * {
     *   "id": "550e8400-e29b-41d4-a716-446655440000",
     *   "email": "user@example.com",
     *   "name": "João Silva",
     *   "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
     *   "expiresIn": 259200
     * }
     *
     * Se erro:
     * - Email/senha inválidos → 401 UNAUTHORIZED
     * - Erro interno → 500 INTERNAL SERVER ERROR
     */
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {
        try {
            // Chamamos o serviço para fazer login
            LoginResponse response = userService.login(request);

            // ✅ Sucesso! Retorna 200 OK com token
            return ResponseEntity
                    .status(HttpStatus.OK)
                    .body(response);

        } catch (IllegalArgumentException e) {
            // ❌ Credenciais inválidas
            // Retorna 401 UNAUTHORIZED
            return ResponseEntity
                    .status(HttpStatus.UNAUTHORIZED)
                    .body(new ErrorResponse(e.getMessage()));

        } catch (Exception e) {
            // ❌ Erro inesperado
            // Retorna 500 INTERNAL SERVER ERROR
            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("Erro ao fazer login: " + e.getMessage()));
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
