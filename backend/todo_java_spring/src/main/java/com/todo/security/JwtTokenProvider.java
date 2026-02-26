package com.todo.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.util.Date;
import java.util.UUID;

/**
 * JwtTokenProvider
 *
 * Responsável por:
 * 1. Gerar JWT tokens após login bem-sucedido
 * 2. Validar JWT tokens em requisições protegidas
 * 3. Extrair informações do token (user_id, claims)
 *
 * JWT = JSON Web Token
 * Formato: header.payload.signature
 *
 * Exemplo:
 * eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9
 * .eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ
 * .SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
 *
 * Como funciona:
 * 1. header: tipo de token (JWT) e algoritmo (HS256)
 * 2. payload: dados do usuário (user_id, email, etc) + exp (expiração)
 * 3. signature: assinatura com chave secreta
 *
 * Segurança:
 * - Apenas o servidor conhece a chave secreta (JWT_SECRET)
 * - Se alguém tentar modificar o token, a assinatura fica inválida
 * - Token expira após expiresIn segundos
 */
@Component
public class JwtTokenProvider {

    @Value("${jwt.secret:seu-secret-key-muito-seguro-com-minimo-32-caracteres}")
    private String jwtSecret;

    @Value("${jwt.expiration:259200}") // 3 dias em segundos
    private long jwtExpirationSeconds;

    /**
     * Gera um JWT token para um usuário
     *
     * @param userId - ID do usuário
     * @param email - Email do usuário
     * @return JWT token como String
     *
     * Exemplo:
     * String token = jwtTokenProvider.generateToken(user.getId(), user.getEmail());
     */
    public String generateToken(UUID userId, String email) {
        // Calcula data de expiração
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + (jwtExpirationSeconds * 1000));

        // Cria token com claims (dados)
        return Jwts.builder()
            .setSubject(userId.toString())                 // sub: ID do usuário
            .claim("email", email)                        // email: email do usuário
            .setIssuedAt(now)                              // iat: data de emissão
            .setExpiration(expiryDate)                     // exp: data de expiração
                .signWith(Keys.hmacShaKeyFor(jwtSecret.getBytes()), SignatureAlgorithm.HS256)
                .compact();
    }

    /**
     * Extrai o user_id (subject) do token
     *
     * @param token - JWT token
     * @return UUID do usuário
     *
     * Exemplo:
     * UUID userId = jwtTokenProvider.getUserIdFromToken(token);
     */
    public UUID getUserIdFromToken(String token) {
        Claims claims = Jwts.parserBuilder()
                .setSigningKey(Keys.hmacShaKeyFor(jwtSecret.getBytes()))
                .build()
                .parseClaimsJws(token)
                .getBody();

        return UUID.fromString(claims.getSubject());
    }

    /**
     * Extrai o email do token
     *
     * @param token - JWT token
     * @return Email do usuário
     */
    public String getEmailFromToken(String token) {
        Claims claims = Jwts.parserBuilder()
                .setSigningKey(Keys.hmacShaKeyFor(jwtSecret.getBytes()))
                .build()
                .parseClaimsJws(token)
                .getBody();

        return claims.get("email", String.class);
    }

    /**
     * Valida se o token é válido
     *
     * Verifica:
     * 1. Assinatura está correta
     * 2. Token não expirou
     * 3. Formato está correto
     *
     * @param token - JWT token
     * @return true se válido, false se inválido ou expirado
     *
     * Exemplo:
     * if (jwtTokenProvider.validateToken(token)) {
     *     // Token é válido, permitir acesso
     * }
     */
    public boolean validateToken(String token) {
        try {
            Jwts.parserBuilder()
                    .setSigningKey(Keys.hmacShaKeyFor(jwtSecret.getBytes()))
                    .build()
                    .parseClaimsJws(token);
            return true;
        } catch (SecurityException e) {
            System.err.println("JWT signature inválida: " + e);
        } catch (MalformedJwtException e) {
            System.err.println("JWT inválido: " + e);
        } catch (ExpiredJwtException e) {
            System.err.println("JWT expirou: " + e);
        } catch (UnsupportedJwtException e) {
            System.err.println("JWT não suportado: " + e);
        } catch (IllegalArgumentException e) {
            System.err.println("JWT claims string vazio: " + e);
        }
        return false;
    }

    /**
     * Retorna tempo de expiração em segundos
     *
     * Útil para cliente saber quanto tempo o token dura
     */
    public long getExpirationSeconds() {
        return jwtExpirationSeconds;
    }
}
