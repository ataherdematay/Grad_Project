package com.bitadilat.catalog;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.bitadilat.ApiTestBase;
import java.util.ArrayList;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpMethod;
import tools.jackson.databind.JsonNode;

class CatalogTest extends ApiTestBase {

    @Test
    void eightCategoriesWithoutAuthentication() throws Exception {
        JsonNode list = body(call(HttpMethod.GET, "/api/v1/categories", null, null)
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(8)));

        List<String> ids = new ArrayList<>();
        list.forEach(c -> ids.add(c.get("id").asString()));
        assertThat(ids).containsExactly("plumbing", "electrical", "painting", "hvac", "bathroom", "kitchen",
                "carpentry", "other");
        JsonNode plumbing = list.get(0);
        assertThat(plumbing.propertyNames()).containsExactlyInAnyOrder(
                "id", "nameTr", "nameEn", "icon", "colorHex", "sortOrder");
        assertThat(plumbing.get("nameTr").asString()).isEqualTo("Tesisat");
        assertThat(plumbing.get("nameEn").asString()).isEqualTo("Plumbing");
        assertThat(list.get(2).get("nameTr").asString()).isEqualTo("Boya & Badana");
        assertThat(list.get(3).get("nameEn").asString()).isEqualTo("Air conditioning");
    }

    @Test
    void thirtyNineDistrictsWithSides() throws Exception {
        JsonNode list = body(call(HttpMethod.GET, "/api/v1/districts", null, null)
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(39)));

        long anadolu = 0;
        boolean kadikoy = false;
        for (JsonNode d : list) {
            assertThat(d.propertyNames()).containsExactlyInAnyOrder("id", "name", "side");
            if ("ANADOLU".equals(d.get("side").asString())) {
                anadolu++;
            }
            if ("Kadıköy".equals(d.get("name").asString())) {
                kadikoy = "ANADOLU".equals(d.get("side").asString());
            }
        }
        assertThat(anadolu).isEqualTo(14);
        assertThat(kadikoy).isTrue();
    }

    @Test
    void districtsAreCompleteCorrectlySpelledAndInTurkishAlphabeticalOrder() throws Exception {
        List<String> anadolu = List.of("Adalar", "Ataşehir", "Beykoz", "Çekmeköy", "Kadıköy", "Kartal", "Maltepe",
                "Pendik", "Sancaktepe", "Sultanbeyli", "Şile", "Tuzla", "Ümraniye", "Üsküdar");
        // Türk alfabesi sırası (ç c'den, ş s'den, ü u'dan sonra), veritabanı harmanlamasından bağımsız.
        List<String> expected = List.of("Adalar", "Arnavutköy", "Ataşehir", "Avcılar", "Bağcılar", "Bahçelievler",
                "Bakırköy", "Başakşehir", "Bayrampaşa", "Beşiktaş", "Beykoz", "Beylikdüzü", "Beyoğlu", "Büyükçekmece",
                "Çatalca", "Çekmeköy", "Esenler", "Esenyurt", "Eyüpsultan", "Fatih", "Gaziosmanpaşa", "Güngören",
                "Kadıköy", "Kağıthane", "Kartal", "Küçükçekmece", "Maltepe", "Pendik", "Sancaktepe", "Sarıyer",
                "Silivri", "Sultanbeyli", "Sultangazi", "Şile", "Şişli", "Tuzla", "Ümraniye", "Üsküdar",
                "Zeytinburnu");
        JsonNode list = body(call(HttpMethod.GET, "/api/v1/districts", null, null).andExpect(status().isOk()));
        List<String> names = new ArrayList<>();
        for (JsonNode d : list) {
            names.add(d.get("name").asString());
            assertThat(d.get("side").asString()).as(d.get("name").asString())
                    .isEqualTo(anadolu.contains(d.get("name").asString()) ? "ANADOLU" : "AVRUPA");
        }
        assertThat(names).containsExactlyElementsOf(expected);
    }

    @Test
    void questionsFollowContractAndNotFoundOtherwise() throws Exception {
        call(HttpMethod.GET, "/api/v1/categories/plumbing/questions", null, null)
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(3))
                .andExpect(jsonPath("$[0].key").value("since"))
                .andExpect(jsonPath("$[0].options.length()").value(3))
                .andExpect(jsonPath("$[0].options[0].labelTr").value("Bugün"))
                .andExpect(jsonPath("$[1].key").value("water_cut"))
                .andExpect(jsonPath("$[2].key").value("other_rooms"));
        call(HttpMethod.GET, "/api/v1/categories/painting/questions", null, null)
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].key").value("since"));
        call(HttpMethod.GET, "/api/v1/categories/yok/questions", null, null)
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.code").value("NOT_FOUND"));
    }
}
