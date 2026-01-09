package com.todo.config;

import com.todo.security.JwtAuthenticationFilter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import static org.springframework.security.config.Customizer.withDefaults;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;

/**
 * SecurityConfig
 *
 * Configuração central de segurança do Spring Security.
 *
 * Responsável por:
 * 1. Configurar PasswordEncoder (BCrypt)
 * 2. Definir qual filtro de JWT usar
 * 3. Configurar CORS
 * 4. Definir endpoints públicos/privados
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Autowired
    private JwtAuthenticationFilter jwtAuthenticationFilter;

    /**
     * PasswordEncoder Bean
     *
     * @Bean = Spring cria uma instância única (Singleton) e injeta onde precisar
     *
     * BCryptPasswordEncoder = Implementação de PasswordEncoder usando BCrypt
     * - Usa strength 10 (padrão)
     * - Força de processamento equilibrada entre segurança e performance
     *
     * Métodos principais:
     * - encode(String) = Criptografa uma senha
     * - matches(String, String) = Compara senha com hash criptografado
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    /**
     * SecurityFilterChain Configuration
     *
     * Define a cadeia de filtros de segurança.
     *
     * Fluxo de requisição:
     * 1. Requisição chega
     * 2. JwtAuthenticationFilter processa (extrai token, valida)
     * 3. SecurityFilterChain verifica autorização
     * 4. Se OK → passa para controller
     * 5. Se NOT OK → retorna 401/403
     */
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            // 1️⃣ Desabilitar CSRF (não precisa para JWT/REST)
            .csrf(csrf -> csrf.disable())

            // 2️⃣ Configurar CORS
            .cors(withDefaults())

            // 3️⃣ Configurar autorização
            .authorizeHttpRequests(auth -> auth
                // ✅ Endpoints públicos (sem autenticação)
                .requestMatchers("/auth/**").permitAll()           // /auth/register, /auth/login
                .requestMatchers("/docs/**").permitAll()           // Documentação
                .requestMatchers("/swagger-ui/**").permitAll()     // Swagger UI
                .requestMatchers("/v3/api-docs/**").permitAll()    // OpenAPI

                // 🔒 Endpoints protegidos (com autenticação)
                .requestMatchers("/api/**").authenticated()        // /api/todos, /api/users, etc

                // Tudo mais → requer autenticação
                .anyRequest().authenticated()
            )

            // 4️⃣ Adicionar JWT Filter
            // Executa ANTES de UsernamePasswordAuthenticationFilter
            .addFilterBefore(
                jwtAuthenticationFilter,
                UsernamePasswordAuthenticationFilter.class
            )

            // 5️⃣ Tratamento de exceções
            .exceptionHandling(ex -> ex
                .authenticationEntryPoint((req, res, exc) -> {
                    res.setContentType("application/json");
                    res.setStatus(401);
                    res.getWriter().write("{\"error\": \"Não autenticado\"}");
                })
                .accessDeniedHandler((req, res, exc) -> {
                    res.setContentType("application/json");
                    res.setStatus(403);
                    res.getWriter().write("{\"error\": \"Acesso negado\"}");
                })
            );

        return http.build();
    }

    /**
     * CORS Configuration
     *
     * Permite requisições cross-origin (diferentes origens)
     *
     * Exemplo:
     * - Frontend em http://localhost:3000
     * - Backend em http://localhost:8080
     * - Sem CORS: ❌ Bloqueado
     * - Com CORS: ✅ Permitido
     */
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();

        // Origens permitidas
        configuration.addAllowedOrigin("*");                // Todas (mais permissivo)

        // Métodos permitidos
        configuration.addAllowedMethod("*");                // GET, POST, PUT, DELETE, etc

        // Headers permitidos
        configuration.addAllowedHeader("*");                // Content-Type, Authorization, etc

        // Headers que cliente pode ler
        configuration.addExposedHeader("Authorization");    // Cliente pode ler token

        // Permitir credentials
        configuration.setAllowCredentials(true);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
