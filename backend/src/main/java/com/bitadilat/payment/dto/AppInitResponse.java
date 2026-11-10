package com.bitadilat.payment.dto;

/** Uygulama kanalı 3DS başlatma yanıtı: WebView'e verilecek banka sayfası ve sonucu sorgulamak için ref. */
public record AppInitResponse(String ref, String htmlContent) {
}
