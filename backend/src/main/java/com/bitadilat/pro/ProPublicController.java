package com.bitadilat.pro;

import com.bitadilat.pro.dto.PublicPro;
import com.bitadilat.pro.dto.ReviewList;
import java.util.UUID;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/pros")
public class ProPublicController {

    private final ProPublicService pros;

    public ProPublicController(ProPublicService pros) {
        this.pros = pros;
    }

    @GetMapping("/{id}")
    public PublicPro get(@PathVariable UUID id) {
        return pros.get(id);
    }

    @GetMapping("/{id}/reviews")
    public ReviewList reviews(@PathVariable UUID id,
                              @RequestParam(value = "cursor", required = false) String cursor,
                              @RequestParam(value = "limit", required = false) Integer limit) {
        return pros.reviews(id, cursor, limit);
    }
}
