package com.bitadilat.offer;

import com.bitadilat.common.security.AuthPrincipal;
import com.bitadilat.offer.dto.DeclineBody;
import com.bitadilat.offer.dto.OfferDetail;
import com.bitadilat.offer.dto.OfferList;
import jakarta.validation.Valid;
import java.math.BigDecimal;
import java.util.UUID;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
public class OfferController {

    private final OfferService offers;

    public OfferController(OfferService offers) {
        this.offers = offers;
    }

    @GetMapping("/requests/{id}/offers")
    public OfferList forRequest(@AuthenticationPrincipal AuthPrincipal p, @PathVariable UUID id,
                                @RequestParam(value = "sort", required = false) String sort,
                                @RequestParam(value = "maxPrice", required = false) BigDecimal maxPrice,
                                @RequestParam(value = "minRating", required = false) BigDecimal minRating,
                                @RequestParam(value = "cursor", required = false) String cursor,
                                @RequestParam(value = "limit", required = false) Integer limit) {
        return offers.listForRequest(p.userId(), id, sort, maxPrice, minRating, cursor, limit);
    }

    @GetMapping("/offers/{id}")
    public OfferDetail get(@AuthenticationPrincipal AuthPrincipal p, @PathVariable UUID id) {
        return offers.get(p.userId(), id);
    }

    @PostMapping("/offers/{id}/decline")
    public OfferDetail decline(@AuthenticationPrincipal AuthPrincipal p, @PathVariable UUID id,
                               @Valid @RequestBody DeclineBody body) {
        return offers.decline(p.userId(), id, body);
    }
}
