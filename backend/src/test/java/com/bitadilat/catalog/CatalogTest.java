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
    void questionsAreEmptyForKnownCategoryAndNotFoundOtherwise() throws Exception {
        call(HttpMethod.GET, "/api/v1/categories/plumbing/questions", null, null)
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(0));
        call(HttpMethod.GET, "/api/v1/categories/yok/questions", null, null)
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.code").value("NOT_FOUND"));
    }
}
