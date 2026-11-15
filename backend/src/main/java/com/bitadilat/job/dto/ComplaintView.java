package com.bitadilat.job.dto;

import com.bitadilat.job.ComplaintReason;
import com.bitadilat.media.dto.MediaRef;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

/** Şikayet. {@code decision} (FULL_REFUND, SPLIT_50_50, RELEASE_TO_PRO) admin kararına kadar null. {@code refundAmount}/{@code proAmount}
 * (müşteriye iade edilen, ustaya aktarılan net tutar) emanet kaydından okunur ve karardan önce null'dır. */
public record ComplaintView(UUID id, String publicCode, UUID jobId, ComplaintReason reason, String description,
                            List<MediaRef> evidence, String status, String decision, String decisionNote,
                            Instant createdAt, Instant decidedAt,
                            java.math.BigDecimal refundAmount, java.math.BigDecimal proAmount) {
}
