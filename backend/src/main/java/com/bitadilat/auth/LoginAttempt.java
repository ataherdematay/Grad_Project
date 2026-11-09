package com.bitadilat.auth;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;

/** Giriş denemesi. Tanımlayıcı (e-posta/telefon) yalnızca SHA-256 özeti olarak tutulur. */
@Entity
@Table(name = "login_attempts")
@Getter
@Setter
@NoArgsConstructor
public class LoginAttempt {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private String identifierHash;

    private String ip;

    @Column(nullable = false)
    private boolean success;

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private Instant createdAt;
}
