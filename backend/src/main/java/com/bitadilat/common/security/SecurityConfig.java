package com.bitadilat.common.security;

import jakarta.servlet.http.HttpServletRequest;
import java.util.Arrays;
import java.util.List;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.server.resource.web.BearerTokenResolver;
import org.springframework.security.oauth2.server.resource.web.DefaultBearerTokenResolver;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

/**
 * Stateless JWT. Herkese açık: kimlik uç noktaları, katalog okuma, OpenAPI (yalnız dev'de açık) ve
 * prototip için eski /api/offers, /api/payments, /preview. Diğer /api/v1/** kimlik ister.
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    SecurityFilterChain apiChain(HttpSecurity http, JwtAuthConverter converter, SecurityErrorHandlers errors,
                                 @Qualifier("corsConfigurationSource") CorsConfigurationSource cors,
                                 BearerTokenResolver resolver) throws Exception {
        http
                .csrf(AbstractHttpConfigurer::disable)
                .cors(c -> c.configurationSource(cors))
                .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .formLogin(AbstractHttpConfigurer::disable)
                .httpBasic(AbstractHttpConfigurer::disable)
                .logout(AbstractHttpConfigurer::disable)
                .requestCache(AbstractHttpConfigurer::disable)
                // Prototip (preview/index.html) ekranları aynı origin'den iframe ile açar; varsayılan DENY onu bozar.
                .headers(h -> h.frameOptions(f -> f.sameOrigin()))
                .authorizeHttpRequests(a -> a
                        .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                        .requestMatchers("/api/v1/auth/**").permitAll()
                        .requestMatchers(HttpMethod.GET, "/api/v1/categories", "/api/v1/categories/**",
                                "/api/v1/districts").permitAll()
                        // Medya içeriği: erişimi imza belirler (HMAC + son kullanma), Authorization gerekmez.
                        .requestMatchers(HttpMethod.GET, "/api/v1/media/*/content").permitAll()
                        .requestMatchers("/v3/api-docs/**", "/swagger-ui/**", "/swagger-ui.html").permitAll()
                        // Banka dönüşü ve APP kanalı bitiş sayfası her profilde açık (bankanın tarayıcısı kimlik taşımaz).
                        .requestMatchers(HttpMethod.POST, "/api/payments/3ds/callback").permitAll()
                        .requestMatchers(HttpMethod.GET, "/api/payments/3ds/done").permitAll()
                        // Prototip uyumu: eski uç noktalar kimliksiz kalır (yalnız dev'de denetleyicisi vardır).
                        .requestMatchers("/api/offers/**", "/api/payments/**", "/preview/**", "/", "/error")
                        .permitAll()
                        // Dev bean'i yalnız dev profilinde vardır; loopback kontrolü denetleyicidedir.
                        .requestMatchers(HttpMethod.POST, "/api/v1/dev/reset").permitAll()
                        .requestMatchers("/api/v1/**").authenticated()
                        // v1 dışındaki yollar eskisi gibi çalışır (statik dosya yoksa 404).
                        .anyRequest().permitAll())
                .oauth2ResourceServer(o -> o
                        .bearerTokenResolver(resolver)
                        .authenticationEntryPoint(errors)
                        .accessDeniedHandler(errors)
                        .jwt(j -> j.jwtAuthenticationConverter(converter)))
                .exceptionHandling(e -> e.authenticationEntryPoint(errors).accessDeniedHandler(errors));
        return http.build();
    }

    @Bean
    JwtDecoder jwtDecoder(JwtService jwtService) {
        return jwtService.decoder();
    }

    /** Herkese açık yollarda eski/bozuk bir Authorization başlığı isteği 401'e düşürmesin. */
    @Bean
    BearerTokenResolver bearerTokenResolver() {
        DefaultBearerTokenResolver delegate = new DefaultBearerTokenResolver();
        return (HttpServletRequest request) -> {
            String path = request.getRequestURI();
            boolean publicPath = !path.startsWith("/api/v1/")
                    || path.startsWith("/api/v1/auth/")
                    || path.startsWith("/api/v1/dev/")
                    || (HttpMethod.GET.matches(request.getMethod()) && path.matches("/api/v1/media/[^/]+/content"))
                    || (HttpMethod.GET.matches(request.getMethod())
                    && (path.startsWith("/api/v1/categories") || path.equals("/api/v1/districts")));
            return publicPath ? null : delegate.resolve(request);
        };
    }

    @Bean
    PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    CorsConfigurationSource corsConfigurationSource(
            @Value("${bitadilat.cors.allowed-origins:}") String allowedOrigins) {
        CorsConfiguration config = new CorsConfiguration();
        List<String> patterns = Arrays.stream(allowedOrigins.split(","))
                .map(String::trim).filter(s -> !s.isEmpty()).toList();
        config.setAllowedOriginPatterns(patterns);
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        config.setAllowedHeaders(List.of("Authorization", "Content-Type", "Accept", "Idempotency-Key"));
        config.setMaxAge(3600L);
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        if (!patterns.isEmpty()) {
            source.registerCorsConfiguration("/api/**", config);
        }
        // Banka dönüşü XHR değil, bankanın sayfasından üst düzey form POST'udur: tarayıcı
        // `Origin: https://<banka>` gönderir. CORS burada geçerli değildir; kural uygulanırsa
        // Spring isteği "Invalid CORS request" (403) ile keser ve ödeme INITIALIZED kalır.
        // Callback'in doğruluğu imza ve Craftgate sorgusuyla denetlenir.
        return request -> THREEDS_BROWSER_PATHS.contains(request.getRequestURI())
                ? null
                : source.getCorsConfiguration(request);
    }

    /** Bankanın tarayıcısının ulaştığı, CORS dışı bırakılan yollar. */
    static final java.util.Set<String> THREEDS_BROWSER_PATHS =
            java.util.Set.of("/api/payments/3ds/callback", "/api/payments/3ds/done");
}
