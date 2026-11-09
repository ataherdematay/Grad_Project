package com.bitadilat.auth.dto;

import com.bitadilat.user.dto.Me;

/** accessExpiresIn saniye cinsindendir. */
public record AuthResponse(String accessToken, String refreshToken, int accessExpiresIn, Me user) {
}
