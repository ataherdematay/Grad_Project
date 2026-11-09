package com.bitadilat.user;

import com.bitadilat.common.security.AuthPrincipal;
import com.bitadilat.user.dto.ChangePasswordRequest;
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

    public MeController(AccountService accounts) {
        this.accounts = accounts;
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

    @DeleteMapping
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@AuthenticationPrincipal AuthPrincipal principal) {
        accounts.delete(principal.userId());
    }
}
