package com.todo.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.ArrayList;

/**
 * JwtAuthenticationFilter
 *
 * Intercepta TODAS as requisições HTTP para:
 * 1. Extrair o JWT token do header Authorization
 * 2. Validar o token
 * 3. Extrair user_id do token
 * 4. Adicionar ao SecurityContext (contexto de segurança)
 * 5. Passar para o controller
 *
 * Fluxo:
 *
 * Cliente envia:
 * GET /api/todos
 * Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
 *                      │
 *                      └── Token aqui
 *
 * Filter:
 * 1. Extrai token do header
 * 2. Valida com JwtTokenProvider
 * 3. Se válido → Extrai user_id
 * 4. Cria UsernamePasswordAuthenticationToken
 * 5. Adiciona ao SecurityContextHolder
 * 6. Passa para próximo filter
 *
 * Controller:
 * public ResponseEntity<?> getTodos(
 *     @AuthenticationPrincipal UserDetails user // ← Vem do SecurityContext!
 * ) { ... }
 *
 *
 * O que é OncePerRequestFilter?
 * - Garante que o filtro execute UMA VEZ por requisição
 * - Mesmo que haja forwarding/dispatching interno
 */
@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    /**
     * Método chamado para cada requisição HTTP
     *
     * @param request - Requisição HTTP
     * @param response - Resposta HTTP
     * @param filterChain - Cadeia de filtros
     */
    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain) throws ServletException, IOException {

        try {
            // 1️⃣ EXTRAIR token do header
            String jwt = extractTokenFromRequest(request);

            // 2️⃣ VALIDAR token
            if (jwt != null && jwtTokenProvider.validateToken(jwt)) {
                // 3️⃣ EXTRAIR user_id do token
                var userId = jwtTokenProvider.getUserIdFromToken(jwt);
                var email = jwtTokenProvider.getEmailFromToken(jwt);

                // 4️⃣ CRIAR autenticação
                // UsernamePasswordAuthenticationToken = token de autenticação Spring
                UsernamePasswordAuthenticationToken authentication =
                        new UsernamePasswordAuthenticationToken(
                                userId.toString(),    // principal (quem é)
                                null,                  // credentials (não precisa)
                                new ArrayList<>()      // authorities/roles (vazias por agora)
                        );

                // 5️⃣ ADICIONAR ao contexto de segurança
                SecurityContextHolder.getContext().setAuthentication(authentication);

                // Log para debug (remover em produção)
                System.out.println("✅ JWT validado para usuário: " + email);
            }

        } catch (Exception ex) {
            System.err.println("❌ Erro ao processar JWT: " + ex.getMessage());
        }

        // 6️⃣ PASSAR para próximo filtro
        filterChain.doFilter(request, response);
    }

    /**
     * Extrai token do header Authorization
     *
     * Formato esperado:
     * Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
     *                       └── Token aqui
     *
     * @param request - Requisição HTTP
     * @return Token ou null se não encontrar
     */
    private String extractTokenFromRequest(HttpServletRequest request) {
        // 1. Pega header "Authorization"
        String authHeader = request.getHeader("Authorization");

        // 2. Se header é nulo ou vazio, retorna null
        if (authHeader == null || authHeader.isEmpty()) {
            return null;
        }

        // 3. Se não começa com "Bearer ", retorna null
        if (!authHeader.startsWith("Bearer ")) {
            return null;
        }

        // 4. Remove "Bearer " e retorna token
        return authHeader.substring(7); // "Bearer ".length() = 7
    }
}
