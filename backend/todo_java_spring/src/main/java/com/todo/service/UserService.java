package com.todo.service;

import com.todo.dto.LoginRequest;
import com.todo.dto.LoginResponse;
import com.todo.dto.RegisterRequest;
import com.todo.dto.UserResponse;
import com.todo.model.User;
import com.todo.repository.UserRepository;
import com.todo.security.JwtTokenProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Optional;

/**
 * UserService - Serviço de usuários
 *
 * @Service = Anotação que diz ao Spring: "Isso é um serviço, gerencia a injeção de dependência"
 *
 * Responsabilidades:
 * 1. Validar dados
 * 2. Criptografar senhas
 * 3. Gerar JWT tokens
 * 4. Chamar o repository para salvar
 * 5. Tratamento de erros
 */
@Service
public class UserService {

    /**
     * @Autowired = Spring injeta automaticamente a dependência
     *
     * PasswordEncoder = Classe do Spring Security que criptografa senhas
     * Usamos BCrypt (já configurado no Spring Security)
     */
    @Autowired
    private PasswordEncoder passwordEncoder;

    /**
     * UserRepository = Objeto que acessa o banco de dados
     * Criamos a interface, o Spring cria a implementação automaticamente
     */
    @Autowired
    private UserRepository userRepository;

    /**
     * JwtTokenProvider = Gera e valida JWT tokens
     */
    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    /**
     * Método para registrar um novo usuário
     *
     * @param request - Dados do usuário (email, password, name)
     * @return - Resposta com dados do usuário criado (sem a senha!)
     * @throws - Lança exceção se email já existe
     */
    public LoginResponse register(RegisterRequest request) {
        // 1️⃣ Validar se email já existe
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("Email já registrado");
        }

        // 2️⃣ Validar se campos obrigatórios estão preenchidos
        if (request.getEmail() == null || request.getEmail().isEmpty()) {
            throw new IllegalArgumentException("Email é obrigatório");
        }
        if (request.getPassword() == null || request.getPassword().isEmpty()) {
            throw new IllegalArgumentException("Senha é obrigatória");
        }

        // 3️⃣ Criar novo objeto User
        User user = new User();
        user.setEmail(request.getEmail());
        user.setName(request.getName());

        // 4️⃣ ✨ CRIPTOGRAFAR A SENHA ✨
        // passwordEncoder.encode() = Usa BCrypt para criptografar
        // Uma vez criptografada, NÃO pode ser descriptografada
        // Apenas comparamos depois com passwordEncoder.matches()
        String encryptedPassword = passwordEncoder.encode(request.getPassword());
        user.setPassword(encryptedPassword);

        // 5️⃣ Salvar no banco de dados
        User savedUser = userRepository.save(user);

        String token = jwtTokenProvider.generateToken(savedUser.getId(), savedUser.getEmail());
        long expiresIn = jwtTokenProvider.getExpirationSeconds();

        UserResponse userResponse = new UserResponse(
            savedUser.getId().toString(),
            savedUser.getEmail(),
            savedUser.getName()
        );

        return new LoginResponse(token, "Bearer", expiresIn, userResponse);
    }

    /**
     * Método para fazer login
     *
     * Fluxo:
     * 1. Recebe email e senha
     * 2. Busca usuário no banco
     * 3. Valida senha com BCrypt
     * 4. Se válido → Gera JWT token
     * 5. Retorna token + dados do usuário
     *
     * @param request - LoginRequest (email, password)
     * @return - LoginResponse (id, email, name, token, expiresIn)
     * @throws - Lança exceção se email/senha inválidos
     *
     * Exemplo de resposta:
     * {
     *   "id": "uuid-aqui",
     *   "email": "user@example.com",
     *   "name": "João Silva",
     *   "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
     *   "expiresIn": 259200
     * }
     */
    public LoginResponse login(LoginRequest request) {
        // 1️⃣ VALIDAR entrada
        if (request.getEmail() == null || request.getEmail().isEmpty()) {
            throw new IllegalArgumentException("Email é obrigatório");
        }
        if (request.getPassword() == null || request.getPassword().isEmpty()) {
            throw new IllegalArgumentException("Senha é obrigatória");
        }

        // 2️⃣ BUSCAR usuário no banco
        Optional<User> userOpt = userRepository.findByEmail(request.getEmail());

        if (userOpt.isEmpty()) {
            // ❌ Usuário não existe
            throw new IllegalArgumentException("Email ou senha inválidos");
        }

        User user = userOpt.get();

        // 3️⃣ VALIDAR senha
        // passwordEncoder.matches(senhaDigitada, senhaArmazenada)
        // Compara a senha digitada com o hash armazenado (SEM descriptografar!)
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            // ❌ Senha incorreta
            throw new IllegalArgumentException("Email ou senha inválidos");
        }

        // ✅ Email e senha são válidos!

        // 4️⃣ GERAR JWT token
        String token = jwtTokenProvider.generateToken(user.getId(), user.getEmail());
        long expiresIn = jwtTokenProvider.getExpirationSeconds();

        // 5️⃣ RETORNAR response
        UserResponse userResponse = new UserResponse(
                user.getId().toString(),
                user.getEmail(),
                user.getName()
        );

        return new LoginResponse(token, "Bearer", expiresIn, userResponse);
    }
}

