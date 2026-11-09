-- Bir medya en fazla bir kayda iliştirilir. Uygulama bunu önceden kontrol eder; bu indeksler eşzamanlı iki isteğin
-- aynı dosyayı iki talebe (veya iki belge satırına) bağlamasını veritabanında engeller.
CREATE UNIQUE INDEX ux_request_photos_media ON request_photos (media_id);
CREATE UNIQUE INDEX ux_pro_documents_media ON pro_documents (media_id);
