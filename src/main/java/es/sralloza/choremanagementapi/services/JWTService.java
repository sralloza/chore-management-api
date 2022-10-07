package es.sralloza.choremanagementapi.services;

import com.auth0.jwt.JWT;
import com.auth0.jwt.JWTVerifier;
import com.auth0.jwt.algorithms.Algorithm;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.UUID;

@Service
public class JWTService {
    public static final String ISSUER = "chore-management-api";
    @Value("${application-secret}")
    private String applicationSecret;

    public String generateToken(long issuedAt, long expiresAt) {
        return JWT.create()
            .withExpiresAt(Instant.ofEpochMilli(expiresAt))
            .withIssuedAt(Instant.ofEpochMilli(issuedAt))
            .withIssuer(ISSUER)
            .withSubject(UUID.randomUUID().toString())
            .sign(Algorithm.HMAC256(applicationSecret));
    }

    public Boolean isTokenValid(String token) {
        Algorithm algorithm = Algorithm.HMAC256(applicationSecret);
        JWTVerifier verifier = JWT.require(algorithm)
            .withIssuer(ISSUER)
            .build();
        try {
            verifier.verify(token);
        } catch (Exception e) {
            return false;
        }
        return true;
    }
}
