package com.bitadilat.media;

import com.bitadilat.common.security.AuthPrincipal;
import com.bitadilat.media.dto.MediaUploaded;
import java.util.UUID;
import org.springframework.http.CacheControl;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/v1/media")
public class MediaController {

    private final MediaService media;

    public MediaController(MediaService media) {
        this.media = media;
    }

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @ResponseStatus(HttpStatus.CREATED)
    public MediaUploaded upload(@AuthenticationPrincipal AuthPrincipal principal,
                                @RequestParam(value = "file", required = false) MultipartFile file,
                                @RequestParam(value = "purpose", required = false) String purpose) {
        return media.upload(principal.userId(), file, purpose);
    }

    /** Herkese açık: erişimi imza belirler (SecurityConfig'te kimliksiz bırakılmıştır). */
    @GetMapping("/{id}/content")
    public ResponseEntity<byte[]> content(@PathVariable UUID id,
                                          @RequestParam(value = "exp", required = false) String exp,
                                          @RequestParam(value = "sig", required = false) String sig) {
        Long expSeconds = null;
        try {
            expSeconds = exp == null ? null : Long.valueOf(exp.trim());
        } catch (NumberFormatException e) {
            // bozuk exp imzasız sayılır: 403
        }
        MediaService.Content c = media.content(id, expSeconds, sig);
        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(c.contentType()))
                .cacheControl(CacheControl.noStore())
                .header("X-Content-Type-Options", "nosniff")
                .body(c.bytes());
    }
}
