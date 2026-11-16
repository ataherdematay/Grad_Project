package com.bitadilat.user;

import com.bitadilat.common.security.AuthPrincipal;
import com.bitadilat.user.dto.ChangePasswordRequest;
import com.bitadilat.user.dto.DeleteAccountRequest;
import com.bitadilat.user.dto.EmailChangeRequest;
import com.bitadilat.user.dto.EmailConfirmRequest;
import com.bitadilat.user.dto.Me;
import com.bitadilat.user.dto.UpdateMeRequest;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/me")
public class MeController {

    private final AccountService accounts;
    private final EmailChangeService emailChange;

    public MeController(AccountService accounts, EmailChangeService emailChange) {
        this.accounts = accounts;
        this.emailChange = emailChange;
    }

    @GetMapping
    public Me me(@AuthenticationPrincipal AuthPrincipal principal) {
        return accounts.get(principal.userId());
    }

    @PatchMapping
    public Me update(@AuthenticationPrincipal AuthPrincipal principal, @Valid @RequestBody UpdateMeRequest request) {
        return accounts.update(principal.userId(), request);
    }

    @PostMapping("/password")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void changePassword(@AuthenticationPrincipal AuthPrincipal principal,
                               @Valid @RequestBody ChangePasswordRequest request) {
        accounts.changePassword(principal.userId(), principal.familyId(), request);
    }

    /** Gövde isteğe bağlıdır: {@code {reason}} yalnızca analiz için, kullanıcıya bağlanmadan saklanır. */
    @DeleteMapping
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@AuthenticationPrincipal AuthPrincipal principal,
                       @RequestBody(required = false) DeleteAccountRequest request) {
        accounts.delete(principal.userId(), request == null ? null : request.reason());
    }

    /** Yeni adrese doğrulama kodu gönderir; e-posta kod doğrulanana kadar değişmez. */
    @PostMapping("/email")
    @ResponseStatus(HttpStatus.ACCEPTED)
    public void requestEmailChange(@AuthenticationPrincipal AuthPrincipal principal,
                                   @Valid @RequestBody EmailChangeRequest request) {
        emailChange.request(principal.userId(), request.newEmail(), request.password());
    }

    @PostMapping("/email/confirm")
    public Me confirmEmailChange(@AuthenticationPrincipal AuthPrincipal principal,
                                 @Valid @RequestBody EmailConfirmRequest request) {
        return emailChange.confirm(principal.userId(), request.code());
    }
}
