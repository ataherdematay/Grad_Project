package com.bitadilat.user;

import com.bitadilat.auth.PasswordResetCodeRepository;
import com.bitadilat.auth.RefreshTokenRepository;
import com.bitadilat.common.ApiException;
import com.bitadilat.pro.ProProfile;
import com.bitadilat.pro.ProProfileRepository;
import com.bitadilat.user.dto.ChangePasswordRequest;
import com.bitadilat.user.dto.Me;
import com.bitadilat.user.dto.UpdateMeRequest;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AccountService {

    private final UserRepository users;
    private final ProProfileRepository proProfiles;
    private final AddressRepository addresses;
    private final RefreshTokenRepository refreshTokens;
    private final PasswordResetCodeRepository resetCodes;
    private final PasswordEncoder encoder;
    private final List<AccountDeletionGuard> deletionGuards;

    public AccountService(UserRepository users, ProProfileRepository proProfiles, AddressRepository addresses,
                          RefreshTokenRepository refreshTokens, PasswordResetCodeRepository resetCodes,
                          PasswordEncoder encoder, List<AccountDeletionGuard> deletionGuards) {
        this.users = users;
        this.proProfiles = proProfiles;
        this.addresses = addresses;
        this.refreshTokens = refreshTokens;
        this.resetCodes = resetCodes;
        this.encoder = encoder;
        this.deletionGuards = deletionGuards;
    }

    @Transactional(readOnly = true)
    public Me toMe(User user) {
        Me.ProSummary pro = proProfiles.findById(user.getId())
                .map(AccountService::summary).orElse(null);
        return new Me(user.getId(), user.getFullName(), user.getEmail(), user.getPhone(), user.getLocale(),
                user.getLastMode(), user.isAdmin(), user.getStatus(), pro);
    }

    private static Me.ProSummary summary(ProProfile p) {
        return new Me.ProSummary(p.getReviewStatus(), p.getAvailability(), p.getBusinessName());
    }

    @Transactional(readOnly = true)
    public Me get(UUID userId) {
        return toMe(load(userId));
    }

    @Transactional
    public Me update(UUID userId, UpdateMeRequest request) {
        User user = load(userId);
        if (request.fullName() != null) {
            user.setFullName(request.fullName().trim());
        }
        if (request.locale() != null) {
            user.setLocale(request.locale());
        }
        if (request.lastMode() != null) {
            UserMode mode = UserMode.valueOf(request.lastMode());
            if (mode == UserMode.PRO && !proProfiles.existsById(userId)) {
                throw ApiException.illegalState("Usta profili olmadan PRO moduna geçilemez.");
            }
            user.setLastMode(mode);
        }
        return toMe(users.save(user));
    }

    @Transactional
    public void changePassword(UUID userId, ChangePasswordRequest request) {
        User user = load(userId);
        if (!encoder.matches(request.currentPassword(), user.getPasswordHash())) {
            throw ApiException.validation("currentPassword", "Mevcut şifre yanlış.");
        }
        user.setPasswordHash(encoder.encode(request.newPassword()));
        users.save(user);
    }

    /** Kişisel alanları anonimleştirir, durumu DELETED yapar, tüm oturumları kapatır. */
    @Transactional
    public void delete(UUID userId) {
        User user = load(userId);
        deletionGuards.forEach(g -> g.assertCanDelete(userId));
        Instant now = Instant.now();
        user.setFullName("Silinmiş kullanıcı");
        user.setEmail("deleted-" + userId + "@deleted.invalid");
        user.setPhone(null);
        user.setPasswordHash("!");
        user.setStatus(UserStatus.DELETED);
        user.setLastMode(UserMode.CUSTOMER);
        user.setDeletedAt(now);
        users.save(user);
        addresses.deleteByUserId(userId);
        resetCodes.invalidateAll(userId, now);
        refreshTokens.revokeAllForUser(userId, now);
    }

    private User load(UUID userId) {
        return users.findById(userId).orElseThrow(() -> ApiException.unauthenticated("Kullanıcı bulunamadı."));
    }
}
