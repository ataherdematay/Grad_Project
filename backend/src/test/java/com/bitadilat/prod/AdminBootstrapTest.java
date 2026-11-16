package com.bitadilat.prod;

import static org.assertj.core.api.Assertions.assertThat;

import com.bitadilat.ApiTestBase;
import com.bitadilat.user.AdminBootstrap;
import com.bitadilat.user.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;

class AdminBootstrapTest extends ApiTestBase {

    private static final String PASSWORD = "Prod-Admin-2026-xyz1";

    @Autowired UserRepository users;
    @Autowired PasswordEncoder encoder;
    @Autowired JdbcTemplate jdbc;

    @BeforeEach
    void clean() {
        jdbc.update("delete from users where is_admin or lower(email) like '%@bootstrap.test'");
    }

    private AdminBootstrap bootstrap(String email, String password) {
        return new AdminBootstrap(users, encoder, email, password);
    }

    @Test
    void createsAdminOnceWithBcryptHash() {
        assertThat(bootstrap("root@bootstrap.test", PASSWORD).ensureAdmin()).isTrue();
        var admin = users.findByEmailIgnoreCase("root@bootstrap.test").orElseThrow();
        assertThat(admin.isAdmin()).isTrue();
        assertThat(admin.getPasswordHash()).startsWith("$2").doesNotContain(PASSWORD);
        assertThat(encoder.matches(PASSWORD, admin.getPasswordHash())).isTrue();

        // idempotent
        assertThat(bootstrap("root@bootstrap.test", PASSWORD).ensureAdmin()).isFalse();
        assertThat(bootstrap("other@bootstrap.test", PASSWORD).ensureAdmin()).isFalse();
        assertThat(jdbc.queryForObject("select count(*) from users where is_admin", Integer.class)).isEqualTo(1);
    }

    @Test
    void missingOrInvalidSettingsCreateNothingAndDoNotThrow() {
        assertThat(bootstrap("", "").ensureAdmin()).isFalse();
        assertThat(bootstrap("root@bootstrap.test", "").ensureAdmin()).isFalse();
        assertThat(bootstrap("not-an-email", PASSWORD).ensureAdmin()).isFalse();
        assertThat(bootstrap("root@bootstrap.test", "short1").ensureAdmin()).isFalse();
        assertThat(bootstrap("root@bootstrap.test", "onlylettersnodigits").ensureAdmin()).isFalse();
        assertThat(jdbc.queryForObject("select count(*) from users where is_admin", Integer.class)).isZero();
    }

    @Test
    void existingRegularUserIsNeverPromoted() {
        jdbc.update("insert into users (full_name, email, password_hash) values ('X', 'normal@bootstrap.test', 'h')");
        assertThat(bootstrap("normal@bootstrap.test", PASSWORD).ensureAdmin()).isFalse();
        assertThat(users.findByEmailIgnoreCase("normal@bootstrap.test").orElseThrow().isAdmin()).isFalse();
    }
}
