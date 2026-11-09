package com.bitadilat;

import com.bitadilat.auth.EmailSender;
import com.bitadilat.common.security.JwtService;
import com.bitadilat.payment.TestDatabaseConfig;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.atomic.AtomicLong;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Import;
import org.springframework.context.annotation.Primary;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

/** Kimlik ve hesap entegrasyon testlerinin ortak zemini: gerçek PostgreSQL, gerçek güvenlik zinciri, sahte e-posta. */
@SpringBootTest
@Import({TestDatabaseConfig.class, ApiTestBase.FakeEmail.class})
@AutoConfigureMockMvc
public abstract class ApiTestBase {

    /** LoggingEmailSender yerine kodu yakalayan sahte gönderici. */
    public static class CapturingEmailSender implements EmailSender {
        private final Map<String, String> lastCode = new ConcurrentHashMap<>();
        private final List<String> recipients = new CopyOnWriteArrayList<>();

        @Override
        public void sendPasswordResetCode(String toEmail, String code) {
            lastCode.put(toEmail.toLowerCase(), code);
            recipients.add(toEmail.toLowerCase());
        }

        public String codeFor(String email) {
            return lastCode.get(email.toLowerCase());
        }

        public long sentTo(String email) {
            return recipients.stream().filter(email.toLowerCase()::equals).count();
        }
    }

    @TestConfiguration(proxyBeanMethods = false)
    static class FakeEmail {
        @Bean
        @Primary
        CapturingEmailSender capturingEmailSender() {
            return new CapturingEmailSender();
        }
    }

    protected static final String PASSWORD = "Parola123";
    private static final AtomicLong SEQ = new AtomicLong(Math.abs(System.nanoTime()) % 8_000_000L);

    @Autowired
    protected MockMvc mvc;
    @Autowired
    protected ObjectMapper json;
    @Autowired
    protected JdbcTemplate jdbc;
    @Autowired
    protected JwtService jwt;
    @Autowired
    protected CapturingEmailSender emails;

    /** Kayıtlı kullanıcının test içi bilgileri. */
    protected record Account(String id, String email, String phone, String access, String refresh) {
    }

    protected static String uniqueEmail() {
        return "user" + SEQ.incrementAndGet() + "@example.test";
    }

    /** "0532 xxx xx xx" biçiminde benzersiz bir cep numarası. */
    protected static String uniquePhone() {
        String digits = String.format("%07d", SEQ.incrementAndGet() % 10_000_000L);
        return "0532 " + digits.substring(0, 3) + " " + digits.substring(3, 5) + " " + digits.substring(5);
    }

    protected Map<String, Object> registerBody(String email, String phone) {
        return Map.of("fullName", "Test Kullanıcı", "email", email, "phone", phone, "password", PASSWORD,
                "wantsPro", false, "kvkkAccepted", true, "termsAccepted", true);
    }

    protected Account register() throws Exception {
        String email = uniqueEmail();
        String phone = uniquePhone();
        JsonNode r = body(call(HttpMethod.POST, "/api/v1/auth/register", null, registerBody(email, phone))
                .andExpect(org.springframework.test.web.servlet.result.MockMvcResultMatchers.status().isCreated()));
        return new Account(r.get("user").get("id").asString(), email, phone,
                r.get("accessToken").asString(), r.get("refreshToken").asString());
    }

    protected ResultActions call(HttpMethod method, String url, String bearer, Object payload) throws Exception {
        MockHttpServletRequestBuilder b = MockMvcRequestBuilders.request(method, url);
        if (bearer != null) {
            b.header("Authorization", "Bearer " + bearer);
        }
        if (payload != null) {
            b.contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(payload));
        }
        return mvc.perform(b);
    }

    protected JsonNode body(ResultActions actions) throws Exception {
        String content = actions.andReturn().getResponse().getContentAsString();
        return json.readTree(content);
    }
}
