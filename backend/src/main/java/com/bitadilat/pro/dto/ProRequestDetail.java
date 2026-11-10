package com.bitadilat.pro.dto;

import com.bitadilat.media.dto.MediaRef;
import com.bitadilat.offer.dto.OfferDetail;
import com.bitadilat.request.Urgency;
import com.bitadilat.request.dto.AnswerDto;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

/** FeedItem alanları + ayrıntı. Adres yalnızca ilçe ve mahalle (FeedItem içinde); tam adres hiç yok. */
public record ProRequestDetail(UUID id, String publicCode, String title, String categoryId, Urgency urgency,
                               String districtName, String neighborhood, Instant createdAt, Instant preferredFrom,
                               Instant preferredTo, int photoCount, int offerCount, UUID myOfferId,
                               String description, List<MediaRef> photos, List<AnswerDto> answers,
                               OfferDetail myOffer, com.bitadilat.request.RequestStatus status) {
}
