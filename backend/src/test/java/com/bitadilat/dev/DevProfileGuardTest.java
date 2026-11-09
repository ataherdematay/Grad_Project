package com.bitadilat.dev;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import org.junit.jupiter.api.Test;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.core.env.MapPropertySource;
import java.util.Map;

class DevProfileGuardTest {

    private AnnotationConfigApplicationContext context(String profile, Map<String, Object> props) {
        AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext();
        ctx.getEnvironment().setActiveProfiles(profile);
        ctx.getEnvironment().getPropertySources().addFirst(new MapPropertySource("t", props));
        ctx.register(DevProfileGuard.class);
        return ctx;
    }

    @Test
    void devProfileOnWildcardAddressFailsStartup() {
        try (var ctx = context("dev", Map.of("server.address", "0.0.0.0"))) {
            assertThatThrownBy(ctx::refresh)
                    .hasStackTraceContaining("dev profili yalnızca 127.0.0.1 üzerinde çalışır")
                    .hasStackTraceContaining("SPRING_PROFILES_ACTIVE=prod");
        }
    }

    @Test
    void devProfileOnLoopbackStarts() {
        for (String address : new String[] {"127.0.0.1", "::1", "localhost"}) {
            try (var ctx = context("dev", Map.of("server.address", address))) {
                ctx.refresh();
                assertThat(ctx.getBeansOfType(DevProfileGuard.class)).hasSize(1);
            }
        }
    }

    @Test
    void emptyOrExternalAddressIsRejected() {
        for (String address : new String[] {"", " ", "10.0.0.5", "192.168.1.2", "::"}) {
            assertThatThrownBy(() -> DevProfileGuard.check(address)).isInstanceOf(IllegalStateException.class);
        }
        assertThatThrownBy(() -> DevProfileGuard.check(null)).isInstanceOf(IllegalStateException.class);
        assertThatCode(() -> DevProfileGuard.check("127.0.0.1")).doesNotThrowAnyException();
    }

    @Test
    void guardIsNotActiveOutsideDevProfile() {
        try (var ctx = context("prod", Map.of("server.address", "0.0.0.0"))) {
            ctx.refresh();
            assertThat(ctx.getBeansOfType(DevProfileGuard.class)).isEmpty();
        }
    }
}
