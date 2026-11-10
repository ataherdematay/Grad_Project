package com.bitadilat.pro;

import com.bitadilat.common.security.AuthPrincipal;
import com.bitadilat.offer.OfferService;
import com.bitadilat.offer.dto.CreateOfferBody;
import com.bitadilat.offer.dto.OfferDetail;
import com.bitadilat.offer.dto.ProOfferList;
import com.bitadilat.pro.dto.ApplicationBody;
import com.bitadilat.pro.dto.ApplicationView;
import com.bitadilat.pro.dto.AvailabilityBody;
import com.bitadilat.pro.dto.FeedList;
import com.bitadilat.pro.dto.ProRequestDetail;
import com.bitadilat.pro.dto.ProfileBody;
import com.bitadilat.pro.dto.ProfileView;
import jakarta.validation.Valid;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/** /pro/*: başvuru uç noktaları hariç hepsi APPROVED usta ister (403 PRO_NOT_APPROVED). */
@RestController
@RequestMapping("/api/v1/pro")
public class ProController {

    private final ProService pro;
    private final ProFeedService feed;
    private final OfferService offers;
    private final EarningsService earnings;

    public ProController(ProService pro, ProFeedService feed, OfferService offers, EarningsService earnings) {
        this.pro = pro;
        this.feed = feed;
        this.offers = offers;
        this.earnings = earnings;
    }

    @PostMapping("/application")
    @ResponseStatus(HttpStatus.CREATED)
    public ApplicationView apply(@AuthenticationPrincipal AuthPrincipal p, @Valid @RequestBody ApplicationBody body) {
        return pro.submit(p.userId(), body);
    }

    @GetMapping("/application")
    public ApplicationView application(@AuthenticationPrincipal AuthPrincipal p) {
        return pro.application(p.userId());
    }

    @GetMapping("/profile")
    public ProfileView profile(@AuthenticationPrincipal AuthPrincipal p) {
        return pro.profile(p.userId());
    }

    @PutMapping("/profile")
    public ProfileView updateProfile(@AuthenticationPrincipal AuthPrincipal p, @Valid @RequestBody ProfileBody body) {
        return pro.updateProfile(p.userId(), body);
    }

    @PutMapping("/availability")
    public ProfileView availability(@AuthenticationPrincipal AuthPrincipal p,
                                    @Valid @RequestBody AvailabilityBody body) {
        return pro.setAvailability(p.userId(), body.availability());
    }

    @GetMapping("/feed")
    public FeedList feed(@AuthenticationPrincipal AuthPrincipal p,
                         @RequestParam(value = "urgency", required = false) String urgency,
                         @RequestParam(value = "cursor", required = false) String cursor,
                         @RequestParam(value = "limit", required = false) Integer limit) {
        return feed.feed(p.userId(), urgency, cursor, limit);
    }

    @GetMapping("/requests/{id}")
    public ProRequestDetail request(@AuthenticationPrincipal AuthPrincipal p, @PathVariable UUID id) {
        return feed.detail(p.userId(), id);
    }

    @PostMapping("/requests/{id}/offers")
    @ResponseStatus(HttpStatus.CREATED)
    public OfferDetail offer(@AuthenticationPrincipal AuthPrincipal p, @PathVariable UUID id,
                             @RequestHeader(value = "Idempotency-Key", required = false) String key,
                             @Valid @RequestBody CreateOfferBody body) {
        return offers.create(p.userId(), id, body, key);
    }

    @GetMapping("/offers")
    public ProOfferList myOffers(@AuthenticationPrincipal AuthPrincipal p,
                                 @RequestParam(value = "status", required = false) String status,
                                 @RequestParam(value = "cursor", required = false) String cursor,
                                 @RequestParam(value = "limit", required = false) Integer limit) {
        return offers.listForPro(p.userId(), status, cursor, limit);
    }

    @GetMapping("/earnings")
    public com.bitadilat.pro.dto.EarningsView earnings(@AuthenticationPrincipal AuthPrincipal p) {
        return earnings.earnings(p.userId());
    }

    @PostMapping("/offers/{id}/withdraw")
    public OfferDetail withdraw(@AuthenticationPrincipal AuthPrincipal p, @PathVariable UUID id) {
        return offers.withdraw(p.userId(), id);
    }
}
