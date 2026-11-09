package com.bitadilat.user;

import com.bitadilat.common.security.AuthPrincipal;
import com.bitadilat.user.dto.AddressPatch;
import com.bitadilat.user.dto.AddressRequest;
import com.bitadilat.user.dto.AddressView;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/me/addresses")
public class AddressController {

    private final AddressService addresses;

    public AddressController(AddressService addresses) {
        this.addresses = addresses;
    }

    @GetMapping
    public List<AddressView> list(@AuthenticationPrincipal AuthPrincipal principal) {
        return addresses.list(principal.userId());
    }

    @GetMapping("/{id}")
    public AddressView get(@AuthenticationPrincipal AuthPrincipal principal, @PathVariable UUID id) {
        return addresses.get(principal.userId(), id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public AddressView create(@AuthenticationPrincipal AuthPrincipal principal,
                              @Valid @RequestBody AddressRequest request) {
        return addresses.create(principal.userId(), request);
    }

    @PatchMapping("/{id}")
    public AddressView update(@AuthenticationPrincipal AuthPrincipal principal, @PathVariable UUID id,
                              @Valid @RequestBody AddressPatch patch) {
        return addresses.update(principal.userId(), id, patch);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@AuthenticationPrincipal AuthPrincipal principal, @PathVariable UUID id) {
        addresses.delete(principal.userId(), id);
    }
}
