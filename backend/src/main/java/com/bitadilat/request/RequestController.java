package com.bitadilat.request;

import com.bitadilat.common.security.AuthPrincipal;
import com.bitadilat.request.dto.CancelRequestBody;
import com.bitadilat.request.dto.CreateRequestBody;
import com.bitadilat.request.dto.RequestDetail;
import com.bitadilat.request.dto.RequestList;
import com.bitadilat.request.dto.UpdateRequestBody;
import jakarta.validation.Valid;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/requests")
public class RequestController {

    private final RequestService requests;

    public RequestController(RequestService requests) {
        this.requests = requests;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public RequestDetail create(@AuthenticationPrincipal AuthPrincipal p, @Valid @RequestBody CreateRequestBody body) {
        return requests.create(p.userId(), body);
    }

    @GetMapping
    public RequestList list(@AuthenticationPrincipal AuthPrincipal p,
                            @RequestParam(value = "scope", defaultValue = "active") String scope,
                            @RequestParam(value = "cursor", required = false) String cursor,
                            @RequestParam(value = "limit", required = false) Integer limit) {
        return requests.list(p.userId(), scope, cursor, limit);
    }

    @GetMapping("/{id}")
    public RequestDetail get(@AuthenticationPrincipal AuthPrincipal p, @PathVariable UUID id) {
        return requests.get(p.userId(), id);
    }

    @PatchMapping("/{id}")
    public RequestDetail update(@AuthenticationPrincipal AuthPrincipal p, @PathVariable UUID id,
                                @Valid @RequestBody UpdateRequestBody body) {
        return requests.update(p.userId(), id, body);
    }

    @PostMapping("/{id}/cancel")
    public RequestDetail cancel(@AuthenticationPrincipal AuthPrincipal p, @PathVariable UUID id,
                                @Valid @RequestBody CancelRequestBody body) {
        return requests.cancel(p.userId(), id, body);
    }
}
