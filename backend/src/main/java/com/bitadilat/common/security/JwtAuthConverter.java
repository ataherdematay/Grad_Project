package com.bitadilat.common.security;

import com.bitadilat.user.User;
import com.bitadilat.user.UserRepository;
import com.bitadilat.user.UserStatus;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import org.springframework.core.convert.converter.Converter;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.server.resource.InvalidBearerTokenException;
import org.springframework.security.authentication.AbstractAuthenticationToken;
import org.springframework.stereotype.Component;

/**
 * Doğrulanmış JWT'yi kullanıcıya bağlar. Hesabı silinmiş veya askıya alınmış kullanıcının henüz
 * süresi dolmamış token'ı da reddedilir (her istekte tek bir birincil anahtar sorgusu).
 */
@Component
public class JwtAuthConverter implements Converter<Jwt, AbstractAuthenticationToken> {

    private final UserRepository users;

    public JwtAuthConverter(UserRepository users) {
        this.users = users;
    }

    @Override
    public AbstractAuthenticationToken convert(Jwt jwt) {
        UUID id;
        try {
            id = UUID.fromString(jwt.getSubject());
        } catch (RuntimeException e) {
            throw new InvalidBearerTokenException("Token konusu geçersiz.");
        }
        User user = users.findById(id).orElseThrow(() -> new InvalidBearerTokenException("Kullanıcı bulunamadı."));
        if (user.getStatus() == UserStatus.DELETED) {
            throw new InvalidBearerTokenException("Hesap silinmiş.");
        }
        if (user.getStatus() == UserStatus.SUSPENDED) {
            throw new AccountSuspendedException();
        }
        List<GrantedAuthority> authorities = new ArrayList<>();
        authorities.add(new SimpleGrantedAuthority("ROLE_USER"));
        if (user.isAdmin()) {
            authorities.add(new SimpleGrantedAuthority("ROLE_ADMIN"));
        }
        return new UsernamePasswordAuthenticationToken(new AuthPrincipal(user.getId(), user.isAdmin()), jwt, authorities);
    }
}
