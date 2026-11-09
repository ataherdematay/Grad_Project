package com.bitadilat.payment;

import org.springframework.boot.flyway.autoconfigure.FlywayMigrationStrategy;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Condition;
import org.springframework.context.annotation.ConditionContext;
import org.springframework.context.annotation.Conditional;
import org.springframework.core.type.AnnotatedTypeMetadata;
import org.testcontainers.DockerClientFactory;
import org.testcontainers.postgresql.PostgreSQLContainer;

/**
 * Testler her zaman gerçek PostgreSQL üzerinde koşar. Docker açıksa geçici bir konteyner kullanılır;
 * değilse test ayarlarındaki yerel {@code bitadilat_test} veritabanı. Her bağlamda şema sıfırdan kurulur.
 */
@TestConfiguration(proxyBeanMethods = false)
public class TestDatabaseConfig {

    @Bean
    @ServiceConnection
    @Conditional(DockerAvailable.class)
    PostgreSQLContainer postgres() {
        return new PostgreSQLContainer("postgres:16-alpine");
    }

    /** Yerel veritabanında önceki çalıştırmadan kalan satırlar testleri etkilemesin. */
    @Bean
    FlywayMigrationStrategy cleanThenMigrate() {
        return flyway -> {
            flyway.clean();
            flyway.migrate();
        };
    }

    static class DockerAvailable implements Condition {
        @Override
        public boolean matches(ConditionContext context, AnnotatedTypeMetadata metadata) {
            try {
                return DockerClientFactory.instance().isDockerAvailable();
            } catch (RuntimeException e) {
                return false;
            }
        }
    }
}
